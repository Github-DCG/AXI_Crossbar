class write_incr_test extends axi_base_test;

  `uvm_component_utils(write_incr_test)

  write_incr_virtual_seq             write_incr_vseq;

  function new(string name = "write_incr_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    write_incr_vseq = write_incr_virtual_seq#(WIDTH, SIZE)::type_id::create("write_incr_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  write_incr_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

