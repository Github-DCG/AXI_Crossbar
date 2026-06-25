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
  //  drv2sb_portM2 = new("drv2sb_portM2", this);
  //  drv2sb_portS = new("drv2sb_portS", this);
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
		intf.M_WVALID[i] <= 1'bz;
		intf.M_BREADY[i] = 1'b0;
		intf.M_ARVALID[i] <= 1'b0;
	end
    end
  endtask
  
  task send_data();
	  if(req.M_WVALID[0] == 1 || req.M_WVALID[1] == 1 || req.M_WVALID[2] == 1)begin
		  sent_data_write_trx();  //驱动写数据
		  if(req.M_WLAST[0] == 1'b1 || req.M_WLAST[1] == 1'b1 || req.M_WLAST[2] == 1'b1)received_resp_write();
		  drv2sb_port1.write(req);//传递写数据
    end
    if(req.M_RVALID[0] == 1 || req.M_RVALID[1] == 1 || req.M_RVALID[2] == 1)begin
		  sent_data_read_trx();//驱动读数据
      if(req.S_RLAST[0] == 1'b1 || req.S_RLAST[1] == 1'b1 || req.S_RLAST[2] == 1'b1)received_resp_write();
      drv2sb_port2.write(req);//驱动读数据
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

    $display("drv seq print:");
    req.print();
*/
	fork 
      sent_addr_write_trx();
      sent_addr_read_trx();
      send_data();
	join

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
   
  task sent_addr_write_trx();
  	
	if(req.M_AWVALID [0] == 1 || req.M_AWVALID [1] == 1 || req.M_AWVALID [2] == 1)begin  //发送写地址到DUT
	@(posedge intf.clk) begin
			intf.M_AWVALID <= req.M_AWVALID;
			intf.M_AWADDR <= req.M_AWADDR;
			intf.M_AWBURST <= req.M_AWBURST;
			intf.M_AWSIZE <= req.M_AWSIZE;                                                             
			intf.M_AWLEN <= req.M_AWLEN;
			intf.M_AWID <= req.M_AWID;
        end
        	end
			 @(posedge intf.clk iff (intf.M_AWREADY[0]) || (intf.M_AWREADY[1]) ||(intf.M_AWREADY[2]))
       for (int i = 0; i < 3; i++) begin
			intf.M_AWVALID[i] <= 1'b0;
			intf.M_AWBURST[i] <= '0;
			intf.M_AWSIZE[i] <= '0;
			intf.M_AWLEN[i] <= '0;
			intf.M_AWID[i] <= '0;
			// intf.AWADDR <= '0;
			sent_addr_read_trx();
			$display("sent addr done");
     
	
	end
  endtask

  
  task sent_data_write_trx();  //发送写数据到DUT
    @(posedge intf.clk) begin
      intf.M_WVALID <= req.M_WVALID;
      intf.M_WSTRB <= req.M_WSTRB;//选中哪几个字写入
	    //intf.WSTRB <= 4'b1111;
      intf.M_WDATA <= req.M_WDATA;
      intf.M_WLAST <= req.M_WLAST;
	  end
	   @(posedge intf.clk iff (intf.M_WREADY[0]) || (intf.M_WREADY[1]) ||(intf.M_WREADY[2]))
     for (int i = 0; i < 3; i++) begin
      intf.M_WVALID[i] <= 1'b0;
      intf.M_WSTRB[i] <= 1'b0;
      intf.M_WDATA[i] <= '0;
      intf.M_WLAST[i] <= 1'b0;
	  $display("write data done");
	 
     end
  endtask
  

task received_resp_write();  //发送写响应
  for (int i = 0; i < 3; i = i + 1) begin
      intf.M_BREADY[i] <= 1'b1;
  end
  @(posedge intf.clk iff (intf.M_BVALID[0] || intf.M_BVALID[1] || intf.M_BVALID[2]));
  for (int i = 0; i < 3; i = i + 1) begin
    if (intf.M_BVALID[i]) begin
      intf.M_BREADY[i] <= 1'b0;
    end
  end

  $display("received write resp done");
endtask


  task sent_addr_read_trx();  //发送读地址到DUT
    //#55
    @(posedge intf.clk) begin
	  intf.M_ARVALID <= req.M_AWVALID;
      intf.M_ARADDR <= req.M_AWADDR;
      intf.M_ARLEN <= req.M_AWLEN;
	  intf.M_ARBURST <= req.M_AWBURST;
      intf.M_ARSIZE <= req.M_AWSIZE;
      intf.M_ARID <= req.M_AWID;
		end
	  @(posedge intf.clk iff (intf.M_ARREADY[0]) || (intf.M_ARREADY[1])  || (intf.M_ARREADY[2]))
    for (int i = 0; i < 3; i = i + 1) begin
	  intf.M_ARVALID[i] <= 1'b0;
      // intf.ARADDR <= '0;
      intf.M_ARLEN[i] <= 1'b0;
      intf.M_ARBURST[i] <= 1'b0;
      intf.M_ARSIZE[i] <= 1'b0;
      intf.M_ARID[i] <= 1'b0;
    
    end
  endtask
  
  /*
  task sent_data_read_trx(); //发送读数据
    @(posedge intf.clk) 
      intf.RREADY <= 1'b1;
	 
	@(posedge intf.clk iff (intf.RVALID))
      intf.RREADY <= 1'b0;
	  $display("read data done");
  endtask
  */
  
  task sent_data_read_trx();  //发送读数据到DUT
    @(posedge intf.clk) begin
      intf.S_RVALID <= req.S_RVALID;
      intf.S_RID <= req.S_RID;
      intf.S_RDATA <= req.S_RDATA;
      intf.S_RRESP <= req.S_RRESP;
      intf.S_RLAST <= req.S_RLAST;
	 
	   @(posedge intf.clk iff (intf.S_WREADY[0]) || (intf.S_WREADY[1])||(intf.S_WREADY[2]) )
     for (int i = 0; i < 3; i = i + 1) begin
      intf.S_RVALID[i] <= 1'b0;
      intf.S_RID[i] <= 1'b0;
      intf.S_RDATA[i] <= '0;
      intf.S_RRESP[i] <= 1'b0;
      intf.S_RLAST[i] <= 1'b0;
	  $display("write data done");
     end
	  end
  endtask
  


endclass

