class cross_burst_write_test extends axi_base_test;

  `uvm_component_utils(cross_burst_write_test)

  cross_burst_write_virtual_seq             cross_burst_write_vseq;

  function new(string name = "cross_burst_write_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    cross_burst_write_vseq = cross_burst_write_virtual_seq#(WIDTH, SIZE)::type_id::create("cross_burst_write_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  cross_burst_write_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

