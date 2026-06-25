class axi_environment #(
    int WIDTH = 32,
    SIZE = 3
) extends uvm_env;
  `uvm_component_param_utils(axi_environment#(WIDTH, SIZE))

  axi_m_agent #(WIDTH, SIZE) agent_m;
  axi_scoreboard #(WIDTH, SIZE) scoreboard;
  axi_virtual_sequencer                    v_sqr; 

  function new(string name = "axi_environment", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent_m = axi_m_agent#(WIDTH, SIZE)::type_id::create("agent_m", this);
    scoreboard = axi_scoreboard#(WIDTH, SIZE)::type_id::create("scoreboard", this);
    v_sqr=axi_virtual_sequencer::type_id::create("v_sqr",this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    agent_m.mon.mon2sb_port1.connect(scoreboard.mon2sb_export_mon);
    agent_m.drv.drv2sb_port1.connect(scoreboard.drv2sb_export_drv);
    agent_m.mon.mon2sb_port2.connect(scoreboard.mon2sb_export_mon);
    agent_m.drv.drv2sb_port2.connect(scoreboard.drv2sb_export_drv);

    uvm_config_db#(axi_m_sequencer)::set(this,"*","axi_sqr",agent_m.seq);
  endfunction : connect_phase
endclass



