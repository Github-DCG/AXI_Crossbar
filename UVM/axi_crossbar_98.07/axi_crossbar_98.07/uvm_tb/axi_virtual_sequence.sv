class vseq_base extends uvm_sequence;
    
    `uvm_object_utils(vseq_base)
    `uvm_declare_p_sequencer(axi_virtual_sequencer)
    
    axi_m_sequencer             axi_sqr;
    
    function new(string name="vseq_base");
       super.new(name); 
    endfunction //new()

    extern virtual task body();
endclass //vseq_base extends uvm_sequence

class axi_smoke_virtual_seq extends vseq_base;
    `uvm_object_utils(axi_smoke_virtual_seq)

    function new(string name="axi_smoke_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass


class write_outstanding_virtual_seq extends vseq_base;
    `uvm_object_utils(write_outstanding_virtual_seq)

    function new(string name="write_outstanding_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass


class read_outstanding_virtual_seq extends vseq_base;
    `uvm_object_utils(read_outstanding_virtual_seq)

    function new(string name="read_outstanding_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

/*
class max_outstanding_virtual_seq extends vseq_base;
    `uvm_object_utils(max_outstanding_virtual_seq)

    function new(string name="max_outstanding_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass
*/
class write_incr_virtual_seq extends vseq_base;
    `uvm_object_utils(write_incr_virtual_seq)

    function new(string name="write_incr_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class read_incr_virtual_seq extends vseq_base;
    `uvm_object_utils(read_incr_virtual_seq)

    function new(string name="read_incr_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class write_out_of_order_virtual_seq extends vseq_base;
    `uvm_object_utils(write_out_of_order_virtual_seq)

    function new(string name="write_out_of_order_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass


class read_out_of_order_virtual_seq extends vseq_base;
    `uvm_object_utils(read_out_of_order_virtual_seq)

    function new(string name="read_out_of_order_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class write_interleaving_virtual_seq extends vseq_base;
    `uvm_object_utils(write_interleaving_virtual_seq)

    function new(string name="write_interleaving_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class read_interleaving_virtual_seq extends vseq_base;
    `uvm_object_utils(read_interleaving_virtual_seq)

    function new(string name="read_interleaving_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class random_burst_write_virtual_seq extends vseq_base;
    `uvm_object_utils(random_burst_write_virtual_seq)

    function new(string name="random_burst_write_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class burst_write_virtual_seq extends vseq_base;
    `uvm_object_utils(burst_write_virtual_seq)

    function new(string name="burst_write_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class cross_burst_write_virtual_seq extends vseq_base;
    `uvm_object_utils(cross_burst_write_virtual_seq)

    function new(string name="cross_burst_write_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class cross_burst_read_virtual_seq extends vseq_base;
    `uvm_object_utils(cross_burst_read_virtual_seq)

    function new(string name="cross_burst_read_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class cross_write_s0_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(cross_write_s0_arbiter_virtual_seq)

    function new(string name="cross_write_s0_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class cross_write_s1_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(cross_write_s1_arbiter_virtual_seq)

    function new(string name="cross_write_s1_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class cross_write_s2_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(cross_write_s2_arbiter_virtual_seq)

    function new(string name="cross_write_s2_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass


class cross_read_S_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(cross_read_S_arbiter_virtual_seq)

    function new(string name="cross_read_S_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class m_to_s0_write_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(m_to_s0_write_arbiter_virtual_seq)

    function new(string name="m_to_s0_write_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class m_to_s1_write_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(m_to_s1_write_arbiter_virtual_seq)

    function new(string name="m_to_s1_write_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class m_to_s2_write_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(m_to_s2_write_arbiter_virtual_seq)

    function new(string name="m_to_s2_write_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class m_to_s_read_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(m_to_s_read_arbiter_virtual_seq)

    function new(string name="m_to_s_read_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class Mx_to_s_read_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(Mx_to_s_read_arbiter_virtual_seq)

    function new(string name="Mx_to_s_read_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class Mx_to_s_write_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(Mx_to_s_write_arbiter_virtual_seq)

    function new(string name="Mx_to_s_write_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class default_read_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(default_read_arbiter_virtual_seq)

    function new(string name="default_read_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class default_write_arbiter_virtual_seq extends vseq_base;
    `uvm_object_utils(default_write_arbiter_virtual_seq)

    function new(string name="default_write_arbiter_virtual_seq");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass


task vseq_base::body();
     axi_sqr=p_sequencer.axi_sqr;
endtask

task axi_smoke_virtual_seq::body();                               
    axi_smoke_sequence    axi_seq;
    super.body();
    `uvm_info("axi_smoke_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("axi_smoke_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task write_outstanding_virtual_seq::body();                               
    write_outstanding_sequence    axi_seq;
    super.body();
    `uvm_info("write_outstanding_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("write_outstanding_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task read_outstanding_virtual_seq::body();                               
    read_outstanding_sequence    axi_seq;
    super.body();
    `uvm_info("read_outstanding_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("read_outstanding_virtual_seq", "Sequence complete", UVM_HIGH)
endtask
/*
task max_outstanding_virtual_seq::body();                               
    max_outstanding_sequence    axi_seq;
    super.body();
    `uvm_info("max_outstanding_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("max_outstanding_virtual_seq", "Sequence complete", UVM_HIGH)
endtask
*/

task write_incr_virtual_seq::body();                               
    write_incr_sequence    axi_seq;
    super.body();
    `uvm_info("write_incr_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("write_incr_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task read_incr_virtual_seq::body();                               
    read_incr_sequence    axi_seq;
    super.body();
    `uvm_info("read_incr_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("read_incr_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task write_out_of_order_virtual_seq::body();                               
    write_out_of_order_sequence    axi_seq;
    super.body();
    `uvm_info("write_out_of_order_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("write_out_of_order_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task read_out_of_order_virtual_seq::body();                               
    read_out_of_order_sequence    axi_seq;
    super.body();
    `uvm_info("read_out_of_order_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("read_out_of_order_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task write_interleaving_virtual_seq::body();                               
    write_interleaving_sequence    axi_seq;
    super.body();
    `uvm_info("write_interleaving_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("write_interleaving_virtual_seq", "Sequence complete", UVM_HIGH)
endtask
task read_interleaving_virtual_seq::body();                               
    read_interleaving_sequence    axi_seq;
    super.body();
    `uvm_info("read_interleaving_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("read_interleaving_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task random_burst_write_virtual_seq::body();                               
     random_burst_write_sequence    axi_seq;
    super.body();
    `uvm_info("random_burst_write_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("random_burst_write_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task burst_write_virtual_seq::body();                               
     burst_write_sequence    axi_seq;
    super.body();
    `uvm_info("burst_write_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("burst_write_virtual_seq", "Sequence complete", UVM_HIGH)
endtask


task cross_burst_write_virtual_seq::body();                               
     cross_burst_write_sequence    axi_seq;
    super.body();
    `uvm_info("cross_burst_write_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("cross_burst_write_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task cross_burst_read_virtual_seq::body();                               
     cross_burst_read_sequence    axi_seq;
    super.body();
    `uvm_info("cross_burst_read_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("cross_burst_read_virtual_seq", "Sequence complete", UVM_HIGH)
endtask


task cross_write_s0_arbiter_virtual_seq::body();                               
     cross_write_s0_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("cross_write_s0_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("cross_write_s0_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask


task cross_write_s1_arbiter_virtual_seq::body();                               
     cross_write_s1_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("cross_write_s1_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("cross_write_s1_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task cross_write_s2_arbiter_virtual_seq::body();                               
     cross_write_s2_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("cross_write_s2_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("cross_write_s2_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task cross_read_S_arbiter_virtual_seq::body();                               
     cross_read_S_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("cross_read_S_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("cross_read_S_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task m_to_s0_write_arbiter_virtual_seq::body();                               
     m_to_s0_write_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("m_to_s0_write_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("m_to_s0_write_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task m_to_s1_write_arbiter_virtual_seq::body();                               
     m_to_s1_write_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("m_to_s1_write_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("m_to_s1_write_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task m_to_s2_write_arbiter_virtual_seq::body();                               
     m_to_s2_write_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("m_to_s2_write_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("m_to_s2_write_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task m_to_s_read_arbiter_virtual_seq::body();                               
     m_to_s_read_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("m_to_s_read_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("m_to_s_read_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task Mx_to_s_read_arbiter_virtual_seq::body();                               
     Mx_to_s_read_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("Mx_to_s_read_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("Mx_to_s_read_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task Mx_to_s_write_arbiter_virtual_seq::body();                               
     Mx_to_s_write_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("Mx_to_s_write_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("Mx_to_s_write_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask


task default_read_arbiter_virtual_seq::body();                               
     default_read_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("default_read_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("default_read_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

task default_write_arbiter_virtual_seq::body();                               
     default_write_arbiter_sequence    axi_seq;
    super.body();
    `uvm_info("default_write_arbiter_virtual_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(axi_seq,  axi_sqr)
    `uvm_info("default_write_arbiter_virtual_seq", "Sequence complete", UVM_HIGH)
endtask

