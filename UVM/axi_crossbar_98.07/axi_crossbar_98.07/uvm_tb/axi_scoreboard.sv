
class axi_scoreboard #(
    int WIDTH = 32,
    SIZE = 3
) extends uvm_scoreboard;

  `uvm_component_param_utils(axi_scoreboard#(WIDTH, SIZE))

  uvm_analysis_export #(axi_transaction #(WIDTH, SIZE)) drv2sb_export_drv;  //expected
  uvm_analysis_export #(axi_transaction #(WIDTH, SIZE)) mon2sb_export_mon;  //actual

  uvm_tlm_analysis_fifo #(axi_transaction #(WIDTH, SIZE)) expfifo;
  uvm_tlm_analysis_fifo #(axi_transaction #(WIDTH, SIZE)) actualfifo;

  virtual axi_intf #(WIDTH, SIZE) intf;

  axi_transaction #(WIDTH, SIZE) mon_tx, drv_tx;


  function new(string name = "axi_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv2sb_export_drv = new("drv2sb_export_drv", this);
    mon2sb_export_mon = new("mon2sb_export_mon", this);
    expfifo = new("expfifo", this);
    actualfifo = new("actualfifo", this);
    mon_tx = new("mon_tx");
    drv_tx = new("drv_tx");
  endfunction

  function void connect_phase(uvm_phase phase);

    drv2sb_export_drv.connect(expfifo.analysis_export);
    mon2sb_export_mon.connect(actualfifo.analysis_export);
  endfunction

  virtual task run_phase(uvm_phase phase);
	fork
		compare();
	join
  endtask
  

  virtual task compare();
  forever begin
	expfifo.get(drv_tx);
	actualfifo.get(mon_tx);


//根据什么逻辑选择Master?


/*
if(drv_tx.M_AWADDR[0] inside {[32'h0000_0000:32'h0000_0FFF]} ) begin
	    if (mon_tx.S_WDATA[0] === drv_tx.M_WDATA[0]) 
`uvm_info("M0toS0_test_finished", {"Test: OK!"}, UVM_LOW);
      $display("-------------------------------------------------");
      $display("------ INFO : TEST CASE DATA PASSED ------------------");
      $display("-------------------------------------------------");
end else begin
		$display("mon_tx.S_WDATA: %d", mon_tx.S_RDATA[0]);
	  $display("drv_tx.M_WDATA: %d", drv_tx.M_WDATA[0]);
      $display("---------------------------------------------------");
      $display("------ ERROR : TEST CASE DATA FAILED ------------------");
      $display("---------------------------------------------------");
		`uvm_fatal("test_failed", {"ERROR : TEST CASE DATA FAILED "});
end

if(drv_tx.M_AWADDR[0] inside {[32'h0000_2000:32'h0000_2FFF]})begin
	    if (mon_tx.S_WDATA[1] === drv_tx.M_WDATA[0]) 
`uvm_info("M0toS1_test_finished", {"Test: OK!"}, UVM_LOW);
      $display("-------------------------------------------------");
      $display("------ INFO : TEST CASE DATA PASSED ------------------");
      $display("-------------------------------------------------");
end else begin
		$display("mon_tx.S_WDATA[1: %d", mon_tx.S_RDATA[1]);
	  $display("drv_tx.M_WDATA[0]: %d", drv_tx.M_WDATA[0]);
      $display("---------------------------------------------------");
      $display("------ ERROR : TEST CASE DATA FAILED ------------------");
      $display("---------------------------------------------------");
		`uvm_fatal("test_failed", {"ERROR : TEST CASE DATA FAILED "});
end



if(drv_tx.M_AWADDR[0] inside {[32'h0000_2000:32'h0000_2FFF]} ) begin
	    if (mon_tx.S_WDATA[2] === drv_tx.M_WDATA[0]) 
`uvm_info("M0toS2test_finished", {"Test: OK!"}, UVM_LOW);
      $display("-------------------------------------------------");
      $display("------ INFO : TEST CASE DATA PASSED ------------------");
      $display("-------------------------------------------------");
 end else begin
		$display("mon_tx.S_WDATA[2]: %d", mon_tx.S_RDATA[2]);
	  $display("drv_tx.M_WDATA[0]: %d", drv_tx.M_WDATA[0]);
      $display("---------------------------------------------------");
      $display("------ ERROR : TEST CASE DATA FAILED ------------------");
      $display("---------------------------------------------------");
		`uvm_fatal("test_failed", {"ERROR : TEST CASE DATA FAILED "});
    end

*/


/*
if (drv.tx.M_AWID == 2'b01) begin
  i = 1;
if(drv.tx.M_AWADDR[i] inside (32'h0000_2000:32'h0000_2FFF) begin
	    if (mon_tx.S_WDATA[0] === drv_tx.M_WDATA[i]) 
`uvm_info("test_finished", {"Test: OK!"}, UVM_LOW);
      $display("-------------------------------------------------");
      $display("------ INFO : TEST CASE DATA PASSED ------------------");
      $display("-------------------------------------------------");
 end else begin
		$display("mon_tx.RDATA: %d", mon_tx.RDATA);
	$display("drv_tx.WDATA: %d", drv_tx.WDATA);
      $display("---------------------------------------------------");
      $display("------ ERROR : TEST CASE DATA FAILED ------------------");
      $display("---------------------------------------------------");
		`uvm_fatal("test_failed", {"ERROR : TEST CASE DATA FAILED "});
    end
end


  else if (drv.tx.M_AWADDR[i] inside (32'h0000_2000:32'h0000_2FFF)
	    if (mon_tx.S_WDATA[1] === drv_tx.M_WDATA[i]) 
  else if (drv.tx.M_AWADDR[i] inside (32'h0000_4000:32'h0000_4FFF)
	    if (mon_tx.S_WDATA[2] === drv_tx.M_WDATA[i])       

case (drv.tx.M_RWID)
if(drv.tx.M_ARADDR[i] inside (32'h0000_0000:32'h0000_0FFF)
	    if (mon_tx.S_RDATA[0] === drv_tx.M_RDATA[i]) 
  else if (drv.tx.M_ARADDR[i] inside (32'h0000_2000:32'h0000_2FFF)
	    if (mon_tx.S_RDATA[1] === drv_tx.M_RDATA[i]) 
  else if (drv.tx.M_AWADDR[i] inside (32'h0000_4000:32'h0000_4FFF)
	    if (mon_tx.S_RDATA[2] === drv_tx.M_RDATA[i])    
  
  
  begin

      `uvm_info("test_finished", {"Test: OK!"}, UVM_LOW);
      $display("-------------------------------------------------");
      $display("------ INFO : TEST CASE DATA PASSED ------------------");
      $display("-------------------------------------------------");
    end else begin
		$display("mon_tx.RDATA: %d", mon_tx.RDATA);
	$display("drv_tx.WDATA: %d", drv_tx.WDATA);
      $display("---------------------------------------------------");
      $display("------ ERROR : TEST CASE DATA FAILED ------------------");
      $display("---------------------------------------------------");
		`uvm_fatal("test_failed", {"ERROR : TEST CASE DATA FAILED "});
    end
*/

	end
  endtask

endclass


