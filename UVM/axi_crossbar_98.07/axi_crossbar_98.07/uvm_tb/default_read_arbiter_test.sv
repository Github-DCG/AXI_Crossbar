class default_read_arbiter_test extends axi_base_test;

  `uvm_component_utils(default_read_arbiter_test)

  default_read_arbiter_virtual_seq             default_read_arbiter_vseq;

  function new(string name = "default_read_arbiter_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    default_read_arbiter_vseq = default_read_arbiter_virtual_seq#(WIDTH, SIZE)::type_id::create("default_read_arbiter_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  default_read_arbiter_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

