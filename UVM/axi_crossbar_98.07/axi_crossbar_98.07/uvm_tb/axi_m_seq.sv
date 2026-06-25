class axi_smoke_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(axi_smoke_sequence#(WIDTH, SIZE))

integer i = 0 ;
  function new(string name = "axi_smoke_sequence");
    super.new(name);
  endfunction

  
  virtual task body();
  #12;
 // waddr phase 
  begin  //mst0 to slv0  write
   `uvm_create(req)
	    req.M_AWVALID[i] <= 1'b1;     req.M_WVALID[i] <= 1'b0;
      req.RW<=0;req.M_AWID[i]<=4'b0100;req.M_AWADDR[i] <= 32'h0000_0FFF;req.M_AWLEN[i] <= 8'h0;req.M_AWSIZE[i]<=3'b101;req.M_AWBURST[i] <= 2'b01;
	    `uvm_send(req)
  end
  begin  //mst0 to slv0
   `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;     req.M_WVALID[i] <= 1'b1;    req.M_WLAST[i] <= 1'b1;
      req.RW<=0;req.M_WID[i]<=4'b0100;req.M_WDATA[i]<=32'h0011;req.M_WSTRB[i]<='b1111;
      req.S_BID    [i] <= 8'b0101_0100;  req.S_BVALID[i] <= 1'b1;  req.S_BRESP[i] <= 2'b00;   //B for M0
  `uvm_send(req)  
  end
#10;

  endtask

endclass


class write_outstanding_sequence #(             //m1 to s1                         
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(write_outstanding_sequence#(WIDTH, SIZE))

  integer i = 1 ;
  integer j;
  function new(string name = " write_outstanding_sequence");
    super.new(name);
  endfunction

  virtual task body();

    #12;
    set_response_queue_depth(4096);
    `uvm_create(req)
    req.S_AWREADY[0] <= 1'b0; //awready 0
    req.S_WREADY[0]  <= 1'b0; //wready  0
    req.M_BREADY[0]  <= 1'b0; //bready  0
    `uvm_send(req)
  //m1 to s1 
  for (i = 0; i <= 2; i++) begin
    for (j = 0; j < 8; j++) begin //awaddr-phase
        `uvm_create(req)
        req.M_AWVALID[i] <= 1'b1;
        req.M_WVALID[i] <= 1'b0;
        req.S_AWREADY[0] <= 1'b0; //awready 0
        req.S_WREADY[0]  <= 1'b0; //wready  0
        req.M_BREADY[0]  <= 1'b0; //bready  0

        req.RW<=0;req.M_AWID[i][3:2]<=2'b01+i; req.M_AWID[i][1:0]<=2'b01;
        req.M_AWADDR[i] <= (32'h0000_00a1+j+i*32'h2000);req.M_AWLEN[i] <= 8'h0;
        req.M_AWSIZE[i]<=3'b101;req.M_AWBURST[i] <= 2'b01;
        `uvm_send(req)
      end
      #12;

      for (j = 0; j < 8; j++) begin //wdata-phase, bresp-phase
        `uvm_create(req)
        req.M_AWVALID[i] <= 1'b0;
        req.M_WVALID[i] <= 1'b1;
        req.M_WLAST[i] <= 1'b1;
        req.S_AWREADY[0] <= 1'b1; //awready 1
        req.S_WREADY[0]  <= 1'b0; //wready  0
        req.M_BREADY[0]  <= 1'b0; //bready  0

        req.RW<=0;req.M_WID[i][3:2]<=2'b01+i;req.M_WID[i][1:0]<=2'b01;
        req.M_WDATA[i]<=(32'h00d0+j);req.M_WSTRB[i]<='b1111;
  
        req.S_BID[i][7:6] <= 2'b01+i; req.S_BID[i][5:4] <= 2'b01+i; 
        req.S_BID[i][3:2] <= 2'b01+i; req.S_BID[i][1:0] <= 2'b01; 
        req.S_BVALID[i] <= 1'b1;
        req.S_BRESP[i]  <= 2'b00;
      `uvm_send(req)
    end
    #12;
    `uvm_create(req)
    req.S_AWREADY[0] <= 1'b1; //awready 1
    req.S_WREADY[0]  <= 1'b1; //wready  1
    req.M_BREADY[0]  <= 1'b1; //bready  1
    `uvm_send(req)
    #360;
  end //for (i = 0; i <= 2; i++)
    
  endtask
endclass


//Test mst x to slv x while stall.
class read_outstanding_sequence #( //slv0 1 2 to mst0 1 2                 
    WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(read_outstanding_sequence#(WIDTH, SIZE))

  integer i = 0 ;
  integer j;
  function new(string name = " read_outstanding_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
     `uvm_create(req)
      req.S_ARREADY[0] <= 1'b0; //arready 0
      req.M_RREADY[0]   <= 1'b0; //rready  0
	    `uvm_send(req)
    //i 2 i
    for (i = 0; i <= 2; i++) begin
      for (j = 0; j < 8; j++) begin    //slv0 to mst0 
        `uvm_create(req)
          req.S_ARREADY[0] <= 1'b0; //arready 0
          req.M_RREADY[0]   <= 1'b0; //rready  0
          req.M_ARVALID[i] <= 1'b1;
          req.M_RVALID[i] <= 1'b0;

          req.RW<=1;req.M_ARID[i]<=4'b0001;req.M_ARADDR[i] <= (32'h0000_00a1+j+i*32'h2000);req.M_ARLEN[i] <= 8'h0;req.M_ARSIZE[i]<=3'b101;req.M_ARBURST[i] <= 2'b01;
          `uvm_send(req)
        end
        #12;

        for (j = 0; j < 8; j++) begin 
          `uvm_create(req)
          req.S_ARVALID[i] <= 1'b0;
          req.S_ARREADY[0] <= 1'b1; //arready 1
          req.M_RREADY[0]   <= 1'b0; //rready  0
          req.S_RVALID[i] <= 1'b1;
          req.S_RLAST[i] <= 1'b1;
          req.S_RRESP[i]  <=2'b00;
          req.RW<=1;req.S_RID[i][7:6]<=2'b01+i; req.S_RID[i][5:4]<=2'b01+i; req.S_RID[i][3:0]<=4'b0001;req.S_RDATA[i]<=(32'h00d1+j);
          `uvm_send(req)  //Read sequence
        end
        #4;
        `uvm_create(req)
        req.S_ARREADY[0] <= 1'b1; //arready 1
        req.M_RREADY[0]   <= 1'b1; //rready  1
        `uvm_send(req)  //Read sequence
        #40;
    end //for (i = 0; i <= 2; i++)
    
  endtask
endclass
/*
class max_outstanding_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(max_outstanding_sequence#(WIDTH, SIZE))

  integer i = 0 ;
  integer j;
  function new(string name = " max_outstanding_sequence");
    super.new(name);
  endfunction

  virtual task body();

   
    set_response_queue_depth(4096);

    for (j = 0; j < 10; j++) begin 
      `uvm_create(req)
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.RW<=0;req.M_AWID[i]<=4'b0101;req.M_AWADDR[i] <= (32'h0000_00a1+j);req.M_AWLEN[i]<= 8'h3;req.M_AWSIZE[i]<=3'b101;req.M_AWBURST[i]<= 2'b01;
	    `uvm_send(req)
    end
    #4;
  endtask
endclass
*/

class write_incr_sequence #(                    //m0 to s1                 
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(write_incr_sequence#(WIDTH, SIZE))

  integer i = 0 ;
  integer j;
  integer k = 1 ;
  function new(string name = " write_incr_sequence");
    super.new(name);
  endfunction

  virtual task body();

    #12;
    set_response_queue_depth(4096);
   
//mst0 to slv1
    begin 
    `uvm_create(req)
     req.RW<=0;
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.RW <= 0;req.M_AWID[i] <= 4'b1001;req.M_AWADDR[i]  <=  32'h0000_20a0;req.M_AWLEN[i]  <=  8'h3;req.M_AWSIZE[i] <= 3'b101;req.M_AWBURST[i]  <=  2'b01;
	    `uvm_send(req)
    end

    for (j = 0; j < 3; j++) begin 
      `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      req.RW<=0;req.M_WID[i]<=4'b1001;req.M_WSTRB[i]<='b1111;
       req.M_WDATA[i]<=(32'd0+j);
      `uvm_send(req)  //Read sequence
    end

    begin 
      `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.M_WID[i]<=4'b1001;req.M_WDATA[i]<=(32'd255);req.M_WSTRB[i]<='b1111;
      req.S_BID  [k]  <= 8'b1001_1001;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_send(req) 
    end
  
    
    #20;
  endtask
endclass



class read_incr_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(read_incr_sequence#(WIDTH, SIZE))

  integer i = 2 ;
  integer j;
  function new(string name = "read_incr_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
    
//mst2 to slv2
  begin
     `uvm_create(req)
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
      req.M_ARID[i] <= 4'b0001;req.M_ARADDR[i]<=32'h0000_40a0;req.M_ARLEN[i] <= 8'h3;req.M_ARSIZE[i] <= 3'b101;req.M_ARBURST[i]  <=  2'b01;
	    `uvm_send(req)
  end 
   //Read sequence
  for (j = 0; j < 3; j++) begin 
`uvm_create(req)
      req.S_ARVALID[i]<= 1'b0;
      req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]  <= 1'b0;
      req.S_RRESP[i]  <= 2'b00;
      req.S_RID[i]    <= 8'b1111_0001;
      req.S_RDATA[i]  <= (32'd0+j) ;
      `uvm_send(req)
 end 
   begin
     `uvm_create(req)
      req.S_ARVALID[i]<= 1'b0;
      req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]  <= 1'b1;
      req.S_RRESP[i]  <= 2'b00;
      req.S_RID[i]    <= 8'b1111_0001;
      req.S_RDATA[i]  <= 32'd255;
      `uvm_send(req)  //Read sequence
   end

  #10;
  endtask

endclass




class write_out_of_order_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(write_out_of_order_sequence#(WIDTH, SIZE))

  integer i = 0 ;
  integer j = 1 ;
  function new(string name = " write_out_of_order_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);

// waddr phase -different M_AWID

    begin //m0 to s0
     `uvm_create(req)
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.RW<=0;req.M_AWID[i]<=4'b0100;req.M_AWADDR[i] <= 32'h0000_00a1;req.M_AWLEN[i] <= 8'h1;req.M_AWSIZE[i]<=3'b101;req.M_AWBURST[i] <= 2'b01;
	   `uvm_send(req)
    end

    begin //m1 to s0
     `uvm_create(req)
	    req.M_AWVALID[j] <= 1'b1;
	    req.M_WVALID[j] <= 1'b0;
      req.RW<=0;req.M_AWID[j]<=4'b0101;req.M_AWADDR[j] <= 32'h0000_00a2;req.M_AWLEN[j] <= 8'h1;req.M_AWSIZE[j]<=3'b101;req.M_AWBURST[j] <= 2'b01;
	    `uvm_send(req)
    end 


 // wdata phase 
 
    begin   //m1 to s0
     `uvm_create(req)
      req.M_AWVALID[j] <= 1'b0;   req.M_WVALID[j] <= 1'b1;     req.M_WLAST[j] <= 1'b0;
      req.RW<=0;                  req.M_WID[j]    <=4'b0101;   req.M_WDATA[j] <=32'h10d3;    req.M_WSTRB[j]<='b1111;
      `uvm_send(req)  //Read sequence
    end

    //m1 to s0

  begin
     `uvm_create(req)
    req.M_AWVALID[j] <= 1'b0;   req.M_WVALID[j] <= 1'b1;    req.M_WLAST[j] <= 1'b1; 
    req.RW<=0;                  req.M_WID[j]    <=4'b0101;  req.M_WDATA[j]<=32'h10d4;   req.M_WSTRB[j]<='b1111;
    `uvm_send(req)
  end

  begin
    `uvm_create(req)
    req.S_BID [i] <= 8'b0110_0101;   req.S_BVALID[i] <= 1'b1;    req.S_BRESP[i] <= 2'b00;   //S0 B for M1
    `uvm_send(req)
  end
   
  begin   //m0 to s0
  `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;     req.M_WVALID[i] <= 1'b1;       req.M_WLAST[i] <= 1'b0;
      req.RW  <=  0;                req.M_WID[i]    <= 4'b0100;    req.M_WDATA[i] <=  32'h00d1;   req.M_WSTRB[i]<='b1111;
  `uvm_send(req)  //Read sequence
  end

  begin   //m0 to s0
  `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;     req.M_WVALID[i] <= 1'b1;        req.M_WLAST[i] <= 1'b1;  
      req.RW <= 0;                  req.M_WID[i]   <=  4'b0100;     req.M_WDATA[i] <=32'h00d2;    req.M_WSTRB[i]<='b1111;
  `uvm_send(req)
  end

  begin
  `uvm_create(req)
      req.S_BID   [i]  <= 8'b0101_0100;   req.S_BVALID[i] <= 1'b1;        req.S_BRESP[i] <= 2'b00;   //S0 B for M0
  `uvm_send(req)
end

// waddr phase -same M_AWID
  begin //m0 to s0
    `uvm_create(req)
	    req.M_AWVALID[i] <= 1'b1;           req.M_WVALID[i] <= 1'b0;
      req.RW<=0;req.M_AWID[i]<=4'b0100;   req.M_AWADDR[i] <= 32'h0000_00a1;  req.M_AWLEN[i] <= 8'h1;  req.M_AWSIZE[i]<=3'b101;  req.M_AWBURST[i] <= 2'b01;
	  `uvm_send(req)
  end  

  begin //m1 to s0
    `uvm_create(req)
	    req.M_AWVALID[j] <= 1'b1;           req.M_WVALID[j] <= 1'b0;
      req.RW<=0;req.M_AWID[j]<=4'b0100;   req.M_AWADDR[j] <= 32'h0000_00a2;  req.M_AWLEN[j] <= 8'h1;  req.M_AWSIZE[j]<=3'b101;   req.M_AWBURST[j] <= 2'b01;
	  `uvm_send(req)
    end
// wdata phase 
  begin   //m1 to s0
    `uvm_create(req)
      req.M_AWVALID[j] <= 1'b0;           req.M_WVALID[j] <= 1'b1;      req.M_WLAST[j] <= 1'b0;
      req.RW<=0;req.M_WID[j]<=4'b0100;    req.M_WDATA[j]<=32'h10d3;     req.M_WSTRB[j]<='b1111;
    `uvm_send(req)  //Read sequence
  end

  begin   //m1 to s0
    `uvm_create(req)
      req.M_AWVALID[j] <= 1'b0;         req.M_WVALID[j] <= 1'b1;    req.M_WLAST[j] <= 1'b1;
      req.RW<=0;req.M_WID[j]<=4'b0100;  req.M_WDATA[j]  <=32'h10d4; req.M_WSTRB[j]<='b1111;
    `uvm_send(req) 
    end

  begin   //m0 to s0
    `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;           req.M_WVALID[i] <= 1'b1;        req.M_WLAST[i] <= 1'b0;
      req.RW<=0;req.M_WID[i]<=4'b0100;    req.M_WDATA[i]  <=  32'h00d1;   req.M_WSTRB[i] <='b1111;
    `uvm_send(req)  //Read sequence
  end

  begin   //m0 to s0
    `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;           req.M_WVALID[i] <= 1'b1;    req.M_WLAST[i] <= 1'b1;
      req.RW<=0;req.M_WID[i]<=4'b0100;    req.M_WDATA[i]<=32'h00d2;   req.M_WSTRB[i]<='b1111;    
    `uvm_send(req)  //Read sequence
  end

  begin   //m0 to s0
  `uvm_create(req)
    req.S_BID  [i]  <= 8'b0101_0100;  req.S_BVALID[i] <= 1'b1;  req.S_BRESP[i]  <= 2'b00;   //S0 B for M0
  `uvm_send(req)  //Read sequence
  end
  begin
    `uvm_create(req)
    req.S_BID [i] <= 8'b0110_0101;   req.S_BVALID[i] <= 1'b1;    req.S_BRESP[i] <= 2'b00;   //S0 B for M1
    `uvm_send(req)
  end

#20; 
  endtask

endclass


class read_out_of_order_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(read_out_of_order_sequence#(WIDTH, SIZE))

  integer i = 0;
  integer j = 1;
  function new(string name = " read_out_of_order_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);

//raddr phase -diffreent M_ARID
  begin  //m0 to s0 
    `uvm_create(req)
      req.RW <= 1;       
      req.M_ARVALID[i] <= 1'b1;     req.M_RVALID[i] <= 1'b0;
      req.M_ARID[i]    <= 4'b0001;  req.M_ARADDR[i] <= 32'h0000_00a1;   req.M_ARLEN[i]<=8'h1;   req.M_ARSIZE[i]<=3'b101;  req.M_ARBURST[i]<=2'b01;
    `uvm_send(req)
  end 

  begin //m0 to s1
    `uvm_create(req)
      req.RW <= 1;      
      req.M_ARVALID[i] <= 1'b1;      req.M_RVALID[i] <= 1'b0; 
      req.M_ARID[i]    <= 4'b0010;   req.M_ARADDR[i] <= 32'h0000_20a2;  req.M_ARLEN[i]<=8'h1;   req.M_ARSIZE[i]<=3'b101;  req.M_ARBURST[i]<=2'b01;
    `uvm_send(req)
  end 

//rdata phase
  begin //s1 to m0
    `uvm_create(req)
      req.RW<=1;
      req.S_ARVALID[j] <= 1'b0;           req.S_RVALID[j] <= 1'b1;
      req.S_RLAST[j]   <= 1'b0;           req.S_RRESP[j]  <= 2'b00;
      req.S_RID[j]     <= 8'b1001_0010;   req.S_RDATA[j]  <= 32'h10d3;
    `uvm_send(req)  //Read sequence
  end

  begin //s1 to m0 
    `uvm_create(req)
      req.RW<=1;
      req.S_ARVALID[j] <= 1'b0;           req.S_RVALID[j] <= 1'b1;
      req.S_RLAST[j]   <= 1'b1;           req.S_RRESP[j]  <= 2'b00;
      req.S_RID[j]     <= 8'b1001_0010;   req.S_RDATA[j]  <= 32'h10d4;
    `uvm_send(req)  //Read sequence
  end

  begin //s0 to m0 
   `uvm_create(req)
      req.RW<=1;
      req.S_ARVALID[i] <= 1'b0;          req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]   <= 1'b0;          req.S_RRESP[i]  <= 2'b00;
      req.S_RID[i]     <= 8'b0101_0001;  req.S_RDATA[i]  <= 32'h00d1;
    `uvm_send(req)  //Read sequence
  end

  begin //s0 to m0 
    `uvm_create(req)
      req.RW<=1;
      req.S_ARVALID[i] <= 1'b0;         req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]   <= 1'b1;         req.S_RRESP[i]  <= 2'b00;
      req.S_RID[i]     <= 8'b0101_0001; req.S_RDATA[i]  <= 32'h00d2;
    `uvm_send(req)  //Read sequence
  end

//raddr phase -same M_ARID
  begin  //m0 to s0 
    `uvm_create(req)
      req.RW <= 1;       
      req.M_ARVALID[i] <= 1'b1;       req.M_RVALID[i] <= 1'b0;
      req.M_ARID[i]    <=4'b0001;     req.M_ARADDR[i] <= 32'h0000_00a3;  req.M_ARLEN[i]<=8'h1;  req.M_ARSIZE[i]<=3'b101;  req.M_ARBURST[i]<=2'b01;
    `uvm_send(req)
  end 

  begin //m0 to s1
    `uvm_create(req)
      req.RW <= 1;       
      req.M_ARVALID[i] <= 1'b1;       req.M_RVALID[i] <= 1'b0; 
      req.M_ARID[i]    <= 4'b0001;    req.M_ARADDR[i] <= 32'h0000_20a4;  req.M_ARLEN[i]<=8'h1;  req.M_ARSIZE[i]<=3'b101;  req.M_ARBURST[i]<=2'b01;
    `uvm_send(req)
  end 

//rdata phase
  begin //s1 to m0
    `uvm_create(req)
      req.RW<=1;
      req.S_ARVALID[j] <= 1'b0;           req.S_RVALID[j] <= 1'b1;
      req.S_RLAST[j]   <= 1'b0;           req.S_RRESP[j]  <= 2'b00;
      req.S_RID[j]     <= 8'b1001_0001;   req.S_RDATA[j]  <= 32'h10d3;
    `uvm_send(req)  //Read sequence
  end
  begin //s1 to m0 
   `uvm_create(req)
      req.RW<=1;
      req.S_ARVALID[j] <= 1'b0;           req.S_RVALID[j] <= 1'b1;
      req.S_RLAST[j]   <= 1'b1;           req.S_RRESP[j]  <= 2'b00;
      req.S_RID[j]     <= 8'b1001_0001;   req.S_RDATA[j]  <= 32'h10d4;
      `uvm_send(req)  //Read sequence
  end

  begin //s0 to m0 
   `uvm_create(req)
    req.RW<=1;
      req.S_ARVALID[i] <= 1'b0;           req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]   <= 1'b0;           req.S_RRESP[i]  <= 2'b00;
      req.S_RID[i]     <= 8'b0101_0001;   req.S_RDATA[i]  <= 32'h00d1;
    `uvm_send(req)  //Read sequence
  end

  begin //s0 to m0 
   `uvm_create(req)
      req.RW<=1;
      req.S_ARVALID[i] <= 1'b0;           req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]   <= 1'b1;           req.S_RRESP[i]  <= 2'b00;
      req.S_RID[i]     <= 8'b0101_0001;   req.S_RDATA[i]  <= 32'h00d2;
   `uvm_send(req)  //Read sequence
  end

 #20;
  endtask

endclass



class write_interleaving_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(write_interleaving_sequence#(WIDTH, SIZE))

  integer i = 0 ;
  integer j= 1;
  function new(string name = " write_interleaving_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    `uvm_create(req)

    set_response_queue_depth(4096);

// waddr phase -different M_ARID
  begin  //mst0 to slv0
   `uvm_create(req)
	    req.M_AWVALID[i] <= 1'b1;     req.M_WVALID[i] <= 1'b0;
      req.RW<=0;req.M_AWID[i]<=4'b0100;req.M_AWADDR[i] <= 32'h0000_00a1;req.M_AWLEN[i] <= 8'h1;req.M_AWSIZE[i]<=3'b101;req.M_AWBURST[i] <= 2'b01;
	    `uvm_send(req)
  end

  begin  //mst1 to slv0
   `uvm_create(req)
      req.M_AWVALID[j] <= 1'b1;     req.M_WVALID[j] <= 1'b0;
      req.RW<=0;req.M_AWID[j]<=4'b0101;req.M_AWADDR[j] <= 32'h0000_00a2;req.M_AWLEN[j] <= 8'h1;req.M_AWSIZE[j]<=3'b101;req.M_AWBURST[j] <= 2'b01;
    	`uvm_send(req)
  end
//wdata phase
  begin  //mst1 to slv0
   `uvm_create(req)
      req.M_AWVALID[j] <= 1'b0;     req.M_WVALID[j] <= 1'b1;    req.M_WLAST[j] <= 1'b0;
      req.RW<=0;req.M_WID[j]<=4'b0101;req.M_WDATA[j]<=32'h10d3;req.M_WSTRB[j]<='b1111;
      `uvm_send(req)  //Read sequence
  end
  begin  //mst0 to slv0
   `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;     req.M_WVALID[i] <= 1'b1;    req.M_WLAST[i] <= 1'b0;
      req.RW<=0;req.M_WID[i]<=4'b0100;req.M_WDATA[i]<=32'h00d1;req.M_WSTRB[i]<='b1111;
      `uvm_send(req)  //Read sequence
  end
  begin  //mst1 to slv0
   `uvm_create(req)
      req.M_AWVALID[j] <= 1'b0;          req.M_WVALID[j] <= 1'b1;  req.M_WLAST[j] <= 1'b1;
    
      req.RW<=0;req.M_WID[j]<=4'b0101;req.M_WDATA[j]<=32'h10d4;req.M_WSTRB[j]<='b1111;
      `uvm_send(req)  //Read sequence
  end



  begin  //mst0 t1 slv0
   `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;          req.M_WVALID[i] <= 1'b1;  req.M_WLAST[i] <= 1'b1;

      req.RW<=0;req.M_WID[i]<=4'b0100;req.M_WDATA[i]<=32'h00d2;req.M_WSTRB[i]<='b1111;
      `uvm_send(req)  //Read sequence
  end

    begin  //mst1 to slv0
   `uvm_create(req)
     req.S_BID    [i] <= 8'b0110_0101;  req.S_BVALID[i] <= 1'b1;  req.S_BRESP[i] <= 2'b00;   //B for M1
         `uvm_send(req)  //Read sequence
  end

    begin  //mst0 t1 slv0
   `uvm_create(req)
      req.S_BID    [i] <= 8'b0101_0100;  req.S_BVALID[i] <= 1'b1;  req.S_BRESP[i] <= 2'b00;   //B for M0
            `uvm_send(req)  //Read sequence
  end
  // waddr phase -Same M_ARID
  begin  //mst0 to slv0
   `uvm_create(req)
	    req.M_AWVALID[i] <= 1'b1;     req.M_WVALID[i] <= 1'b0;
      req.RW<=0;req.M_AWID[i]<=4'b0100;req.M_AWADDR[i] <= 32'h0000_00a1;req.M_AWLEN[i] <= 8'h1;req.M_AWSIZE[i]<=3'b101;req.M_AWBURST[i] <= 2'b01;
	    `uvm_send(req)
  end
  begin  //mst1 to slv0
   `uvm_create(req)
      req.M_AWVALID[j] <= 1'b1;     req.M_WVALID[j] <= 1'b0;
      req.RW<=0;req.M_AWID[j]<=4'b0100;req.M_AWADDR[j] <= 32'h0000_00a2;req.M_AWLEN[j] <= 8'h1;req.M_AWSIZE[j]<=3'b101;req.M_AWBURST[j] <= 2'b01;
    	`uvm_send(req)
  end

//wdata phase
  begin  //mst1 to slv0
   `uvm_create(req)
      req.M_AWVALID[j] <= 1'b0;     req.M_WVALID[j] <= 1'b1;    req.M_WLAST[j] <= 1'b0;
      req.RW<=0;req.M_WID[j]<=4'b0100;req.M_WDATA[j]<=32'h10d3;req.M_WSTRB[j]<='b1111;
      `uvm_send(req)  //Read sequence
  end
  begin  //mst0 to slv0
   `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;     req.M_WVALID[i] <= 1'b1;    req.M_WLAST[i] <= 1'b0;
      req.RW<=0;req.M_WID[i]<=4'b0100;req.M_WDATA[i]<=32'h00d1;req.M_WSTRB[i]<='b1111;
      `uvm_send(req)  //Read sequence
  end
  begin  //mst1 to slv0
   `uvm_create(req)
      req.M_AWVALID[j] <= 1'b0;          req.M_WVALID[j] <= 1'b1;  req.M_WLAST[j] <= 1'b1;

      req.RW<=0;req.M_WID[j]<=4'b0100;req.M_WDATA[j]<=32'h10d4;req.M_WSTRB[j]<='b1111;
      `uvm_send(req)  //Read sequence
  end



  begin  //mst0 t1 slv0
   `uvm_create(req)
      req.M_AWVALID[i] <= 1'b0;          req.M_WVALID[i] <= 1'b1;  req.M_WLAST[i] <= 1'b1;

      req.RW<=0;req.M_WID[i]<=4'b0100;req.M_WDATA[i]<=32'h00d2;req.M_WSTRB[i]<='b1111;
      `uvm_send(req)  //Read sequence
  end
    begin  //mst1 to slv0
   `uvm_create(req)
      req.S_BID    [i] <= 8'b0110_0100;  req.S_BVALID[i] <= 1'b1;  req.S_BRESP[i] <= 2'b00;   //B for M1
      `uvm_send(req)  //Read sequence
  end
  
  begin  //mst0 t1 slv0
   `uvm_create(req)
      req.S_BID    [i] <= 8'b0101_0100;  req.S_BVALID[i] <= 1'b1;  req.S_BRESP[i] <= 2'b00;   //B for M0
      `uvm_send(req)  //Read sequence
  end

    #20;
  endtask

endclass


class read_interleaving_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(read_interleaving_sequence#(WIDTH, SIZE))

  integer i = 0;
  integer j = 1;
  function new(string name = " read_interleaving_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);

//raddr phase -different M_ARID
  begin  //m0 to s0
   `uvm_create(req)
      req.RW <= 1;               req.M_ARVALID[i] <= 1'b1;           req.M_RVALID[i] <= 1'b0;
      req.M_ARID[i]   <=4'b0001; req.M_ARADDR [i] <= 32'h0000_00a1;  req.M_ARLEN[i]  <= 8'h1;
      req.M_ARSIZE[i] <=3'b101;  req.M_ARBURST[i] <= 2'b01;
      `uvm_send(req) 
  end 
  begin //m0 to s1
   `uvm_create(req)
      req.RW <= 1;               req.M_ARVALID[i] <= 1'b1;           req.M_RVALID[i] <= 1'b0;
      req.M_ARID[i]   <=4'b0010; req.M_ARADDR[i]  <= 32'h0000_20a2;  req.M_ARLEN[i]  <= 8'h1;
      req.M_ARSIZE[i] <=3'b101;  req.M_ARBURST[i] <= 2'b01;
      `uvm_send(req) 
  end 
// rdata phase -interleaving
  begin //s1 to m0
   `uvm_create(req)
      req.S_ARVALID[j] <= 1'b0; req.S_RVALID[j] <= 1'b1;
      req.S_RLAST[j]   <= 1'b0; req.S_RRESP[j] <= 2'b00;
      req.RW<=1;req.S_RID[j]<=8'b1001_0010; req.S_RDATA[j] <= 32'h10d3;
      `uvm_send(req) 
       //Read sequence
  end

  begin //s0 to m0 
   `uvm_create(req)
      req.S_ARVALID[i] <= 1'b0; req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]   <= 1'b0; req.S_RRESP[i] <= 2'b00;
      req.RW<=1;req.S_RID[i]<=8'b0101_0001; req.S_RDATA[i] <= 32'h00d1;
      `uvm_send(req)  //Read sequence
  end

  begin //s1 to m0 
   `uvm_create(req)
      req.S_ARVALID[j] <= 1'b0; req.S_RVALID[j] <= 1'b1;
      req.S_RLAST[j]   <= 1'b1; req.S_RRESP[j] <= 2'b00;
      req.RW<=1;req.S_RID[j]<=8'b1001_0010; req.S_RDATA[j] <= 32'h10d4;
      `uvm_send(req)  //Read sequence
  end

  begin //s0 to m0 
   `uvm_create(req)
      req.S_ARVALID[i] <= 1'b0; req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]  <= 1'b1;  req.S_RRESP[i] <= 2'b00;
      req.RW<=1;req.S_RID[i]<=8'b0101_0001; req.S_RDATA[i] <= 32'h00d2;
      `uvm_send(req)  //Read sequence
  end


  //raddr phase -same M_ARID
  begin  //m0 to s0
   `uvm_create(req)
      req.RW <= 1;               req.M_ARVALID[i] <= 1'b1;           req.M_RVALID[i] <= 1'b0;
      req.M_ARID[i]   <=4'b0001; req.M_ARADDR [i] <= 32'h0000_00a1;  req.M_ARLEN[i]  <= 8'h1;
      req.M_ARSIZE[i] <=3'b101;  req.M_ARBURST[i] <= 2'b01;
       `uvm_send(req) 
  end 
  begin //m0 to s1
   `uvm_create(req)
      req.RW <= 1;               req.M_ARVALID[i] <= 1'b1;           req.M_RVALID[i] <= 1'b0;
      req.M_ARID[i]   <=4'b0001; req.M_ARADDR[i]  <= 32'h0000_20a2;  req.M_ARLEN[i]  <= 8'h1;
      req.M_ARSIZE[i] <=3'b101;  req.M_ARBURST[i] <= 2'b01;
       `uvm_send(req) 
  end 
// rdata phase -interleaving  -need hold-order
  begin //s1 to m0
   `uvm_create(req)
      req.S_ARVALID[j] <= 1'b0; req.S_RVALID[j] <= 1'b1;
      req.S_RLAST[j]   <= 1'b0; req.S_RRESP[j] <= 2'b00;
      req.RW<=1;req.S_RID[j]<=8'b1001_0001; req.S_RDATA[j] <= 32'h10d3;
      `uvm_send(req)  //Read sequence
  end

  begin //s0 to m0 
   `uvm_create(req)
      req.S_ARVALID[i] <= 1'b0; req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]   <= 1'b0; req.S_RRESP[i] <= 2'b00;
      req.RW<=1;req.S_RID[i]<=8'b0101_0001; req.S_RDATA[i] <= 32'h00d1;
      `uvm_send(req)  //Read sequence
  end

  begin //s1 to m0 
   `uvm_create(req)
      req.S_ARVALID[j] <= 1'b0; req.S_RVALID[j] <= 1'b1;
      req.S_RLAST[j]   <= 1'b1; req.S_RRESP[j] <= 2'b00;
      req.RW<=1;req.S_RID[j]<=8'b1001_0001; req.S_RDATA[j] <= 32'h10d4;
      `uvm_send(req)  //Read sequence
  end

  begin //s0 to m0 
   `uvm_create(req)
      req.S_ARVALID[i] <= 1'b0; req.S_RVALID[i] <= 1'b1;
      req.S_RLAST[i]  <= 1'b1;  req.S_RRESP[i] <= 2'b00;
      req.RW<=1;req.S_RID[i]<=8'b0101_0001; req.S_RDATA[i] <= 32'h00d2;
      `uvm_send(req)  //Read sequence
  end
 #20;
  endtask
endclass

//
//-----------------------------random test---------------------------------
//
class random_burst_write_sequence #(                    //m0 to s1                 
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(random_burst_write_sequence#(WIDTH, SIZE))

  integer i = 0 ;
  integer j;
  integer k = 1 ;
  function new(string name = "random_burst_write_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  // = 4'b1001;
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  // = 4'b0101;
    req.M_AWSIZE.rand_mode(1);  // = 3'b100;
    req.M_AWBURST.rand_mode(1);  // = 2'b11;
    
    req.M_WID.rand_mode(1);  // = 2'b11;
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

    set_response_queue_depth(4096);

//mst0 to slv1
  begin 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1001;req.M_AWADDR[i] inside {['h2000:'h2fff]};req.M_AWLEN[i] inside{[8'h0:8'h05]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
   
  end
    repeat(req.M_AWLEN[i]) begin 
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1001;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
 
    begin 
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b1001_1001;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1001;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
    #10;

  endtask
endclass

class burst_write_sequence #(                    //m0 to s1                 
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(burst_write_sequence#(WIDTH, SIZE))

  integer i = 0 ;
  integer j;
  integer k = 1 ;
  function new(string name = "burst_write_sequence");
    super.new(name);
  endfunction

  virtual task body();
  #12;
/*
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
    
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);
*/
    set_response_queue_depth(409600);

//mst0 to slv1
repeat(10)  begin
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1001;req.M_AWADDR[i] inside{[32'h0000_2000:32'h0000_3222]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1001;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b1001_1001;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1001;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end
    #10;
  endtask
endclass


class cross_burst_write_sequence #(                    //m0 to s1                 
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(cross_burst_write_sequence#(WIDTH, SIZE))


  function new(string name = "cross_burst_write_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(409600);

//mst0 to slv0
repeat(60)  begin
  integer i = 0 ;
  integer k = 0 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b0101;req.M_AWADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b0101;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b0101_0101;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b0101;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end


//mst0 to slv1

repeat(60)  begin
  integer i = 0 ;
  integer k = 1 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1001;req.M_AWADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1001;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b1001_1001;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1001;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end

//mst0 to slv2

repeat(60)  begin
  integer i = 0 ;
  integer k = 2 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1101;req.M_AWADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1101;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b1101_1101;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1101;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end


//mst1 to slv0
repeat(60)  begin
  integer i = 1 ;
  integer k = 0 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b0110;req.M_AWADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b0110;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b0110_0110;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b0110;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end

//mst1 to slv1

repeat(60)  begin
  integer i = 1 ;
  integer k = 1 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1010;req.M_AWADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1010;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b1010_1010;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1010;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end


//mst1 to slv2

repeat(60)  begin
  integer i = 1 ;
  integer k = 2 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1110;req.M_AWADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1110;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b1110_1110;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1110;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end

//mst2 to slv0

repeat(60)  begin
  integer i = 2 ;
  integer k = 0 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b0111;req.M_AWADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b0111;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b0111_0111;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b0111;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end


//mst2 to slv1

repeat(60)  begin
  integer i = 2 ;
  integer k = 1 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1011;req.M_AWADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1011;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b1011_1011;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1011;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end

//mst2 to slv2

repeat(60)  begin
  integer i = 2 ;
  integer k = 2 ;
   begin 
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1111;req.M_AWADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[i] inside{[8'h0:8'hff]};req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;})
    end

    repeat(req.M_AWLEN[i])
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1111;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end

    begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BID  [k]  <= 8'b1111_1111;
      req.S_BVALID[k] <= 1'b1;
      req.S_BRESP[k]  <= 2'b00;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1111;req.M_WSTRB[i]=='b1111;})  //Read sequence
    end
end


  endtask
endclass

class cross_burst_read_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(cross_burst_read_sequence#(WIDTH, SIZE))


  function new(string name = "cross_burst_read_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
   
//mst0 to slv0
repeat(60)begin
      integer i = 0 ;
      integer j = 0 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b0101;req.M_ARADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b0101_0101;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b0101_0101;})  
  end
end

//mst0 to slv1
repeat(60)begin
      integer i = 0 ;
      integer j = 1 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b1001;req.M_ARADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1001_1001;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1001_1001;})  
  end
end

//mst0 to slv2
repeat(60)begin
      integer i = 0 ;
      integer j = 2 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b1101;req.M_ARADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1101_1101;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1101_1101;})  
  end
end



//mst1 to slv0
repeat(60)begin
      integer i = 1 ;
      integer j = 0 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b0110;req.M_ARADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b0110_0110;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b0110_0110;})  
  end
end


//mst1 to slv1
repeat(60)begin
      integer i = 1 ;
      integer j = 1 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b1010;req.M_ARADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1010_1010;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1010_1010;})  
  end
end

//mst1 to slv2
repeat(60)begin
      integer i = 1 ;
      integer j = 2 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b1110;req.M_ARADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1110_1110;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1110_1110;})  
  end
end


//mst2 to slv0
repeat(60)begin
      integer i = 2 ;
      integer j = 0 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b0111;req.M_ARADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b0111_0111;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b0111_0111;})  
  end
end

//mst2 to slv1
repeat(60)begin
      integer i = 2 ;
      integer j = 1 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b1011;req.M_ARADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1011_1011;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1011_1011;})  
  end
end

//mst2 to slv2
repeat(60)begin
      integer i = 2 ;
      integer j = 2 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b1111;req.M_ARADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[i] inside{[8'h0:8'hff]};req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1111_1111;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1111_1111;})  
  end
end

#20;
  endtask

endclass


//-----------------cross_write_S_arbiter slave------------------------
class cross_write_s0_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(cross_write_s0_arbiter_sequence#(WIDTH, SIZE))


  function new(string name = "cross_write_s0_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(409600);

repeat(80)  begin  //M1 2 3 to S0

  integer i = 0 ;
  integer j = 1 ;
  integer k = 2 ;

   begin  //waddr mo 1 2 to s0
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b1;
	    req.M_WVALID[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b1;
	    req.M_WVALID[k] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b0101;req.M_AWADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[i]==8'd1;req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;
                                          req.M_AWID[j]==4'b0110;req.M_AWADDR[j] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[j]==8'd1;req.M_AWSIZE[j]==3'b101;req.M_AWBURST[j] == 2'b01; 
                                          req.M_AWID[k]==4'b0111;req.M_AWADDR[k] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[k]==8'd1;req.M_AWSIZE[k]==3'b101;req.M_AWBURST[k] == 2'b01; })
    end

    repeat(req.M_AWLEN[i]) //wdata M1 2 3 to S0
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j] <= 1'b1;
      req.M_WLAST[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k] <= 1'b1;
      req.M_WLAST[k] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b0101;req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j]==4'b0110;req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k]==4'b0111;req.M_WSTRB[k]=='b1111;})  //Read sequence
     end

    begin       //B SO to M
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i]  <= 1'b1;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j]  <= 1'b1;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k]  <= 1'b1;

      req.M_WLAST[i]   <= 1'b1;
      req.M_WLAST[j]   <= 1'b1;
      req.M_WLAST[k]   <= 1'b1;
      req.S_BVALID[i]  <= 1'b1;
      req.S_BRESP[i]   <= 2'b00;
     
      req.S_BID  [i]   = 8'b0111_0111;
      req.S_BID  [i]   = 8'b0110_0110;
      req.S_BID  [i]   = 8'b0101_0101;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b0101;req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j]==4'b0110;req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k]==4'b0111;req.M_WSTRB[k]=='b1111;})  //Read sequence
    end
end

#20;
    endtask

endclass

class cross_write_s1_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(cross_write_s1_arbiter_sequence#(WIDTH, SIZE))


  function new(string name = "cross_write_s1_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(409600);

repeat(80)  begin  //M1 2 3 to S1

  integer i = 0 ;
  integer j = 1 ;
  integer k = 2 ;

   begin  //waddr mo 1 2 to s1
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b1;
	    req.M_WVALID[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b1;
	    req.M_WVALID[k] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1001;req.M_AWADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[i]==8'd1;req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;
                                          req.M_AWID[j]==4'b1010;req.M_AWADDR[j] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[j]==8'd1;req.M_AWSIZE[j]==3'b101;req.M_AWBURST[j] == 2'b01; 
                                          req.M_AWID[k]==4'b1011;req.M_AWADDR[k] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[k]==8'd1;req.M_AWSIZE[k]==3'b101;req.M_AWBURST[k] == 2'b01; })
    end

    repeat(req.M_AWLEN[i]) //wdata M1 2 3 to S1
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j] <= 1'b1;
      req.M_WLAST[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k] <= 1'b1;
      req.M_WLAST[k] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1001;req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j]==4'b1010;req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k]==4'b1011;req.M_WSTRB[k]=='b1111;})  //Read sequence
    end

    begin       //B SO to M
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i]  <= 1'b1;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j]  <= 1'b1;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k]  <= 1'b1;

      req.M_WLAST[i]   <= 1'b1;
      req.M_WLAST[j]   <= 1'b1;
      req.M_WLAST[k]   <= 1'b1;
      req.S_BVALID[i]  <= 1'b1;
      req.S_BRESP[i]   <= 2'b00;
     
      req.S_BID  [i]   = 8'b1011_1011;
      req.S_BID  [i]   = 8'b1010_1010;
      req.S_BID  [i]   = 8'b1001_1001;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1001;req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j]==4'b1010;req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k]==4'b1011;req.M_WSTRB[k]=='b1111;})  //Read sequence
    end
end

#20;
    endtask

endclass

class cross_write_s2_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(cross_write_s2_arbiter_sequence#(WIDTH, SIZE))


  function new(string name = "cross_write_s2_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(409600);

repeat(80)  begin // m1 2 3 to s2
  integer i = 0 ;
  integer j = 1 ;
  integer k = 2 ;

//fork
   begin  //waddr m1 2 3 to s2
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b1;
	    req.M_WVALID[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b1;
	    req.M_WVALID[k] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i]==4'b1101;req.M_AWADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[i]==8'd1;req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01;
                                          req.M_AWID[j]==4'b1110;req.M_AWADDR[j] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[j]==8'd1;req.M_AWSIZE[j]==3'b101;req.M_AWBURST[j] == 2'b01; 
                                          req.M_AWID[k]==4'b1111;req.M_AWADDR[k] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[k]==8'd1;req.M_AWSIZE[k]==3'b101;req.M_AWBURST[k] == 2'b01; })
    end

    repeat(req.M_AWLEN[i]) //wdata mo to s0
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j] <= 1'b1;
      req.M_WLAST[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k] <= 1'b1;
      req.M_WLAST[k] <= 1'b0;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1101;req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j]==4'b1110;req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k]==4'b1111;req.M_WSTRB[k]=='b1111;})  //Read sequence
    end

    begin       //B SO to M
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i]  <= 1'b1;

      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j]  <= 1'b1;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k]  <= 1'b1;

      req.M_WLAST[i]   <= 1'b1;
      req.M_WLAST[j]   <= 1'b1;
      req.M_WLAST[k]   <= 1'b1;
      req.S_BVALID[i]  <= 1'b1;
      req.S_BRESP[i]   <= 2'b00;
     
      req.S_BID  [i]   = 8'b1111_1111;
      req.S_BID  [i]   = 8'b1110_1110;
      req.S_BID  [i]   = 8'b1101_1101;
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i]==4'b1101;req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j]==4'b1110;req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k]==4'b1111;req.M_WSTRB[k]=='b1111;})  //Read sequence
    end
end

#20;
    endtask

endclass


class cross_read_S_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(cross_read_S_arbiter_sequence#(WIDTH, SIZE))


  function new(string name = "cross_read_S_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
   
repeat(80)begin //mst0 1 2 to slv0
      integer i = 0 ;
      integer j = 1 ;
      integer k = 2 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
      req.M_ARVALID[j] <= 1'b1;
	    req.M_RVALID[j] <= 1'b0;
      req.M_ARVALID[k] <= 1'b1;
	    req.M_RVALID[k] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b0101;req.M_ARADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[i] == 8'h2;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;
                           req.M_ARID[j] == 4'b0110;req.M_ARADDR[j] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[j] == 8'h2;req.M_ARSIZE[j] ==  3'b101;req.M_ARBURST[j]  ==  2'b01;
                           req.M_ARID[k] == 4'b0111;req.M_ARADDR[k] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[k] == 8'h2;req.M_ARSIZE[k] ==  3'b101;req.M_ARBURST[k]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[i] <= 1'b0;
     req.S_RVALID[i]  <= 1'b1;
     req.S_RLAST[i]   <= 1'b0;
     req.S_RRESP[i]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[i] == 8'b0101_0101;})
  `uvm_rand_send_with(req,{req.S_RID[i] == 8'b0110_0110;})
  `uvm_rand_send_with(req,{req.S_RID[i] == 8'b0111_0111;})
  end 

  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[i] <= 1'b0;
     req.S_RVALID[i]  <= 1'b1;
     req.S_RLAST[i]   <= 1'b1;
     req.S_RRESP[i]   <= 2'b00;
    
  `uvm_rand_send_with(req,{req.S_RID[i] == 8'b0101_0101;})
  `uvm_rand_send_with(req,{req.S_RID[i] == 8'b0110_0110;})
  `uvm_rand_send_with(req,{req.S_RID[i] == 8'b0111_0111;})  
  end
end

repeat(80)begin //mst0 1 2 to slv1
      integer i = 0 ;
      integer j = 1 ;
      integer k = 2 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
      req.M_ARVALID[j] <= 1'b1;
	    req.M_RVALID[j] <= 1'b0;
      req.M_ARVALID[k] <= 1'b1;
	    req.M_RVALID[k] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b1001;req.M_ARADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[i] == 8'h2;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;
                           req.M_ARID[j] == 4'b1010;req.M_ARADDR[j] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[j] == 8'h2;req.M_ARSIZE[j] ==  3'b101;req.M_ARBURST[j]  ==  2'b01;
                           req.M_ARID[k] == 4'b1011;req.M_ARADDR[k] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[k] == 8'h2;req.M_ARSIZE[k] ==  3'b101;req.M_ARBURST[k]  ==  2'b01;})
  end 
   
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b0;
     req.S_RRESP[j]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1001_1001;})
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1010_1010;})
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1011_1011;})
  end 
  
  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[j] <= 1'b0;
     req.S_RVALID[j]  <= 1'b1;
     req.S_RLAST[j]   <= 1'b1;
     req.S_RRESP[j]   <= 2'b00;
    
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1001_1001;})
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1010_1010;})
  `uvm_rand_send_with(req,{req.S_RID[j] == 8'b1011_1011;})  
  end
end

repeat(80)begin //mst0 1 2 to slv2
      integer i = 0 ;
      integer j = 1 ;
      integer k = 2 ;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
      req.M_ARVALID[j] <= 1'b1;
	    req.M_RVALID[j] <= 1'b0;
      req.M_ARVALID[k] <= 1'b1;
	    req.M_RVALID[k] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i] == 4'b1101;req.M_ARADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[i] == 8'h2;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;
                           req.M_ARID[j] == 4'b1110;req.M_ARADDR[j] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[j] == 8'h2;req.M_ARSIZE[j] ==  3'b101;req.M_ARBURST[j]  ==  2'b01;
                           req.M_ARID[k] == 4'b1111;req.M_ARADDR[k] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[k] == 8'h2;req.M_ARSIZE[k] ==  3'b101;req.M_ARBURST[k]  ==  2'b01;})
  end 
   //Read sequence
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[k] <= 1'b0;
     req.S_RVALID[k]  <= 1'b1;
     req.S_RLAST[k]   <= 1'b0;
     req.S_RRESP[k]   <= 2'b00;
  `uvm_rand_send_with(req,{req.S_RID[k] == 8'b1101_1101;})
  `uvm_rand_send_with(req,{req.S_RID[k] == 8'b1110_1110;})
  `uvm_rand_send_with(req,{req.S_RID[k] == 8'b1111_1111;})
  end 
  
  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[k] <= 1'b0;
     req.S_RVALID[k]  <= 1'b1;
     req.S_RLAST[k]   <= 1'b1;
     req.S_RRESP[k]   <= 2'b00;
    
  `uvm_rand_send_with(req,{req.S_RID[k] == 8'b1101_1101;})
  `uvm_rand_send_with(req,{req.S_RID[k] == 8'b1110_1110;})
  `uvm_rand_send_with(req,{req.S_RID[k] == 8'b1111_1111;})  
  end
end


#20;
    endtask

endclass


class m_to_s0_write_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(m_to_s0_write_arbiter_sequence#(WIDTH, SIZE))

  rand int i;
  rand int j;
  rand int k;
  rand int q;
  function new(string name = "m_to_s0_write_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(409600);
repeat(30)  begin  //M1 2 3 to S1
  i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      q = 0;  // 初始化为0
// repeat(10) 
begin  //waddr mo 1 2 to s1
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b1;
	    req.M_WVALID[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b1;
	    req.M_WVALID[k] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i][3:2]==2'b01;req.M_AWID[i][1:0]==(2'b01+i);req.M_AWADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[i]==8'd1;req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01; 
                                          req.M_AWID[j][3:2]==2'b01;req.M_AWID[j][1:0]==(2'b01+j);req.M_AWADDR[j] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[j]==8'd1;req.M_AWSIZE[j]==3'b101;req.M_AWBURST[j] == 2'b01; 
                                          req.M_AWID[k][3:2]==2'b01;req.M_AWID[k][1:0]==(2'b01+k);req.M_AWADDR[k] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[k]==8'd1;req.M_AWSIZE[k]==3'b101;req.M_AWBURST[k] == 2'b01; })

    end

    repeat(req.M_AWLEN[i]) //wdata M1 2 3 to S1
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j] <= 1'b1;
      req.M_WLAST[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k] <= 1'b1;
      req.M_WLAST[k] <= 1'b0;
      
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2]==2'b01;req.M_WID[i][1:0]==(2'b01+i);req.M_WSTRB[i]=='b1111;  //Read sequence
                                          req.M_WID[j][3:2]==2'b01;req.M_WID[j][1:0]==(2'b01+j);req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k][3:2]==2'b01;req.M_WID[k][1:0]==(2'b01+k);req.M_WSTRB[k]=='b1111;})
     end

    begin       //B SO to M
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i]  <= 1'b1;
      req.M_WLAST[i]   <= 1'b1;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j]  <= 1'b1;
      req.M_WLAST[j]   <= 1'b1;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k]  <= 1'b1;
      req.M_WLAST[k]   <= 1'b1;
      
      req.S_BVALID[q]  <= 1'b1;
      req.S_BRESP[q]   <= 2'b00;
     
      req.S_BID[q][7:6]<= (2'b01+q);req.S_BID[q][5:4]<=(2'b01+i); req.S_BID[q][3:2]<= 2'b01;req.S_BID[q][1:0]<=(2'b01+i); 

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2]==2'b01;req.M_WID[i][1:0]==(2'b01+i);req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j][3:2]==2'b01;req.M_WID[j][1:0]==(2'b01+j);req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k][3:2]==2'b01;req.M_WID[k][1:0]==(2'b01+k);req.M_WSTRB[k]=='b1111;})  //Read sequence
    end
end
//end

#20;
    endtask

endclass

class m_to_s1_write_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(m_to_s1_write_arbiter_sequence#(WIDTH, SIZE))

  rand int i;
  rand int j;
  rand int k;
  rand int q;
  function new(string name = "m_to_s1_write_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(409600);
repeat(80)  begin  //M1 2 3 to S1
  i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      q = 1;  // 初始化为0
// repeat(10) 
begin  //waddr mo 1 2 to s1
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b1;
	    req.M_WVALID[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b1;
	    req.M_WVALID[k] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i][3:2]==2'b10;req.M_AWID[i][1:0]==(2'b01+i);req.M_AWADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[i]==8'd1;req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01; 
                                          req.M_AWID[j][3:2]==2'b10;req.M_AWID[j][1:0]==(2'b01+j);req.M_AWADDR[j] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[j]==8'd1;req.M_AWSIZE[j]==3'b101;req.M_AWBURST[j] == 2'b01; 
                                          req.M_AWID[k][3:2]==2'b10;req.M_AWID[k][1:0]==(2'b01+k);req.M_AWADDR[k] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[k]==8'd1;req.M_AWSIZE[k]==3'b101;req.M_AWBURST[k] == 2'b01; })

    end

    repeat(req.M_AWLEN[i]) //wdata M1 2 3 to S1
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j] <= 1'b1;
      req.M_WLAST[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k] <= 1'b1;
      req.M_WLAST[k] <= 1'b0;
      
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2]==2'b10;req.M_WID[i][1:0]==(2'b01+i);req.M_WSTRB[i]=='b1111;  //Read sequence
                                          req.M_WID[j][3:2]==2'b10;req.M_WID[j][1:0]==(2'b01+j);req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k][3:2]==2'b10;req.M_WID[k][1:0]==(2'b01+k);req.M_WSTRB[k]=='b1111;})
     end

    begin       //B SO to M
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i]  <= 1'b1;
      req.M_WLAST[i]   <= 1'b1;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j]  <= 1'b1;
      req.M_WLAST[j]   <= 1'b1;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k]  <= 1'b1;
      req.M_WLAST[k]   <= 1'b1;
      
      req.S_BVALID[q]  <= 1'b1;
      req.S_BRESP[q]   <= 2'b00;
     
      req.S_BID[q][7:6]<= (2'b01+q);req.S_BID[q][5:4]<=(2'b01+i); req.S_BID[q][3:2]<= 2'b01;req.S_BID[q][1:0]<=(2'b01+i); 

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2]==2'b10;req.M_WID[i][1:0]==(2'b01+i);req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j][3:2]==2'b10;req.M_WID[j][1:0]==(2'b01+j);req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k][3:2]==2'b10;req.M_WID[k][1:0]==(2'b01+k);req.M_WSTRB[k]=='b1111;})  //Read sequence
    end
end
//end

#20;
    endtask

endclass

class m_to_s2_write_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(m_to_s2_write_arbiter_sequence#(WIDTH, SIZE))

  rand int i;
  rand int j;
  rand int k;
  rand int q;
  function new(string name = "m_to_s2_write_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(409600);
repeat(80)  begin  //M1 2 3 to S1
      i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      q = 2;  
// repeat(10) 
begin  //waddr mo 1 2 to s1
    `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b1;
	    req.M_WVALID[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b1;
	    req.M_WVALID[k] <= 1'b0;
	    `uvm_rand_send_with(req, {req.RW==0;req.M_AWID[i][3:2]==2'b11;req.M_AWID[i][1:0]==(2'b01+i);req.M_AWADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[i]==8'd1;req.M_AWSIZE[i]==3'b101;req.M_AWBURST[i] == 2'b01; 
                                          req.M_AWID[j][3:2]==2'b11;req.M_AWID[j][1:0]==(2'b01+j);req.M_AWADDR[j] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[j]==8'd1;req.M_AWSIZE[j]==3'b101;req.M_AWBURST[j] == 2'b01; 
                                          req.M_AWID[k][3:2]==2'b11;req.M_AWID[k][1:0]==(2'b01+k);req.M_AWADDR[k] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[k]==8'd1;req.M_AWSIZE[k]==3'b101;req.M_AWBURST[k] == 2'b01; })

    end

    repeat(req.M_AWLEN[i]) //wdata M1 2 3 to S1
     begin 
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j] <= 1'b1;
      req.M_WLAST[j] <= 1'b0;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k] <= 1'b1;
      req.M_WLAST[k] <= 1'b0;
      
      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2]==2'b11;req.M_WID[i][1:0]==(2'b01+i);req.M_WSTRB[i]=='b1111;  //Read sequence
                                          req.M_WID[j][3:2]==2'b11;req.M_WID[j][1:0]==(2'b01+j);req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k][3:2]==2'b11;req.M_WID[k][1:0]==(2'b01+k);req.M_WSTRB[k]=='b1111;})
     end

    begin       //B SO to M
    `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i]  <= 1'b1;
      req.M_WLAST[i]   <= 1'b1;
      req.M_AWVALID[j] <= 1'b0;
      req.M_WVALID[j]  <= 1'b1;
      req.M_WLAST[j]   <= 1'b1;
      req.M_AWVALID[k] <= 1'b0;
      req.M_WVALID[k]  <= 1'b1;
      req.M_WLAST[k]   <= 1'b1;
      
      req.S_BVALID[q]  <= 1'b1;
      req.S_BRESP[q]   <= 2'b00;
     
      req.S_BID[q][7:6]<= (2'b01+q);req.S_BID[q][5:4]<=(2'b01+i); req.S_BID[q][3:2]<= 2'b01;req.S_BID[q][1:0]<=(2'b01+i); 

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2]==2'b11;req.M_WID[i][1:0]==(2'b01+i);req.M_WSTRB[i]=='b1111;
                                          req.M_WID[j][3:2]==2'b11;req.M_WID[j][1:0]==(2'b01+j);req.M_WSTRB[j]=='b1111;
                                          req.M_WID[k][3:2]==2'b11;req.M_WID[k][1:0]==(2'b01+k);req.M_WSTRB[k]=='b1111;})  //Read sequence
    end
end
//end

#20;
    endtask

endclass


class m_to_s_read_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(m_to_s_read_arbiter_sequence#(WIDTH, SIZE))


  rand int i;
  rand int j;
  rand int k;
  rand int q;
  function new(string name = "m_to_s_read_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
repeat(80)  begin  //M1 2 3 to S0  read
      i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      // num =  //same number of i j k
      q = 0;  
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
      req.M_ARVALID[j] <= 1'b1;
	    req.M_RVALID[j] <= 1'b0;
      req.M_ARVALID[k] <= 1'b1;
	    req.M_RVALID[k] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b01;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[i] == 8'h2;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;
                           req.M_ARID[j][3:2] == 2'b01;req.M_ARID[j][1:0] == (2'b01+j);req.M_ARADDR[j] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[j] == 8'h2;req.M_ARSIZE[j] ==  3'b101;req.M_ARBURST[j]  ==  2'b01;
                           req.M_ARID[k][3:2] == 2'b01;req.M_ARID[k][1:0] == (2'b01+k);req.M_ARADDR[k] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[k] == 8'h2;req.M_ARSIZE[k] ==  3'b101;req.M_ARBURST[k]  ==  2'b01;})
  end 
   //Read sequence
   
if(i!=j && i!=k) begin
repeat(2) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+i);})
 end

end

if(j!=k) begin
repeat(req.M_ARLEN[j]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+j); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+j);})
 end
   
end

repeat(req.M_ARLEN[k]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+k); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+k);})
 end

   if(i!=j && i!=k)  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+i);})
  end

  if(j!=k) begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+j); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+j);})
  end
    begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+k); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+k);})
  end
    
end

repeat(80)  begin  //M1 2 3 to S1  read
      i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      // num =  //same number of i j k
      q = 1;  
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
      req.M_ARVALID[j] <= 1'b1;
	    req.M_RVALID[j] <= 1'b0;
      req.M_ARVALID[k] <= 1'b1;
	    req.M_RVALID[k] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b10;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[i] == 8'h2;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;
                           req.M_ARID[j][3:2] == 2'b10;req.M_ARID[j][1:0] == (2'b01+j);req.M_ARADDR[j] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[j] == 8'h2;req.M_ARSIZE[j] ==  3'b101;req.M_ARBURST[j]  ==  2'b01;
                           req.M_ARID[k][3:2] == 2'b10;req.M_ARID[k][1:0] == (2'b01+k);req.M_ARADDR[k] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[k] == 8'h2;req.M_ARSIZE[k] ==  3'b101;req.M_ARBURST[k]  ==  2'b01;})
  end 
   //Read sequence
   
if(i!=j && i!=k) begin
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b10;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b10;req.S_RID[q][1:0] == (2'b01+i);})
 end

end

if(j!=k) begin
repeat(req.M_ARLEN[j]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b10;req.S_RID[q][5:4] == (2'b01+j); req.S_RID[q][3:2] == 2'b10;req.S_RID[q][1:0] == (2'b01+j);})
 end
   
end

repeat(req.M_ARLEN[k]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b10;req.S_RID[q][5:4] == (2'b01+k); req.S_RID[q][3:2] == 2'b10;req.S_RID[q][1:0] == (2'b01+k);})
 end

   if(i!=j && i!=k)  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b10;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b10;req.S_RID[q][1:0] == (2'b01+i);})
  end

  if(j!=k) begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b10;req.S_RID[q][5:4] == (2'b01+j); req.S_RID[q][3:2] == 2'b10;req.S_RID[q][1:0] == (2'b01+j);})
  end
    begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b10;req.S_RID[q][5:4] == (2'b01+k); req.S_RID[q][3:2] == 2'b10;req.S_RID[q][1:0] == (2'b01+k);})
  end
    
end

repeat(80)  begin  //M1 2 3 to S2  read
      i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      // num =  //same number of i j k
      q = 2;  
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
      req.M_ARVALID[j] <= 1'b1;
	    req.M_RVALID[j] <= 1'b0;
      req.M_ARVALID[k] <= 1'b1;
	    req.M_RVALID[k] <= 1'b0;
	`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b11;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[i] == 8'h2;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;
                           req.M_ARID[j][3:2] == 2'b11;req.M_ARID[j][1:0] == (2'b01+j);req.M_ARADDR[j] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[j] == 8'h2;req.M_ARSIZE[j] ==  3'b101;req.M_ARBURST[j]  ==  2'b01;
                           req.M_ARID[k][3:2] == 2'b11;req.M_ARID[k][1:0] == (2'b01+k);req.M_ARADDR[k] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[k] == 8'h2;req.M_ARSIZE[k] ==  3'b101;req.M_ARBURST[k]  ==  2'b01;})
  end 
   //Read sequence
   
if(i!=j && i!=k) begin
repeat(req.M_ARLEN[i]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b11;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b11;req.S_RID[q][1:0] == (2'b01+i);})
 end

end

if(j!=k) begin
repeat(req.M_ARLEN[j]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b11;req.S_RID[q][5:4] == (2'b01+j); req.S_RID[q][3:2] == 2'b11;req.S_RID[q][1:0] == (2'b01+j);})
 end
   
end

repeat(req.M_ARLEN[k]) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1);  
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b0;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b11;req.S_RID[q][5:4] == (2'b01+k); req.S_RID[q][3:2] == 2'b11;req.S_RID[q][1:0] == (2'b01+k);})
 end

   if(i!=j && i!=k)  begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b11;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b11;req.S_RID[q][1:0] == (2'b01+i);})
  end

  if(j!=k) begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b11;req.S_RID[q][5:4] == (2'b01+j); req.S_RID[q][3:2] == 2'b11;req.S_RID[q][1:0] == (2'b01+j);})
  end
    begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b11;req.S_RID[q][5:4] == (2'b01+k); req.S_RID[q][3:2] == 2'b11;req.S_RID[q][1:0] == (2'b01+k);})
  end
    
end


#20;
    endtask

endclass

//  m_to_s_read_arbite 一个mater对多个slave发起读操作请求
class Mx_to_s_read_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(Mx_to_s_read_arbiter_sequence#(WIDTH, SIZE))

  int count0;
  int count1;
  int count2;
  rand int i;
  rand int j;
  rand int k;
  rand int q;
  rand int m;
  rand int n;
  rand int x;
  int x_values[3];

  function new(string name = "Mx_to_s_read_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
repeat(80)  begin  //M1 2 3 to S0  read
      i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      // num =  //same number of i j k
      q = 0;  
      m = 1;  
      n = 2;  
     count0 = 0;
     count1 = 0;
     count2 = 0;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
  repeat(3) begin
    for (int z = 0; z < 3; z++) begin
        x = $urandom_range(0, 2); 
          x_values[z] = x;
    end
  case (x)
	    0:`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b01;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[i] == 8'h0;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
      1:`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b10;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[i] == 8'h0;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
	    2:`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b11;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[i] == 8'h0;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  endcase
  if (x == 0) begin
    count0++;
    end 
  if (x == 1) begin
    count1++;
    end
  if (x == 2) begin
    count2++;
      end
    end
  $display("count0=", count0);
  $display("count1=", count1);
  $display("count2=", count2);

  end
   //Read sequence

// if (x_values[0]==0 || x_values[1]==0 || x_values[2]==0 ) begin  
//   repeat(req.M_ARLEN[i]) begin 
//   `uvm_create(req)
//      req.S_RID.rand_mode(1);  
//      req.S_RDATA.rand_mode(1);
//      req.S_RLAST.rand_mode(1);
//      req.S_ARVALID[q] <= 1'b0;
//      req.S_RVALID[q]  <= 1'b1;
//      req.S_RLAST[q]   <= 1'b0;
//      req.S_RRESP[q]   <= 2'b00;

//     `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+i);})
//   end
// end
  
//if (x_values[0]==0 || x_values[1]==0 || x_values[2]==0 ) begin  
   repeat (count0) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+i);})
  end

// if (x_values[0]==1 || x_values[1]==1 || x_values[2]==1 ) begin 
//   repeat(req.M_ARLEN[i]) begin 
//   `uvm_create(req)
//      req.S_RID.rand_mode(1);  
//      req.S_RDATA.rand_mode(1);
//      req.S_RLAST.rand_mode(1);
//      req.S_ARVALID[m] <= 1'b0;
//      req.S_RVALID[m]  <= 1'b1;
//      req.S_RLAST[m]   <= 1'b0;
//      req.S_RRESP[m]   <= 2'b00;
//     `uvm_rand_send_with(req,{req.S_RID[m][7:6] == 2'b10;req.S_RID[m][5:4] == (2'b01+i); req.S_RID[m][3:2] == 2'b10;req.S_RID[m][1:0] == (2'b01+i);})
//   end
// end
//if (x_values[0]==1 || x_values[1]==1 || x_values[2]==1 ) begin 
repeat (count1) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[m] <= 1'b0;
     req.S_RVALID[m]  <= 1'b1;
     req.S_RLAST[m]   <= 1'b1;
     req.S_RRESP[m]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[m][7:6] == 2'b10;req.S_RID[m][5:4] == (2'b01+i); req.S_RID[m][3:2] == 2'b10;req.S_RID[m][1:0] == (2'b01+i);})
  end

// if (x_values[0]==2 || x_values[1]==2 || x_values[2]==2 ) begin 
//   repeat(req.M_ARLEN[i]) begin 
//   `uvm_create(req)
//      req.S_RID.rand_mode(1);  
//      req.S_RDATA.rand_mode(1);
//      req.S_RLAST.rand_mode(1);
//      req.S_ARVALID[n] <= 1'b0;
//      req.S_RVALID[n]  <= 1'b1;
//      req.S_RLAST[n]   <= 1'b0;
//      req.S_RRESP[n]   <= 2'b00;
//     `uvm_rand_send_with(req,{req.S_RID[n][7:6] == 2'b11;req.S_RID[n][5:4] == (2'b01+i); req.S_RID[n][3:2] == 2'b11;req.S_RID[n][1:0] == (2'b01+i);})
//   end
// end
 
//if (x_values[0]==2 || x_values[1]==2 || x_values[2]==2 ) begin 
   repeat (count2 ) begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[n] <= 1'b0;
     req.S_RVALID[n]  <= 1'b1;
     req.S_RLAST[n]   <= 1'b1;
     req.S_RRESP[n]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[n][7:6] == 2'b11;req.S_RID[n][5:4] == (2'b01+i); req.S_RID[n][3:2] == 2'b11;req.S_RID[n][1:0] == (2'b01+i);})
  end 
 
end
#20;

  endtask
endclass

//m对多个s的写操作
class Mx_to_s_write_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(Mx_to_s_write_arbiter_sequence#(WIDTH, SIZE))

  int count0;
  int count1;
  int count2;
  rand int i;
  rand int j;
  rand int k;
  rand int q;
  rand int m;
  rand int n;
  rand int x;
  int x_values[3];

  function new(string name = "Mx_to_s_write_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
repeat(80)  begin  //M1 2 3 to S0 S1 S2 read
      i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      // num =  //same number of i j k
      q = 0;  
      m = 1;  
      n = 2;  
     count0 = 0;
     count1 = 0;
     count2 = 0;
  begin
 `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.RW <= 0;
  repeat(3) begin
    for (int z = 0; z < 3; z++) begin
        x = $urandom_range(0, 2); 
          x_values[z] = x;
    end
  case (x)
	    0:`uvm_rand_send_with(req,{req.M_AWID[i][3:2] == 2'b01;req.M_AWID[i][1:0] == (2'b01+i);req.M_AWADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[i] == 8'h0;req.M_AWSIZE[i] ==  3'b101;req.M_AWBURST[i]  ==  2'b01;})
	    1:`uvm_rand_send_with(req,{req.M_AWID[i][3:2] == 2'b10;req.M_AWID[i][1:0] == (2'b01+i);req.M_AWADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[i] == 8'h0;req.M_AWSIZE[i] ==  3'b101;req.M_AWBURST[i]  ==  2'b01;})
	    2:`uvm_rand_send_with(req,{req.M_AWID[i][3:2] == 2'b11;req.M_AWID[i][1:0] == (2'b01+i);req.M_AWADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[i] == 8'h0;req.M_AWSIZE[i] ==  3'b101;req.M_AWBURST[i]  ==  2'b01;})

  endcase
  if (x == 0) begin
    count0++;
    end 
  if (x == 1) begin
    count1++;
    end
  if (x == 2) begin
    count2++;
      end
    end
  $display("count0=", count0);
  $display("count1=", count1);
  $display("count2=", count2);

  end
   //Read sequence
  /*   
  begin
    repeat(req.M_AWLEN[i])
  `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);
      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b0;
  `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2] == 2'b01;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;
                                      req.M_WID[i][3:2] == 2'b10;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;
                                      req.M_WID[i][3:2] == 2'b11;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;})  //Read sequence
  end
*/
   repeat (count0) 
   begin 
  `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

    req.M_AWVALID[i] <= 1'b0;
    req.M_WVALID[i] <= 1'b1;
    req.M_WLAST[i] <= 1'b1;

    req.S_BVALID[q] <= 1'b1;
    req.S_BRESP[q]  <= 2'b00;
    req.S_BID[q][7:6] <= 2'b01;req.S_BID[q][5:4] <= (2'b01+i);req.S_BID[q][3:2] <= 2'b01;req.S_BID[q][1:0] <= (2'b01+i);

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2] == 2'b01;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;})  
      end



   repeat (count1) 
   begin 
  `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BVALID[m] <= 1'b1;
      req.S_BRESP[m]  <= 2'b00;
      req.S_BID[m][7:6] <= 2'b10;req.S_BID[m][5:4] <= (2'b01+i);req.S_BID[m][3:2] <= 2'b10;req.S_BID[m][1:0] <= (2'b01+i);

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2] == 2'b10;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;})  
  end

   repeat (count2) begin 
  `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BVALID[n] <= 1'b1;
      req.S_BRESP[n]  <= 2'b00;
      req.S_BID[n][7:6] <= 2'b11;req.S_BID[n][5:4] <= (2'b01+i);req.S_BID[n][3:2] <= 2'b11;req.S_BID[n][1:0] <= (2'b01+i);

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2] == 2'b11;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;})  
  end

end
#20;

  endtask
endclass

class default_read_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(default_read_arbiter_sequence#(WIDTH, SIZE))

  int count0;
  int count1;
  int count2;
  rand int i;
  rand int j;
  rand int k;
  rand int q;
  rand int m;
  rand int n;
  rand int x;
  int x_values[3];

  function new(string name = "default_read_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
repeat(200)  begin  //M1 2 3 to S0  read
      i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      // num =  //same number of i j k
      q = 0;  
      m = 1;  
      n = 2;  
     count0 = 0;
     count1 = 0;
     count2 = 0;
  begin
 `uvm_create(req)
    req.M_ARID.rand_mode(1);  
    req.M_ARADDR.rand_mode(1);
    req.M_ARLEN.rand_mode(1);  
    req.M_ARSIZE.rand_mode(1);  
    req.M_ARBURST.rand_mode(1); 
      req.RW <= 1;
	    req.M_ARVALID[i] <= 1'b1;
	    req.M_RVALID[i] <= 1'b0;
  repeat(4) begin
    for (int z = 0; z < 3; z++) begin
        x = $urandom_range(0, 3); 
          x_values[z] = x;
    end
  case (x)
	    0:`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b01;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_ARLEN[i] == 8'h0;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
      1:`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b10;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_ARLEN[i] == 8'h0;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
	    2:`uvm_rand_send_with(req,{req.M_ARID[i][3:2] == 2'b11;req.M_ARID[i][1:0] == (2'b01+i);req.M_ARADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_ARLEN[i] == 8'h0;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})
  	  3:`uvm_rand_send_with(req,{req.M_ARLEN[i] == 8'h0;req.M_ARSIZE[i] ==  3'b101;req.M_ARBURST[i]  ==  2'b01;})

  endcase
  if (x == 0) begin
    count0++;
    end 
  if (x == 1) begin
    count1++;
    end
  if (x == 2) begin
    count2++;
      end
    end
  $display("count0=", count0);
  $display("count1=", count1);
  $display("count2=", count2);

  end
   //Read sequence

   repeat (count0) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[q] <= 1'b0;
     req.S_RVALID[q]  <= 1'b1;
     req.S_RLAST[q]   <= 1'b1;
     req.S_RRESP[q]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[q][7:6] == 2'b01;req.S_RID[q][5:4] == (2'b01+i); req.S_RID[q][3:2] == 2'b01;req.S_RID[q][1:0] == (2'b01+i);})
  end

repeat (count1) begin 
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[m] <= 1'b0;
     req.S_RVALID[m]  <= 1'b1;
     req.S_RLAST[m]   <= 1'b1;
     req.S_RRESP[m]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[m][7:6] == 2'b10;req.S_RID[m][5:4] == (2'b01+i); req.S_RID[m][3:2] == 2'b10;req.S_RID[m][1:0] == (2'b01+i);})
  end

   repeat (count2 ) begin
  `uvm_create(req)
     req.S_RID.rand_mode(1); 
     req.S_RDATA.rand_mode(1);
     req.S_RLAST.rand_mode(1);
     req.S_ARVALID[n] <= 1'b0;
     req.S_RVALID[n]  <= 1'b1;
     req.S_RLAST[n]   <= 1'b1;
     req.S_RRESP[n]   <= 2'b00;
    `uvm_rand_send_with(req,{req.S_RID[n][7:6] == 2'b11;req.S_RID[n][5:4] == (2'b01+i); req.S_RID[n][3:2] == 2'b11;req.S_RID[n][1:0] == (2'b01+i);})
  end 
 
end
#20;

  endtask
endclass


class default_write_arbiter_sequence #(                                    
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_transaction#(WIDTH, SIZE));

  `uvm_object_param_utils(default_write_arbiter_sequence#(WIDTH, SIZE))

  int count0;
  int count1;
  int count2;
  rand int i;
  rand int j;
  rand int k;
  rand int q;
  rand int m;
  rand int n;
  rand int x;
  int x_values[3];

  function new(string name = "default_write_arbiter_sequence");
    super.new(name);
  endfunction

  virtual task body();
    #12;
    set_response_queue_depth(4096);
repeat(200)  begin  //M1 2 3 to S0 S1 S2 read
      i = $urandom_range(0, 2);
      $display("i is: %d", i);

      j = $urandom_range(0, 2);
      $display("j is: %d", j);

      k = $urandom_range(0, 2);
      $display("k is: %d", k);

      // num =  //same number of i j k
      q = 0;  
      m = 1;  
      n = 2;  
     count0 = 0;
     count1 = 0;
     count2 = 0;
  begin
 `uvm_create(req)
    req.M_AWID.rand_mode(1);  
    req.M_AWADDR.rand_mode(1);
    req.M_AWLEN.rand_mode(1);  
    req.M_AWSIZE.rand_mode(1); 
    req.M_AWBURST.rand_mode(1); 
	    req.M_AWVALID[i] <= 1'b1;
	    req.M_WVALID[i] <= 1'b0;
      req.RW <= 0;
  repeat(4) begin
    for (int z = 0; z < 3; z++) begin
        x = $urandom_range(0, 2); 
          x_values[z] = x;
    end
  case (x)
	    0:`uvm_rand_send_with(req,{req.M_AWID[i][3:2] == 2'b01;req.M_AWID[i][1:0] == (2'b01+i);req.M_AWADDR[i] inside{[32'h0000_0000:32'h0000_0fff]};req.M_AWLEN[i] == 8'h0;req.M_AWSIZE[i] ==  3'b101;req.M_AWBURST[i]  ==  2'b01;})
	    1:`uvm_rand_send_with(req,{req.M_AWID[i][3:2] == 2'b10;req.M_AWID[i][1:0] == (2'b01+i);req.M_AWADDR[i] inside{[32'h0000_2000:32'h0000_2fff]};req.M_AWLEN[i] == 8'h0;req.M_AWSIZE[i] ==  3'b101;req.M_AWBURST[i]  ==  2'b01;})
	    2:`uvm_rand_send_with(req,{req.M_AWID[i][3:2] == 2'b11;req.M_AWID[i][1:0] == (2'b01+i);req.M_AWADDR[i] inside{[32'h0000_4000:32'h0000_4fff]};req.M_AWLEN[i] == 8'h0;req.M_AWSIZE[i] ==  3'b101;req.M_AWBURST[i]  ==  2'b01;})
	    3:`uvm_rand_send_with(req,{req.M_AWLEN[i] == 8'h0;req.M_AWSIZE[i] ==  3'b101;req.M_AWBURST[i]  ==  2'b01;})

  endcase
  if (x == 0) begin
    count0++;
    end 
  if (x == 1) begin
    count1++;
    end
  if (x == 2) begin
    count2++;
      end
    end
  $display("count0=", count0);
  $display("count1=", count1);
  $display("count2=", count2);

  end

   repeat (count0) 
   begin 
  `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

    req.M_AWVALID[i] <= 1'b0;
    req.M_WVALID[i] <= 1'b1;
    req.M_WLAST[i] <= 1'b1;

    req.S_BVALID[q] <= 1'b1;
    req.S_BRESP[q]  <= 2'b00;
    req.S_BID[q][7:6] <= 2'b01;req.S_BID[q][5:4] <= (2'b01+i);req.S_BID[q][3:2] <= 2'b01;req.S_BID[q][1:0] <= (2'b01+i);

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2] == 2'b01;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;})  
      end



   repeat (count1) 
   begin 
  `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BVALID[m] <= 1'b1;
      req.S_BRESP[m]  <= 2'b00;
      req.S_BID[m][7:6] <= 2'b10;req.S_BID[m][5:4] <= (2'b01+i);req.S_BID[m][3:2] <= 2'b10;req.S_BID[m][1:0] <= (2'b01+i);

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2] == 2'b10;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;})  
  end

   repeat (count2) begin 
  `uvm_create(req)
    req.M_WID.rand_mode(1); 
    req.M_WDATA.rand_mode(1);
    req.M_WSTRB.rand_mode(1);
    req.M_WLAST.rand_mode(1);

    req.S_BID.rand_mode(1);
    req.S_BVALID.rand_mode(1);
    req.S_BRESP.rand_mode(1);

      req.M_AWVALID[i] <= 1'b0;
      req.M_WVALID[i] <= 1'b1;
      req.M_WLAST[i] <= 1'b1;
      req.S_BVALID[n] <= 1'b1;
      req.S_BRESP[n]  <= 2'b00;
      req.S_BID[n][7:6] <= 2'b11;req.S_BID[n][5:4] <= (2'b01+i);req.S_BID[n][3:2] <= 2'b11;req.S_BID[n][1:0] <= (2'b01+i);

      `uvm_rand_send_with(req, {req.RW==0;req.M_WID[i][3:2] == 2'b11;req.M_WID[i][1:0] == (2'b01+i);req.M_WSTRB[i]=='b1111;})  
  end

end
#20;

  endtask
endclass
