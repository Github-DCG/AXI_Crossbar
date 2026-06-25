`timescale 1ns / 1ps

module top;

  bit clk, reset;

  axi_intf #(32, 3) intf (
      clk,
      reset
  );
integer i;


initial begin
  clk <= 0;
  reset <= 0;
  #2 reset <= 1;
  #4 reset <= 0;
  #4 reset <= 1;
  // # 350000;
  # 500000000;
  #4 reset <= 0;
   // @(posedge clk);
		// reset <= 0;Y
  $finish(0);  
  end

always #2 clk = ~clk;


  initial begin
    intf.S_ARREADY[0] <= 1'b1; intf.S_ARREADY[1] <= 1'b1; intf.S_ARREADY[2] <= 1'b1;
    intf.M_RREADY [0] <= 1'b1; intf.M_RREADY [1] <= 1'b1; intf.M_RREADY [2] <= 1'b1;
    intf.S_AWREADY[0] <= 1'b1; intf.S_AWREADY[1] <= 1'b1; intf.S_AWREADY[2] <= 1'b1;
    intf.S_WREADY [0] <= 1'b1; intf.S_WREADY [1] <= 1'b1; intf.S_WREADY [2] <= 1'b1;
    intf.M_BREADY [0] <= 1'b1; intf.M_BREADY [1] <= 1'b1; intf.M_BREADY [2] <= 1'b1;

    intf.M_ARID[0]    = 0; intf.M_AWID   [0] = 0; intf.S_RID   [0] = 0;  intf.M_WID   [0] = 0; intf.S_BID   [0] = 0;
    intf.M_ARADDR[0]  = 0; intf.M_AWADDR [0] = 0; intf.S_RDATA [0] = 0;  intf.M_WDATA [0] = 0; intf.S_BRESP [0] = 0;
    intf.M_ARLEN[0]   = 0; intf.M_AWLEN  [0] = 0; intf.S_RVALID[0] = 0;  intf.M_WSTRB [0] = 0; intf.S_BVALID[0] = 0;
    intf.M_ARSIZE[0]  = 0; intf.M_AWSIZE [0] = 0; intf.M_WLAST [0] = 0; 
    intf.M_ARBURST[0] = 0; intf.M_AWBURST[0] = 0; intf.S_RRESP [0] = 0;  intf.M_WVALID[0] = 0;
    intf.M_ARVALID[0] = 0; intf.M_AWVALID[0] = 0; intf.S_RLAST [0] = 0;  

    intf.M_ARID[1]    = 0; intf.M_AWID   [1] = 0; intf.S_RID   [1] = 0;  intf.M_WID   [1] = 0; intf.S_BID   [1] = 0;
    intf.M_ARADDR[1]  = 0; intf.M_AWADDR [1] = 0; intf.S_RDATA [1] = 0;  intf.M_WDATA [1] = 0; intf.S_BRESP [1] = 0;
    intf.M_ARLEN[1]   = 0; intf.M_AWLEN  [1] = 0; intf.S_RVALID[1] = 0;  intf.M_WSTRB [1] = 0; intf.S_BVALID[1] = 0;
    intf.M_ARSIZE[1]  = 0; intf.M_AWSIZE [1] = 0; intf.M_WLAST [1] = 0; 
    intf.M_ARBURST[1] = 0; intf.M_AWBURST[1] = 0; intf.S_RRESP [1] = 0;  intf.M_WVALID[1] = 0;
    intf.M_ARVALID[1] = 0; intf.M_AWVALID[1] = 0; intf.S_RLAST [1] = 0;  

    intf.M_ARID[2]    = 0; intf.M_AWID   [2] = 0; intf.S_RID   [2] = 0;  intf.M_WID   [2] = 0; intf.S_BID   [2] = 0;
    intf.M_ARADDR[2]  = 0; intf.M_AWADDR [2] = 0; intf.S_RDATA [2] = 0;  intf.M_WDATA [2] = 0; intf.S_BRESP [2] = 0;
    intf.M_ARLEN[2]   = 0; intf.M_AWLEN  [2] = 0; intf.S_RVALID[2] = 0;  intf.M_WSTRB [2] = 0; intf.S_BVALID[2] = 0;
    intf.M_ARSIZE[2]  = 0; intf.M_AWSIZE [2] = 0; intf.M_WLAST [2] = 0; 
    intf.M_ARBURST[2] = 0; intf.M_AWBURST[2] = 0; intf.S_RRESP [2] = 0;  intf.M_WVALID[2] = 0;
    intf.M_ARVALID[2] = 0; intf.M_AWVALID[2] = 0; intf.S_RLAST [2] = 0;  
  end


  axi_interconnect #(
      .WIDTH_CID (4),
      .WIDTH_ID(4),
      .WIDTH_AD (32),
      .WIDTH_DA(32),
      .WIDTH_DS(4),
      .WIDTH_SID (8)
  ) dut_inst (
    
      .AXI_RSTn        (reset),
      .AXI_CLK         (clk),

      .M_AXI_AWID     (intf.M_AWID),
      .M_AXI_AWADDR   (intf.M_AWADDR),
      .M_AXI_AWLEN    (intf.M_AWLEN),
      .M_AXI_AWSIZE   (intf.M_AWSIZE),
      .M_AXI_AWBURST  (intf.M_AWBURST),
      .M_AXI_AWVALID  (intf.M_AWVALID),
      .M_AXI_AWREADY  (intf.M_AWREADY),

 
      .M_AXI_WID      (intf.M_WID),
      .M_AXI_WDATA    (intf.M_WDATA),
      .M_AXI_WSTRB    (intf.M_WSTRB),
      .M_AXI_WLAST    (intf.M_WLAST),
      .M_AXI_WVALID   (intf.M_WVALID),
      .M_AXI_WREADY   (intf.M_WREADY),

      .M_AXI_BID      (intf.M_BID),
      .M_AXI_BRESP    (intf.M_BRESP),
      .M_AXI_BVALID   (intf.M_BVALID),
      .M_AXI_BREADY   (intf.M_BREADY),

      .M_AXI_ARID     (intf.M_ARID),
      .M_AXI_ARADDR   (intf.M_ARADDR),
      .M_AXI_ARLEN    (intf.M_ARLEN),
      .M_AXI_ARSIZE   (intf.M_ARSIZE),
      .M_AXI_ARBURST  (intf.M_ARBURST),
      .M_AXI_ARVALID  (intf.M_ARVALID),
      .M_AXI_ARREADY  (intf.M_ARREADY),

      .M_AXI_RID      (intf.M_RID),
      .M_AXI_RDATA    (intf.M_RDATA),
      .M_AXI_RRESP    (intf.M_RRESP),
      .M_AXI_RLAST    (intf.M_RLAST),
      .M_AXI_RVALID   (intf.M_RVALID),
      .M_AXI_RREADY   (intf.M_RREADY),

      .S_AXI_AWID     (intf.S_AWID),
      .S_AXI_AWADDR   (intf.S_AWADDR),
      .S_AXI_AWLEN    (intf.S_AWLEN),
      .S_AXI_AWSIZE   (intf.S_AWSIZE),
      .S_AXI_AWBURST  (intf.S_AWBURST),
      .S_AXI_AWVALID  (intf.S_AWVALID),
      .S_AXI_AWREADY  (intf.S_AWREADY),

      .S_AXI_WID      (intf.S_WID),
      .S_AXI_WDATA    (intf.S_WDATA),
      .S_AXI_WSTRB    (intf.S_WSTRB),
      .S_AXI_WLAST    (intf.S_WLAST),
      .S_AXI_WVALID   (intf.S_WVALID),
      .S_AXI_WREADY   (intf.S_WREADY),

      .S_AXI_BID    (intf.S_BID),
      .S_AXI_BRESP  (intf.S_BRESP),
      .S_AXI_BVALID (intf.S_BVALID),
      .S_AXI_BREADY (intf.S_BREADY),

      .S_AXI_ARID   (intf.S_ARID),
      .S_AXI_ARADDR (intf.S_ARADDR),
      .S_AXI_ARLEN  (intf.S_ARLEN),
      .S_AXI_ARSIZE (intf.S_ARSIZE),
      .S_AXI_ARBURST(intf.S_ARBURST),
      .S_AXI_ARVALID(intf.S_ARVALID),
      .S_AXI_ARREADY(intf.S_ARREADY),

      .S_AXI_RID    (intf.S_RID),
      .S_AXI_RDATA  (intf.S_RDATA),
      .S_AXI_RRESP  (intf.S_RRESP),
      .S_AXI_RLAST  (intf.S_RLAST),
      .S_AXI_RVALID (intf.S_RVALID),
      .S_AXI_RREADY (intf.S_RREADY)
  );
  

  axi_property  assertions(
      .ACLK       (intf.clk  ),
      .ARESET     (intf.reset),

      .MST_AWID     (intf.M_AWID),
      .MST_AWADDR   (intf.M_AWADDR),
      .MST_AWLEN    (intf.M_AWLEN),
      .MST_AWSIZE   (intf.M_AWSIZE),
      .MST_AWBURST  (intf.M_AWBURST),
      .MST_AWVALID  (intf.M_AWVALID),
      .MST_AWREADY  (intf.M_AWREADY),

 
      .MST_WID     (intf.M_WID),
      .MST_WDATA   (intf.M_WDATA),
      .MST_WSTRB   (intf.M_WSTRB),
      .MST_WLAST   (intf.M_WLAST),
      .MST_WVALID  (intf.M_WVALID),
      .MST_WREADY  (intf.M_WREADY),

      .MST_BID     (intf.M_BID),
      .MST_BRESP   (intf.M_BRESP),
      .MST_BVALID  (intf.M_BVALID),
      .MST_BREADY  (intf.M_BREADY),

      .MST_ARID     (intf.M_ARID),
      .MST_ARADDR   (intf.M_ARADDR),
      .MST_ARLEN    (intf.M_ARLEN),
      .MST_ARSIZE   (intf.M_ARSIZE),
      .MST_ARBURST  (intf.M_ARBURST),
      .MST_ARVALID  (intf.M_ARVALID),
      .MST_ARREADY  (intf.M_ARREADY),

      .MST_RID      (intf.M_RID),
      .MST_RDATA    (intf.M_RDATA),
      .MST_RRESP    (intf.M_RRESP),
      .MST_RLAST    (intf.M_RLAST),
      .MST_RVALID   (intf.M_RVALID),
      .MST_RREADY   (intf.M_RREADY),

      .SLV_AWID     (intf.S_AWID),
      .SLV_AWADDR   (intf.S_AWADDR),
      .SLV_AWLEN    (intf.S_AWLEN),
      .SLV_AWSIZE   (intf.S_AWSIZE),
      .SLV_AWBURST  (intf.S_AWBURST),
      .SLV_AWVALID  (intf.S_AWVALID),
      .SLV_AWREADY  (intf.S_AWREADY),

      .SLV_WID      (intf.S_WID),
      .SLV_WDATA    (intf.S_WDATA),
      .SLV_WSTRB    (intf.S_WSTRB),
      .SLV_WLAST    (intf.S_WLAST),
      .SLV_WVALID   (intf.S_WVALID),
      .SLV_WREADY   (intf.S_WREADY),

      .SLV_BID      (intf.S_BID),
      .SLV_BRESP    (intf.S_BRESP),
      .SLV_BVALID   (intf.S_BVALID),
      .SLV_BREADY   (intf.S_BREADY),
  
      .SLV_ARID     (intf.S_ARID),
      .SLV_ARADDR   (intf.S_ARADDR),
      .SLV_ARLEN    (intf.S_ARLEN),
      .SLV_ARSIZE   (intf.S_ARSIZE),
      .SLV_ARBURST  (intf.S_ARBURST),
      .SLV_ARVALID  (intf.S_ARVALID),
      .SLV_ARREADY  (intf.S_ARREADY),
  
      .SLV_RID      (intf.S_RID),
      .SLV_RDATA    (intf.S_RDATA),
      .SLV_RRESP    (intf.S_RRESP),
      .SLV_RLAST    (intf.S_RLAST),
      .SLV_RVALID    (intf.S_RVALID),
      .SLV_RREADY    (intf.S_RREADY)
  );  





  initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
    ///*
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, top, "+mda");
    $fsdbDumpMDA();
    

    uvm_config_db#(virtual axi_intf #(32, 3))::set(uvm_root::get(), "*", "intf", intf);

    run_test("axi_base_test");
  end

  initial begin: assertion_control
  
    fork
      forever begin
        wait(reset==1);
          $asserton();
       		$display ("assertion_start");
        wait(reset==0);
         $assertoff(); 
         $display ("assertion_no");
      end
    join_none
  end


endmodule
