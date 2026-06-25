class random_burst_write_test extends axi_base_test;

  `uvm_component_utils(random_burst_write_test)

  random_burst_write_virtual_seq             random_burst_write_vseq;

  function new(string name = "random_burst_write_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    random_burst_write_vseq = random_burst_write_virtual_seq#(WIDTH, SIZE)::type_id::create("random_burst_write_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  random_burst_write_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

