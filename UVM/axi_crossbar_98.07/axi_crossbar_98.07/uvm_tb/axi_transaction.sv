
import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_transaction #(
    int WIDTH = 32,
    int SIZE = 3
) extends uvm_sequence_item;

//From Master
  rand bit RW = 0;
  logic M_AWREADY                       [0:2];
  logic M_AWVALID                       [0:2];
  rand logic [SIZE-2:0] M_AWBURST       [0:2];
  rand logic [SIZE-1:0] M_AWSIZE        [0:2];
  rand logic [7:0]      M_AWLEN         [0:2];
  randc logic [WIDTH-1:0] M_AWADDR      [0:2];
  rand logic [(WIDTH/8)-1:0] M_AWID     [0:2];

  // DATA WRITE CHANNEL
  logic M_WREADY                        [0:2];
  logic M_WVALID                        [0:2];
  logic M_WLAST                         [0:2];
  rand logic [(WIDTH/8)-1:0] M_WSTRB    [0:2];
  rand logic [WIDTH-1:0] M_WDATA        [0:2];
  rand logic	[(WIDTH/8)-1:0]  M_WID    [0:2];

  // WRITE RESPONSE CHANNEL
  logic [(WIDTH/8)-1:0] M_BID           [0:2];
  logic [SIZE-2:0] M_BRESP              [0:2];
  logic M_BVALID                        [0:2];
  logic M_BREADY                        [0:2];

  // READ ADDRESS CHANNEL
  logic M_ARREADY                       [0:2];
  logic M_ARVALID                       [0:2];
  rand logic [(WIDTH/8)-1:0] M_ARID     [0:2];
  randc logic [WIDTH-1:0] M_ARADDR      [0:2];
  rand logic [(WIDTH/4)-1:0] M_ARLEN    [0:2];
  rand logic [SIZE-1:0] M_ARSIZE        [0:2];
  rand logic [SIZE-2:0] M_ARBURST       [0:2];

  // READ DATA CHANNEL
  rand logic [(WIDTH/8)-1:0] M_RID      [0:2];
  rand logic [WIDTH-1:0] M_RDATA        [0:2];
  logic [SIZE-2:0] M_RRESP              [0:2];
  logic M_RLAST                         [0:2];
  logic M_RVALID                        [0:2];
  logic M_RREADY                        [0:2];

  //From Slave
  //rand bit RW = 0;
  logic S_AWREADY                       [0:2];
  logic S_AWVALID                       [0:2];
  rand logic [SIZE-2:0] S_AWBURST       [0:2];
  rand logic [SIZE-1:0] S_AWSIZE        [0:2];
  rand logic [7:0]      S_AWLEN         [0:2];
  randc logic [WIDTH-1:0] S_AWADDR      [0:2];
  rand logic [(WIDTH/4)-1:0] S_AWID     [0:2];

  // DATA WRITE CHANNEL
  logic S_WREADY                        [0:2];
  logic S_WVALID                        [0:2];
  logic S_WLAST                         [0:2];
  rand logic [(WIDTH/8)-1:0] S_WSTRB    [0:2];
  rand logic [WIDTH-1:0] S_WDATA        [0:2];
  rand logic	[(WIDTH/4)-1:0]  S_WID    [0:2];

  // WRITE RESPONSE CHANNEL
  logic [(WIDTH/4)-1:0] S_BID           [0:2];
  logic [SIZE-2:0] S_BRESP              [0:2];
  logic S_BVALID                        [0:2];
  logic S_BREADY                        [0:2];

  // READ ADDRESS CHANNEL
  logic S_ARREADY                       [0:2];
  logic S_ARVALID                       [0:2];
  rand logic [(WIDTH/4)-1:0] S_ARID     [0:2];
  randc logic [WIDTH-1:0] S_ARADDR      [0:2];
  rand logic [(WIDTH/4)-1:0] S_ARLEN    [0:2];
  rand logic [SIZE-1:0] S_ARSIZE        [0:2];
  rand logic [SIZE-2:0] S_ARBURST       [0:2];

  // READ DATA CHANNEL
  rand logic [(WIDTH/4)-1:0] S_RID      [0:2];
  rand logic [WIDTH-1:0] S_RDATA        [0:2];
  logic [SIZE-2:0] S_RRESP              [0:2];
  logic S_RLAST                         [0:2];
  logic S_RVALID                        [0:2];
  logic S_RREADY                        [0:2];

  `uvm_object_param_utils_begin(axi_transaction#(WIDTH, SIZE))
  //From Master
    `uvm_field_sarray_int(M_AWREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_AWVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_AWBURST, UVM_ALL_ON)
    `uvm_field_sarray_int(M_AWSIZE, UVM_ALL_ON)
    `uvm_field_sarray_int(M_AWLEN, UVM_ALL_ON)
    `uvm_field_sarray_int(M_AWADDR, UVM_ALL_ON)
    `uvm_field_sarray_int(M_AWID, UVM_ALL_ON)
    `uvm_field_int(RW, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_WREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_WVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_WLAST, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_WSTRB, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_WDATA, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_WID, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_BID, UVM_ALL_ON)
    `uvm_field_sarray_int(M_BRESP, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_BVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_BREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_ARREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_ARVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_ARBURST, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_ARSIZE, UVM_ALL_ON)
    `uvm_field_sarray_int(M_ARLEN, UVM_ALL_ON)
    `uvm_field_sarray_int(M_ARADDR, UVM_ALL_ON)
    `uvm_field_sarray_int(M_ARID, UVM_ALL_ON)
    `uvm_field_sarray_int(M_RREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_RVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_RLAST, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_RRESP, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_RDATA, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(M_RID, UVM_ALL_ON)

    //From Slave
    `uvm_field_sarray_int(S_AWREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_AWVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_AWBURST, UVM_ALL_ON)
    `uvm_field_sarray_int(S_AWSIZE, UVM_ALL_ON)
    `uvm_field_sarray_int(S_AWLEN, UVM_ALL_ON)
    `uvm_field_sarray_int(S_AWADDR, UVM_ALL_ON)
    `uvm_field_sarray_int(S_AWID, UVM_ALL_ON)
   // `uvm_field_int(S_RW, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_WREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_WVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_WLAST, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_WSTRB, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_WDATA, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_WID, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_BID, UVM_ALL_ON)
    `uvm_field_sarray_int(S_BRESP, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_BVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_BREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_ARREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_ARVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_ARBURST, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_ARSIZE, UVM_ALL_ON)
    `uvm_field_sarray_int(S_ARLEN, UVM_ALL_ON)
    `uvm_field_sarray_int(S_ARADDR, UVM_ALL_ON)
    `uvm_field_sarray_int(S_ARID, UVM_ALL_ON)
    `uvm_field_sarray_int(S_RREADY, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_RVALID, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_RLAST, UVM_ALL_ON | UVM_NOPRINT | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_RRESP, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_RDATA, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_sarray_int(S_RID, UVM_ALL_ON)
  `uvm_object_utils_end

  //constraint  strb  {WSTRB inside{[4'b0000:4'b1111]};}   //给掩码信号加个约束
  //constraint  awlen {AWLEN inside{0,1,3,7,15,31,63,127};}  //给突发长度加个约束

  function new(string name = "axi_transaction");
    super.new(name);
  endfunction

endclass



