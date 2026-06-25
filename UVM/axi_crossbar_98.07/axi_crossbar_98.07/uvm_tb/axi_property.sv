// PROPERY ASSERTION
module axi_property#(
    int WIDTH = 32,
    SIZE = 3)
(input  logic   ACLK,
 input  logic   ARESET,


 input logic MST_AWREADY                       [0:2],
 input logic MST_AWVALID                       [0:2],
 input logic [SIZE-2:0]      MST_AWBURST       [0:2],
 input logic [SIZE-1:0]      MST_AWSIZE        [0:2],
 input logic [7:0]           MST_AWLEN         [0:2],
 input logic [WIDTH-1:0]     MST_AWADDR        [0:2],
 input logic [(WIDTH/8)-1:0] MST_AWID          [0:2],

  // DATA WRITE CHANNEL
 input logic MST_WREADY                        [0:2],
 input logic MST_WVALID                        [0:2],
 input logic MST_WLAST                         [0:2],
 input logic [(WIDTH/8)-1:0] MST_WSTRB         [0:2],
 input logic [WIDTH-1:0] MST_WDATA             [0:2],
 input logic	[(WIDTH/8)-1:0]  MST_WID         [0:2],

 // WRITE RESPONSE CHANNEL
 input logic [(WIDTH/8)-1:0] MST_BID           [0:2],
 input logic [SIZE-2:0] MST_BRESP              [0:2],
 input logic MST_BVALID                        [0:2],
 input logic MST_BREADY                        [0:2],

// READ ADDRESS CHANNEL
 input logic MST_ARREADY                       [0:2],
 input logic MST_ARVALID                       [0:2],
 input  logic [(WIDTH/8)-1:0] MST_ARID         [0:2],
 input  logic [WIDTH-1:0] MST_ARADDR           [0:2],
 input  logic [(WIDTH/4)-1:0] MST_ARLEN        [0:2],
 input  logic [SIZE-1:0] MST_ARSIZE            [0:2],
 input  logic [SIZE-2:0] MST_ARBURST           [0:2],

// READ DATA CHANNEL
 input logic [(WIDTH/8)-1:0] MST_RID           [0:2],
 input logic [WIDTH-1:0] MST_RDATA             [0:2],
 input logic [SIZE-2:0] MST_RRESP              [0:2],
 input logic MST_RLAST                         [0:2],
 input logic MST_RVALID                        [0:2],
 input logic MST_RREADY                        [0:2],

  //From Slave
  //rand bit RW = 0;
input logic SLV_AWREADY                        [0:2],
input logic SLV_AWVALID                        [0:2],
input  logic [SIZE-2:0] SLV_AWBURST            [0:2],
input  logic [SIZE-1:0] SLV_AWSIZE             [0:2],
input  logic [7:0]      SLV_AWLEN              [0:2],
input  logic [WIDTH-1:0] SLV_AWADDR            [0:2],
input  logic [(WIDTH/4)-1:0] SLV_AWID          [0:2],
   
// DATA WRITE CHANNEL
input logic SLV_WREADY                        [0:2],
input logic SLV_WVALID                        [0:2],
input logic SLV_WLAST                         [0:2],
input logic [(WIDTH/8)-1:0] SLV_WSTRB         [0:2],
input logic [WIDTH-1:0] SLV_WDATA             [0:2],
input logic	[(WIDTH/4)-1:0]  SLV_WID          [0:2],

// WRITE RESPONSE CHANNEL
input logic [(WIDTH/4)-1:0] SLV_BID           [0:2],
input logic [SIZE-2:0] SLV_BRESP              [0:2],
input logic SLV_BVALID                        [0:2],
input logic SLV_BREADY                        [0:2],

// READ ADDRESS CHANNEL
input  logic SLV_ARREADY                      [0:2],
input  logic SLV_ARVALID                      [0:2],
input  logic [(WIDTH/4)-1:0] SLV_ARID         [0:2],
input  logic [WIDTH-1:0] SLV_ARADDR           [0:2],
input  logic [(WIDTH/4)-1:0] SLV_ARLEN        [0:2],
input  logic [SIZE-1:0] SLV_ARSIZE            [0:2],
input  logic [SIZE-2:0] SLV_ARBURST           [0:2],

// READ DATA CHANNEL
input logic [(WIDTH/4)-1:0] SLV_RID           [0:2],
input logic [WIDTH-1:0] SLV_RDATA             [0:2],
input logic [SIZE-2:0] SLV_RRESP              [0:2],
input logic SLV_RLAST                         [0:2],
input logic SLV_RVALID                        [0:2],
input logic SLV_RREADY                        [0:2]);

//M_AWVALID master写地址通道握手信号维持一个周期
  property M0_AWVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_AWREADY[0] && MST_AWVALID[0] |=>  $fell(MST_AWVALID[0]);
  endproperty: M0_AWVALID_rose_next_cycle_fall
  assert property(M0_AWVALID_rose_next_cycle_fall) 
  else
   `uvm_error("ASSERT", "MST_AWVALID[0] is high after 1 cycle MST_AWREADY[0] rose")

 property M1_AWVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_AWREADY[1] && MST_AWVALID[1] |=>  $fell(MST_AWVALID[1]);
  endproperty: M1_AWVALID_rose_next_cycle_fall
  assert property(M1_AWVALID_rose_next_cycle_fall) 
  else
   `uvm_error("ASSERT", "MST_AWVALID[1] is high after 1 cycle MST_AWREADY[1] rose")

 property M2_AWVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_AWREADY[2] && MST_AWVALID[2] |=>  $fell(MST_AWVALID[2]);
  endproperty: M2_AWVALID_rose_next_cycle_fall
  assert property(M2_AWVALID_rose_next_cycle_fall) 
  else
   `uvm_error("ASSERT", "MST_AWVALID[2] is high after 1 cycle MST_AWREADY[2] rose")
//M_AWVALID master写地址通道信号握手维持一个周期 end

//M_ARVALID master读地址通道握手信号维持一个周期
  property M0_ARVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_ARREADY[0] && MST_ARVALID[0] |=>  $fell(MST_ARVALID[0]);
  endproperty: M0_ARVALID_rose_next_cycle_fall
  assert property(M0_ARVALID_rose_next_cycle_fall) 
  else
   `uvm_error("ASSERT", "MST_ARVALID[0] is high after 1 cycle MST_ARREADY[0] rose")

 property M1_ARVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_ARREADY[1] && MST_ARVALID[1] |=>  $fell(MST_ARVALID[1]);
  endproperty: M1_ARVALID_rose_next_cycle_fall
  assert property(M1_ARVALID_rose_next_cycle_fall) 
  else
   `uvm_error("ASSERT", "MST_ARVALID[1] is high after 1 cycle MST_ARREADY[1] rose")

 property M2_ARVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_ARREADY[2] && MST_ARVALID[2] |=>  $fell(MST_ARVALID[2]);
  endproperty: M2_ARVALID_rose_next_cycle_fall
  assert property(M2_ARVALID_rose_next_cycle_fall) 
  else
   `uvm_error("ASSERT", "MST_ARVALID[2] is high after 1 cycle MST_ARREADY[2] rose")
//M_ARVALID master读地址通道信号握手维持一个周期 end

//M_AWVALID信号有效期间，写地址保持稳定
  property M0_AWADDR_stable_during_M0_AWVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge ACLK) 
    ($rose(MST_AWVALID[0]),addr1 = MST_AWADDR[0])  |-> MST_AWADDR[0] == addr1 throughout MST_AWVALID[0];
  endproperty: M0_AWADDR_stable_during_M0_AWVALID
  assert property(M0_AWADDR_stable_during_M0_AWVALID) 
  else 
  `uvm_error("ASSERT", "MST_AWADDR[0] not stable during MST_AWVALID[0]")

  property M1_AWADDR_stable_during_M1_AWVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge ACLK) 
    ($rose(MST_AWVALID[1]),addr1 = MST_AWADDR[1])  |-> MST_AWADDR[1] == addr1 throughout MST_AWVALID[1];
  endproperty: M1_AWADDR_stable_during_M1_AWVALID
  assert property(M1_AWADDR_stable_during_M1_AWVALID) 
  else 
  `uvm_error("ASSERT", "MST_AWADDR[1] not stable during MST_AWVALID[1]")

  property M2_AWADDR_stable_during_M2_AWVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge ACLK) 
    ($rose(MST_AWVALID[2]),addr1 = MST_AWADDR[2])  |-> MST_AWADDR[2] == addr1 throughout MST_AWVALID[2];
  endproperty: M2_AWADDR_stable_during_M2_AWVALID
  assert property(M2_AWADDR_stable_during_M2_AWVALID) 
  else 
  `uvm_error("ASSERT", "MST_AWADDR[2] not stable during MST_AWVALID[2]")
  //M_AWVALID信号有效期间，写地址保持稳定 end
  
//M_ARVALID信号有效期间，读地址保持稳定
  property M0_ARADDR_stable_during_M0_ARVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge ACLK) 
    ($rose(MST_ARVALID[0]),addr1 = MST_ARADDR[0])  |-> MST_ARADDR[0] == addr1 throughout MST_ARVALID[0];
  endproperty: M0_ARADDR_stable_during_M0_ARVALID
  assert property(M0_ARADDR_stable_during_M0_ARVALID) 
  else 
  `uvm_error("ASSERT", "MST_ARADDR[0] not stable during MST_ARVALID[0]")

  property M1_ARADDR_stable_during_M1_ARVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge ACLK) 
    ($rose(MST_ARVALID[1]),addr1 = MST_ARADDR[1])  |-> MST_ARADDR[1] == addr1 throughout MST_ARVALID[1];
  endproperty: M1_ARADDR_stable_during_M1_ARVALID
  assert property(M1_ARADDR_stable_during_M1_ARVALID) 
  else 
  `uvm_error("ASSERT", "MST_ARADDR[1] not stable during MST_ARVALID[1]")

  property M2_ARADDR_stable_during_M2_ARVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge ACLK) 
    ($rose(MST_ARVALID[2]),addr1 = MST_ARADDR[2])  |-> MST_ARADDR[2] == addr1 throughout MST_ARVALID[2];
  endproperty: M2_ARADDR_stable_during_M2_ARVALID
  assert property(M2_ARADDR_stable_during_M2_ARVALID) 
  else 
  `uvm_error("ASSERT", "MST_ARADDR[2] not stable during MST_ARVALID[2]")
  //M_ARVALID信号有效期间，读地址保持稳定 end

  //写数据在WVALID信号拉高期间保持稳定
  property M0_WDATA_stable_during_M0_WVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge ACLK) 
    ($rose(MST_WVALID[0]),d1 = MST_WDATA[0])  |-> MST_WDATA[0] == d1 throughout MST_WVALID[0];
  endproperty: M0_WDATA_stable_during_M0_WVALID
  assert property(M0_WDATA_stable_during_M0_WVALID) 
  else 
  `uvm_error("ASSERT", "MST_WDATA[0] not stable during MST_WVALID[0]")

  property M1_WDATA_stable_during_M1_WVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge ACLK) 
    ($rose(MST_WVALID[1]),d1 = MST_WDATA[1])  |-> MST_WDATA[1] == d1 throughout MST_WVALID[1];
  endproperty: M1_WDATA_stable_during_M1_WVALID
  assert property(M1_WDATA_stable_during_M1_WVALID) 
  else 
  `uvm_error("ASSERT", "MST_WDATA[1] not stable during MST_WVALID[1]")

  property M2_WDATA_stable_during_M2_WVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge ACLK) 
    ($rose(MST_WVALID[2]),d1 = MST_WDATA[2])  |-> MST_WDATA[2] == d1 throughout MST_WVALID[2];
  endproperty: M2_WDATA_stable_during_M2_WVALID
  assert property(M2_WDATA_stable_during_M2_WVALID) 
  else 
  `uvm_error("ASSERT", "MST_WDATA[2] not stable during MST_WVALID[2]")
//写数据在WVALID信号拉高期间保持稳定 end

//读数据在RVALID信号拉高期间保持稳定
  property M0_RDATA_stable_during_M0_RVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge ACLK) 
    ($rose(MST_RVALID[0]),d1 = MST_RDATA[0])  |-> MST_RDATA[0] == d1 throughout MST_RVALID[0];
  endproperty: M0_RDATA_stable_during_M0_RVALID
  assert property(M0_RDATA_stable_during_M0_RVALID) 
  else 
  `uvm_error("ASSERT", "MST_RDATA[0] not stable during MST_RVALID[0]")

  property M1_RDATA_stable_during_M1_RVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge ACLK) 
    ($rose(MST_RVALID[1]),d1 = MST_RDATA[1])  |-> MST_RDATA[1] == d1 throughout MST_RVALID[1];
  endproperty: M1_RDATA_stable_during_M1_RVALID
  assert property(M1_RDATA_stable_during_M1_RVALID) 
  else 
  `uvm_error("ASSERT", "MST_RDATA[1] not stable during MST_RVALID[1]")

  property M2_RDATA_stable_during_M2_RVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge ACLK) 
    ($rose(MST_RVALID[2]),d1 = MST_RDATA[2])  |-> MST_RDATA[2] == d1 throughout MST_RVALID[2];
  endproperty: M2_RDATA_stable_during_M2_RVALID
  assert property(M2_RDATA_stable_during_M2_RVALID) 
  else 
  `uvm_error("ASSERT", "MST_RDATA[2] not stable during MST_RVALID[2]")
//读数据在RVALID信号拉高期间保持稳定 end
  
//写响应握手维持一个周期
  property M0_BVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_BVALID[0] && MST_BREADY[0] |=> $fell(MST_BVALID[0]);
  endproperty: M0_BVALID_rose_next_cycle_fall
  assert property(M0_BVALID_rose_next_cycle_fall) 
  else 
  `uvm_error("ASSERT", "M0_BVALID is high after 1 cycle M0_BVALID rose")

  property M1_BVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_BVALID[1] && MST_BREADY[1] |=> $fell(MST_BVALID[1]);
  endproperty: M1_BVALID_rose_next_cycle_fall
  assert property(M1_BVALID_rose_next_cycle_fall) 
  else 
  `uvm_error("ASSERT", "M1_BVALID is high after 1 cycle M1_BVALID rose")

   property M2_BVALID_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_BVALID[2] && MST_BREADY[2] |=> $fell(MST_BVALID[2]);
  endproperty: M2_BVALID_rose_next_cycle_fall
  assert property(M2_BVALID_rose_next_cycle_fall) 
  else 
  `uvm_error("ASSERT", "M2_BVALID is high after 1 cycle M2_BVALID rose")
//写响应握手维持一个周期 end

/*
  
  property BVALID_rose_after_WLAST_fall;
    @(posedge ACLK) 
    $fell(WLAST)  |=> ##[0:$] $rose(BVALID);
  endproperty: BVALID_rose_after_WLAST_fall
  assert property(BVALID_rose_after_WLAST_fall) 
  else 
  `uvMST_error("ASSERT", "BVALID is low after WLAST fall")
  
  property MST_BVALID[1]_rose_next_cycle_fall;
    @(posedge ACLK) 
    MST_BVALID[1] && MST_BREADY[1] |=> $fell(MST_BVALID[1]);
  endproperty: MST_BVALID[0]_rose_next_cycle_fall
  assert property(MST_BVALID[1]_rose_next_cycle_fall) 
  else 
  `uvm_error("ASSERT", "MST_BVALID[1] is high after 1 cycle MST_BVALID[1] rose")
  
  
  
  
  
  /*
  property ARREADY_rose_next_cycle_fall;
    @(posedge ACLK) 
    ARVALID && ARREADY |=> $fell(ARREADY) && $fell(ARVALID);
  endproperty: ARREADY_rose_next_cycle_fall
  assert property(ARREADY_rose_next_cycle_fall) 
  else 
  `uvMST_error("ASSERT", "ARVALID or ARREADY is high after 1 cycle ARREADY rose")
  
  property ARADDR_stable_during_ARVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge ACLK) 
    ($rose(ARVALID),addr1 = ARADDR)  |-> ARADDR == addr1 throughout ARVALID;
  endproperty: ARADDR_stable_during_ARVALID
  assert property(ARADDR_stable_during_ARVALID) 
  else 
  `uvMST_error("ASSERT", "ARADDR not stable during ARVALID")
  
  property read_RDATA_after_AWREADY_fell;
    @(posedge ACLK) 
    $fell(ARREADY) |=> ##[0:$] ($rose(RLAST) && RVALID);
  endproperty: read_RDATA_after_AWREADY_fell
  assert property(read_RDATA_after_AWREADY_fell) 
  else 
  `uvMST_error("ASSERT", "must read data after ARREADY fell")
  
  property RDATA_stable_during_RVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge ACLK) 
    ($rose(RVALID),d1 = RDATA)  |-> RDATA == d1 throughout RVALID;
  endproperty: RDATA_stable_during_RVALID
  assert property(RDATA_stable_during_RVALID) 
  else 
  `uvMST_error("ASSERT", "RDATA not stable during RVALID")

*/

endmodule
