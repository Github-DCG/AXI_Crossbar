# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此仓库中工作时提供指导。

## 项目概述

一个 AXI4 Crossbar/Interconnect IP — 3 主设备 × 3 从设备（外加默认从设备）的可配置交叉开关，将多个 AXI 主设备连接到多个 AXI 从设备。实现了地址解码、仲裁（轮询 / 固定优先级）、基于 FIFO 的流水线解耦、4KB 边界拆分、事务排序以及基于 APB 的运行时配置。包含完整的物理实现 RTL-to-GDSII 流程（使用 OpenROAD + Yosys + Nangate45 PDK）。

## 构建 / 仿真 / 运行

### RTL 仿真 (Synopsys VCS + Verdi)

```bash
cd axi_interconnect
make          # 清理 → 编译 → 仿真 → 启动 Verdi
make com      # 仅 VCS 编译
make sim      # 运行 simv 二进制文件
make verdi    # 启动 Verdi 波形查看器
make clean    # 删除构建产物
```

测试平台 (`sim/axi_interconnect_tb.v`) 使用手动测试用例块 — 通过注释/取消注释来选择测试场景。`sim/filelist.f` 定义了 RTL 文件列表。仿真会导出 FSDB 波形。VCS 编译选项包含 `+define+FSDB` 用于波形导出。

### RTL 生成器 (生成参数化 Verilog 的 C 程序)

```bash
cd auto_gen_script/axi_interconnect
make                    # 编译 gen_amba_axi 二进制文件
make run                # 示例：生成 3 主设备、4 从设备的交叉开关
./gen_amba_axi --mst=3 --slv=4 --out=axi_crossbar_m3s4.v
./gen_amba_axi --help   # 查看所有选项：--mst, --slv, --mod, --pre, --out, --ver
```

该生成器以编程方式生成所有子模块，可根据主/从设备数量和信号扇出进行变化。

### UVM 测试平台 (Synopsys VCS + UVM-1.2)

```bash
cd UVM/axi_crossbar_98.07/axi_crossbar_98.07/sim
make compile                          # 使用 UVM 进行 VCS 编译
make run                              # 运行 testname.f 中列出的所有测试
make run-test TEST=<test_name>        # 按名称运行单个测试
make run_cov_all                      # 运行所有测试并收集覆盖率
make verdi                            # 在 Verdi 中查看覆盖率
make clean
```

UVM 测试用例名称列在 `testname.f` 中。覆盖率收集包括行/翻转/条件/分支/断言/状态机覆盖率。

### 物理实现 (OpenROAD + Yosys + Nangate45)

```bash
cd physical_implement
make DESIGN_CONFIG=./Constraint/config.mk   # 完整的 RTL→GDS 流程
```

或者通过 `Scripts/run_all.tcl` 中的 OpenROAD Tcl 流程逐步执行，其顺序为：
Yosys 综合 → 布图规划 → 布局 → 时钟树综合 → 布线 → 填充 → 最终报告 → KLayout 导出。

中间结果和最终结果存放在 `physical_implement/Result/` 中。配置文件 (`Constraint/config.mk`) 设置了 `DESIGN_NAME = axi_interconnect`、`PLATFORM = nangate45`、目标利用率和密度。

> **注意**: `physical_implement/` 是独立的 OpenROAD+Yosys 开源流程。它**不使用** `ic_post_test/` 下的 DC/ICC2/PrimeTime 脚本。

### 后端物理实现 (Synopsys DC + ICC2 + PrimeTime) — `ic_post_test/`

`ic_post_test/` 是独立的 Synopsys 标准工具链后端流程目录，采用 **DC 逻辑综合 → PrimeTime STA → ICC2 物理实现 → PrimeTime 最终 STA** 的业界标准流程。

> **核心原则**: `ic_post_test/` 完全独立于 `physical_implement/`。所有修改仅在 `ic_post_test/` 内进行。流程依赖永远建在 `ic_post_test/common/` 下。

```bash
# 顺序运行完整流程
cd ic_post_test
cd 01_synthesis        && bash run.sh   # DC 逻辑综合
cd ../02_sta_post_synth && bash run.sh  # 综合后 STA (PrimeTime)
cd ../03_floorplan      && bash run.sh  # 布图规划 (ICC2)
cd ../04_placement      && bash run.sh  # 布局 (ICC2)
cd ../05_cts            && bash run.sh  # 时钟树综合 (ICC2)
cd ../06_route          && bash run.sh  # 布线 (ICC2)
cd ../07_finish         && bash run.sh  # 最终输出 GDS/SPEF (ICC2)
cd ../08_sta_post_layout && bash run.sh # 布局后 STA (PrimeTime)

# 或者单独重跑某一步 — 各步骤完全独立
cd ic_post_test/04_placement && bash run.sh
```

#### 目录结构

```
ic_post_test/
├── common/                        ← 公共资源（各步骤共享，通过软链接引用外部文件）
│   ├── setup_env.sh               ← 统一环境变量（工具路径/设计参数/PDK路径）
│   ├── rtl/                       ← RTL 源文件 → 软链接到 axi_interconnect/rtl/
│   ├── rtl_uvm/                   ← 补充 RTL → 软链接到 UVM/.../rtl/
│   ├── lef/lib/gds/cdl/           ← PDK 工艺文件 → 软链接到 physical_implement/PDK/nangate45/
│   ├── sdc/constraint.sdc         ← SDC 时序约束（直接复制，非软链接）
│   └── extra/                     ← 额外 LEF (fakeram)
├── 01_synthesis/   ~ 08_sta_post_layout/   ← 各流程步骤
```

#### 依赖管理原则

1. **RTL 源文件** — `common/rtl/` 下所有文件为指向 `axi_interconnect/rtl/` 的**软链接**。如果顶层实例化了新模块（如 `cross_4k_if`、`rr_fixed_arbiter`），必须在 `common/rtl/` 中添加对应的软链接并在 `setup_env.sh` 的 `RTL_FILES` 列表中补充。

2. **补充 RTL (UVM 命名)** — `common/rtl_uvm/` 存放 UVM 版本独有的模块（`axi_arbiter_mtos_m3.v`、`axi_arbiter_stom_s3.v`、`round_robin_s2m.v`），软链接指向 `UVM/axi_crossbar_98.07/.../rtl/`。

3. **PDK 文件** — `common/lef/`, `common/lib/`, `common/gds/`, `common/cdl/` 下全为软链接，指向 `physical_implement/PDK/nangate45/`。

4. **SDC 约束** — `common/sdc/constraint.sdc` 是**直接复制**的文件（非软链接），内容可独立修改，不影响 `physical_implement/Constraint/` 中的原版。

5. **修改原则** — 新增模块依赖时按以下顺序操作：
   - 在 `common/rtl/` (或 `common/rtl_uvm/`) 创建软链接
   - 更新 `common/setup_env.sh` 的 `RTL_FILES` 列表
   - 不允许修改 `physical_implement/` 或 `axi_interconnect/rtl/` 的原始文件

#### DC 综合关键注意事项

- **DC License** — 需要先启动 Synopsys 许可证服务器：
  ```bash
  /home/yian/Synopsys/scl/2024.06/linux64/bin/lmgrd \
    -c /home/yian/Synopsys/scl/2024.06/admin/license/synopsys.lic \
    -l /home/yian/Synopsys/scl/2024.06/admin/license/license.log
  ```

- **Liberty 库格式** — Nangate45 提供 ASCII `.lib` 格式（非编译后的 `.db`）。DC 直接 `set_app_var target_library "$env(LIB_FILE)"` 即可（初次加载会打印 DB-1 非致命警告，随后自动回退到 Liberty 解析）。

- **RTL 宏定义** — 综合脚本中必须设置 `set_app_var hdlin_define "APB_CFG"` 以启用顶层 APB 配置寄存器实例化。

- **设计名称** — `DESIGN_NAME = axi_interconnect`

#### RTL 文件清单 (13+2 个模块)

`common/rtl/` (主 RTL — 14 个文件):
```
axi_interconnect.v / axi_crossbar.v / axi_m2s_m3.v / axi_s2m_s3.v
axi_arbiter_m2s_m3.v / axi_arbiter_s2m_s3.v / rr_fixed_arbiter.v
cross_4k_if.v / axi_default_slave.v / axi_fifo_sync.v
round_robin_m2s.v / sid_buffer.v / reorder.v / apb_regs_cfg.v
```

`common/rtl_uvm/` (UVM 补充 — 3 个文件):
```
axi_arbiter_mtos_m3.v / axi_arbiter_stom_s3.v / round_robin_s2m.v
```

> `round_robin_s2m.v` 仅在 UVM 版本中存在；主 RTL 使用 `rr_fixed_arbiter.v` 统一替代。

#### 设计参数

| 项目 | 值 |
|------|-----|
| 设计名称 | `axi_interconnect` |
| 工艺 | Nangate45 (FreePDK45) 45nm |
| 时钟周期 | 2.8 ns (~357 MHz) |
| I/O 延迟 | 0.56 ns (20% 时钟) |
| 电源 | VDD=1.1V, VSS=0.0V |
| 布线层 | metal2 ~ metal10 |

### APB 寄存器文件生成器

```bash
cd auto_gen_script/apb_cfg_module
python gen_apb_file.py    # 读取 apb_regs.xls，生成 apb_regs_cfg.v
```

## 架构

### 顶层层次结构

```
axi_interconnect.v          ← 顶层封装（使用 `define APB_CFG）
├── cross_4k_if (×3)        ← 每个主设备的 4KB 边界跨越检测
├── axi_fifo_sync (×30)     ← 每个通道边界处的 FWFT 流水线 FIFO
├── axi_crossbar.v          ← 核心交叉开关
│   ├── axi_m2s_m3 (×4)     ← M→S 地址解码 + 仲裁（3 个从设备 + 默认从设备）
│   ├── axi_s2m_s3 (×3)     ← 每个主设备的 S→M 响应路由
│   ├── axi_arbiter_m2s_m3  ← 嵌入在 m2s 中，带有 RUN/WAIT 状态机的 M→S 仲裁
│   ├── axi_arbiter_s2m_s3  ← 嵌入在 s2m 中，S→M 仲裁
│   ├── rr_fixed_arbiter    ← 轮询/固定优先级仲裁核心（4 输入）
│   ├── sid_buffer (×2)     ← 事务 ID 排序队列（读 + 写）
│   ├── reorder (×2)        ← 响应重排序以匹配发出顺序
│   └── axi_default_slave   ← 回退从设备（对未映射地址返回 DECERR）
└── apb_regs_cfg            ← APB 配置寄存器（仲裁类型、从设备使能、调试）
```

### 核心设计概念

**SID 编码** — 8 位从设备 ID 是一个组合键：`{slv_addr[1:0], mst_MID[1:0], orig_ID[3:0]}`。它同时嵌入了源和目标信息，使得可以通过简单的位选择比较来进行路由（无需查找表）。

**事务排序** — `sid_buffer` 记录正在处理中的事务的发出顺序（4 级深度队列）。`reorder` 会阻塞响应通过，直到最旧的在途事务匹配为止。两者共同保证响应按照请求发出的顺序返回给主设备，即使不同的从设备在不同时间完成。

**FWFT FIFO** — `axi_fifo_sync` 使用首字直通（组合逻辑读取）、预寄存的 next-pointer（减少关键路径上的加法）以及显式的 `item_cnt` 寄存器以实现明确的满/空检测。深度通常为 4 个条目。FIFO 不仅仅是缓冲区 — 它们的写/读使能由 `sid_buffer`/`reorder` 门控，共同构成排序流水线。

**4KB 边界拆分** — `cross_4k_if` 检测跨越 4KB 边界的突发传输（违反 AXI 协议），并通过 3 状态状态机（IDLE → TRANS1 → TRANS2）将其拆分为两个顺序的子事务。第二个子事务的 ID 会递增，以便下游能够区分它们以进行写交织。

**仲裁器 RUN/WAIT 状态机** — 当获胜主设备尚未完成握手时，仲裁器会锁定当前授权，防止过早抢占导致违反 AXI 协议。

**APB 配置** — 通过 APB 在地址 `0x50000000` 处进行运行时配置：读取解码错误计数、SID 缓冲区快照、事务计数、仲裁类型（轮询 vs 固定优先级）以及各从设备使能位。

### 模块命名规范

`axi_interconnect/rtl/` 下的文件使用 `m2s`/`s2m` 和 `_m3`/`_s3` 后缀：
- `axi_m2s_m3.v` — 3 主设备的主到从多路复用器（每个从设备实例化）
- `axi_s2m_s3.v` — 3 从设备的从到主多路复用器（每个主设备实例化）
- `axi_arbiter_m2s_m3.v` — M2S 方向仲裁器，3 输入

`UVM/axi_crossbar_98.07/` 下的 UVM 副本使用替代命名：`mtos`/`stom` 以及 `round_robin_*` 而非 `rr_fixed_arbiter`。它们在功能上等效，但文件名不同。

### 两套 RTL 变体

本仓库中有两份 RTL 副本：
1. **`axi_interconnect/rtl/`** — 主开发版本，包含 `rr_fixed_arbiter.v`、`cross_4k_if.v`、APB 配置和 AXI-to-AHB 桥接支持。这是用于物理实现的版本。
2. **`UVM/axi_crossbar_98.07/.../rtl/`** — UVM 测试平台版本，包含 `round_robin_m2s.v`/`round_robin_s2m.v`（拆分仲裁器）和 `axi_mtos_m3.v`/`axi_stom_s3.v`（不同命名）。不含 `cross_4k_if`。

### 两套后端流程

本仓库提供两种后端物理实现方案，**彼此独立、互不干扰**：

| | `physical_implement/` | `ic_post_test/` |
|---|---|---|
| **工具链** | Yosys + OpenROAD (开源) | DC + ICC2 + PrimeTime (Synopsys 商用) |
| **综合** | Yosys ABC 技术映射 | `compile_ultra -gate_clock` |
| **SDC** | `Constraint/constraint.sdc` | `common/sdc/constraint.sdc` (独立副本) |
| **RTL 来源** | `designs/src/interconnect/` (需手动创建) | `common/rtl/` + `common/rtl_uvm/` (软链接) |
| **PDK** | 内置 | 软链接指向 `physical_implement/PDK/nangate45/` |
| **运行方式** | `make` / OpenROAD Tcl | 各步骤独立 `bash run.sh` |
| **修改原则** | 仅修改本目录内文件 | 仅修改本目录内文件 |

> **关键原则**: 修改任一流程时，不得破坏另一流程。两个 `constraint.sdc` 和配置文件独立维护。

### 文件列表

- `axi_interconnect/sim/filelist.f` — 独立 VCS 仿真的 RTL 文件列表
- `UVM/.../rtl/filelist.f` — UVM 测试平台的 RTL 文件列表
- `axi_interconnect/rtl/axi2ahb_bridge/filelist.f` — AXI-to-AHB 桥接子项目
- `axi_interconnect/rtl/cross_4k/filelist.f` — 4K 边界拆分器子项目

## 工具依赖

- **Synopsys VCS** (vcs) — RTL 仿真编译器和仿真器
- **Synopsys Verdi** (verdi) — 波形查看器和调试器
- **Synopsys DC** (dc_shell) — ASIC 逻辑综合（用于 `ic_post_test/` 流程）
- **Synopsys ICC2** (icc2_shell) — 后端物理实现（用于 `ic_post_test/` 流程）
- **Synopsys PrimeTime** (pt_shell) — 静态时序分析 STA（用于 `ic_post_test/` 流程）
- **Synopsys SCL** (lmgrd/snpslmd) — License 服务器（位于 `/home/yian/Synopsys/scl/2024.06/`）
- **OpenROAD** — 物理实现（布图规划、布局、时钟树综合、布线）（用于 `physical_implement/` 流程）
- **Yosys** — 物理流程中的逻辑综合（用于 `physical_implement/` 流程）
- **Nangate45 PDK** — 标准单元库（FreePDK45 变体），位于 `physical_implement/PDK/nangate45/`
- **GCC** — 用于基于 C 的 RTL 生成器
- **Python 3** — 用于 APB 寄存器文件生成器
