class read_outstanding_test extends axi_base_test;

  `uvm_component_utils(read_outstanding_test)

  read_outstanding_virtual_seq             read_outstanding_vseq;

  function new(string name = "read_outstanding_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    read_outstanding_vseq = read_outstanding_virtual_seq#(WIDTH, SIZE)::type_id::create("read_outstanding_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  read_outstanding_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

