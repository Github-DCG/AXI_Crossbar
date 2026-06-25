class axi_burst_test extends axi_base_test;

  `uvm_component_utils(axi_burst_test)

  axi_burst_virtual_seq             axi_burst_vseq;

  function new(string name = "axi_burst_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    axi_burst_vseq = axi_burst_virtual_seq#(`WIDTH, `SIZE)::type_id::create("axi_burst_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  axi_burst_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

