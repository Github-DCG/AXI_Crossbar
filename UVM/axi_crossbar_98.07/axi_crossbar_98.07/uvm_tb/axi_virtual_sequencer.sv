class axi_virtual_sequencer extends uvm_sequencer;
   `uvm_component_utils(axi_virtual_sequencer)

    axi_m_sequencer axi_sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
endclass

function void axi_virtual_sequencer::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (!uvm_config_db#(axi_m_sequencer)::get(this, "", "axi_sqr", axi_sqr))
        `uvm_fatal("VSQR/CFG/NOAHB", "No ahb_sqr specified for this instance");

endfunction
