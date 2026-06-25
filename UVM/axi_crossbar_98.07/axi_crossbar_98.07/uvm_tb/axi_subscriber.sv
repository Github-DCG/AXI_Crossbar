class axi_subscriber#(int WIDTH=32,SIZE=3) extends uvm_subscriber#(virtual axi_intf#(WIDTH,SIZE));
  
  `uvm_component_param_utils(axi_subscriber#(WIDTH,SIZE))
 
  virtual axi_intf#(WIDTH,SIZE) tx;
  bit [(WIDTH/8)-1:0] wstrb;
  
  covergroup AXI_cg;
 

    M0_AWADDR_write   : coverpoint tx.M_AWADDR[0] iff(tx.M_AWVALID[0]==1)
                   {
                     bins awaddr_1[10] = {[32'h0000_0000:32'h0000_0fff]};
                     bins awaddr_2[10] = {[32'h0000_2000:32'h0000_2fff]};
                     bins awaddr_3[10] = {[32'h0000_4000:32'h0000_4fff]};
                    //  illegal_bins awaddr_5 = {[32'h0000_1000:32'h0000_1fff],[32'h0000_3000:32'h0000_3fff],[32'h0000_5000:$]};
                   }
    M1_AWADDR_write   : coverpoint tx.M_AWADDR[1] iff(tx.M_AWVALID[1]==1)
                   {
                     bins awaddr_1[10] = {[32'h0000_0000:32'h0000_0fff]};
                     bins awaddr_2[10] = {[32'h0000_2000:32'h0000_2fff]};
                     bins awaddr_3[10] = {[32'h0000_4000:32'h0000_4fff]};
                    //  illegal_bins awaddr_5 = {[32'h0000_1000:32'h0000_1fff],[32'h0000_3000:32'h0000_3fff],[32'h0000_5000:$]};
                   }
    M2_AWADDR_write   : coverpoint tx.M_AWADDR[2] iff(tx.M_AWVALID[2]==1) 
                    {
                     bins awaddr_1[10] = {[32'h0000_0000:32'h0000_0fff]};
                     bins awaddr_2[10] = {[32'h0000_2000:32'h0000_2fff]};
                     bins awaddr_3[10] = {[32'h0000_4000:32'h0000_4fff]};
                    //  illegal_bins awaddr_5 = {[32'h0000_1000:32'h0000_1fff],[32'h0000_3000:32'h0000_3fff],[32'h0000_5000:$]};
                   }

    M0_ARADDR_read    : coverpoint tx.M_ARADDR[0] iff(tx.M_ARVALID[0]==1)
                   {
                     bins awaddr_1[10] = {[32'h0000_0000:32'h0000_0fff]};
                     bins awaddr_2[10] = {[32'h0000_2000:32'h0000_2fff]};
                     bins awaddr_3[10] = {[32'h0000_4000:32'h0000_4fff]};
                    //  illegal_bins awaddr_5 = {[32'h0000_1000:32'h0000_1fff],[32'h0000_3000:32'h0000_3fff],[32'h0000_5000:$]};
                   }
    M1_ARADDR_read    : coverpoint tx.M_ARADDR[1] iff(tx.M_ARVALID[1]==1)
                  {
                     bins awaddr_1[10] = {[32'h0000_0000:32'h0000_0fff]};
                     bins awaddr_2[10] = {[32'h0000_2000:32'h0000_2fff]};
                     bins awaddr_3[10] = {[32'h0000_4000:32'h0000_4fff]};
                    //  illegal_bins awaddr_5 = {[32'h0000_1000:32'h0000_1fff],[32'h0000_3000:32'h0000_3fff],[32'h0000_5000:$]};
                   }
    M2_ARADDR_read    : coverpoint tx.M_ARADDR[2] iff(tx.M_ARVALID[2]==1)
                   {
                     bins awaddr_1[10] = {[32'h0000_0000:32'h0000_0fff]};
                     bins awaddr_2[10] = {[32'h0000_2000:32'h0000_2fff]};
                     bins awaddr_3[10] = {[32'h0000_4000:32'h0000_4fff]};
                    //  illegal_bins awaddr_5 = {[32'h0000_1000:32'h0000_1fff],[32'h0000_3000:32'h0000_3fff],[32'h0000_5000:$]};
                   }

    M0_AWSIZE_write : coverpoint tx.M_AWSIZE[0]   iff(tx.M_AWVALID[0]==1) 
                   {
                     bins awsize   = {3'b101};
                  //   illegal_bins illegal_awsize ={0,1};
                   }
    M1_AWSIZE_write : coverpoint tx.M_AWSIZE[1]   iff(tx.M_AWVALID[1]==1) 
                   {
                     bins awsize   = {3'b101};
                //     illegal_bins illegal_awsize ={0,1};
                   }
    M2_AWSIZE_write : coverpoint tx.M_AWSIZE[2]   iff(tx.M_AWVALID[2]==1)
                   {
                     bins awsize   = {3'b101};
                //     illegal_bins illegal_awsize ={0,1};
                   }

    M0_ARSIZE_read  : coverpoint tx.M_ARSIZE[0]   iff(tx.M_ARVALID[0]==1) 
                   {
                     bins arsize   = {3'b101};
                  //   illegal_bins illegal_arsize ={0,1};
                   }
    M1_ARSIZE_read  : coverpoint tx.M_ARSIZE[1]   iff(tx.M_ARVALID[1] ==1) 
                   {
                     bins arsize   = {3'b101};
                  //   illegal_bins illegal_arsize ={0,1};
                   }
    M2_ARSIZE_read  : coverpoint tx.M_ARSIZE[2]   iff(tx.M_ARVALID[2] ==1) 
                   {
                     bins arsize   = {3'b101};
                  //   illegal_bins illegal_arsize ={0,1};
                   }

    M0_AWLEN_write  : coverpoint tx.M_AWLEN[0]    iff(tx.M_AWVALID[0]==1)
                   {
                     bins arlen_1[5] = {[8'h0:8'h4f]};
                     bins arlen_2[5] = {[8'h50:8'h8f]};
                     bins arlen_3[5] = {[8'h90:8'hff]};
                   //  illegal_bins arlen_4 = {[9'h1ff:$]};
                   }  
    M1_AWLEN_write  : coverpoint tx.M_AWLEN[1]    iff(tx.M_AWVALID[1]==1)
                   {
                     bins arlen_1[5] = {[8'h0:8'h4f]};
                     bins arlen_2[5] = {[8'h50:8'h8f]};
                     bins arlen_3[5] = {[8'h90:8'hff]};
                   //  illegal_bins arlen_4 = {[9'h1ff:$]};
                   }             
    M2_AWLEN_write  : coverpoint tx.M_AWLEN[2]    iff(tx.M_AWVALID[2]==1)
                   {
                     bins arlen_1[5] = {[8'h0:8'h4f]};
                     bins arlen_2[5] = {[8'h50:8'h8f]};
                     bins arlen_3[5] = {[8'h90:8'hff]};
                   //  illegal_bins arlen_4 = {[9'h1ff:$]};
                   }


    M0_ARLEN_read   : coverpoint tx.M_ARLEN[0]    iff(tx.M_ARVALID[0]==1)
                   {
                     bins arlen_1[5] = {[8'h0:8'h4f]};
                     bins arlen_2[5] = {[8'h50:8'h8f]};
                     bins arlen_3[5] = {[8'h90:8'hff]};
                   //  illegal_bins arlen_4 = {[9'h1ff:$]};
                   }
    M1_ARLEN_read   : coverpoint tx.M_ARLEN[1]    iff(tx.M_ARVALID[1]==1)
                   {
                     bins arlen_1[5] = {[8'h0:8'h4f]};
                     bins arlen_2[5] = {[8'h50:8'h8f]};
                     bins arlen_3[5] = {[8'h90:8'hff]};
                   //  illegal_bins arlen_4 = {[9'h1ff:$]};
                   }
    M2_ARLEN_read   : coverpoint tx.M_ARLEN[2]    iff(tx.M_ARVALID[2]==1)
                   {
                     bins arlen_1[5] = {[8'h0:8'h4f]};
                     bins arlen_2[5] = {[8'h50:8'h8f]};
                     bins arlen_3[5] = {[8'h90:8'hff]};
                   //  illegal_bins arlen_4 = {[9'h1ff:$]};
                   }

    M0_AWBURST_write  : coverpoint tx.M_AWBURST[0] iff(tx.M_AWVALID[0]==1)
                   {
		             bins awburst = {0,1};//liangwei
                //     illegal_bins awburst_illegal   = {[2:$]};
                   }
    M1_AWBURST_write  : coverpoint tx.M_AWBURST[1] iff(tx.M_AWVALID[1]==1)
                   {
		             bins awburst = {0,1};
                 //    illegal_bins awburst_illegal   = {[2:$]};
                   }
    M2_AWBURST_write  : coverpoint tx.M_AWBURST[2] iff(tx.M_AWVALID[2]==1)
                   {
		             bins awburst = {0,1};
                 //    illegal_bins awburst_illegal   = {[2:$]};
                   }
                   
    M0_ARBURST_read   : coverpoint tx.M_ARBURST[0] iff(tx.M_ARVALID[0]==1)
                   {
		             bins arburst = {0,1};
                //     illegal_bins arburst_illegal   = {[2:$]};
                   }
    M1_ARBURST_read   : coverpoint tx.M_ARBURST[1] iff(tx.M_ARVALID[1]==1)
                   {
		             bins arburst = {0,1};
                //     illegal_bins arburst_illegal   = {[2:$]};
                   }
    M2_ARBURST_read   : coverpoint tx.M_ARBURST[2] iff(tx.M_ARVALID[2]==1)
                   {
		             bins arburst = {0,1};
               //      illegal_bins arburst_illegal   = {[2:$]};
                   }

  endgroup

   covergroup AXI_STRB_cg;
     M0_WSTRB_write  : coverpoint tx.M_WSTRB[0] iff(tx.M_WVALID[0]==1)
                   {
                     bins wstrb = {4'b1111};
                 //    illegal_bins wstrb_illegal = {[0:14]};
                   } 
     M1_WSTRB_write  : coverpoint tx.M_WSTRB[1] iff(tx.M_WVALID[1]==1)
                   {
                     bins wstrb = {4'b1111};
                   //  illegal_bins wstrb_illegal = {[0:14]};
                   }   
     M2_WSTRB_write  : coverpoint tx.M_WSTRB[2] iff(tx.M_WVALID[2]==1)
                  {
                     bins wstrb = {4'b1111};
                  //   illegal_bins wstrb_illegal = {[0:14]};
                   }   

     endgroup

  function new(string name="axi_subscriber",uvm_component parent);
    super.new(name,parent);
    AXI_cg = new();
    AXI_STRB_cg=new();
  endfunction : new 

  virtual function void write(virtual axi_intf#(WIDTH,SIZE) t);
    this.tx = t;
  endfunction
  
  	task do_sample();
      forever begin
        @(posedge tx.clk iff tx.reset)begin
			AXI_cg.sample();
            AXI_STRB_cg.sample();
		 end
      end
	endtask 
endclass



