class axi_m_sequencer #(
    int WIDTH = 32,
    int SIZE = 3
) extends uvm_sequencer#(axi_transaction#(WIDTH, SIZE));
  `uvm_component_param_utils(axi_m_sequencer#(WIDTH, SIZE))

  function new(string name = "axi_m_sequencer", uvm_component parent);
    super.new(name, parent);
    $display("inside axi m seqncr");
  endfunction : new
endclass



