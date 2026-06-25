class write_out_of_order_test extends axi_base_test;

  `uvm_component_utils(write_out_of_order_test)

  write_out_of_order_virtual_seq             write_out_of_order_vseq;

  function new(string name = "write_out_of_order_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    write_out_of_order_vseq = write_out_of_order_virtual_seq#(WIDTH, SIZE)::type_id::create("write_out_of_order_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  write_out_of_order_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

