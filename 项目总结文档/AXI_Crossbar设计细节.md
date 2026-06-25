# AXI Crossbar 设计架构详解

## 1. 顶层架构概览

### 1.1 系统规格

```
  ┌─ Master0 ──┐      ┌──────────────────────────────┐      ┌─ Slave0 ──┐
  │             │      │                              │      │            │
  ├─ Master1 ──┤◄────►│      AXI Interconnect         │◄────►├─ Slave1 ──┤
  │             │      │      (3 Master × 3 Slave)    │      │            │
  ├─ Master2 ──┤      │                              │      ├─ Slave2 ──┤
  │             │      │   + Default Slave + APB CFG  │      │            │
  └─────────────┘      └──────────────────────────────┘      └────────────┘
```

- **Master数量**: 3个 (MID = 01, 10, 11)
- **Slave数量**: 3个 (S0地址空间0010xxx, S1地址空间0020xxx, S2地址空间0030xxx) + 1个Default Slave
- **数据宽度**: 32位
- **地址宽度**: 32位
- **ID宽度**: 4位 (W_ID) + 4位通道ID (W_CID) = 8位SID
- **Burst长度**: 最大256拍 (8位AWLEN/ARLEN)
- **仲裁策略**: 支持Round-Robin和Fixed Priority两种，通过APB配置切换

### 1.2 整体数据流

AXI有5个独立通道，数据流向如下：

```
  Master侧                    Crossbar核心                    Slave侧
  ═══════                    ═══════════                    ═══════
  
  [M→] AW通道: M_AW* ──► [cross_4k_if] ──► [FIFO] ──► [m2s解码+仲裁] ──► [FIFO] ──► S_AW*
  [M→]  W通道: M_W*  ──────────────────────────────────► [m2s路由选择] ──► [FIFO] ──► S_W*
  [←M]  B通道: M_B*  ◄── [FIFO] ◄── [s2m路由+仲裁] ◄── [FIFO] ◄── S_B*
  [M→] AR通道: M_AR* ──► [cross_4k_if] ──► [FIFO] ──► [m2s解码+仲裁] ──► [FIFO] ──► S_AR*
  [←M]  R通道: M_R*  ◄── [FIFO] ◄── [s2m路由+仲裁] ◄── [FIFO] ◄── S_R*
                     │                                  │
                     ├── [sid_buffer + reorder] ────────┤  (读写事务排序)
                     └── [apb_regs_cfg]  ◄──  APB接口    (配置/状态监控)
```

### 1.3 子模块清单与调用关系

| 模块名 | 例化数量 | 功能说明 |
|--------|----------|----------|
| `cross_4k_if` | 3个 | 跨4KB边界事务自动拆分 |
| `axi_fifo_sync` | 30个 (每通道×每Master/Slave) | 流水线同步FIFO缓冲 |
| `axi_crossbar` | 1个 | 核心交叉开关顶层 |
| `axi_m2s_m3` | 4个 (3 Slave + 1 Default) | Master→Slave地址译码与仲裁 |
| `axi_s2m_s3` | 3个 (3 Master) | Slave→Master响应路由 |
| `axi_arbiter_m2s_m3` | 4个 (内嵌在m2s中) | M2S方向仲裁 |
| `axi_arbiter_s2m_s3` | 3个 (内嵌在s2m中) | S2M方向仲裁 |
| `rr_fixed_arbiter` | 多个 (内嵌在arbiter中) | Round-Robin/Fixed Priority仲裁核心 |
| `sid_buffer` | 2个 (读事务+写事务) | 事务ID排序缓冲 |
| `reorder` | 2个 (读+写) | 响应顺序匹配 |
| `axi_default_slave` | 1个 | 未命中地址的默认响应 |
| `apb_regs_cfg` | 1个 (条件编译) | APB配置与状态寄存器 |

---

## 2. 各子模块详细设计

### 2.1 cross_4k_if — 跨4K边界事务拆分

**功能**：检测Master发出的Burst事务是否跨越4KB地址边界，若跨越则自动拆分为2个子事务。

**设计原理**：
- AXI协议规定，任何burst不得跨越4KB边界。该模块在Master侧检测并处理此约束。
- 计算`end_addr = start_addr + (arlen << 2)`
- 若`start_addr[12] ≠ end_addr[12]`，则判定为跨4K边界，需拆分。

**控制流 (状态机)**：
```
  IDLE ──(cross4k_flag)──► TRANS1 ──(s_axi_arready)──► TRANS2 ──(s_axi_arready)──► IDLE
```

- **TRANS1**: 发送第1段事务，地址为原始地址，长度为 `(0x1000 - addr[11:0]) >> 2`
- **TRANS2**: 发送第2段事务，地址为下个4K对齐边界地址，长度为 `(end_addr - 0x...000) >> 2`
- 不跨边界时 (IDLE)：直通传输，ready信号直接连通下游。

**数据流特点**：
- AR通道和AW通道独立处理，各有自己的状态机。
- 在TRANS2阶段，AW通道的ID会+1 (cid递增)，以区分同一次传输的两个子事务，保证后续写数据交错时的正确路由。

---

### 2.2 axi_fifo_sync — 同步FIFO缓冲 (重点分析)

**功能**：提供First-Word Fall-Through (FWFT) 同步FIFO，用于流水线解耦和反压缓冲。

#### 2.2.1 内部设计详解

该FIFO的设计与普通同步FIFO有显著区别，体现在以下几个关键设计决策上：

**1) 双指针 + 预计算next指针的架构**

```
fifo_tail ──→ 指向下一个要写入的位置
next_tail ──→ = fifo_tail + 1 (组合逻辑预计算)
fifo_head ──→ 指向下一个要读取的位置 (也是rd_dout的数据来源)
next_head ──→ = fifo_head + 1 (组合逻辑预计算)
```

**普通同步FIFO**：通常在时钟沿当场计算 `tail + 1` 或 `head + 1`，这意味着加法器在关键路径上。

**本设计**：`next_tail` 和 `next_head` 是**预寄存器化的下一位置**。写入时直接将 `next_tail` 赋给 `fifo_tail`，避免了在更新时再做加法。这减少了关键路径上的组合逻辑延迟，是一种**流水线化指针管理**技术。

```
// push 操作：用预计算好的 next_tail 直接赋值
if (!full && wr_vld) begin
    fifo_tail <= next_tail;       // 直接赋值，无需再计算 tail+1
    next_tail <= next_tail + 1;   // 同时更新下一拍的预计算值
end
```

**2) item_cnt 精确控制满/空判断**

本设计使用 `item_cnt` 寄存器直接追踪FIFO中有效数据条目数，而非仅依赖指针比较：

```
full  = (item_cnt >= FDT)    // 条目数达到深度 → 满
empty = (fifo_head == fifo_tail)  // 头尾指针重合 → 空
```

| 判断方式 | 普通FIFO | 本设计 |
|----------|----------|--------|
| full判断 | (write_ptr+1 == read_ptr) 或额外flag | item_cnt >= FDT |
| empty判断 | write_ptr == read_ptr | fifo_head == fifo_tail |
| 优缺点 | 节省寄存器，但需处理指针回绕和满空歧义 | 多5位计数器，但满判断直接、无歧义 |

item_cnt 的更新逻辑也极其严谨，区分了四种场景：

```verilog
if (wr_vld && !full && (!rd_rdy || (rd_rdy && empty)))
    item_cnt <= item_cnt + 1;   // 纯写入 (读未发生 或 读发生但FIFO原本为空)
else if (rd_rdy && !empty && (!wr_vld || (wr_vld && full)))
    item_cnt <= item_cnt - 1;   // 纯读出 (写未发生 或 写发生但FIFO原本已满)
```

关键：当读写**同时发生**时：
- 若FIFO原本为空：`rd_rdy && empty` 为真，但 `(!empty)` 条件阻断减操作，item_cnt 只+1（数据流过FIFO但净增1）→ 实际上这保证了FWFT行为：空FIFO写入后立即出现在输出，读端此时未取走，item_cnt变为1是合理的
- 若FIFO原本已满：`wr_vld && full` 为真，但 `(!full)` 条件阻断加操作，item_cnt 只-1（流出1个但新进入1个→净不变，但此时代码的 `(!full)` 阻止了加操作，实际上同时读写时满了就不会有新写入接受）

实际同时读写且不满不空时：item_cnt同时加减，净不变。但由于条件互斥（`(!rd_rdy || (rd_rdy && empty))`与 `(!empty)`互为补集），item_cnt不会同时加减，保证计数正确。

**3) FWFT (First-Word Fall-Through) 实现**

```
assign rd_vld = ~empty;               // FIFO非空即数据有效
assign rd_dout = Mem[fifo_head[FAW-1:0]]; // 直接从head位置读出
```

普通FIFO通常需要先拉高rd_en、下一拍数据才出现在输出端。而FWFT模式下，只要FIFO非空，当前head指向的数据**组合逻辑直达输出端口**，无需额外等待周期。这在AXI流水线中极大降低了延迟——数据穿通FIFO只需经过一个MUX (Mem读取) 的延迟。

**4) 寄存器阵列存储 (非SRAM)**

```
reg [FDW-1:0] Mem [0:FDT-1];
```

使用触发器阵列而非SRAM实现存储。深度仅4时，触发器面积开销可接受，且避免了SRAM的读写时序约束，更适合高速流水线场景。

#### 2.2.2 与普通同步FIFO的核心区别总结

| 特性 | 普通同步FIFO | axi_fifo_sync |
|------|-------------|---------------|
| 指针管理 | 当场计算+1，单寄存器 | pre-next寄存器化，双寄存器 |
| 满判断 | 指针比较+额外flag | item_cnt >= FDT，直接阈值比较 |
| 读延迟 | 1拍 (先rd_en，下拍出数据) | 0拍 (FWFT，组合逻辑直达) |
| 满空歧义 | 需要额外处理 | 无歧义（两种不同判断机制） |
| 存储 | SRAM或寄存器 | 纯寄存器阵列 |
| 适用场景 | 通用缓冲 | 高速AXI流水线 |

#### 2.2.3 在Crossbar架构中的位置与作用

FIFO在Crossbar中的例化分为**四组**，分布在数据路径的关键节点：

```
                    ┌─── fifo_ar_mx (AW=4, DW=49bit)  ──┐
M_AW* ──► c4k ──►  ├─── fifo_aw_mx (AW=4, DW=49bit)  ──┤──► axi_crossbar (m2s解码+仲裁)
M_AR* ──► c4k ──►  ├─── fifo_ar_mx (AW=4, DW=49bit)  ──┤
M_W*  ──────────── ├─── fifo_w_mx  (AW=4, DW=41bit)  ──┤
                   └────────────────────────────────────┘
                   
                   ┌─── fifo_aw_sx (AW=4, DW=57bit)  ──┐
 axi_crossbar ──►  ├─── fifo_w_sx  (AW=4, DW=49bit)  ──┤──► S_*
                   ├─── fifo_ar_sx (AW=4, DW=57bit)  ──┤
                   └────────────────────────────────────┘

 S_R* ──────────── ├─── fifo_r_sx  (AW=4, DW=43bit)  ──┤──► axi_crossbar (s2m路由)
 S_B* ──────────── ├─── fifo_b_sx  (AW=4, DW=10bit)  ──┤
                   └────────────────────────────────────┘

                   ┌─── fifo_r_mx  (AW=4, DW=39bit)  ──┐
 axi_crossbar ──►  ├─── fifo_b_mx  (AW=4, DW= 6bit)  ──┤──► M_*
                   └────────────────────────────────────┘
```

**数据宽度说明**（注意Master侧和Slave侧FIFO宽度不同）：
- Master侧入口AW通道: 49bit = `{cid(4), awid(4), awaddr(32), awlen(8), awsize(3), awburst(2)}` → **未包含slv_addr字段**
- Slave侧出口AW通道: 57bit = `{sid(8), awaddr(32), awlen(8), awsize(3), awburst(2)}` → **SID已重组**，含slv_addr
- 这两组FIFO宽度差异反映了SID编组发生在crossbar核心内部 (m2s模块中)，FIFO两侧的数据格式不同。

**FIFO的关键控制信号**：

部分FIFO的写使能并非简单直连，而是受排序逻辑控制：

```
// AR通道Slave侧出口FIFO：写使能受sid_buffer反压
fifo_ar_sx_vld[i] = S_ARVALID[i] & s_push_srid_rdy[i]
                    ↑                           ↑
               crossbar输出有效          sid_buffer允许该事务入队
```

```
// R通道Master侧出口FIFO：读使能受reorder控制
fifo_r_mx_vld[i] = M_RVALID[i] & m[i]_rsid_clr_rdy
                    ↑                          ↑
              crossbar数据有效          reorder确认该事务可出队
```

这意味着**FIFO不仅是缓冲，还是事务排序流水线的一环**：sid_buffer通过控制FIFO的写使能来节制事务进入速率，reorder通过控制FIFO的读使能来保证响应顺序。

**设计意图总结**：
1. **时序解耦**：隔离Master侧、Crossbar核心、Slave侧三段的时序路径，每段可独立优化
2. **反压缓冲**：当Slave端反压时，FIFO吸收burst传输中的拍数，避免反压立即回传阻塞整个通路
3. **吞吐提升**：FWFT特性使数据穿通FIFO仅需组合逻辑延迟，不引入额外等待周期
4. **排序配合**：FIFO的使能信号受sid_buffer/reorder控制，成为事务排序流水线的有机组成部分

---

### 2.3 axi_m2s_m3 — Master到Slave多路选择器

**功能**：将3个Master的请求汇聚到一个Slave端口，包含地址译码和仲裁。

**地址译码逻辑**：
```
AWSELECT[i] = channel_en & (M[i]_AWADDR[31:ADDR_LENGTH] == ADDR_BASE[31:ADDR_LENGTH])
```
- 通过比较Master地址高位与当前Slave的基地址，确定该Master是否要访问本Slave。
- Default Slave模式下：`AWSELECT = ~AWSELECT_IN & AWVALID`，即未被其他Slave选中的请求都路由到Default Slave。

**SID编组 (关键设计)**：

在生成Slave端ID时，会重组为8位SID格式：
```
S_AWID = {2-bit slv_addr, 2-bit mst_MID, 4-bit M_AWID}
S_WID  = {2-bit slv_addr, 2-bit mst_MID, 4-bit M_WID}
```
- **高2位 (slv_addr)**：目标Slave地址编码 (00/01/10对应S0/S1/S2)
- **中间2位 (mst_MID)**：源Master ID (01/10/11对应M0/M1/M2)
- **低4位**：原始ID

这种编组方式使得后续S2M方向可以仅通过ID字段完成反向路由。

**W通道路由的特殊性 (写交织支持)**：
```
WSELECT[i] = channel_en & (M[i]_WID[3:2] == ADDR_BASE[ADDR_LENGTH+1:ADDR_LENGTH])
```
W通道不是通过地址译码，而是通过WID的高2位 (即slv_addr) 来确定目标Slave。这使得支持**写交织**：多个Master的写数据可以交错到达同一Slave，由WID中的slv_addr字段指导路由。

**Ready信号汇聚**：
```
M0_AWREADY = AWGRANT[0] & S_AWREADY
```
只有仲裁获胜的Master才能看到Slave的ready信号。

---

### 2.4 axi_s2m_s3 — Slave到Master多路选择器

**功能**：将多个Slave的响应汇聚到一个Master端口，通过ID译码实现路由。

**ID译码逻辑**：
```
BSELECT[i] = (S[i]_BID[W_ID+1:W_ID] == M_MID)
```
- 通过读取BID/RID中的**中间2位 (mst_MID字段)** 来确定该响应属于哪个Master。
- 这就是M2S方向编组SID的设计目的：在S2M方向仅需位选择即可还原路径。

**响应路由**：
- B通道响应：根据BGRANT选择对应的Slave响应路由给Master
- R通道响应：根据RGRANT + r_order_grant 选择响应
- RSELECT_in = RSELECT & {1'b1, r_order_grant}，reorder模块通过grant信号控制哪路响应可以发送。

---

### 2.5 axi_arbiter_m2s_m3 — M2S仲裁器

**功能**：对3个Master的请求进行仲裁，选择当前获得Slave访问权的Master。

**三通道独立仲裁**：AW通道、W通道、AR通道各有独立的仲裁逻辑。

**状态机设计** (以AR通道为例)：
```
STAR_RUN ──(grant未完成)──► STAR_WAIT ──(granted master握手成功)──► STAR_RUN
```
- **STAR_RUN**：正常运行状态，输出仲裁器选中的grant。
- **STAR_WAIT**：当仲裁选中的Master因Slave端未ready而不能完成传输时，锁存当前grant，防止被更高优先级请求抢占而导致协议错误。
- 退出WAIT条件：当前granted的Master完成了有效的ready-vld握手。

**仲裁策略**：由rr_fixed_arbiter实现，支持Round-Robin和Fixed Priority两种模式。

---

### 2.6 axi_arbiter_s2m_s3 — S2M仲裁器

**功能**：对多个Slave返回的响应进行仲裁，确定哪个Slave的响应先发送给Master。

- 结构类似M2S仲裁器，但仲裁对象是Slave的响应通道 (BVALID/RVALID)。
- B通道仲裁器和R通道仲裁器独立。
- 同样有RUN/WAIT状态机防止未完成事务被抢占。

---

### 2.7 rr_fixed_arbiter — 仲裁算法核心

**功能**：实现Round-Robin和Fixed Priority两种仲裁算法。

**Round-Robin模式** (`arbiter_type=0`)：
- 维护`last_winner`寄存器，记录上次获得授权的请求。
- 从`last_winner`的下一个位置开始循环查找有效请求，实现公平轮询。
- 例如：如果上次授权给了req[0]，则本轮优先检查req[1]→req[2]→req[3]→req[0]。

**Fixed Priority模式** (`arbiter_type=1`)：
- 使用`casex`优先级编码器：req[0]优先权最高，req[3]最低。
- `4'bxxx1 → sel=0001, 4'bxx10 → sel=0010, ...`

**4输入设计**：仲裁器设计为4输入 (3个有效通道+1个预留)，M2S方向使用{1'b0, REQ}连接。

---

### 2.8 sid_buffer — 事务ID缓冲与排序

**功能**：维护一个4深度的ID缓冲队列，记录正在进行中的事务ID顺序。分为读事务缓冲 (ar_sid_buffer) 和写事务缓冲 (aw_sid_buffer)。

**核心数据流**：

**Push操作 (事务发起时)**：
```
push_select[i] = s[i]_axid_vld & s[i]_fifo_rdy
push_grant = priority_sel(push_select)
s[i]_push_rdy = ~(push_select[i] ^ push_grant[i]) & clr_rdy
```
- 使用固定优先级仲裁，将事务ID按发起顺序写入buffer的空闲位置。
- buffer深度为4，`full = (buffer[3] != 0)`

**Clear操作 (事务完成时)**：
```
clr_select[i] = last_i & sid_i_vld
clr_grant = priority_sel(clr_select)
```
- 当某个Master的last信号到达且数据有效时，清除该ID在buffer中的记录。
- 清除后自动**向前移位压缩**：buffer[n] ← buffer[n+1]，buffer[3] ← 0，保持队列连续性。

**控制Readiness**：
- `s_push_rdy`：只有当该Master被允许push到buffer，且有空间时才允许其事务进入FIFO。
- `sid_clr_rdy`：只有当该Master的事务完成被清理，才允许其读取数据进入后续FIFO。

---

### 2.9 reorder — 响应重排序

**功能**：确保从Slave返回的读数据/写响应按照事务发起的原始顺序返回给Master。

**设计原理**：
- 多个Slave可能以任意顺序返回响应，但Master期望按事务发起顺序接收。
- reorder模块将当前返回的sid与sid_buffer中记录的**第一个待完成事务**进行比对：
  - 低4位 (rid_low) 匹配 → 原始ID匹配
  - 高4位 (rid_high) 匹配 → 完整SID匹配

**order_grant判断逻辑** (以s0为例)：
```
if (s0_rid_high[0] && s0_rid_low[0])        // 匹配buffer[0]
   order_grant[0] = 1;
else if (s0_rid matches buffer[1] only)       // 匹配buffer[1]（前序事务可能已完成）
   order_grant[0] = 1;
...
```
- 仅当返回的事务ID与buffer中最早未完成的事务ID匹配时，才授权该通道发送。
- order_grant信号控制S2M仲裁器中的RSELECT，只有按序到达的响应才能参与仲裁。

**写通道处理**：写事务的reorder逻辑类似，输入信号为W通道的sid (经过重组：`{WID[3:2], M_MID, WID[1:0]}`)。

---

### 2.10 axi_default_slave — 默认从设备

**功能**：处理所有不被任何正常Slave地址空间覆盖的访问，返回DECERR错误响应。

**设计要点**：

- 写事务处理：接收AW+W通道数据，吸收所有写数据后返回`BRESP=2'b11` (DECERR)
- 读事务处理：接收AR通道请求，返回`RRESP=2'b11`，`RDATA=全1` (~0)
- 状态机保证完整的AXI握手协议合规，包括：
  - 正确响应AWREADY/WREADY
  - 计数burst长度，按时产生BVALID/RLAST
  - ID字段回传，保持事务ID一致性

---

### 2.11 apb_regs_cfg — APB配置寄存器

**功能**：通过APB接口提供对Crossbar运行参数的配置和状态监控。

**寄存器映射** (基地址 0x50000000)：

| 偏移 | 寄存器名 | 位宽 | 访问 | 功能 |
|------|----------|------|------|------|
| 0x00 | DECODE_ERR | 32 | RO | bit[1]=aw_decode_err, bit[0]=ar_decode_err |
| 0x04 | AW_SID_BUFFER | 32 | RO | 4×8bit写地址SID缓冲快照 |
| 0x08 | AR_SID_BUFFER | 32 | RO | 4×8bit读地址SID缓冲快照 |
| 0x0C | AW_TRANS_COUNT | 32 | RO | 写事务计数 (buffer中非零条目数) |
| 0x10 | AR_TRANS_COUNT | 32 | RO | 读事务计数 |
| 0x14 | ARBITER_TYPE | 32 | RW | bit[0]=0为RR, =1为Fixed Priority |
| 0x18 | SLAVER_EN | 32 | RW | bit[2:0]分别控制Slave2/1/0的使能 |

**控制流**：
- `arbiter_type` → 控制所有仲裁器的调度策略
- `slaver_en` → 控制每个Slave通道的`channel_en`信号，用于动态关断特定Slave
- decode_err信号来自Default Slave的AWSELECT/ARSELECT输出 (当有请求命中default slave时拉高)

---

## 3. 关键设计思想总结

### 3.1 事务排序机制 (Ordering)

整个设计最核心的设计挑战是**保证事务顺序**：

1. **sid_buffer** 记录每个事务发起的顺序 (FIFO入队)。
2. **reorder** 确保响应按发起顺序返回：只有与buffer头部匹配的响应才能通过。
3. **SID编组方案**：8位SID = {slv_addr, mst_MID, orig_ID}，实现了从请求到响应的完整路径追踪。

### 3.2 SID编组的设计智慧

```
S_AWID[7:0] = {2-bit slv_addr, 2-bit mst_MID, 4-bit orig_AWID}
S_WID[7:0]  = {2-bit slv_addr, 2-bit mst_MID, 4-bit orig_WID}
S_ARID[7:0] = {2-bit slv_addr, 2-bit mst_MID, 4-bit orig_ARID}
```

- **slv_addr** (bit[7:6])：记录目标Slave地址 → 用于W通道写数据路由
- **mst_MID** (bit[5:4])：记录源Master ID → 用于B/R通道响应路由
- **orig_ID** (bit[3:0])：原始ID → 用于区分同一Master的不同事务

这种编组使得路由选择仅需位比较操作，无需查表，硬件开销极小。

### 3.3 跨4K边界处理

AXI协议禁止单笔burst跨4K边界。cross_4k_if在Master入口处自动检测并拆分，保证了协议合规性。拆分后的第二笔事务ID会递增，以区分两个子事务。

### 3.4 可配置仲裁策略

通过APB寄存器动态切换Round-Robin和Fixed Priority，满足不同应用场景的公平性/优先级需求。

### 3.5 流水线化设计

大量使用FIFO缓冲 (共30个例化)，实现了各通道间的时序解耦，提高了系统吞吐能力。