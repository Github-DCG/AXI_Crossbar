class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)
     axi_environment axi_env;
    
    function new(string name="axi_base_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction //new()

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration();
    extern virtual function void report_phase(uvm_phase phase);

endclass 

function void axi_base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_env=axi_environment::type_id::create("axi_env",this);

endfunction

function void axi_base_test::end_of_elaboration();
	print();
endfunction 

// ---------------------------------------
//  end_of_elobaration phase
// ---------------------------------------   
function void axi_base_test::report_phase(uvm_phase phase);
	uvm_report_server svr;
	super.report_phase(phase);
   
   	svr = uvm_report_server::get_server();
   	if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) 
	begin
   		`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
   		`uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
   		`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
   	 end
   	 else 
	begin
   		`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
   		`uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
   		`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
   	 end
endfunction 
