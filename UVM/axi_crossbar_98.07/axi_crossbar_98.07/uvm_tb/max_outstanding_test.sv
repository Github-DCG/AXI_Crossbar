class max_outstanding_test extends axi_base_test;

  `uvm_component_utils(max_outstanding_test)

  max_outstanding_virtual_seq             max_outstanding_vseq;

  function new(string name = "max_outstanding_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    max_outstanding_vseq = max_outstanding_virtual_seq#(WIDTH, SIZE)::type_id::create("max_outstanding_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  max_outstanding_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

