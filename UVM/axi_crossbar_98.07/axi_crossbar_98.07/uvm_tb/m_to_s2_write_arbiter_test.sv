class m_to_s2_write_arbiter_test extends axi_base_test;

  `uvm_component_utils(m_to_s2_write_arbiter_test)

  m_to_s2_write_arbiter_virtual_seq             m_to_s2_write_arbiter_vseq;

  function new(string name = "m_to_s2_write_arbiter_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("HR:: AXI Test is Here");

    m_to_s2_write_arbiter_vseq = m_to_s2_write_arbiter_virtual_seq#(WIDTH, SIZE)::type_id::create("m_to_s2_write_arbiter_vseq", this);
	
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	  m_to_s2_write_arbiter_vseq.start(axi_env.v_sqr);
    phase.drop_objection(this);
  endtask

endclass

