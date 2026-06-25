
`define MASTER_MONITOR

class axi_m_monitor#(int WIDTH=32,SIZE=3) extends uvm_monitor;//#(axi_transaction#(WIDTH,SIZE));

    `uvm_component_param_utils(axi_m_monitor#(WIDTH,SIZE))
    virtual axi_intf#(WIDTH,SIZE) intf;
    uvm_analysis_port#(axi_transaction#(WIDTH,SIZE)) mon2sb_port1;
    uvm_analysis_port#(axi_transaction#(WIDTH,SIZE)) mon2sb_port2;
    axi_transaction#(WIDTH,SIZE) w_tx;
      
    function new(string name, uvm_component parent);
        super.new(name, parent);
        w_tx = new(); 
        mon2sb_port1 = new("mon2sb_port1",this);
		mon2sb_port2 = new("mon2sb_port2",this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_intf#(WIDTH,SIZE))::get(this, "", "intf", intf))
        `uvm_fatal("NO_VIF","virtual interface not found");
    endfunction
    
    
    virtual task run_phase(uvm_phase phase);
	fork 
        collect_trans();   
	join
    endtask
    
task collect_trans();

	forever begin
		@(posedge intf.clk iff (intf.M_RREADY[0] && intf.M_RVALID[0]) || 
		(intf.M_RREADY[1] && intf.M_RVALID[1]) || (intf.M_RREADY[2] && intf.M_RVALID[2]) )

		w_tx.M_RID = intf.M_RID;
		w_tx.M_RDATA = intf.M_RDATA;
		w_tx.M_RRESP = intf.M_RRESP;
		w_tx.M_RLAST = intf.M_RLAST;		
		mon2sb_port2.write(w_tx);
		$display("Mon M2_rdata: %d", w_tx.M_RDATA[2]);
		$display("Mon M1_rdata: %d", w_tx.M_RDATA[1]);
		$display("Mon M0_rdata: %d", w_tx.M_RDATA[0]);
	end

	forever begin
	@(posedge intf.clk iff (intf.S_WREADY[0] && intf.S_WVALID[0]) ||
	 (intf.S_WREADY[1] && intf.S_WVALID[1]) || (intf.S_WREADY[2] && intf.S_WVALID[2])  )

		w_tx.S_WID = intf.S_WID;
		w_tx.S_WDATA = intf.S_WDATA;
		w_tx.S_WSTRB = intf.S_WSTRB;
		w_tx.S_WLAST = intf.S_WLAST;
		w_tx.S_AWADDR = intf.S_AWADDR;		
		mon2sb_port1.write(w_tx);
		$display("Mon S2_wdata: %d", w_tx.S_WDATA[2]);
		$display("Mon S1_wdata: %d", w_tx.S_WDATA[1]);
		$display("Mon S0_wdata: %d", w_tx.S_WDATA[0]);
  	end
  
endtask
     
endclass


