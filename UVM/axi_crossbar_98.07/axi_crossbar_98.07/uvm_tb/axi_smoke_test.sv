class axi_smoke_test extends axi_base_test;

  `uvm_component_utils(axi_smoke_test)

  axi_smoke_virtual_seq             axi_smoke_vseq;

  function new(string name = "axi_smoke_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    axi_smoke_vseq = axi_smoke_virtual_seq#(WIDTH, SIZE)::type_id::create("axi_smoke_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  axi_smoke_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

