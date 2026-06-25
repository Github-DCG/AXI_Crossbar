class read_incr_test extends axi_base_test;

  `uvm_component_utils(read_incr_test)

  read_incr_virtual_seq             read_incr_vseq;

  function new(string name = "read_incr_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    read_incr_vseq = read_incr_virtual_seq#(WIDTH, SIZE)::type_id::create("read_incr_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  read_incr_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

