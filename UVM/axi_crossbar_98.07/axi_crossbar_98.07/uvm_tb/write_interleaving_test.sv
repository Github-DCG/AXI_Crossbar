class write_interleaving_test extends axi_base_test;

  `uvm_component_utils(write_interleaving_test)

  write_interleaving_virtual_seq             write_interleaving_vseq;

  function new(string name = "write_interleaving_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    write_interleaving_vseq = write_interleaving_virtual_seq#(WIDTH, SIZE)::type_id::create("write_interleaving_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  write_interleaving_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

