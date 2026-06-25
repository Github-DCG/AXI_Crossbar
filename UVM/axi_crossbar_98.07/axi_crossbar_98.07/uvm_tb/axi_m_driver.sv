`define DRIVER

class axi_m_driver #(
    int WIDTH = 32,
    SIZE = 3
) extends uvm_driver#(axi_transaction#(WIDTH, SIZE));

  `uvm_component_utils_begin(axi_m_driver#(WIDTH, SIZE))
  `uvm_component_utils_end
  
   axi_subscriber#(WIDTH, SIZE) sub;

  virtual interface axi_intf #(WIDTH, SIZE) intf;

  uvm_analysis_port #(axi_transaction #(WIDTH, SIZE)) drv2sb_port1;
  uvm_analysis_port #(axi_transaction #(WIDTH, SIZE)) drv2sb_port2;
 // uvm_analysis_port #(axi_transaction #(WIDTH, SIZE)) drv2sb_portM2;
 // uvm_analysis_port #(axi_transaction #(WIDTH, SIZE)) drv2sb_portS;

  // new
  int RW;
  //

  axi_transaction #(WIDTH, SIZE) tx;

  function new(string name = "axi_m_driver", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv2sb_port1 = new("drv2sb_port1", this);
    drv2sb_port2 = new("drv2sb_port2", this);
	sub = axi_subscriber#(WIDTH, SIZE)::type_id::create("sub", this);
  endfunction : build_phase


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual interface axi_intf #(WIDTH, SIZE))::get(this, "", "intf", intf))
      `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".intf"})
	sub.write(intf);
	
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
	super.run_phase(phase);
	// fork
		// reset_intf();
	// join_none
	fork
		sub.do_sample();
		my_send_drv_msg();
	join
  endtask : run_phase
  
  task reset_intf();
	  forever begin
		@(negedge intf.reset) 
  for (int i = 0; i < 3; i++) begin
		intf.M_AWVALID[i] <= 1'b0;
		intf.M_WVALID[i] <= 1'b0;
		intf.M_BREADY[i] = 1'b0;
		intf.M_ARVALID[i] <= 1'b0;
	end
  	end

  endtask

  
  task my_send_drv_msg();
  forever begin
    seq_item_port.get_next_item(req);

/*
    @(posedge intf.clk) 
	  req.RDATA = req.WDATA;
    req.ARADDR = req.AWADDR;
    req.ARLEN = req.AWLEN;
    req.ARSIZE = req.AWSIZE;
    req.ARBURST = req.AWBURST;
*/
    $display("drv seq print:");
    req.print();
begin
      sent_addr_write_trx();
      sent_addr_read_trx();
      send_data();
       
end
	seq_item_port.item_done();
   	seq_item_port.put(req);
  end
  endtask

  task sent_trx_to_seq();
    begin
      case (RW)
        0: drv2sb_port1.write(req); //RW=0,写操作
        1: drv2sb_port2.write(req); //RW=1,读操作
      endcase
    end
  endtask

//发送写地址
task sent_addr_write_trx();
  if(req.S_AWREADY[0]==0)begin
    intf.S_AWREADY[0] <= 0;
    intf.S_AWREADY[1] <= 0;
    intf.S_AWREADY[2] <= 0;
  end
  else begin
    intf.S_AWREADY[0] <= 1;
    intf.S_AWREADY[1] <= 1;
    intf.S_AWREADY[2] <= 1;
  end
fork

if(req.M_AWVALID[0])begin  //发送写地址到DUT
  		 @(posedge intf.clk) begin

			intf.M_AWVALID[0] <= req.M_AWVALID[0];
			intf.M_AWADDR[0] <= req.M_AWADDR[0];
			intf.M_AWBURST[0] <= req.M_AWBURST[0];
			intf.M_AWSIZE[0] <= req.M_AWSIZE[0];                                                             
			intf.M_AWLEN[0] <= req.M_AWLEN[0];
			intf.M_AWID[0] <= req.M_AWID[0];
   
			 @(posedge intf.clk iff (intf.M_AWREADY[0]))
			intf.M_AWVALID[0] <= 'd0;
			intf.M_AWBURST[0] <= 'd0;
			intf.M_AWSIZE[0] <= 'd0;
			intf.M_AWLEN[0] <= 'd0;
			intf.M_AWID[0] <= 'd0;
			intf.M_AWADDR[0] <= 'd0;
			$display("sent addr m0 done");
	end
     drv2sb_port1.write(req);
end

if(req.M_AWVALID[1])begin  //发送写地址到DUT
  		@(posedge intf.clk) begin

			intf.M_AWVALID[1] <= req.M_AWVALID[1];
			intf.M_AWADDR[1] <= req.M_AWADDR[1];
			intf.M_AWBURST[1] <= req.M_AWBURST[1];
			intf.M_AWSIZE[1] <= req.M_AWSIZE[1];                                                             
			intf.M_AWLEN[1] <= req.M_AWLEN[1];
			intf.M_AWID[1] <= req.M_AWID[1];
      
			 @(posedge intf.clk iff (intf.M_AWREADY[1]))
			intf.M_AWVALID[1] <= 'd0;
			intf.M_AWBURST[1] <= 'd0;
			intf.M_AWSIZE[1] <= 'd0;
			intf.M_AWLEN[1] <= 'd0;
			intf.M_AWID[1] <= 'd0;
			intf.M_AWADDR[1] <= 'd0;
			$display("sent addr m1 done");
	end
      drv2sb_port1.write(req);
end

if(req.M_AWVALID[2])begin  //发送写地址到DUT
  		@(posedge intf.clk) begin

			intf.M_AWVALID[2] <= req.M_AWVALID[2];
			intf.M_AWADDR[2] <= req.M_AWADDR[2];
			intf.M_AWBURST[2] <= req.M_AWBURST[2];
			intf.M_AWSIZE[2] <= req.M_AWSIZE[2];                                                             
			intf.M_AWLEN[2] <= req.M_AWLEN[2];
			intf.M_AWID[2] <= req.M_AWID[2];
      
			 @(posedge intf.clk iff (intf.M_AWREADY[2]))
			intf.M_AWVALID[2] <= 'd0;
			intf.M_AWBURST[2] <= 'd0;
			intf.M_AWSIZE[2] <= 'd0;
			intf.M_AWLEN[2] <= 'd0;
			intf.M_AWID[2] <= 'd0;
			intf.M_AWADDR[2] <= 'd0;
			$display("sent addr m2 done");
	end
      drv2sb_port1.write(req);
end  
join
  endtask

// task ctrl_arready();

//发送读地址
  task sent_addr_read_trx();  //发送读地址到DUT
  if(req.S_ARREADY[0]==0)begin
    intf.S_ARREADY[0] <= 0;
    intf.S_ARREADY[1] <= 0;
    intf.S_ARREADY[2] <= 0;
    $display("S_ARREADY 000");
  end
  else begin
    intf.S_ARREADY[0] <= 1;
    intf.S_ARREADY[1] <= 1;
    intf.S_ARREADY[2] <= 1;
    $display("S_ARREADY 111");
  end
fork
  if(req.M_ARVALID[0])begin  //发送M0读地址到DUT
    @(posedge intf.clk) begin

	    intf.M_ARVALID[0] <= req.M_ARVALID[0];
			// intf.S_ARREADY[0] <= req.S_ARREADY[0];
      intf.M_ARADDR[0] <= req.M_ARADDR[0];
      intf.M_ARLEN[0] <= req.M_ARLEN[0];
	    intf.M_ARBURST[0] <= req.M_ARBURST[0];
      intf.M_ARSIZE[0] <= req.M_ARSIZE[0];
      intf.M_ARID[0] <= req.M_ARID[0];
      
	  @(posedge intf.clk iff (intf.M_ARREADY[0]))

	    intf.M_ARVALID[0] <= 'd0;
      intf.M_ARADDR[0] <= 'h0;
      intf.M_ARLEN[0] <= 'd0;
      intf.M_ARBURST[0] <= 'd0;
      intf.M_ARSIZE[0] <= 'd0;
      intf.M_ARID[0] <= 'd0;
      $display("sent addr m0 read done");
  end   
      drv2sb_port2.write(req);
    end

  if(req.M_ARVALID[1])begin  //发送M1读地址到DUT
    @(posedge intf.clk) begin

	    intf.M_ARVALID[1] <= req.M_ARVALID[1];
      intf.M_ARADDR[1] <= req.M_ARADDR[1];
      intf.M_ARLEN[1] <= req.M_ARLEN[1];
	    intf.M_ARBURST[1] <= req.M_ARBURST[1];
      intf.M_ARSIZE[1] <= req.M_ARSIZE[1];
      intf.M_ARID[1] <= req.M_ARID[1];
      
	  @(posedge intf.clk iff (intf.M_ARREADY[1]))

	    intf.M_ARVALID[1] <= 'd0;
      intf.M_ARADDR[1] <= 'h0;
      intf.M_ARLEN[1] <= 'd0;
      intf.M_ARBURST[1] <= 'd0;
      intf.M_ARSIZE[1] <= 'd0;
      intf.M_ARID[1] <= 'd0;
      $display("sent addr m1 read done");
  end   
      drv2sb_port2.write(req);
    end

  if(req.M_ARVALID[2])begin  //发送M2读地址到DUT
    @(posedge intf.clk) begin
   

	    intf.M_ARVALID[2] <= req.M_ARVALID[2];
      intf.M_ARADDR[2] <= req.M_ARADDR[2];
      intf.M_ARLEN[2] <= req.M_ARLEN[2];
	    intf.M_ARBURST[2] <= req.M_ARBURST[2];
      intf.M_ARSIZE[2] <= req.M_ARSIZE[2];
      intf.M_ARID[2] <= req.M_ARID[2];
      
	  @(posedge intf.clk iff (intf.M_ARREADY[2]))

	    intf.M_ARVALID[2] <= 'd0;
      intf.M_ARADDR[2] <= 'h0;
      intf.M_ARLEN[2] <= 'd0;
      intf.M_ARBURST[2] <= 'd0;
      intf.M_ARSIZE[2] <= 'd0;
      intf.M_ARID[2] <= 'd0;
      $display("sent addr m2 read done");
  end   
      drv2sb_port2.write(req);
    end
join
  endtask

task send_data();
  if(req.M_RREADY[0]==0) begin
    intf.M_RREADY[0] <= 1'b0; //rready  0
    intf.M_RREADY[1] <= 1'b0; //rready  0
    intf.M_RREADY[2] <= 1'b0; //rready  0
	  $display("RREADY 000");
  end 
  else begin
    intf.M_RREADY[0] <= 1'b1; //rready  1
    intf.M_RREADY[1] <= 1'b1; //rready  1
    intf.M_RREADY[2] <= 1'b1; //rready  1
	  $display("RREADY 111");
  end
  if(req.S_WREADY[0]==0) begin
    intf.S_WREADY[0] <= 1'b0; //wready  0
    intf.S_WREADY[1] <= 1'b0; //wready  0
    intf.S_WREADY[2] <= 1'b0; //wready  0
	  $display("WREADY 000");
  end 
  else begin
    intf.S_WREADY[0] <= 1'b1; //wready  1
    intf.S_WREADY[1] <= 1'b1; //wready  1
    intf.S_WREADY[2] <= 1'b1; //wready  1
	  $display("WREADY 111");
  end
  if(req.M_BREADY[0]==0) begin
    intf.M_BREADY[0] <= 1'b0; //bready  0
    intf.M_BREADY[1] <= 1'b0; //bready  0
    intf.M_BREADY[2] <= 1'b0; //bready  0
	  $display("M_BREADY 000");
  end 
  else begin
    intf.M_BREADY[0] <= 1'b1; //bready  1
    intf.M_BREADY[1] <= 1'b1; //bready  1
    intf.M_BREADY[2] <= 1'b1; //bready  1
	  $display("M_BREADY 111");
  end

fork
	  if(req.M_WVALID[0] == 1)begin//驱动m0写数据
	    $display("write data m0 start");
      @(posedge intf.clk) 
      
      begin
        intf.M_WVALID[0] <= req.M_WVALID[0];
        intf.M_WSTRB[0] <= req.M_WSTRB[0];//选中哪几个字写入
        intf.M_WID[0] <= req.M_WID[0];
        intf.M_WDATA[0] <= req.M_WDATA[0];
        intf.M_WLAST[0] <= req.M_WLAST[0];
        @(posedge intf.clk iff (intf.M_WREADY[0]))
        intf.M_WVALID[0] <= 'b0;
        intf.M_WSTRB[0] <= 'b0;
        intf.M_WID[0] <= 'b0;
        intf.M_WDATA[0] <= 'b0;
        intf.M_WLAST[0] <= 'b0;
        $display("write data m0 done");
      end    
        drv2sb_port1.write(req);
 end
		  if(req.S_BVALID[0] == 1'b1) begin
        $display("received write s0 resp start");
        // while (!(intf.S_WLAST[0] & intf.S_WREADY[0] & intf.S_WVALID[0])) @(posedge intf.clk);
        @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk);
        intf.S_BID[0] <= req.S_BID[0];
        intf.S_BVALID[0] <= req.S_BVALID[0];
        intf.S_BRESP[0] <= req.S_BRESP[0];
       @(posedge intf.clk iff intf.S_BREADY[0]) 
        intf.S_BID[0] <= 0;
        intf.S_BVALID[0] <= 0;
        intf.S_BRESP[0] <= 0;	
        $display("received write s0 resp done");
         drv2sb_port1.write(req);
      end

	  if(req.M_WVALID[1] == 1)begin//驱动m1写数据
	    $display("write data s1 start");
      @(posedge intf.clk) 
      
      begin
        intf.M_WVALID[1] <= req.M_WVALID[1];
        intf.M_WSTRB[1] <= req.M_WSTRB[1];//选中哪几个字写入
        intf.M_WID[1] <= req.M_WID[1];
        intf.M_WDATA[1] <= req.M_WDATA[1];
        intf.M_WLAST[1] <= req.M_WLAST[1];
        @(posedge intf.clk iff (intf.M_WREADY[1]))
        intf.M_WVALID[1] <= 'b0;
        intf.M_WSTRB[1] <= 'b0;
        intf.M_WID[1] <= 'b0;
        intf.M_WDATA[1] <= 'b0;
        intf.M_WLAST[1] <= 'b0;
        $display("write data m1 done");
      end    
        drv2sb_port1.write(req);
 end
		  if(req.S_BVALID[1] == 1'b1) begin
        $display("received write m1 resp start");
        // while (!(intf.S_WLAST[1] & intf.S_WREADY[1] & intf.S_WVALID[1])) @(posedge intf.clk);
        @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk);
        intf.S_BID[1] <= req.S_BID[1];
        intf.S_BVALID[1] <= req.S_BVALID[1];
        intf.S_BRESP[1] <= req.S_BRESP[1];
       @(posedge intf.clk iff intf.S_BREADY[1]) 
        intf.S_BID[1] <= 0;
        intf.S_BVALID[1] <= 0;
        intf.S_BRESP[1] <= 0;	
        $display("received write m1 resp done");
         drv2sb_port1.write(req);
      end
   

	  	  if(req.M_WVALID[2] == 1)begin//驱动m2写数据
	    $display("write data m2 start");
      @(posedge intf.clk) 
      
      begin
        intf.M_WVALID[2] <= req.M_WVALID[2];
        intf.M_WSTRB[2] <= req.M_WSTRB[2];//选中哪几个字写入
        intf.M_WID[2] <= req.M_WID[2];
        intf.M_WDATA[2] <= req.M_WDATA[2];
        intf.M_WLAST[2] <= req.M_WLAST[2];
        @(posedge intf.clk iff (intf.M_WREADY[2]))
        intf.M_WVALID[2] <= 'b0;
        intf.M_WSTRB[2] <= 'b0;
        intf.M_WID[2] <= 'b0;
        intf.M_WDATA[2] <= 'b0;
        intf.M_WLAST[2] <= 'b0;
        $display("write data m2 done");
      end    
       drv2sb_port1.write(req);
 end
		  if(req.S_BVALID[2] == 1'b1) begin
        $display("received write m2 resp start");
        // while (!(intf.S_WLAST[2] & intf.S_WREADY[2] & intf.S_WVALID[2])) @(posedge intf.clk);
        @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk); @(posedge intf.clk);
        intf.S_BID[2] <= req.S_BID[2];
        intf.S_BVALID[2] <= req.S_BVALID[2];
        intf.S_BRESP[2] <= req.S_BRESP[2];
       @(posedge intf.clk iff intf.S_BREADY[2]) 
        intf.S_BID[2] <= 0;
        intf.S_BVALID[2] <= 0;
        intf.S_BRESP[2] <= 0;	
        $display("received write m2 resp done");
         drv2sb_port1.write(req);
      end

//发送读数据

  //task sent_data_read_trx();  //发送读数据到DUT


    if(req.S_RVALID[0] == 1 )begin //驱动s0读数据
    $display("read s0 data start");
    @(posedge intf.clk) begin
      intf.S_RVALID[0] <= req.S_RVALID[0];
      intf.S_RID[0]    <= req.S_RID[0];
      intf.S_RDATA[0]  <= req.S_RDATA[0];
      intf.S_RRESP[0]  <= req.S_RRESP[0];
      intf.S_RLAST[0]  <= req.S_RLAST[0];
	   @(posedge intf.clk iff (intf.S_RREADY[0]) )
      intf.S_RVALID[0] <= 'b0;
      intf.S_RID[0] <= 'b0;
      intf.S_RDATA[0] <= 'b0;
      intf.S_RRESP[0] <= 'b0;
      intf.S_RLAST[0] <= 'b0;
	    $display("read s0 data done");
	  end   
       drv2sb_port2.write(req);
end

    if(req.S_RVALID[1] == 1 )begin //驱动s1读数据
    $display("read s1 data start");
    @(posedge intf.clk) begin
      intf.S_RVALID[1] <= req.S_RVALID[1];
      intf.S_RID[1]    <= req.S_RID[1];
      intf.S_RDATA[1]  <= req.S_RDATA[1];
      intf.S_RRESP[1]  <= req.S_RRESP[1];
      intf.S_RLAST[1]  <= req.S_RLAST[1];
	   @(posedge intf.clk iff (intf.S_RREADY[1]) )
      intf.S_RVALID[1] <= 'b0;
      intf.S_RID[1] <= 'b0;
      intf.S_RDATA[1] <= 'b0;
      intf.S_RRESP[1] <= 'b0;
      intf.S_RLAST[1] <= 'b0;
	  $display("read s1 data done");
     drv2sb_port2.write(req);
	  end    
end

    if(req.S_RVALID[2] == 1 )begin //驱动s2读数据
    $display("read s2 data start");
    @(posedge intf.clk) 
  
      intf.S_RVALID[2] <= req.S_RVALID[2];
      intf.S_RID[2]    <= req.S_RID[2];
      intf.S_RDATA[2]  <= req.S_RDATA[2];
      intf.S_RRESP[2]  <= req.S_RRESP[2];
      intf.S_RLAST[2]  <= req.S_RLAST[2];
  begin
	   @(posedge intf.clk iff (intf.S_RREADY[2]) )
      intf.S_RVALID[2] <= 'b0;
      intf.S_RID[2] <= 'b0;
      intf.S_RDATA[2] <= 'b0;
      intf.S_RRESP[2] <= 'b0;
      intf.S_RLAST[2] <= 'b0;
	  $display("read s2 data done");
      drv2sb_port2.write(req); 
	  end    
end
join
  endtask


endclass

