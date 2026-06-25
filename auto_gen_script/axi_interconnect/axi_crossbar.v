//******************************************************
// CICC5091, generated axi_crossbar module
//******************************************************
module axi_interconnect
      #(parameter W_CID  = 6           // Channel ID width, 3-bits for slv, 3-bits for mst
                , W_ID   = 6           // ID width in bits
                , W_ADDR = 32          // address width
                , W_LEN  = 8           // burst len
                , W_DATA = 32          // data width
                , W_STRB = (W_DATA/8)  // data strobe width
                , W_SID  = (W_CID+W_ID)// ID for slave
                , SLAVE_EN0  = 1, ADDR_BASE0 = 32'h00001000, ADDR_LENGTH0 = 12 // effective addre bits
                , SLAVE_EN1  = 1, ADDR_BASE1 = 32'h00002000, ADDR_LENGTH1 = 12 // effective addre bits
                , SLAVE_EN2  = 1, ADDR_BASE2 = 32'h00003000, ADDR_LENGTH2 = 12 // effective addre bits
                , SLAVE_EN3  = 1, ADDR_BASE3 = 32'h00004000, ADDR_LENGTH3 = 12 // effective addre bits
                , NUM_M = 4
                , NUM_S = 4
       )
(
         input   wire                      AXI_RSTn
       , input   wire                      AXI_CLK

       //AXI from master
       , input   wire  [W_ID-1:0]          M_AXI_AWID     [0:NUM_M-1]
       , input   wire  [W_ADDR-1:0]        M_AXI_AWADDR   [0:NUM_M-1]
       , input   wire  [W_LEN-1:0]         M_AXI_AWLEN    [0:NUM_M-1]
       , input   wire  [2:0]               M_AXI_AWSIZE   [0:NUM_M-1]
       , input   wire  [1:0]               M_AXI_AWBURST  [0:NUM_M-1]
       , input   wire                      M_AXI_AWVALID  [0:NUM_M-1]
       , output  wire                      M_AXI_AWREADY  [0:NUM_M-1]

       , input   wire  [W_ID-1:0]          M_AXI_WID      [0:NUM_M-1]
       , input   wire  [W_DATA-1:0]        M_AXI_WDATA    [0:NUM_M-1]
       , input   wire  [W_STRB-1:0]        M_AXI_WSTRB    [0:NUM_M-1]
       , input   wire                      M_AXI_WLAST    [0:NUM_M-1]
       , input   wire                      M_AXI_WVALID   [0:NUM_M-1]
       , output  wire                      M_AXI_WREADY   [0:NUM_M-1]

       , output  wire  [W_ID-1:0]          M_AXI_BID      [0:NUM_M-1]
       , output  wire  [1:0]               M_AXI_BRESP    [0:NUM_M-1]
       , output  wire                      M_AXI_BVALID   [0:NUM_M-1]
       , input   wire                      M_AXI_BREADY   [0:NUM_M-1]

       , input   wire  [W_ID-1:0]          M_AXI_ARID     [0:NUM_M-1]
       , input   wire  [W_ADDR-1:0]        M_AXI_ARADDR   [0:NUM_M-1]
       , input   wire  [W_LEN-1:0]         M_AXI_ARLEN    [0:NUM_M-1]
       , input   wire  [2:0]               M_AXI_ARSIZE   [0:NUM_M-1]
       , input   wire  [1:0]               M_AXI_ARBURST  [0:NUM_M-1]
       , input   wire                      M_AXI_ARVALID  [0:NUM_M-1]
       , output  wire                      M_AXI_ARREADY  [0:NUM_M-1]

       , output  wire  [W_ID-1:0]          M_AXI_RID      [0:NUM_M-1]
       , output  wire  [W_DATA-1:0]        M_AXI_RDATA    [0:NUM_M-1]
       , output  wire  [W_STRB-1:0]        M_AXI_RRESP    [0:NUM_M-1]
       , output  wire                      M_AXI_RLAST    [0:NUM_M-1]
       , output  wire                      M_AXI_RVALID   [0:NUM_M-1]
       , input   wire                      M_AXI_RREADY   [0:NUM_M-1]

       //AXI from slaver
       , output  wire   [W_SID-1:0]        S_AXI_AWID     [0:NUM_S-1]
       , output  wire   [W_ADDR-1:0]       S_AXI_AWADDR   [0:NUM_S-1]
       , output  wire   [W_LEN-1:0]        S_AXI_AWLEN    [0:NUM_S-1]
       , output  wire   [2:0]              S_AXI_AWSIZE   [0:NUM_S-1]
       , output  wire   [1:0]              S_AXI_AWBURST  [0:NUM_S-1]
       , output  wire                      S_AXI_AWVALID  [0:NUM_S-1]
       , input   wire                      S_AXI_AWREADY  [0:NUM_S-1]

       , output  wire   [W_SID-1:0]        S_AXI_WID      [0:NUM_S-1]
       , output  wire   [W_DATA-1:0]       S_AXI_WDATA    [0:NUM_S-1]
       , output  wire   [W_STRB-1:0]       S_AXI_WSTRB    [0:NUM_S-1]
       , output  wire                      S_AXI_WLAST    [0:NUM_S-1]
       , output  wire                      S_AXI_WVALID   [0:NUM_S-1]
       , input   wire                      S_AXI_WREADY   [0:NUM_S-1]

       , input   wire   [W_SID-1:0]        S_AXI_BID      [0:NUM_S-1]
       , input   wire   [1:0]              S_AXI_BRESP    [0:NUM_S-1]
       , input   wire                      S_AXI_BVALID   [0:NUM_S-1]
       , output  wire                      S_AXI_BREADY   [0:NUM_S-1]

       , output  wire   [W_SID-1:0]        S_AXI_ARID     [0:NUM_S-1]
       , output  wire   [W_ADDR-1:0]       S_AXI_ARADDR   [0:NUM_S-1]
       , output  wire   [W_LEN-1:0]        S_AXI_ARLEN    [0:NUM_S-1]
       , output  wire   [2:0]              S_AXI_ARSIZE   [0:NUM_S-1]
       , output  wire   [1:0]              S_AXI_ARBURST  [0:NUM_S-1]
       , output  wire                      S_AXI_ARVALID  [0:NUM_S-1]
       , input   wire                      S_AXI_ARREADY  [0:NUM_S-1]

       , input   wire   [W_SID-1:0]        S_AXI_RID      [0:NUM_S-1]
       , input   wire   [W_DATA-1:0]       S_AXI_RDATA    [0:NUM_S-1]
       , input   wire   [1:0]              S_AXI_RRESP    [0:NUM_S-1]
       , input   wire                      S_AXI_RLAST    [0:NUM_S-1]
       , input   wire                      S_AXI_RVALID   [0:NUM_S-1]
       , output  wire                      S_AXI_RREADY   [0:NUM_S-1]

);

wire [W_ID-1:0]       M_AWID    [0:NUM_M-1] ;
wire [W_ADDR-1:0]     M_AWADDR  [0:NUM_M-1] ;
wire [W_LEN-1:0]      M_AWLEN   [0:NUM_M-1] ;
wire [2:0]            M_AWSIZE  [0:NUM_M-1] ;
wire [1:0]            M_AWBURST [0:NUM_M-1] ;
wire                  M_AWVALID [0:NUM_M-1] ;
wire                  M_AWREADY [0:NUM_M-1] ;
wire [W_ID-1:0]       M_WID     [0:NUM_M-1] ;
wire [W_DATA-1:0]     M_WDATA   [0:NUM_M-1] ;
wire [W_STRB-1:0]     M_WSTRB   [0:NUM_M-1] ;
wire                  M_WLAST   [0:NUM_M-1] ;
wire                  M_WVALID  [0:NUM_M-1] ;
wire                  M_WREADY  [0:NUM_M-1] ;
wire [W_ID-1:0]       M_BID     [0:NUM_M-1] ;
wire [1:0]            M_BRESP   [0:NUM_M-1] ;
wire                  M_BVALID  [0:NUM_M-1] ;
wire                  M_BREADY  [0:NUM_M-1] ;

wire [W_ID-1:0]       M_ARID    [0:NUM_M-1] ;
wire [W_ADDR-1:0]     M_ARADDR  [0:NUM_M-1] ;
wire [W_LEN-1:0]      M_ARLEN   [0:NUM_M-1] ;
wire [2:0]            M_ARSIZE  [0:NUM_M-1] ;
wire [1:0]            M_ARBURST [0:NUM_M-1] ;
wire                  M_ARVALID [0:NUM_M-1] ;
wire                  M_ARREADY [0:NUM_M-1] ;
wire [W_SID-1:0]      M_RSID    [0:NUM_M-1] ;
wire [W_DATA-1:0]     M_RDATA   [0:NUM_M-1] ;
wire [1:0]            M_RRESP   [0:NUM_M-1] ;
wire                  M_RLAST   [0:NUM_M-1] ;
wire                  M_RVALID  [0:NUM_M-1] ;
wire                  M_RREADY  [0:NUM_M-1] ;

wire [W_SID-1:0]      S_AWID    [0:NUM_S-1] ;
wire [W_ADDR-1:0]     S_AWADDR  [0:NUM_S-1] ;
wire [W_LEN-1:0]      S_AWLEN   [0:NUM_S-1] ;
wire [2:0]            S_AWSIZE  [0:NUM_S-1] ;
wire [1:0]            S_AWBURST [0:NUM_S-1] ;
wire                  S_AWVALID [0:NUM_S-1] ;
wire                  S_AWREADY [0:NUM_S-1] ;
wire [W_SID-1:0]      S_WID     [0:NUM_S-1] ;
wire [W_DATA-1:0]     S_WDATA   [0:NUM_S-1] ;
wire [W_STRB-1:0]     S_WSTRB   [0:NUM_S-1] ;
wire                  S_WLAST   [0:NUM_S-1] ;
wire                  S_WVALID  [0:NUM_S-1] ;
wire                  S_WREADY  [0:NUM_S-1] ;
wire [W_SID-1:0]      S_BID     [0:NUM_S-1] ;
wire [1:0]            S_BRESP   [0:NUM_S-1] ;
wire                  S_BVALID  [0:NUM_S-1] ;
wire                  S_BREADY  [0:NUM_S-1] ;

wire [W_SID-1:0]      S_ARID    [0:NUM_S-1] ;
wire [W_ADDR-1:0]     S_ARADDR  [0:NUM_S-1] ;
wire [W_LEN-1:0]      S_ARLEN   [0:NUM_S-1] ;
wire [2:0]            S_ARSIZE  [0:NUM_S-1] ;
wire [1:0]            S_ARBURST [0:NUM_S-1] ;
wire                  S_ARVALID [0:NUM_S-1] ;
wire                  S_ARREADY [0:NUM_S-1] ;
wire [W_SID-1:0]      S_RID     [0:NUM_S-1] ;
wire [W_DATA-1:0]     S_RDATA   [0:NUM_S-1] ;
wire [1:0]            S_RRESP   [0:NUM_S-1] ;
wire                  S_RLAST   [0:NUM_S-1] ;
wire                  S_RVALID  [0:NUM_S-1] ;
wire                  S_RREADY  [0:NUM_S-1] ;

wire      [W_ID-1:0]       c4k_arid    [0:NUM_M-1] ;
wire      [W_ADDR-1:0]     c4k_araddr  [0:NUM_M-1] ;
wire      [W_LEN-1:0]      c4k_arlen   [0:NUM_M-1] ;
wire      [2:0]            c4k_arsize  [0:NUM_M-1] ;
wire      [1:0]            c4k_arburst [0:NUM_M-1] ;
wire                       c4k_arvalid [0:NUM_M-1] ;
wire                       c4k_arready [0:NUM_M-1] ;
wire      [W_ID-1:0]       c4k_awid    [0:NUM_M-1] ;
wire      [W_ADDR-1:0]     c4k_awaddr  [0:NUM_M-1] ;
wire      [W_LEN-1:0]      c4k_awlen   [0:NUM_M-1] ;
wire      [2:0]            c4k_awsize  [0:NUM_M-1] ;
wire      [1:0]            c4k_awburst [0:NUM_M-1] ;
wire                       c4k_awvalid [0:NUM_M-1] ;
wire                       c4k_awready [0:NUM_M-1] ;

wire [NUM_S-1:0] s_push_srid_rdy    ;
wire [W_SID-1:0] ar_sid_buffer [0:3];
wire [NUM_S-1:0] r_order_grant      ;

wire [NUM_M-1:0] m_rsid_clr_rdy     ;
wire [NUM_S-1:0] S_ARREADY_in       ; 
wire [NUM_M-1:0] M_RREADY_in        ; 
                                      
wire [NUM_S-1:0] fifo_ar_sx_vld     ; 
wire [NUM_M-1:0] fifo_r_mx_vld      ; 
wire [NUM_S-1:0] s_push_swid_rdy    ;
wire [W_SID-1:0] aw_sid_buffer [0:3];
wire [NUM_M-1:0] w_order_grant      ;

wire [NUM_S-1:0] s_wsid_clr_rdy     ;
wire [NUM_S-1:0] S_AWREADY_in       ;
wire [NUM_S-1:0] S_WREADY_in        ;
                                     
wire [NUM_S-1:0] fifo_aw_sx_vld     ;
wire [NUM_S-1:0] fifo_w_sx_vld      ;

//-------for r reorder-------                                        
genvar i;                                                            
generate;                                                            
    for (i = 0; i < NUM_S; i = i + 1) begin                          
        assign S_ARREADY_in  [i] = S_ARREADY[i] & s_push_srid_rdy[i];
        assign fifo_ar_sx_vld[i] = S_ARVALID[i] & s_push_srid_rdy[i];
end                                                                  
endgenerate                                                          
                                                                     
generate;                                                            
    for (i = 0; i < NUM_M; i = i + 1) begin                          
        assign M_RREADY_in  [i] = M_RREADY[i] & m_rsid_clr_rdy[i];   
        assign fifo_r_mx_vld[i] = M_RVALID[i] & m_rsid_clr_rdy[i];   
end                                                                  
endgenerate                                                          
                                                                     
                                                                     
//-------for w reorder-------                                        
generate;                                                            
    for (i = 0; i < NUM_S; i = i + 1) begin                          
        assign S_AWREADY_in  [i] = S_AWREADY[i] & s_push_swid_rdy[i];
        assign fifo_aw_sx_vld[i] = S_AWVALID[i] & s_push_swid_rdy[i];
        assign S_WREADY_in   [i] = S_WREADY[i] & s_wsid_clr_rdy      
        assign fifo_w_sx_vld [i] = S_WVALID[i] & s_wsid_clr_rdy;     
end                                                                  
endgenerate                                                          

//--------------------CROSS 4K PROCESS---------------     
genvar i;                                                 
generate                                                  
    for (i = 0; i < NUM_M; i++) begin:mx_cross_4k_if          
        cross_4k_if #()                                   
        mx_cross_4k_if(                                   
            .clk                       (AXI_CLK         ),
            .rst_n                     (AXI_RSTn        ),
            // input                                      
            .m_axi_arid                (M_AXI_ARID   [i]),
            .m_axi_araddr              (M_AXI_ARADDR [i]),
            .m_axi_arlen               (M_AXI_ARLEN  [i]),
            .m_axi_arsize              (M_AXI_ARSIZE [i]),
            .m_axi_arburst             (M_AXI_ARBURST[i]),
            .m_axi_arvalid             (M_AXI_ARVALID[i]),
            .m_axi_arready             (M_AXI_ARREADY[i]),

            .m_axi_awid                (M_AXI_AWID   [i]),
            .m_axi_awaddr              (M_AXI_AWADDR [i]),
            .m_axi_awlen               (M_AXI_AWLEN  [i]),
            .m_axi_awsize              (M_AXI_AWSIZE [i]),
            .m_axi_awburst             (M_AXI_AWBURST[i]),
            .m_axi_awvalid             (M_AXI_AWVALID[i]),
            .m_axi_awready             (M_AXI_AWREADY[i]),
            // output                                     
            .s_axi_arid                (c4k_arid   [i]  ),
            .s_axi_araddr              (c4k_araddr [i]  ),
            .s_axi_arlen               (c4k_arlen  [i]  ),
            .s_axi_arsize              (c4k_arsize [i]  ),
            .s_axi_arburst             (c4k_arburst[i]  ),
            .s_axi_arvalid             (c4k_arvalid[i]  ),
            .s_axi_arready             (c4k_arready[i]  ),

            .s_axi_awid                (c4k_awid   [i]  ),
            .s_axi_awaddr              (c4k_awaddr [i]  ),
            .s_axi_awlen               (c4k_awlen  [i]  ),
            .s_axi_awsize              (c4k_awsize [i]  ),
            .s_axi_awburst             (c4k_awburst[i]  ),
            .s_axi_awvalid             (c4k_awvalid[i]  ),
            .s_axi_awready             (c4k_awready[i]  ) 
        );                                                
    end                                                   
endgenerate                                               

//---------------------AR_* fifo----------------------                                             
//axi_interconnect slave interface, signals from mst                                               
generate                                                                                           
    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_ar_mx                                             
        axi_fifo_sync #(.FDW(W_ID+W_ADDR+W_LEN+3+2), .FAW(2)) //fifo depth == 4                    
        u_fifo_ar_mx(                                                                              
              .rstn     (AXI_RSTn      )                                                           
            , .clr      (1'b0          )                                                           
            , .clk      (AXI_CLK       )                                                           
            , .wr_rdy   (c4k_arready[i])                                                           
            , .wr_vld   (c4k_arvalid[i])                                                           
            , .wr_din   ({c4k_arid[i], c4k_araddr[i], c4k_arlen[i], c4k_arsize[i], c4k_arburst[i]})
            , .rd_rdy   (M_ARREADY[i])                                                             
            , .rd_vld   (M_ARVALID[i])                                                             
            , .rd_dout  ({M_ARID[i], M_ARADDR[i], M_ARLEN[i], M_ARSIZE[i], M_ARBURST[i]})          
        );                                                                                         
    end                                                                                            
endgenerate                                                                                        
//axi_interconnect master interface, signals to slv                                                
generate                                                                                           
    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_ar_sx                                             
        axi_fifo_sync #(.FDW(W_SID+W_ADDR+W_LEN+3+2), .FAW(2))                                     
        u_fifo_ar_sx(                                                                              
              .rstn     (AXI_RSTn    )                                                             
            , .clr      (1'b0        )                                                             
            , .clk      (AXI_CLK     )                                                             
            , .wr_rdy   (S_ARREADY[i])                                                             
            , .wr_vld   (fifo_ar_sx_vld[i])                                                        
            , .wr_din   ({S_ARID[i], S_ARADDR[i], S_ARLEN[i], S_ARSIZE[i], S_ARBURST[i]})          
            , .rd_rdy   (S_AXI_ARREADY[i])                                                         
            , .rd_vld   (S_AXI_ARVALID[i])                                                         
            , .rd_dout  ({S_AXI_ARID[i], S_AXI_ARADDR[i], S_AXI_ARLEN[i], S_AXI_ARSIZE[i], S_AXI_ARBURST[i]})
        );                                                                                         
    end                                                                                            
endgenerate                                                                                        

//---------------------R_* fifo----------------------                                   
//axi_interconnect slave interface, signals from slv                                    
generate                                                                                
    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_r_sx                                   
        axi_fifo_sync #(.FDW(W_SID+W_DATA+2+1), .FAW(2))                                
        u_fifo_r_sx(                                                                    
              .rstn     (AXI_RSTn  )                                                    
            , .clr      (1'b0      )                                                    
            , .clk      (AXI_CLK   )                                                    
            , .wr_rdy   (S_AXI_RREADY[i])                                               
            , .wr_vld   (S_AXI_RVALID[i])                                               
            , .wr_din   ({S_AXI_RID[i], S_AXI_RDATA[i], S_AXI_RRESP[i], S_AXI_RLAST[i]})
            , .rd_rdy   (S_RREADY[i])                                                   
            , .rd_vld   (S_RVALID[i])                                                   
            , .rd_dout  ({S_RID[i], S_RDATA[i], S_RRESP[i], S_RLAST[i]})                
        );                                                                              
    end                                                                                 
endgenerate                                                                             
//axi_interconnect master interface, signals to mst                                     
generate                                                                                
    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_r_mx                                   
        axi_fifo_sync #(.FDW(W_ID+W_DATA+2+1), .FAW(2))                                     
        u_fifo_r_mx(                                                                    
            .rstn     (AXI_RSTn   )                                                     
          , .clr      (1'b0       )                                                     
          , .clk      (AXI_CLK    )                                                     
          , .wr_rdy   (M_RREADY[i])                                                     
          , .wr_vld   (fifo_r_mx_vld[i])                                                
          , .wr_din   ({M_RSID[i][W_ID-1:0], M_RDATA[i], M_RRESP[i], M_RLAST[i]})       
          , .rd_rdy   (M_AXI_RREADY[i])                                                 
          , .rd_vld   (M_AXI_RVALID[i])                                                 
          , .rd_dout  ({M_AXI_RID[i], M_AXI_RDATA[i], M_AXI_RRESP[i], M_AXI_RLAST[i]})  
      );                                                                                
    end                                                                                 
endgenerate                                                                             

//---------------------AW_* fifo----------------------                                                       
//axi slave interface, signals from master                                                                   
generate                                                                                                     
    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_aw_mx                                                       
        axi_fifo_sync #(.FDW(W_ID+W_ADDR+W_LEN+3+2), .FAW(2))                                                
        u_fifo_aw_mx(                                                                                        
              .rstn     (AXI_RSTn      )                                                                     
            , .clr      (1'b0          )                                                                     
            , .clk      (AXI_CLK       )                                                                     
            , .wr_rdy   (c4k_awready[i])                                                                     
            , .wr_vld   (c4k_awvalid[i])                                                                     
            , .wr_din   ({c4k_awid[i], c4k_awaddr[i], c4k_awlen[i], c4k_awsize[i], c4k_awburst[i]})          
                                                                                                             
            , .rd_rdy   (M_AWREADY[i])                                                                       
            , .rd_vld   (M_AWVALID[i])                                                                       
            , .rd_dout  ({M_AWID[i], M_AWADDR[i], M_AWLEN[i], M_AWSIZE[i], M_AWBURST[i]})                    
        );                                                                                                   
    end                                                                                                      
endgenerate                                                                                                  
//axi master interface, signals to slaver                                                                    
generate                                                                                                     
    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_aw_sx                                                       
        axi_fifo_sync #(.FDW(W_SID+W_ADDR+W_LEN+3+2), .FAW(2))                                               
        u_fifo_aw_sx(                                                                                        
              .rstn     (AXI_RSTn)                                                                           
            , .clr      (1'b0   )                                                                            
            , .clk      (AXI_CLK   )                                                                         
            , .wr_rdy   (S_AWREADY[i])                                                                       
            , .wr_vld   (fifo_aw_sx_vld[i])                                                                  
            , .wr_din   ({S_AWID[i], S_AWADDR[i], S_AWLEN[i], S_AWSIZE[i], S_AWBURST[i]})                    
            , .rd_rdy   (S_AXI_AWREADY[i])                                                                   
            , .rd_vld   (S_AXI_AWVALID[i])                                                                   
            , .rd_dout  ({S_AXI_AWID[i], S_AXI_AWADDR[i], S_AXI_AWLEN[i], S_AXI_AWSIZE[i], S_AXI_AWBURST[i]})
        );                                                                                                   
    end                                                                                                      
endgenerate                                                                                                  

//---------------------W_* fifo----------------------                                   
generate                                                                                
    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_w_mx                                   
        axi_fifo_sync #(.FDW(W_ID+W_DATA+4+1), .FAW(2))                                 
        u_fifo_w_mx(                                                                    
              .rstn     (AXI_RSTn)                                                      
            , .clr      (1'b0   )                                                       
            , .clk      (AXI_CLK   )                                                    
            , .wr_rdy   (M_AXI_WREADY[i])                                               
            , .wr_vld   (M_AXI_WVALID[i])                                               
            , .wr_din   ({M_AXI_WID[i], M_AXI_WDATA[i], M_AXI_WSTRB[i], M_AXI_WLAST[i]})
            , .rd_rdy   (M_WREADY[i])                                                   
            , .rd_vld   (M_WVALID[i])                                                   
            , .rd_dout  ({M_WID[i], M_WDATA[i], M_WSTRB[i], M_WLAST[i]})                
        );                                                                              
    end                                                                                 
endgenerate                                                                             
generate                                                                                
    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_w_sx                                   
        axi_fifo_sync #(.FDW(W_SID+W_DATA+4+1), .FAW(2))                                
        u_fifo_w_sx(                                                                    
              .rstn     (AXI_RSTn)                                                      
            , .clr      (1'b0   )                                                       
            , .clk      (AXI_CLK   )                                                    
            , .wr_rdy   (S_WREADY[i])                                                   
            , .wr_vld   (fifo_w_sx_vld[i])                                              
            , .wr_din   ({S_WID[i], S_WDATA[i], S_WSTRB[i], S_WLAST[i]})                
            , .rd_rdy   (S_AXI_WREADY[i])                                               
            , .rd_vld   (S_AXI_WVALID[i])                                               
            , .rd_dout  ({S_AXI_WID[i], S_AXI_WDATA[i], S_AXI_WSTRB[i], S_AXI_WLAST[i]})
        );                                                                              
    end                                                                                 
endgenerate                                                                             

//---------------------B_* fifo----------------------   
generate                                                
    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_b_sx   
        axi_fifo_sync #(.FDW(W_SID+2), .FAW(2))         
        u_fifo_b_sx(                                    
              .rstn     (AXI_RSTn)                      
            , .clr      (1'b0   )                       
            , .clk      (AXI_CLK   )                    
            , .wr_rdy   (S_AXI_BREADY[i])               
            , .wr_vld   (S_AXI_BVALID[i])               
            , .wr_din   ({S_AXI_BID[i], S_AXI_BRESP[i]})
            , .rd_rdy   (S_BREADY[i])                   
            , .rd_vld   (S_BVALID[i])                   
            , .rd_dout  ({S_BID[i], S_BRESP[i]})        
        );                                              
    end                                                 
endgenerate                                             
generate                                                
    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_b_mx   
        axi_fifo_sync #(.FDW(W_ID+2), .FAW(2))          
        u_fifo_b_mx(                                    
              .rstn     (AXI_RSTn)                      
            , .clr      (1'b0   )                       
            , .clk      (AXI_CLK   )                    
            , .wr_rdy   (M_BREADY[i])                   
            , .wr_vld   (M_BVALID[i])                   
            , .wr_din   ({M_BID[i], M_BRESP[i]})        
            , .rd_rdy   (M_AXI_BREADY[i])               
            , .rd_vld   (M_AXI_BVALID[i])               
            , .rd_dout  ({M_AXI_BID[i], M_AXI_BRESP[i]})
        );                                              
    end                                                 
endgenerate                                             

axi_crossbar #(
)
    u_axi_crossbar(                                                     
      .AXI_RSTn                           (AXI_RSTn                    )
    , .AXI_CLK                            (AXI_CLK                     )

    , .M0_MID                             (3'b001 + 0                  )
    , .M0_AWID                            (M_AWID    [0]               )
    , .M0_AWADDR                          (M_AWADDR  [0]               )
    , .M0_AWLEN                           (M_AWLEN   [0]               )
    , .M0_AWSIZE                          (M_AWSIZE  [0]               )
    , .M0_AWBURST                         (M_AWBURST [0]               )
    , .M0_AWVALID                         (M_AWVALID [0]               )
    , .M0_AWREADY                         (M_AWREADY [0]               )
    , .M0_WID                             (M_WID     [0]               )
    , .M0_WDATA                           (M_WDATA   [0]               )
    , .M0_WSTRB                           (M_WSTRB   [0]               )
    , .M0_WLAST                           (M_WLAST   [0]               )
    , .M0_WVALID                          (M_WVALID  [0]               )
    , .M0_WREADY                          (M_WREADY  [0]               )
    , .M0_BID                             (M_BID     [0]               )
    , .M0_BRESP                           (M_BRESP   [0]               )
    , .M0_BVALID                          (M_BVALID  [0]               )
    , .M0_BREADY                          (M_BREADY  [0]               )

    , .M0_ARID                            (M_ARID     [0]              )
    , .M0_ARADDR                          (M_ARADDR   [0]              )
    , .M0_ARLEN                           (M_ARLEN    [0]              )
    , .M0_ARSIZE                          (M_ARSIZE   [0]              )
    , .M0_ARBURST                         (M_ARBURST  [0]              )
    , .M0_ARVALID                         (M_ARVALID  [0]              )
    , .M0_ARREADY                         (M_ARREADY  [0]              )
    , .M0_RSID                            (M_RSID     [0]              )
    , .M0_RDATA                           (M_RDATA    [0]              )
    , .M0_RRESP                           (M_RRESP    [0]              )
    , .M0_RLAST                           (M_RLAST    [0]              )
    , .M0_RVALID                          (M_RVALID   [0]              )
    , .M0_RREADY                          (M_RREADY_in[0]              )

    , .M1_MID                             (3'b001 + 1                  )
    , .M1_AWID                            (M_AWID    [1]               )
    , .M1_AWADDR                          (M_AWADDR  [1]               )
    , .M1_AWLEN                           (M_AWLEN   [1]               )
    , .M1_AWSIZE                          (M_AWSIZE  [1]               )
    , .M1_AWBURST                         (M_AWBURST [1]               )
    , .M1_AWVALID                         (M_AWVALID [1]               )
    , .M1_AWREADY                         (M_AWREADY [1]               )
    , .M1_WID                             (M_WID     [1]               )
    , .M1_WDATA                           (M_WDATA   [1]               )
    , .M1_WSTRB                           (M_WSTRB   [1]               )
    , .M1_WLAST                           (M_WLAST   [1]               )
    , .M1_WVALID                          (M_WVALID  [1]               )
    , .M1_WREADY                          (M_WREADY  [1]               )
    , .M1_BID                             (M_BID     [1]               )
    , .M1_BRESP                           (M_BRESP   [1]               )
    , .M1_BVALID                          (M_BVALID  [1]               )
    , .M1_BREADY                          (M_BREADY  [1]               )

    , .M1_ARID                            (M_ARID     [1]              )
    , .M1_ARADDR                          (M_ARADDR   [1]              )
    , .M1_ARLEN                           (M_ARLEN    [1]              )
    , .M1_ARSIZE                          (M_ARSIZE   [1]              )
    , .M1_ARBURST                         (M_ARBURST  [1]              )
    , .M1_ARVALID                         (M_ARVALID  [1]              )
    , .M1_ARREADY                         (M_ARREADY  [1]              )
    , .M1_RSID                            (M_RSID     [1]              )
    , .M1_RDATA                           (M_RDATA    [1]              )
    , .M1_RRESP                           (M_RRESP    [1]              )
    , .M1_RLAST                           (M_RLAST    [1]              )
    , .M1_RVALID                          (M_RVALID   [1]              )
    , .M1_RREADY                          (M_RREADY_in[1]              )

    , .M2_MID                             (3'b001 + 2                  )
    , .M2_AWID                            (M_AWID    [2]               )
    , .M2_AWADDR                          (M_AWADDR  [2]               )
    , .M2_AWLEN                           (M_AWLEN   [2]               )
    , .M2_AWSIZE                          (M_AWSIZE  [2]               )
    , .M2_AWBURST                         (M_AWBURST [2]               )
    , .M2_AWVALID                         (M_AWVALID [2]               )
    , .M2_AWREADY                         (M_AWREADY [2]               )
    , .M2_WID                             (M_WID     [2]               )
    , .M2_WDATA                           (M_WDATA   [2]               )
    , .M2_WSTRB                           (M_WSTRB   [2]               )
    , .M2_WLAST                           (M_WLAST   [2]               )
    , .M2_WVALID                          (M_WVALID  [2]               )
    , .M2_WREADY                          (M_WREADY  [2]               )
    , .M2_BID                             (M_BID     [2]               )
    , .M2_BRESP                           (M_BRESP   [2]               )
    , .M2_BVALID                          (M_BVALID  [2]               )
    , .M2_BREADY                          (M_BREADY  [2]               )

    , .M2_ARID                            (M_ARID     [2]              )
    , .M2_ARADDR                          (M_ARADDR   [2]              )
    , .M2_ARLEN                           (M_ARLEN    [2]              )
    , .M2_ARSIZE                          (M_ARSIZE   [2]              )
    , .M2_ARBURST                         (M_ARBURST  [2]              )
    , .M2_ARVALID                         (M_ARVALID  [2]              )
    , .M2_ARREADY                         (M_ARREADY  [2]              )
    , .M2_RSID                            (M_RSID     [2]              )
    , .M2_RDATA                           (M_RDATA    [2]              )
    , .M2_RRESP                           (M_RRESP    [2]              )
    , .M2_RLAST                           (M_RLAST    [2]              )
    , .M2_RVALID                          (M_RVALID   [2]              )
    , .M2_RREADY                          (M_RREADY_in[2]              )

    , .M3_MID                             (3'b001 + 3                  )
    , .M3_AWID                            (M_AWID    [3]               )
    , .M3_AWADDR                          (M_AWADDR  [3]               )
    , .M3_AWLEN                           (M_AWLEN   [3]               )
    , .M3_AWSIZE                          (M_AWSIZE  [3]               )
    , .M3_AWBURST                         (M_AWBURST [3]               )
    , .M3_AWVALID                         (M_AWVALID [3]               )
    , .M3_AWREADY                         (M_AWREADY [3]               )
    , .M3_WID                             (M_WID     [3]               )
    , .M3_WDATA                           (M_WDATA   [3]               )
    , .M3_WSTRB                           (M_WSTRB   [3]               )
    , .M3_WLAST                           (M_WLAST   [3]               )
    , .M3_WVALID                          (M_WVALID  [3]               )
    , .M3_WREADY                          (M_WREADY  [3]               )
    , .M3_BID                             (M_BID     [3]               )
    , .M3_BRESP                           (M_BRESP   [3]               )
    , .M3_BVALID                          (M_BVALID  [3]               )
    , .M3_BREADY                          (M_BREADY  [3]               )

    , .M3_ARID                            (M_ARID     [3]              )
    , .M3_ARADDR                          (M_ARADDR   [3]              )
    , .M3_ARLEN                           (M_ARLEN    [3]              )
    , .M3_ARSIZE                          (M_ARSIZE   [3]              )
    , .M3_ARBURST                         (M_ARBURST  [3]              )
    , .M3_ARVALID                         (M_ARVALID  [3]              )
    , .M3_ARREADY                         (M_ARREADY  [3]              )
    , .M3_RSID                            (M_RSID     [3]              )
    , .M3_RDATA                           (M_RDATA    [3]              )
    , .M3_RRESP                           (M_RRESP    [3]              )
    , .M3_RLAST                           (M_RLAST    [3]              )
    , .M3_RVALID                          (M_RVALID   [3]              )
    , .M3_RREADY                          (M_RREADY_in[3]              )

    , .S0_AWID                            (S_AWID      [0]             )
    , .S0_AWADDR                          (S_AWADDR    [0]             )
    , .S0_AWLEN                           (S_AWLEN     [0]             )
    , .S0_AWSIZE                          (S_AWSIZE    [0]             )
    , .S0_AWBURST                         (S_AWBURST   [0]             )
    , .S0_AWVALID                         (S_AWVALID   [0]             )
    , .S0_AWREADY                         (S_AWREADY_in[0]             )
    , .S0_WID                             (S_WID       [0]             )
    , .S0_WDATA                           (S_WDATA     [0]             )
    , .S0_WSTRB                           (S_WSTRB     [0]             )
    , .S0_WLAST                           (S_WLAST     [0]             )
    , .S0_WVALID                          (S_WVALID    [0]             )
    , .S0_WREADY                          (S_WREADY_in [0]             )
    , .S0_BID                             (S_BID       [0]             )
    , .S0_BRESP                           (S_BRESP     [0]             )
    , .S0_BVALID                          (S_BVALID    [0]             )
    , .S0_BREADY                          (S_BREADY    [0]             )

    , .S0_ARID                            (S_ARID      [0]               )
    , .S0_ARADDR                          (S_ARADDR    [0]               )
    , .S0_ARLEN                           (S_ARLEN     [0]               )
    , .S0_ARSIZE                          (S_ARSIZE    [0]               )
    , .S0_ARBURST                         (S_ARBURST   [0]               )
    , .S0_ARVALID                         (S_ARVALID   [0]               )
    , .S0_ARREADY                         (S_ARREADY_in[0]               )
    , .S0_RID                             (S_RID       [0]               )
    , .S0_RDATA                           (S_RDATA     [0]               )
    , .S0_RRESP                           (S_RRESP     [0]               )
    , .S0_RLAST                           (S_RLAST     [0]               )
    , .S0_RVALID                          (S_RVALID    [0]               )
    , .S0_RREADY                          (S_RREADY    [0]               )

    , .S1_AWID                            (S_AWID      [1]             )
    , .S1_AWADDR                          (S_AWADDR    [1]             )
    , .S1_AWLEN                           (S_AWLEN     [1]             )
    , .S1_AWSIZE                          (S_AWSIZE    [1]             )
    , .S1_AWBURST                         (S_AWBURST   [1]             )
    , .S1_AWVALID                         (S_AWVALID   [1]             )
    , .S1_AWREADY                         (S_AWREADY_in[1]             )
    , .S1_WID                             (S_WID       [1]             )
    , .S1_WDATA                           (S_WDATA     [1]             )
    , .S1_WSTRB                           (S_WSTRB     [1]             )
    , .S1_WLAST                           (S_WLAST     [1]             )
    , .S1_WVALID                          (S_WVALID    [1]             )
    , .S1_WREADY                          (S_WREADY_in [1]             )
    , .S1_BID                             (S_BID       [1]             )
    , .S1_BRESP                           (S_BRESP     [1]             )
    , .S1_BVALID                          (S_BVALID    [1]             )
    , .S1_BREADY                          (S_BREADY    [1]             )

    , .S1_ARID                            (S_ARID      [1]               )
    , .S1_ARADDR                          (S_ARADDR    [1]               )
    , .S1_ARLEN                           (S_ARLEN     [1]               )
    , .S1_ARSIZE                          (S_ARSIZE    [1]               )
    , .S1_ARBURST                         (S_ARBURST   [1]               )
    , .S1_ARVALID                         (S_ARVALID   [1]               )
    , .S1_ARREADY                         (S_ARREADY_in[1]               )
    , .S1_RID                             (S_RID       [1]               )
    , .S1_RDATA                           (S_RDATA     [1]               )
    , .S1_RRESP                           (S_RRESP     [1]               )
    , .S1_RLAST                           (S_RLAST     [1]               )
    , .S1_RVALID                          (S_RVALID    [1]               )
    , .S1_RREADY                          (S_RREADY    [1]               )

    , .S2_AWID                            (S_AWID      [2]             )
    , .S2_AWADDR                          (S_AWADDR    [2]             )
    , .S2_AWLEN                           (S_AWLEN     [2]             )
    , .S2_AWSIZE                          (S_AWSIZE    [2]             )
    , .S2_AWBURST                         (S_AWBURST   [2]             )
    , .S2_AWVALID                         (S_AWVALID   [2]             )
    , .S2_AWREADY                         (S_AWREADY_in[2]             )
    , .S2_WID                             (S_WID       [2]             )
    , .S2_WDATA                           (S_WDATA     [2]             )
    , .S2_WSTRB                           (S_WSTRB     [2]             )
    , .S2_WLAST                           (S_WLAST     [2]             )
    , .S2_WVALID                          (S_WVALID    [2]             )
    , .S2_WREADY                          (S_WREADY_in [2]             )
    , .S2_BID                             (S_BID       [2]             )
    , .S2_BRESP                           (S_BRESP     [2]             )
    , .S2_BVALID                          (S_BVALID    [2]             )
    , .S2_BREADY                          (S_BREADY    [2]             )

    , .S2_ARID                            (S_ARID      [2]               )
    , .S2_ARADDR                          (S_ARADDR    [2]               )
    , .S2_ARLEN                           (S_ARLEN     [2]               )
    , .S2_ARSIZE                          (S_ARSIZE    [2]               )
    , .S2_ARBURST                         (S_ARBURST   [2]               )
    , .S2_ARVALID                         (S_ARVALID   [2]               )
    , .S2_ARREADY                         (S_ARREADY_in[2]               )
    , .S2_RID                             (S_RID       [2]               )
    , .S2_RDATA                           (S_RDATA     [2]               )
    , .S2_RRESP                           (S_RRESP     [2]               )
    , .S2_RLAST                           (S_RLAST     [2]               )
    , .S2_RVALID                          (S_RVALID    [2]               )
    , .S2_RREADY                          (S_RREADY    [2]               )

    , .S3_AWID                            (S_AWID      [3]             )
    , .S3_AWADDR                          (S_AWADDR    [3]             )
    , .S3_AWLEN                           (S_AWLEN     [3]             )
    , .S3_AWSIZE                          (S_AWSIZE    [3]             )
    , .S3_AWBURST                         (S_AWBURST   [3]             )
    , .S3_AWVALID                         (S_AWVALID   [3]             )
    , .S3_AWREADY                         (S_AWREADY_in[3]             )
    , .S3_WID                             (S_WID       [3]             )
    , .S3_WDATA                           (S_WDATA     [3]             )
    , .S3_WSTRB                           (S_WSTRB     [3]             )
    , .S3_WLAST                           (S_WLAST     [3]             )
    , .S3_WVALID                          (S_WVALID    [3]             )
    , .S3_WREADY                          (S_WREADY_in [3]             )
    , .S3_BID                             (S_BID       [3]             )
    , .S3_BRESP                           (S_BRESP     [3]             )
    , .S3_BVALID                          (S_BVALID    [3]             )
    , .S3_BREADY                          (S_BREADY    [3]             )

    , .S3_ARID                            (S_ARID      [3]               )
    , .S3_ARADDR                          (S_ARADDR    [3]               )
    , .S3_ARLEN                           (S_ARLEN     [3]               )
    , .S3_ARSIZE                          (S_ARSIZE    [3]               )
    , .S3_ARBURST                         (S_ARBURST   [3]               )
    , .S3_ARVALID                         (S_ARVALID   [3]               )
    , .S3_ARREADY                         (S_ARREADY_in[3]               )
    , .S3_RID                             (S_RID       [3]               )
    , .S3_RDATA                           (S_RDATA     [3]               )
    , .S3_RRESP                           (S_RRESP     [3]               )
    , .S3_RLAST                           (S_RLAST     [3]               )
    , .S3_RVALID                          (S_RVALID    [3]               )
    , .S3_RREADY                          (S_RREADY    [3]               )

, .r_order_grant                      (r_order_grant               ) //input   wire  [11:0]  [0:3]
, .w_order_grant                      (w_order_grant               )

    );

//{{ ******* READ TRANSACTION REORDER *********
sid_buffer #(.NUM(NUM_M)) u_ar_sid_buffer(
.clk             (AXI_CLK           ),     //input
.rstn            (AXI_RSTn          ),     //input

// --------------Write buffer------------
.s_axid         (S_ARID         ),     //input [12-1:0]
.s_axid_vld     (S_ARVALID      ),     //input      
.s_fifo_rdy     (S_ARREADY      ),     //input      
.s_push_rdy     (s_push_srid_rdy),     //output     

//------Clean buffer and ajust position--------
.last          (M_RLAST        ),     //input          
.sid           (M_RSID         ),     //input [11:0]    
.sid_vld       (M_RVALID       ),     //input          
.sid_clr_rdy   (m_rsid_clr_rdy ),     //output       
.sid_buffer      (ar_sid_buffer)      //output reg [11:0] [0:3]
);

reorder #(.NUM_SID(NUM_S)) ar_reorder(
.clk            (AXI_CLK       ),    //input      
.rstn           (AXI_RSTn      ),    //input      

.sid            (S_RID         ),    //input [11:0]
.sid_vld        (S_RVALID      ),    //input      
.rob_buffer     (ar_sid_buffer ),    //input [11:0] [0:3]
.order_grant    (r_order_grant )     //output reg [2:0]
);

//{{ ******* WRITE TRANSACTION REORDER *********
sid_buffer #(.NUM(NUM_M)) u_aw_sid_buffer(
.clk           (AXI_CLK      ),     //input            
.rstn          (AXI_RSTn     ),     //input  

//--------------Write buffer------------
.s_axid         (S_AWID         ),     //input [11:0]      
.s_axid_vld     (S_AWVALID      ),     //input            
.s_fifo_rdy     (S_AWREADY      ),     //input            
.s_push_rdy     (s_push_swid_rdy),     //output           

//------Clean buffer and ajust position--------
.last          (S_WLAST        ),     //input            
.sid           (S_WID          ),     //input [11:0]      
.sid_vld       (S_WVALID       ),     //input            
.sid_clr_rdy   (s_wsid_clr_rdy ),     //output           
.sid_buffer      (aw_sid_buffer)      //output reg [11:0] [0:3]
);
wire [W_SID-1:0] sid_array[NUM_M-1:0];
wire [NUM_M-1:0] sid_vld_array;

generate
    genvar i;
    for (i = 0; i < NUM_M; i = i + 1) begin : GEN_SID
        assign sid_array[i] = {M_WID[i][5:3], (3'b001 + i), M_WID[i]};
        assign sid_vld_array[i] = M_WVALID[i];
    end
endgenerate

reorder #(.NUM_SID(NUM_M)) aw_reorder (
    .clk         (AXI_CLK),            // input            
    .rstn        (AXI_RSTn),           // input            
    .sid         (sid_array),          // input [11:0] [NUM_M-1:0]
    .sid_vld     (sid_vld_array),      // input [NUM_M-1:0]
    .rob_buffer  (aw_sid_buffer),      // input [11:0] [0:3]
    .order_grant (w_order_grant)       // output reg
);
//}} ******* WRITE TRANSACTION REORDER *********

endmodule

module axi_crossbar
      #(parameter W_CID      = 6           // Channel ID width in bits
                , W_ID       = 6           // ID width in bits
                , W_ADDR     = 32          // address width
                , W_DATA     = 32          // data width
                , W_STRB     = (W_DATA/8)  // data strobe width
                , W_SID      = (W_CID+W_ID)// ID for slave
                , SLAVE_EN0  = 1, ADDR_BASE0 = 32'h00001000, ADDR_LENGTH0 = 12 // effective addre bits
                , SLAVE_EN1  = 1, ADDR_BASE1 = 32'h00002000, ADDR_LENGTH1 = 12 // effective addre bits
                , SLAVE_EN2  = 1, ADDR_BASE2 = 32'h00003000, ADDR_LENGTH2 = 12 // effective addre bits
                , SLAVE_EN3  = 1, ADDR_BASE3 = 32'h00004000, ADDR_LENGTH3 = 12 // effective addre bits
                , NUM_MASTER = 4
                , NUM_SLAVE  = 4
       )
(
       input   wire                      AXI_RSTn
     , input   wire                      AXI_CLK

     //--------------------------------------------------------------
     , input   wire  [W_CID-1:0]         M0_MID   // if not sure use 'h0
     , input   wire  [W_ID-1:0]          M0_AWID
     , input   wire  [W_ADDR-1:0]        M0_AWADDR
     , input   wire  [ 7:0]              M0_AWLEN
     , input   wire  [ 2:0]              M0_AWSIZE
     , input   wire  [ 1:0]              M0_AWBURST
     , input   wire                      M0_AWVALID
     , output  wire                      M0_AWREADY
     , input   wire  [W_ID-1:0]          M0_WID
     , input   wire  [W_DATA-1:0]        M0_WDATA
     , input   wire  [W_STRB-1:0]        M0_WSTRB
     , input   wire                      M0_WLAST
     , input   wire                      M0_WVALID
     , output  wire                      M0_WREADY
     , output  wire  [W_ID-1:0]          M0_BID
     , output  wire  [ 1:0]              M0_BRESP
     , output  wire                      M0_BVALID
     , input   wire                      M0_BREADY
     , input   wire  [W_ID-1:0]          M0_ARID
     , input   wire  [W_ADDR-1:0]        M0_ARADDR
     , input   wire  [ 7:0]              M0_ARLEN
     , input   wire  [ 2:0]              M0_ARSIZE
     , input   wire  [ 1:0]              M0_ARBURST
     , input   wire                      M0_ARVALID
     , output  wire                      M0_ARREADY
     , output  wire  [W_ID-1:0]          M0_RID
     , output  wire  [W_DATA-1:0]        M0_RDATA
     , output  wire  [ 1:0]              M0_RRESP
     , output  wire                      M0_RLAST
     , output  wire                      M0_RVALID
     , input   wire                      M0_RREADY

     //--------------------------------------------------------------
     , input   wire  [W_CID-1:0]         M1_MID   // if not sure use 'h1
     , input   wire  [W_ID-1:0]          M1_AWID
     , input   wire  [W_ADDR-1:0]        M1_AWADDR
     , input   wire  [ 7:0]              M1_AWLEN
     , input   wire  [ 2:0]              M1_AWSIZE
     , input   wire  [ 1:0]              M1_AWBURST
     , input   wire                      M1_AWVALID
     , output  wire                      M1_AWREADY
     , input   wire  [W_ID-1:0]          M1_WID
     , input   wire  [W_DATA-1:0]        M1_WDATA
     , input   wire  [W_STRB-1:0]        M1_WSTRB
     , input   wire                      M1_WLAST
     , input   wire                      M1_WVALID
     , output  wire                      M1_WREADY
     , output  wire  [W_ID-1:0]          M1_BID
     , output  wire  [ 1:0]              M1_BRESP
     , output  wire                      M1_BVALID
     , input   wire                      M1_BREADY
     , input   wire  [W_ID-1:0]          M1_ARID
     , input   wire  [W_ADDR-1:0]        M1_ARADDR
     , input   wire  [ 7:0]              M1_ARLEN
     , input   wire  [ 2:0]              M1_ARSIZE
     , input   wire  [ 1:0]              M1_ARBURST
     , input   wire                      M1_ARVALID
     , output  wire                      M1_ARREADY
     , output  wire  [W_ID-1:0]          M1_RID
     , output  wire  [W_DATA-1:0]        M1_RDATA
     , output  wire  [ 1:0]              M1_RRESP
     , output  wire                      M1_RLAST
     , output  wire                      M1_RVALID
     , input   wire                      M1_RREADY

     //--------------------------------------------------------------
     , input   wire  [W_CID-1:0]         M2_MID   // if not sure use 'h2
     , input   wire  [W_ID-1:0]          M2_AWID
     , input   wire  [W_ADDR-1:0]        M2_AWADDR
     , input   wire  [ 7:0]              M2_AWLEN
     , input   wire  [ 2:0]              M2_AWSIZE
     , input   wire  [ 1:0]              M2_AWBURST
     , input   wire                      M2_AWVALID
     , output  wire                      M2_AWREADY
     , input   wire  [W_ID-1:0]          M2_WID
     , input   wire  [W_DATA-1:0]        M2_WDATA
     , input   wire  [W_STRB-1:0]        M2_WSTRB
     , input   wire                      M2_WLAST
     , input   wire                      M2_WVALID
     , output  wire                      M2_WREADY
     , output  wire  [W_ID-1:0]          M2_BID
     , output  wire  [ 1:0]              M2_BRESP
     , output  wire                      M2_BVALID
     , input   wire                      M2_BREADY
     , input   wire  [W_ID-1:0]          M2_ARID
     , input   wire  [W_ADDR-1:0]        M2_ARADDR
     , input   wire  [ 7:0]              M2_ARLEN
     , input   wire  [ 2:0]              M2_ARSIZE
     , input   wire  [ 1:0]              M2_ARBURST
     , input   wire                      M2_ARVALID
     , output  wire                      M2_ARREADY
     , output  wire  [W_ID-1:0]          M2_RID
     , output  wire  [W_DATA-1:0]        M2_RDATA
     , output  wire  [ 1:0]              M2_RRESP
     , output  wire                      M2_RLAST
     , output  wire                      M2_RVALID
     , input   wire                      M2_RREADY

     //--------------------------------------------------------------
     , input   wire  [W_CID-1:0]         M3_MID   // if not sure use 'h3
     , input   wire  [W_ID-1:0]          M3_AWID
     , input   wire  [W_ADDR-1:0]        M3_AWADDR
     , input   wire  [ 7:0]              M3_AWLEN
     , input   wire  [ 2:0]              M3_AWSIZE
     , input   wire  [ 1:0]              M3_AWBURST
     , input   wire                      M3_AWVALID
     , output  wire                      M3_AWREADY
     , input   wire  [W_ID-1:0]          M3_WID
     , input   wire  [W_DATA-1:0]        M3_WDATA
     , input   wire  [W_STRB-1:0]        M3_WSTRB
     , input   wire                      M3_WLAST
     , input   wire                      M3_WVALID
     , output  wire                      M3_WREADY
     , output  wire  [W_ID-1:0]          M3_BID
     , output  wire  [ 1:0]              M3_BRESP
     , output  wire                      M3_BVALID
     , input   wire                      M3_BREADY
     , input   wire  [W_ID-1:0]          M3_ARID
     , input   wire  [W_ADDR-1:0]        M3_ARADDR
     , input   wire  [ 7:0]              M3_ARLEN
     , input   wire  [ 2:0]              M3_ARSIZE
     , input   wire  [ 1:0]              M3_ARBURST
     , input   wire                      M3_ARVALID
     , output  wire                      M3_ARREADY
     , output  wire  [W_ID-1:0]          M3_RID
     , output  wire  [W_DATA-1:0]        M3_RDATA
     , output  wire  [ 1:0]              M3_RRESP
     , output  wire                      M3_RLAST
     , output  wire                      M3_RVALID
     , input   wire                      M3_RREADY

     //--------------------------------------------------------------
     , output  wire   [W_SID-1:0]        S0_AWID
     , output  wire   [W_ADDR-1:0]       S0_AWADDR
     , output  wire   [ 7:0]             S0_AWLEN
     , output  wire   [ 2:0]             S0_AWSIZE
     , output  wire   [ 1:0]             S0_AWBURST
     , output  wire                      S0_AWVALID
     , input   wire                      S0_AWREADY
     , output  wire   [W_SID-1:0]        S0_WID
     , output  wire   [W_DATA-1:0]       S0_WDATA
     , output  wire   [W_STRB-1:0]       S0_WSTRB
     , output  wire                      S0_WLAST
     , output  wire                      S0_WVALID
     , input   wire                      S0_WREADY
     , input   wire   [W_SID-1:0]        S0_BID
     , input   wire   [ 1:0]             S0_BRESP
     , input   wire                      S0_BVALID
     , output  wire                      S0_BREADY
     , output  wire   [W_SID-1:0]        S0_ARID
     , output  wire   [W_ADDR-1:0]       S0_ARADDR
     , output  wire   [ 7:0]             S0_ARLEN
     , output  wire   [ 2:0]             S0_ARSIZE
     , output  wire   [ 1:0]             S0_ARBURST
     , output  wire                      S0_ARVALID
     , input   wire                      S0_ARREADY
     , input   wire   [W_SID-1:0]        S0_RID
     , input   wire   [W_DATA-1:0]       S0_RDATA
     , input   wire   [ 1:0]             S0_RRESP
     , input   wire                      S0_RLAST
     , input   wire                      S0_RVALID
     , output  wire                      S0_RREADY

     //--------------------------------------------------------------
     , output  wire   [W_SID-1:0]        S1_AWID
     , output  wire   [W_ADDR-1:0]       S1_AWADDR
     , output  wire   [ 7:0]             S1_AWLEN
     , output  wire   [ 2:0]             S1_AWSIZE
     , output  wire   [ 1:0]             S1_AWBURST
     , output  wire                      S1_AWVALID
     , input   wire                      S1_AWREADY
     , output  wire   [W_SID-1:0]        S1_WID
     , output  wire   [W_DATA-1:0]       S1_WDATA
     , output  wire   [W_STRB-1:0]       S1_WSTRB
     , output  wire                      S1_WLAST
     , output  wire                      S1_WVALID
     , input   wire                      S1_WREADY
     , input   wire   [W_SID-1:0]        S1_BID
     , input   wire   [ 1:0]             S1_BRESP
     , input   wire                      S1_BVALID
     , output  wire                      S1_BREADY
     , output  wire   [W_SID-1:0]        S1_ARID
     , output  wire   [W_ADDR-1:0]       S1_ARADDR
     , output  wire   [ 7:0]             S1_ARLEN
     , output  wire   [ 2:0]             S1_ARSIZE
     , output  wire   [ 1:0]             S1_ARBURST
     , output  wire                      S1_ARVALID
     , input   wire                      S1_ARREADY
     , input   wire   [W_SID-1:0]        S1_RID
     , input   wire   [W_DATA-1:0]       S1_RDATA
     , input   wire   [ 1:0]             S1_RRESP
     , input   wire                      S1_RLAST
     , input   wire                      S1_RVALID
     , output  wire                      S1_RREADY

     //--------------------------------------------------------------
     , output  wire   [W_SID-1:0]        S2_AWID
     , output  wire   [W_ADDR-1:0]       S2_AWADDR
     , output  wire   [ 7:0]             S2_AWLEN
     , output  wire   [ 2:0]             S2_AWSIZE
     , output  wire   [ 1:0]             S2_AWBURST
     , output  wire                      S2_AWVALID
     , input   wire                      S2_AWREADY
     , output  wire   [W_SID-1:0]        S2_WID
     , output  wire   [W_DATA-1:0]       S2_WDATA
     , output  wire   [W_STRB-1:0]       S2_WSTRB
     , output  wire                      S2_WLAST
     , output  wire                      S2_WVALID
     , input   wire                      S2_WREADY
     , input   wire   [W_SID-1:0]        S2_BID
     , input   wire   [ 1:0]             S2_BRESP
     , input   wire                      S2_BVALID
     , output  wire                      S2_BREADY
     , output  wire   [W_SID-1:0]        S2_ARID
     , output  wire   [W_ADDR-1:0]       S2_ARADDR
     , output  wire   [ 7:0]             S2_ARLEN
     , output  wire   [ 2:0]             S2_ARSIZE
     , output  wire   [ 1:0]             S2_ARBURST
     , output  wire                      S2_ARVALID
     , input   wire                      S2_ARREADY
     , input   wire   [W_SID-1:0]        S2_RID
     , input   wire   [W_DATA-1:0]       S2_RDATA
     , input   wire   [ 1:0]             S2_RRESP
     , input   wire                      S2_RLAST
     , input   wire                      S2_RVALID
     , output  wire                      S2_RREADY

     //--------------------------------------------------------------
     , output  wire   [W_SID-1:0]        S3_AWID
     , output  wire   [W_ADDR-1:0]       S3_AWADDR
     , output  wire   [ 7:0]             S3_AWLEN
     , output  wire   [ 2:0]             S3_AWSIZE
     , output  wire   [ 1:0]             S3_AWBURST
     , output  wire                      S3_AWVALID
     , input   wire                      S3_AWREADY
     , output  wire   [W_SID-1:0]        S3_WID
     , output  wire   [W_DATA-1:0]       S3_WDATA
     , output  wire   [W_STRB-1:0]       S3_WSTRB
     , output  wire                      S3_WLAST
     , output  wire                      S3_WVALID
     , input   wire                      S3_WREADY
     , input   wire   [W_SID-1:0]        S3_BID
     , input   wire   [ 1:0]             S3_BRESP
     , input   wire                      S3_BVALID
     , output  wire                      S3_BREADY
     , output  wire   [W_SID-1:0]        S3_ARID
     , output  wire   [W_ADDR-1:0]       S3_ARADDR
     , output  wire   [ 7:0]             S3_ARLEN
     , output  wire   [ 2:0]             S3_ARSIZE
     , output  wire   [ 1:0]             S3_ARBURST
     , output  wire                      S3_ARVALID
     , input   wire                      S3_ARREADY
     , input   wire   [W_SID-1:0]        S3_RID
     , input   wire   [W_DATA-1:0]       S3_RDATA
     , input   wire   [ 1:0]             S3_RRESP
     , input   wire                      S3_RLAST
     , input   wire                      S3_RVALID
     , output  wire                      S3_RREADY

     //--------------For reorder----------------------
     , input   wire  [NUM_S-1:0]               r_order_grant
     , input   wire  [NUM_M-1:0]               w_order_grant
);
     // default slave signal
     wire  [W_SID-1:0]         SD_AWID     ;
     wire  [W_ADDR-1:0]        SD_AWADDR   ;
     wire  [ 7:0]              SD_AWLEN    ;
     wire  [ 2:0]              SD_AWSIZE   ;
     wire  [ 1:0]              SD_AWBURST  ;
     wire                      SD_AWVALID  ;
     wire                      SD_AWREADY  ;
     wire  [W_SID-1:0]         SD_WID      ;
     wire  [W_DATA-1:0]        SD_WDATA    ;
     wire  [W_STRB-1:0]        SD_WSTRB    ;
     wire                      SD_WLAST    ;
     wire                      SD_WVALID   ;
     wire                      SD_WREADY   ;
     wire  [W_SID-1:0]         SD_BID      ;
     wire  [ 1:0]              SD_BRESP    ;
     wire                      SD_BVALID   ;
     wire                      SD_BREADY   ;
     wire  [W_SID-1:0]         SD_ARID     ;
     wire  [W_ADDR-1:0]        SD_ARADDR   ;
     wire  [ 7:0]              SD_ARLEN    ;
     wire  [ 2:0]              SD_ARSIZE   ;
     wire  [ 1:0]              SD_ARBURST  ;
     wire                      SD_ARVALID  ;
     wire                      SD_ARREADY  ;
     wire  [W_SID-1:0]         SD_RID      ;
     wire  [W_DATA-1:0]        SD_RDATA    ;
     wire  [ 1:0]              SD_RRESP    ;
     wire                      SD_RLAST    ;
     wire                      SD_RVALID   ;
     wire                      SD_RREADY   ;

     // driven by axi_mtos_s
     wire M0_AWREADY_S0  ,M0_AWREADY_S1  ,M0_AWREADY_S2  ,M0_AWREADY_S3  ,M0_AWREADY_SD  ;
     wire M0_WREADY_S0   ,M0_WREADY_S1   ,M0_WREADY_S2   ,M0_WREADY_S3   ,M0_WREADY_SD   ;
     wire M0_ARREADY_S0  ,M0_ARREADY_S1  ,M0_ARREADY_S2  ,M0_ARREADY_S3  ,M0_ARREADY_SD  ;
     wire M1_AWREADY_S0  ,M1_AWREADY_S1  ,M1_AWREADY_S2  ,M1_AWREADY_S3  ,M1_AWREADY_SD  ;
     wire M1_WREADY_S0   ,M1_WREADY_S1   ,M1_WREADY_S2   ,M1_WREADY_S3   ,M1_WREADY_SD   ;
     wire M1_ARREADY_S0  ,M1_ARREADY_S1  ,M1_ARREADY_S2  ,M1_ARREADY_S3  ,M1_ARREADY_SD  ;
     wire M2_AWREADY_S0  ,M2_AWREADY_S1  ,M2_AWREADY_S2  ,M2_AWREADY_S3  ,M2_AWREADY_SD  ;
     wire M2_WREADY_S0   ,M2_WREADY_S1   ,M2_WREADY_S2   ,M2_WREADY_S3   ,M2_WREADY_SD   ;
     wire M2_ARREADY_S0  ,M2_ARREADY_S1  ,M2_ARREADY_S2  ,M2_ARREADY_S3  ,M2_ARREADY_SD  ;
     wire M3_AWREADY_S0  ,M3_AWREADY_S1  ,M3_AWREADY_S2  ,M3_AWREADY_S3  ,M3_AWREADY_SD  ;
     wire M3_WREADY_S0   ,M3_WREADY_S1   ,M3_WREADY_S2   ,M3_WREADY_S3   ,M3_WREADY_SD   ;
     wire M3_ARREADY_S0  ,M3_ARREADY_S1  ,M3_ARREADY_S2  ,M3_ARREADY_S3  ,M3_ARREADY_SD  ;

     assign M0_AWREADY  = M0_AWREADY_S0  |M0_AWREADY_S1  |M0_AWREADY_S2  |M0_AWREADY_S3  |M0_AWREADY_SD  ;
     assign M0_WREADY   = M0_WREADY_S0   |M0_WREADY_S1   |M0_WREADY_S2   |M0_WREADY_S3   |M0_WREADY_SD   ;
     assign M0_ARREADY  = M0_ARREADY_S0  |M0_ARREADY_S1  |M0_ARREADY_S2  |M0_ARREADY_S3  |M0_ARREADY_SD  ;
     assign M1_AWREADY  = M1_AWREADY_S0  |M1_AWREADY_S1  |M1_AWREADY_S2  |M1_AWREADY_S3  |M1_AWREADY_SD  ;
     assign M1_WREADY   = M1_WREADY_S0   |M1_WREADY_S1   |M1_WREADY_S2   |M1_WREADY_S3   |M1_WREADY_SD   ;
     assign M1_ARREADY  = M1_ARREADY_S0  |M1_ARREADY_S1  |M1_ARREADY_S2  |M1_ARREADY_S3  |M1_ARREADY_SD  ;
     assign M2_AWREADY  = M2_AWREADY_S0  |M2_AWREADY_S1  |M2_AWREADY_S2  |M2_AWREADY_S3  |M2_AWREADY_SD  ;
     assign M2_WREADY   = M2_WREADY_S0   |M2_WREADY_S1   |M2_WREADY_S2   |M2_WREADY_S3   |M2_WREADY_SD   ;
     assign M2_ARREADY  = M2_ARREADY_S0  |M2_ARREADY_S1  |M2_ARREADY_S2  |M2_ARREADY_S3  |M2_ARREADY_SD  ;
     assign M3_AWREADY  = M3_AWREADY_S0  |M3_AWREADY_S1  |M3_AWREADY_S2  |M3_AWREADY_S3  |M3_AWREADY_SD  ;
     assign M3_WREADY   = M3_WREADY_S0   |M3_WREADY_S1   |M3_WREADY_S2   |M3_WREADY_S3   |M3_WREADY_SD   ;
     assign M3_ARREADY  = M3_ARREADY_S0  |M3_ARREADY_S1  |M3_ARREADY_S2  |M3_ARREADY_S3  |M3_ARREADY_SD  ;

     // driven by axi_stom_m
     wire S0_BREADY_M0,S0_BREADY_M1,S0_BREADY_M2,S0_BREADY_M3;
     wire S0_RREADY_M0,S0_RREADY_M1,S0_RREADY_M2,S0_RREADY_M3;
     wire S1_BREADY_M0,S1_BREADY_M1,S1_BREADY_M2,S1_BREADY_M3;
     wire S1_RREADY_M0,S1_RREADY_M1,S1_RREADY_M2,S1_RREADY_M3;
     wire S2_BREADY_M0,S2_BREADY_M1,S2_BREADY_M2,S2_BREADY_M3;
     wire S2_RREADY_M0,S2_RREADY_M1,S2_RREADY_M2,S2_RREADY_M3;
     wire S3_BREADY_M0,S3_BREADY_M1,S3_BREADY_M2,S3_BREADY_M3;
     wire S3_RREADY_M0,S3_RREADY_M1,S3_RREADY_M2,S3_RREADY_M3;
     wire SD_BREADY_M0,SD_BREADY_M1,SD_BREADY_M2,SD_BREADY_M3;
     wire SD_RREADY_M0,SD_RREADY_M1,SD_RREADY_M2,SD_RREADY_M3;
     //-----------------------------------------------------------
     assign S0_BREADY = S0_BREADY_M0|S0_BREADY_M1|S0_BREADY_M2|S0_BREADY_M3;
     assign S0_RREADY = S0_RREADY_M0|S0_RREADY_M1|S0_RREADY_M2|S0_RREADY_M3;
     assign S1_BREADY = S1_BREADY_M0|S1_BREADY_M1|S1_BREADY_M2|S1_BREADY_M3;
     assign S1_RREADY = S1_RREADY_M0|S1_RREADY_M1|S1_RREADY_M2|S1_RREADY_M3;
     assign S2_BREADY = S2_BREADY_M0|S2_BREADY_M1|S2_BREADY_M2|S2_BREADY_M3;
     assign S2_RREADY = S2_RREADY_M0|S2_RREADY_M1|S2_RREADY_M2|S2_RREADY_M3;
     assign S3_BREADY = S3_BREADY_M0|S3_BREADY_M1|S3_BREADY_M2|S3_BREADY_M3;
     assign S3_RREADY = S3_RREADY_M0|S3_RREADY_M1|S3_RREADY_M2|S3_RREADY_M3;
     assign SD_BREADY = SD_BREADY_M0|SD_BREADY_M1|SD_BREADY_M2|SD_BREADY_M3;
     assign SD_RREADY = SD_RREADY_M0|SD_RREADY_M1|SD_RREADY_M2|SD_RREADY_M3;
     //-----------------------------------------------------------
     // drivne by axi_mtos_m?
     wire [NUM_MASTER-1:0] AWSELECT_OUT[0:NUM_SLAVE-1];
     wire [NUM_MASTER-1:0] ARSELECT_OUT[0:NUM_SLAVE-1];
     wire [NUM_MASTER-1:0] AWSELECT; // goes to default slave
     wire [NUM_MASTER-1:0] ARSELECT; // goes to default slave
     //-----------------------------------------------------------
     assign AWSELECT[0] = AWSELECT_OUT[0][0]|AWSELECT_OUT[1][0]|AWSELECT_OUT[2][0]|AWSELECT_OUT[3][0];
     assign AWSELECT[1] = AWSELECT_OUT[0][1]|AWSELECT_OUT[1][1]|AWSELECT_OUT[2][1]|AWSELECT_OUT[3][1];
     assign AWSELECT[2] = AWSELECT_OUT[0][2]|AWSELECT_OUT[1][2]|AWSELECT_OUT[2][2]|AWSELECT_OUT[3][2];
     assign AWSELECT[3] = AWSELECT_OUT[0][3]|AWSELECT_OUT[1][3]|AWSELECT_OUT[2][3]|AWSELECT_OUT[3][3];
     assign ARSELECT[0] = ARSELECT_OUT[0][0]|ARSELECT_OUT[1][0]|ARSELECT_OUT[2][0]|ARSELECT_OUT[3][0];
     assign ARSELECT[1] = ARSELECT_OUT[0][1]|ARSELECT_OUT[1][1]|ARSELECT_OUT[2][1]|ARSELECT_OUT[3][1];
     assign ARSELECT[2] = ARSELECT_OUT[0][2]|ARSELECT_OUT[1][2]|ARSELECT_OUT[2][2]|ARSELECT_OUT[3][2];
     assign ARSELECT[3] = ARSELECT_OUT[0][3]|ARSELECT_OUT[1][3]|ARSELECT_OUT[2][3]|ARSELECT_OUT[3][3];
     //-----------------------------------------------------------
     // masters to slave for slave 0
     axi_m2s_m4 #(.SLAVE_ID       (0            )
                  ,.SLAVE_EN      (SLAVE_EN0    )
                  ,.ADDR_BASE     (ADDR_BASE0   )
                  ,.ADDR_LENGTH   (ADDR_LENGTH0 )
                  ,.W_CID         (W_CID        )
                  ,.W_ID          (W_ID         )
                  ,.W_ADDR        (W_ADDR       )
                  ,.W_DATA        (W_DATA       )
                  ,.W_STRB        (W_STRB       )
                  ,.W_SID         (W_SID        )
                  ,.SLAVE_DEFAULT (1'b0         )
                 )
     u_axi_m2s_s0 (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )

                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_S0)
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_S0 )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_S0)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_S0)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_S0 )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_S0)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_S0)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_S0 )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_S0)

                              , .M3_MID               (M3_MID       )
                              , .M3_AWID              (M3_AWID      )
                              , .M3_AWADDR            (M3_AWADDR    )
                              , .M3_AWLEN             (M3_AWLEN     )
                              , .M3_AWSIZE            (M3_AWSIZE    )
                              , .M3_AWBURST           (M3_AWBURST   )
                              , .M3_AWVALID           (M3_AWVALID   )
                              , .M3_AWREADY           (M3_AWREADY_S0)
                              , .M3_WID               (M3_WID       )
                              , .M3_WDATA             (M3_WDATA     )
                              , .M3_WSTRB             (M3_WSTRB     )
                              , .M3_WLAST             (M3_WLAST     )
                              , .M3_WVALID            (M3_WVALID    )
                              , .M3_WREADY            (M3_WREADY_S0 )
                              , .M3_ARID              (M3_ARID      )
                              , .M3_ARADDR            (M3_ARADDR    )
                              , .M3_ARLEN             (M3_ARLEN     )
                              , .M3_ARSIZE            (M3_ARSIZE    )
                              , .M3_ARBURST           (M3_ARBURST   )
                              , .M3_ARVALID           (M3_ARVALID   )
                              , .M3_ARREADY           (M3_ARREADY_S0)

                              , .w_order_grant        (w_order_grant)
         , .S_AWID               (S0_AWID      )
         , .S_AWADDR             (S0_AWADDR    )
         , .S_AWLEN              (S0_AWLEN     )
         , .S_AWSIZE             (S0_AWSIZE    )
         , .S_AWBURST            (S0_AWBURST   )
         , .S_AWVALID            (S0_AWVALID   )
         , .S_AWREADY            (S0_AWREADY   )
         , .S_WID                (S0_WID       )
         , .S_WDATA              (S0_WDATA     )
         , .S_WSTRB              (S0_WSTRB     )
         , .S_WLAST              (S0_WLAST     )
         , .S_WVALID             (S0_WVALID    )
         , .S_WREADY             (S0_WREADY    )
         , .S_ARID               (S0_ARID      )
         , .S_ARADDR             (S0_ARADDR    )
         , .S_ARLEN              (S0_ARLEN     )
         , .S_ARSIZE             (S0_ARSIZE    )
         , .S_ARBURST            (S0_ARBURST   )
         , .S_ARVALID            (S0_ARVALID   )
         , .S_ARREADY            (S0_ARREADY   )
         , .AWSELECT_OUT         (AWSELECT_OUT[0])
         , .ARSELECT_OUT         (ARSELECT_OUT[0])
         , .AWSELECT_IN          (AWSELECT_OUT[0])// not used since non-default-slave
         , .ARSELECT_IN          (ARSELECT_OUT[0])// not used since non-default-slave
     );
     //-----------------------------------------------------------
     // masters to slave for slave 1
     axi_m2s_m4 #(.SLAVE_ID       (1            )
                  ,.SLAVE_EN      (SLAVE_EN1    )
                  ,.ADDR_BASE     (ADDR_BASE1   )
                  ,.ADDR_LENGTH   (ADDR_LENGTH1 )
                  ,.W_CID         (W_CID        )
                  ,.W_ID          (W_ID         )
                  ,.W_ADDR        (W_ADDR       )
                  ,.W_DATA        (W_DATA       )
                  ,.W_STRB        (W_STRB       )
                  ,.W_SID         (W_SID        )
                  ,.SLAVE_DEFAULT (1'b0         )
                 )
     u_axi_m2s_s1 (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )

                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_S1)
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_S1 )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_S1)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_S1)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_S1 )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_S1)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_S1)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_S1 )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_S1)

                              , .M3_MID               (M3_MID       )
                              , .M3_AWID              (M3_AWID      )
                              , .M3_AWADDR            (M3_AWADDR    )
                              , .M3_AWLEN             (M3_AWLEN     )
                              , .M3_AWSIZE            (M3_AWSIZE    )
                              , .M3_AWBURST           (M3_AWBURST   )
                              , .M3_AWVALID           (M3_AWVALID   )
                              , .M3_AWREADY           (M3_AWREADY_S1)
                              , .M3_WID               (M3_WID       )
                              , .M3_WDATA             (M3_WDATA     )
                              , .M3_WSTRB             (M3_WSTRB     )
                              , .M3_WLAST             (M3_WLAST     )
                              , .M3_WVALID            (M3_WVALID    )
                              , .M3_WREADY            (M3_WREADY_S1 )
                              , .M3_ARID              (M3_ARID      )
                              , .M3_ARADDR            (M3_ARADDR    )
                              , .M3_ARLEN             (M3_ARLEN     )
                              , .M3_ARSIZE            (M3_ARSIZE    )
                              , .M3_ARBURST           (M3_ARBURST   )
                              , .M3_ARVALID           (M3_ARVALID   )
                              , .M3_ARREADY           (M3_ARREADY_S1)

                              , .w_order_grant        (w_order_grant)
         , .S_AWID               (S1_AWID      )
         , .S_AWADDR             (S1_AWADDR    )
         , .S_AWLEN              (S1_AWLEN     )
         , .S_AWSIZE             (S1_AWSIZE    )
         , .S_AWBURST            (S1_AWBURST   )
         , .S_AWVALID            (S1_AWVALID   )
         , .S_AWREADY            (S1_AWREADY   )
         , .S_WID                (S1_WID       )
         , .S_WDATA              (S1_WDATA     )
         , .S_WSTRB              (S1_WSTRB     )
         , .S_WLAST              (S1_WLAST     )
         , .S_WVALID             (S1_WVALID    )
         , .S_WREADY             (S1_WREADY    )
         , .S_ARID               (S1_ARID      )
         , .S_ARADDR             (S1_ARADDR    )
         , .S_ARLEN              (S1_ARLEN     )
         , .S_ARSIZE             (S1_ARSIZE    )
         , .S_ARBURST            (S1_ARBURST   )
         , .S_ARVALID            (S1_ARVALID   )
         , .S_ARREADY            (S1_ARREADY   )
         , .AWSELECT_OUT         (AWSELECT_OUT[1])
         , .ARSELECT_OUT         (ARSELECT_OUT[1])
         , .AWSELECT_IN          (AWSELECT_OUT[1])// not used since non-default-slave
         , .ARSELECT_IN          (ARSELECT_OUT[1])// not used since non-default-slave
     );
     //-----------------------------------------------------------
     // masters to slave for slave 2
     axi_m2s_m4 #(.SLAVE_ID       (2            )
                  ,.SLAVE_EN      (SLAVE_EN2    )
                  ,.ADDR_BASE     (ADDR_BASE2   )
                  ,.ADDR_LENGTH   (ADDR_LENGTH2 )
                  ,.W_CID         (W_CID        )
                  ,.W_ID          (W_ID         )
                  ,.W_ADDR        (W_ADDR       )
                  ,.W_DATA        (W_DATA       )
                  ,.W_STRB        (W_STRB       )
                  ,.W_SID         (W_SID        )
                  ,.SLAVE_DEFAULT (1'b0         )
                 )
     u_axi_m2s_s2 (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )

                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_S2)
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_S2 )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_S2)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_S2)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_S2 )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_S2)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_S2)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_S2 )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_S2)

                              , .M3_MID               (M3_MID       )
                              , .M3_AWID              (M3_AWID      )
                              , .M3_AWADDR            (M3_AWADDR    )
                              , .M3_AWLEN             (M3_AWLEN     )
                              , .M3_AWSIZE            (M3_AWSIZE    )
                              , .M3_AWBURST           (M3_AWBURST   )
                              , .M3_AWVALID           (M3_AWVALID   )
                              , .M3_AWREADY           (M3_AWREADY_S2)
                              , .M3_WID               (M3_WID       )
                              , .M3_WDATA             (M3_WDATA     )
                              , .M3_WSTRB             (M3_WSTRB     )
                              , .M3_WLAST             (M3_WLAST     )
                              , .M3_WVALID            (M3_WVALID    )
                              , .M3_WREADY            (M3_WREADY_S2 )
                              , .M3_ARID              (M3_ARID      )
                              , .M3_ARADDR            (M3_ARADDR    )
                              , .M3_ARLEN             (M3_ARLEN     )
                              , .M3_ARSIZE            (M3_ARSIZE    )
                              , .M3_ARBURST           (M3_ARBURST   )
                              , .M3_ARVALID           (M3_ARVALID   )
                              , .M3_ARREADY           (M3_ARREADY_S2)

                              , .w_order_grant        (w_order_grant)
         , .S_AWID               (S2_AWID      )
         , .S_AWADDR             (S2_AWADDR    )
         , .S_AWLEN              (S2_AWLEN     )
         , .S_AWSIZE             (S2_AWSIZE    )
         , .S_AWBURST            (S2_AWBURST   )
         , .S_AWVALID            (S2_AWVALID   )
         , .S_AWREADY            (S2_AWREADY   )
         , .S_WID                (S2_WID       )
         , .S_WDATA              (S2_WDATA     )
         , .S_WSTRB              (S2_WSTRB     )
         , .S_WLAST              (S2_WLAST     )
         , .S_WVALID             (S2_WVALID    )
         , .S_WREADY             (S2_WREADY    )
         , .S_ARID               (S2_ARID      )
         , .S_ARADDR             (S2_ARADDR    )
         , .S_ARLEN              (S2_ARLEN     )
         , .S_ARSIZE             (S2_ARSIZE    )
         , .S_ARBURST            (S2_ARBURST   )
         , .S_ARVALID            (S2_ARVALID   )
         , .S_ARREADY            (S2_ARREADY   )
         , .AWSELECT_OUT         (AWSELECT_OUT[2])
         , .ARSELECT_OUT         (ARSELECT_OUT[2])
         , .AWSELECT_IN          (AWSELECT_OUT[2])// not used since non-default-slave
         , .ARSELECT_IN          (ARSELECT_OUT[2])// not used since non-default-slave
     );
     //-----------------------------------------------------------
     // masters to slave for slave 3
     axi_m2s_m4 #(.SLAVE_ID       (3            )
                  ,.SLAVE_EN      (SLAVE_EN3    )
                  ,.ADDR_BASE     (ADDR_BASE3   )
                  ,.ADDR_LENGTH   (ADDR_LENGTH3 )
                  ,.W_CID         (W_CID        )
                  ,.W_ID          (W_ID         )
                  ,.W_ADDR        (W_ADDR       )
                  ,.W_DATA        (W_DATA       )
                  ,.W_STRB        (W_STRB       )
                  ,.W_SID         (W_SID        )
                  ,.SLAVE_DEFAULT (1'b0         )
                 )
     u_axi_m2s_s3 (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )

                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_S3)
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_S3 )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_S3)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_S3)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_S3 )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_S3)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_S3)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_S3 )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_S3)

                              , .M3_MID               (M3_MID       )
                              , .M3_AWID              (M3_AWID      )
                              , .M3_AWADDR            (M3_AWADDR    )
                              , .M3_AWLEN             (M3_AWLEN     )
                              , .M3_AWSIZE            (M3_AWSIZE    )
                              , .M3_AWBURST           (M3_AWBURST   )
                              , .M3_AWVALID           (M3_AWVALID   )
                              , .M3_AWREADY           (M3_AWREADY_S3)
                              , .M3_WID               (M3_WID       )
                              , .M3_WDATA             (M3_WDATA     )
                              , .M3_WSTRB             (M3_WSTRB     )
                              , .M3_WLAST             (M3_WLAST     )
                              , .M3_WVALID            (M3_WVALID    )
                              , .M3_WREADY            (M3_WREADY_S3 )
                              , .M3_ARID              (M3_ARID      )
                              , .M3_ARADDR            (M3_ARADDR    )
                              , .M3_ARLEN             (M3_ARLEN     )
                              , .M3_ARSIZE            (M3_ARSIZE    )
                              , .M3_ARBURST           (M3_ARBURST   )
                              , .M3_ARVALID           (M3_ARVALID   )
                              , .M3_ARREADY           (M3_ARREADY_S3)

                              , .w_order_grant        (w_order_grant)
         , .S_AWID               (S3_AWID      )
         , .S_AWADDR             (S3_AWADDR    )
         , .S_AWLEN              (S3_AWLEN     )
         , .S_AWSIZE             (S3_AWSIZE    )
         , .S_AWBURST            (S3_AWBURST   )
         , .S_AWVALID            (S3_AWVALID   )
         , .S_AWREADY            (S3_AWREADY   )
         , .S_WID                (S3_WID       )
         , .S_WDATA              (S3_WDATA     )
         , .S_WSTRB              (S3_WSTRB     )
         , .S_WLAST              (S3_WLAST     )
         , .S_WVALID             (S3_WVALID    )
         , .S_WREADY             (S3_WREADY    )
         , .S_ARID               (S3_ARID      )
         , .S_ARADDR             (S3_ARADDR    )
         , .S_ARLEN              (S3_ARLEN     )
         , .S_ARSIZE             (S3_ARSIZE    )
         , .S_ARBURST            (S3_ARBURST   )
         , .S_ARVALID            (S3_ARVALID   )
         , .S_ARREADY            (S3_ARREADY   )
         , .AWSELECT_OUT         (AWSELECT_OUT[3])
         , .ARSELECT_OUT         (ARSELECT_OUT[3])
         , .AWSELECT_IN          (AWSELECT_OUT[3])// not used since non-default-slave
         , .ARSELECT_IN          (ARSELECT_OUT[3])// not used since non-default-slave
     );
     
     // masters to slave for default slave
     axi_mtos_m4 #(.SLAVE_ID      (NUM_SLAVE   )
                  ,.SLAVE_EN      (1'b1        ) // always enabled
                  ,.ADDR_BASE     (ADDR_BASE1  )
                  ,.ADDR_LENGTH   (ADDR_LENGTH1)
                  ,.W_CID         (W_CID       )
                  ,.W_ID          (W_ID        )
                  ,.W_ADDR        (W_ADDR      )
                  ,.W_DATA        (W_DATA      )
                  ,.W_STRB        (W_STRB      )
                  ,.W_SID         (W_SID       )
                  ,.SLAVE_DEFAULT (1'b1        )
                 )
     u_axi_m2s_sd (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )
                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_SD)
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_SD )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_SD)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_SD)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_SD )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_SD)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_SD)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_SD )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_SD)

                              , .M3_MID               (M3_MID       )
                              , .M3_AWID              (M3_AWID      )
                              , .M3_AWADDR            (M3_AWADDR    )
                              , .M3_AWLEN             (M3_AWLEN     )
                              , .M3_AWSIZE            (M3_AWSIZE    )
                              , .M3_AWBURST           (M3_AWBURST   )
                              , .M3_AWVALID           (M3_AWVALID   )
                              , .M3_AWREADY           (M3_AWREADY_SD)
                              , .M3_WID               (M3_WID       )
                              , .M3_WDATA             (M3_WDATA     )
                              , .M3_WSTRB             (M3_WSTRB     )
                              , .M3_WLAST             (M3_WLAST     )
                              , .M3_WVALID            (M3_WVALID    )
                              , .M3_WREADY            (M3_WREADY_SD )
                              , .M3_ARID              (M3_ARID      )
                              , .M3_ARADDR            (M3_ARADDR    )
                              , .M3_ARLEN             (M3_ARLEN     )
                              , .M3_ARSIZE            (M3_ARSIZE    )
                              , .M3_ARBURST           (M3_ARBURST   )
                              , .M3_ARVALID           (M3_ARVALID   )
                              , .M3_ARREADY           (M3_ARREADY_SD)

                              , .w_order_grant        (w_order_grant)
         , .S_AWID               (SD_AWID      )
         , .S_AWADDR             (SD_AWADDR    )
         , .S_AWLEN              (SD_AWLEN     )
         , .S_AWSIZE             (SD_AWSIZE    )
         , .S_AWBURST            (SD_AWBURST   )
         , .S_AWVALID            (SD_AWVALID   )
         , .S_AWREADY            (SD_AWREADY   )
         , .S_WID                (SD_WID       )
         , .S_WDATA              (SD_WDATA     )
         , .S_WSTRB              (SD_WSTRB     )
         , .S_WLAST              (SD_WLAST     )
         , .S_WVALID             (SD_WVALID    )
         , .S_WREADY             (SD_WREADY    )
         , .S_ARID               (SD_ARID      )
         , .S_ARADDR             (SD_ARADDR    )
         , .S_ARLEN              (SD_ARLEN     )
         , .S_ARSIZE             (SD_ARSIZE    )
         , .S_ARBURST            (SD_ARBURST   )
         , .S_ARVALID            (SD_ARVALID   )
         , .S_ARREADY            (SD_ARREADY   )
         , .AWSELECT_OUT         (aw_decode_err)
         , .ARSELECT_OUT         (ar_decode_err)
         , .AWSELECT_IN          (AWSELECT     )
         , .ARSELECT_IN          (ARSELECT     )
     );
     //--------------default slave-------------------- 
     axi_default_slave #(.W_CID  (W_CID)// Channel ID width in bits
                        ,.W_ID   (W_ID )  // ID width in bits
                        ,.W_ADDR (W_ADDR )// address width
                        ,.W_DATA (W_DATA )// data width
                        )
     u_axi_default_slave (
            .AXI_RSTn (AXI_RSTn   )
          , .AXI_CLK  (AXI_CLK    )
          , .AWID     (SD_AWID    )
          , .AWADDR   (SD_AWADDR  )
          , .AWLEN    (SD_AWLEN   )
          , .AWSIZE   (SD_AWSIZE  )
          , .AWBURST  (SD_AWBURST )
          , .AWVALID  (SD_AWVALID )
          , .AWREADY  (SD_AWREADY )
          , .WID      (SD_WID     )
          , .WDATA    (SD_WDATA   )
          , .WSTRB    (SD_WSTRB   )
          , .WLAST    (SD_WLAST   )
          , .WVALID   (SD_WVALID  )
          , .WREADY   (SD_WREADY  )
          , .BID      (SD_BID     )
          , .BRESP    (SD_BRESP   )
          , .BVALID   (SD_BVALID  )
          , .BREADY   (SD_BREADY  )
          , .ARID     (SD_ARID    )
          , .ARADDR   (SD_ARADDR  )
          , .ARLEN    (SD_ARLEN   )
          , .ARSIZE   (SD_ARSIZE  )
          , .ARBURST  (SD_ARBURST )
          , .ARVALID  (SD_ARVALID )
          , .ARREADY  (SD_ARREADY )
          , .RID      (SD_RID     )
          , .RDATA    (SD_RDATA   )
          , .RRESP    (SD_RRESP   )
          , .RLAST    (SD_RLAST   )
          , .RVALID   (SD_RVALID  )
          , .RREADY   (SD_RREADY  )
     );
     
     // slaves to master for master 0
     axi_stom_s4 #(.MASTER_ID (0         )
                  ,.W_CID     (W_CID     )
                  ,.W_ID      (W_ID      )
                  ,.W_ADDR    (W_ADDR    )
                  ,.W_DATA    (W_DATA    )
                  ,.W_STRB    (W_STRB    )
                  ,.W_SID     (W_SID     )
                 )
     u_axi_stom_m0 (
           .AXI_RSTn             (AXI_RSTn    )
         , .AXI_CLK              (AXI_CLK     )
         , .M_MID                (M0_MID      )
         , .M_BID                (M0_BID      )
         , .M_BRESP              (M0_BRESP    )
         , .M_BVALID             (M0_BVALID   )
         , .M_BREADY             (M0_BREADY   )
         , .M_RID                (M0_RID      )
         , .M_RDATA              (M0_RDATA    )
         , .M_RRESP              (M0_RRESP    )
         , .M_RLAST              (M0_RLAST    )
         , .M_RVALID             (M0_RVALID   )
         , .M_RREADY             (M0_RREADY   )
                           , .S0_BID               (S0_BID      )
                           , .S0_BRESP             (S0_BRESP    )
                           , .S0_BVALID            (S0_BVALID   )
                           , .S0_BREADY            (S0_BREADY_M0)
                           , .S0_RID               (S0_RID      )
                           , .S0_RDATA             (S0_RDATA    )
                           , .S0_RRESP             (S0_RRESP    )
                           , .S0_RLAST             (S0_RLAST    )
                           , .S0_RVALID            (S0_RVALID   )
                           , .S0_RREADY            (S0_RREADY_M0)

                           , .S1_BID               (S1_BID      )
                           , .S1_BRESP             (S1_BRESP    )
                           , .S1_BVALID            (S1_BVALID   )
                           , .S1_BREADY            (S1_BREADY_M0)
                           , .S1_RID               (S1_RID      )
                           , .S1_RDATA             (S1_RDATA    )
                           , .S1_RRESP             (S1_RRESP    )
                           , .S1_RLAST             (S1_RLAST    )
                           , .S1_RVALID            (S1_RVALID   )
                           , .S1_RREADY            (S1_RREADY_M0)

                           , .S2_BID               (S2_BID      )
                           , .S2_BRESP             (S2_BRESP    )
                           , .S2_BVALID            (S2_BVALID   )
                           , .S2_BREADY            (S2_BREADY_M0)
                           , .S2_RID               (S2_RID      )
                           , .S2_RDATA             (S2_RDATA    )
                           , .S2_RRESP             (S2_RRESP    )
                           , .S2_RLAST             (S2_RLAST    )
                           , .S2_RVALID            (S2_RVALID   )
                           , .S2_RREADY            (S2_RREADY_M0)

                           , .S3_BID               (S3_BID      )
                           , .S3_BRESP             (S3_BRESP    )
                           , .S3_BVALID            (S3_BVALID   )
                           , .S3_BREADY            (S3_BREADY_M0)
                           , .S3_RID               (S3_RID      )
                           , .S3_RDATA             (S3_RDATA    )
                           , .S3_RRESP             (S3_RRESP    )
                           , .S3_RLAST             (S3_RLAST    )
                           , .S3_RVALID            (S3_RVALID   )
                           , .S3_RREADY            (S3_RREADY_M0)

                           , .SD_BID               (SD_BID      )
                           , .SD_BRESP             (SD_BRESP    )
                           , .SD_BVALID            (SD_BVALID   )
                           , .SD_BREADY            (SD_BREADY_M0)
                           , .SD_RID               (SD_RID      )
                           , .SD_RDATA             (SD_RDATA    )
                           , .SD_RRESP             (SD_RRESP    )
                           , .SD_RLAST             (SD_RLAST    )
                           , .SD_RVALID            (SD_RVALID   )
                           , .SD_RREADY            (SD_RREADY_M0)
                           , .r_order_grant        (r_order_grant) //input wire [12-1:0] [3:0]
        );
     
     // slaves to master for master 1
     axi_stom_s4 #(.MASTER_ID (1         )
                  ,.W_CID     (W_CID     )
                  ,.W_ID      (W_ID      )
                  ,.W_ADDR    (W_ADDR    )
                  ,.W_DATA    (W_DATA    )
                  ,.W_STRB    (W_STRB    )
                  ,.W_SID     (W_SID     )
                 )
     u_axi_stom_m1 (
           .AXI_RSTn             (AXI_RSTn    )
         , .AXI_CLK              (AXI_CLK     )
         , .M_MID                (M1_MID      )
         , .M_BID                (M1_BID      )
         , .M_BRESP              (M1_BRESP    )
         , .M_BVALID             (M1_BVALID   )
         , .M_BREADY             (M1_BREADY   )
         , .M_RID                (M1_RID      )
         , .M_RDATA              (M1_RDATA    )
         , .M_RRESP              (M1_RRESP    )
         , .M_RLAST              (M1_RLAST    )
         , .M_RVALID             (M1_RVALID   )
         , .M_RREADY             (M1_RREADY   )
                           , .S0_BID               (S0_BID      )
                           , .S0_BRESP             (S0_BRESP    )
                           , .S0_BVALID            (S0_BVALID   )
                           , .S0_BREADY            (S0_BREADY_M1)
                           , .S0_RID               (S0_RID      )
                           , .S0_RDATA             (S0_RDATA    )
                           , .S0_RRESP             (S0_RRESP    )
                           , .S0_RLAST             (S0_RLAST    )
                           , .S0_RVALID            (S0_RVALID   )
                           , .S0_RREADY            (S0_RREADY_M1)

                           , .S1_BID               (S1_BID      )
                           , .S1_BRESP             (S1_BRESP    )
                           , .S1_BVALID            (S1_BVALID   )
                           , .S1_BREADY            (S1_BREADY_M1)
                           , .S1_RID               (S1_RID      )
                           , .S1_RDATA             (S1_RDATA    )
                           , .S1_RRESP             (S1_RRESP    )
                           , .S1_RLAST             (S1_RLAST    )
                           , .S1_RVALID            (S1_RVALID   )
                           , .S1_RREADY            (S1_RREADY_M1)

                           , .S2_BID               (S2_BID      )
                           , .S2_BRESP             (S2_BRESP    )
                           , .S2_BVALID            (S2_BVALID   )
                           , .S2_BREADY            (S2_BREADY_M1)
                           , .S2_RID               (S2_RID      )
                           , .S2_RDATA             (S2_RDATA    )
                           , .S2_RRESP             (S2_RRESP    )
                           , .S2_RLAST             (S2_RLAST    )
                           , .S2_RVALID            (S2_RVALID   )
                           , .S2_RREADY            (S2_RREADY_M1)

                           , .S3_BID               (S3_BID      )
                           , .S3_BRESP             (S3_BRESP    )
                           , .S3_BVALID            (S3_BVALID   )
                           , .S3_BREADY            (S3_BREADY_M1)
                           , .S3_RID               (S3_RID      )
                           , .S3_RDATA             (S3_RDATA    )
                           , .S3_RRESP             (S3_RRESP    )
                           , .S3_RLAST             (S3_RLAST    )
                           , .S3_RVALID            (S3_RVALID   )
                           , .S3_RREADY            (S3_RREADY_M1)

                           , .SD_BID               (SD_BID      )
                           , .SD_BRESP             (SD_BRESP    )
                           , .SD_BVALID            (SD_BVALID   )
                           , .SD_BREADY            (SD_BREADY_M1)
                           , .SD_RID               (SD_RID      )
                           , .SD_RDATA             (SD_RDATA    )
                           , .SD_RRESP             (SD_RRESP    )
                           , .SD_RLAST             (SD_RLAST    )
                           , .SD_RVALID            (SD_RVALID   )
                           , .SD_RREADY            (SD_RREADY_M1)
                           , .r_order_grant        (r_order_grant) //input wire [12-1:0] [3:0]
        );
     
     // slaves to master for master 2
     axi_stom_s4 #(.MASTER_ID (2         )
                  ,.W_CID     (W_CID     )
                  ,.W_ID      (W_ID      )
                  ,.W_ADDR    (W_ADDR    )
                  ,.W_DATA    (W_DATA    )
                  ,.W_STRB    (W_STRB    )
                  ,.W_SID     (W_SID     )
                 )
     u_axi_stom_m2 (
           .AXI_RSTn             (AXI_RSTn    )
         , .AXI_CLK              (AXI_CLK     )
         , .M_MID                (M2_MID      )
         , .M_BID                (M2_BID      )
         , .M_BRESP              (M2_BRESP    )
         , .M_BVALID             (M2_BVALID   )
         , .M_BREADY             (M2_BREADY   )
         , .M_RID                (M2_RID      )
         , .M_RDATA              (M2_RDATA    )
         , .M_RRESP              (M2_RRESP    )
         , .M_RLAST              (M2_RLAST    )
         , .M_RVALID             (M2_RVALID   )
         , .M_RREADY             (M2_RREADY   )
                           , .S0_BID               (S0_BID      )
                           , .S0_BRESP             (S0_BRESP    )
                           , .S0_BVALID            (S0_BVALID   )
                           , .S0_BREADY            (S0_BREADY_M2)
                           , .S0_RID               (S0_RID      )
                           , .S0_RDATA             (S0_RDATA    )
                           , .S0_RRESP             (S0_RRESP    )
                           , .S0_RLAST             (S0_RLAST    )
                           , .S0_RVALID            (S0_RVALID   )
                           , .S0_RREADY            (S0_RREADY_M2)

                           , .S1_BID               (S1_BID      )
                           , .S1_BRESP             (S1_BRESP    )
                           , .S1_BVALID            (S1_BVALID   )
                           , .S1_BREADY            (S1_BREADY_M2)
                           , .S1_RID               (S1_RID      )
                           , .S1_RDATA             (S1_RDATA    )
                           , .S1_RRESP             (S1_RRESP    )
                           , .S1_RLAST             (S1_RLAST    )
                           , .S1_RVALID            (S1_RVALID   )
                           , .S1_RREADY            (S1_RREADY_M2)

                           , .S2_BID               (S2_BID      )
                           , .S2_BRESP             (S2_BRESP    )
                           , .S2_BVALID            (S2_BVALID   )
                           , .S2_BREADY            (S2_BREADY_M2)
                           , .S2_RID               (S2_RID      )
                           , .S2_RDATA             (S2_RDATA    )
                           , .S2_RRESP             (S2_RRESP    )
                           , .S2_RLAST             (S2_RLAST    )
                           , .S2_RVALID            (S2_RVALID   )
                           , .S2_RREADY            (S2_RREADY_M2)

                           , .S3_BID               (S3_BID      )
                           , .S3_BRESP             (S3_BRESP    )
                           , .S3_BVALID            (S3_BVALID   )
                           , .S3_BREADY            (S3_BREADY_M2)
                           , .S3_RID               (S3_RID      )
                           , .S3_RDATA             (S3_RDATA    )
                           , .S3_RRESP             (S3_RRESP    )
                           , .S3_RLAST             (S3_RLAST    )
                           , .S3_RVALID            (S3_RVALID   )
                           , .S3_RREADY            (S3_RREADY_M2)

                           , .SD_BID               (SD_BID      )
                           , .SD_BRESP             (SD_BRESP    )
                           , .SD_BVALID            (SD_BVALID   )
                           , .SD_BREADY            (SD_BREADY_M2)
                           , .SD_RID               (SD_RID      )
                           , .SD_RDATA             (SD_RDATA    )
                           , .SD_RRESP             (SD_RRESP    )
                           , .SD_RLAST             (SD_RLAST    )
                           , .SD_RVALID            (SD_RVALID   )
                           , .SD_RREADY            (SD_RREADY_M2)
                           , .r_order_grant        (r_order_grant) //input wire [12-1:0] [3:0]
        );
     
     // slaves to master for master 3
     axi_stom_s4 #(.MASTER_ID (3         )
                  ,.W_CID     (W_CID     )
                  ,.W_ID      (W_ID      )
                  ,.W_ADDR    (W_ADDR    )
                  ,.W_DATA    (W_DATA    )
                  ,.W_STRB    (W_STRB    )
                  ,.W_SID     (W_SID     )
                 )
     u_axi_stom_m3 (
           .AXI_RSTn             (AXI_RSTn    )
         , .AXI_CLK              (AXI_CLK     )
         , .M_MID                (M3_MID      )
         , .M_BID                (M3_BID      )
         , .M_BRESP              (M3_BRESP    )
         , .M_BVALID             (M3_BVALID   )
         , .M_BREADY             (M3_BREADY   )
         , .M_RID                (M3_RID      )
         , .M_RDATA              (M3_RDATA    )
         , .M_RRESP              (M3_RRESP    )
         , .M_RLAST              (M3_RLAST    )
         , .M_RVALID             (M3_RVALID   )
         , .M_RREADY             (M3_RREADY   )
                           , .S0_BID               (S0_BID      )
                           , .S0_BRESP             (S0_BRESP    )
                           , .S0_BVALID            (S0_BVALID   )
                           , .S0_BREADY            (S0_BREADY_M3)
                           , .S0_RID               (S0_RID      )
                           , .S0_RDATA             (S0_RDATA    )
                           , .S0_RRESP             (S0_RRESP    )
                           , .S0_RLAST             (S0_RLAST    )
                           , .S0_RVALID            (S0_RVALID   )
                           , .S0_RREADY            (S0_RREADY_M3)

                           , .S1_BID               (S1_BID      )
                           , .S1_BRESP             (S1_BRESP    )
                           , .S1_BVALID            (S1_BVALID   )
                           , .S1_BREADY            (S1_BREADY_M3)
                           , .S1_RID               (S1_RID      )
                           , .S1_RDATA             (S1_RDATA    )
                           , .S1_RRESP             (S1_RRESP    )
                           , .S1_RLAST             (S1_RLAST    )
                           , .S1_RVALID            (S1_RVALID   )
                           , .S1_RREADY            (S1_RREADY_M3)

                           , .S2_BID               (S2_BID      )
                           , .S2_BRESP             (S2_BRESP    )
                           , .S2_BVALID            (S2_BVALID   )
                           , .S2_BREADY            (S2_BREADY_M3)
                           , .S2_RID               (S2_RID      )
                           , .S2_RDATA             (S2_RDATA    )
                           , .S2_RRESP             (S2_RRESP    )
                           , .S2_RLAST             (S2_RLAST    )
                           , .S2_RVALID            (S2_RVALID   )
                           , .S2_RREADY            (S2_RREADY_M3)

                           , .S3_BID               (S3_BID      )
                           , .S3_BRESP             (S3_BRESP    )
                           , .S3_BVALID            (S3_BVALID   )
                           , .S3_BREADY            (S3_BREADY_M3)
                           , .S3_RID               (S3_RID      )
                           , .S3_RDATA             (S3_RDATA    )
                           , .S3_RRESP             (S3_RRESP    )
                           , .S3_RLAST             (S3_RLAST    )
                           , .S3_RVALID            (S3_RVALID   )
                           , .S3_RREADY            (S3_RREADY_M3)

                           , .SD_BID               (SD_BID      )
                           , .SD_BRESP             (SD_BRESP    )
                           , .SD_BVALID            (SD_BVALID   )
                           , .SD_BREADY            (SD_BREADY_M3)
                           , .SD_RID               (SD_RID      )
                           , .SD_RDATA             (SD_RDATA    )
                           , .SD_RRESP             (SD_RRESP    )
                           , .SD_RLAST             (SD_RLAST    )
                           , .SD_RVALID            (SD_RVALID   )
                           , .SD_RREADY            (SD_RREADY_M3)
                           , .r_order_grant        (r_order_grant) //input wire [12-1:0] [3:0]
        );
endmodule

module axi_arbiter_m2s_m4
     #(parameter W_CID = 6  // Channel ID width in bits
               , W_ID  = 6  // Transaction ID
               , W_SID = (W_CID+W_ID)
               , NUM   = 4 // num of masters
               )
(
       input  wire                  AXI_RSTn
     , input  wire                  AXI_CLK
     
     , input  wire  [NUM-1:0]       AWSELECT  
     , input  wire  [NUM-1:0]       AWVALID
     , input  wire  [NUM-1:0]       AWREADY
     , output wire  [NUM-1:0]       AWGRANT
     
     , input  wire  [NUM-1:0]       WSELECT
     , input  wire  [NUM-1:0]       WVALID
     , input  wire  [NUM-1:0]       WREADY
     , input  wire  [NUM-1:0]       WLAST
     , output reg   [NUM-1:0]       WGRANT
     
     , input  wire  [NUM-1:0]       ARSELECT
     , input  wire  [NUM-1:0]       ARVALID
     , input  wire  [NUM-1:0]       ARREADY
     , output wire  [NUM-1:0]       ARGRANT
     
     , input  wire                  arbiter_type
);
                                   
// read-address arbiter
localparam STAR_RUN = 'h0, STAR_WAIT = 'h1,
reg [NUM-1:0]  argrant_reg;
reg [1:0]      stateAR = STAR_RUN;

always @ (posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        argrant_reg <= 'h0;
        stateAR     <= STAR_RUN;
    end else begin
        case (stateAR)
            STAR_RUN: begin
                if (|ARGRANT) begin
                   // prevent the case that the granted-one is not completed due to ~ARREADY
                   // and new higher-priority-one joined, then things can go wrong.
                   if (~|(ARGRANT & ARREADY)) begin
                       argrant_reg <= ARGRANT;
                       stateAR     <= STAR_WAIT;
                   end
                end
            end // STAR_RUN
            STAR_WAIT: begin
                 if (|(ARGRANT & ARVALID & ARREADY)) begin
                     stateAR <= STAR_RUN;
                 end
            end // STAR_WAIT
        endcase
    end
end

wire [NUM_M-1:0] ARREQ;
wire [NUM_M-1:0] ar_sel;
assign ARREQ = ARSELECT & ARVALID;

rr_fixed_arbiter u_arbiter_ar(
.clk          (AXI_CLK      ),
.rst_n        (AXI_RSTn     ),
.arbiter_type (1'b1 /*arbiter_type*/ ),
.req          ({1'b0, ARREQ}),
.sel          (ar_sel       ) 
);

assign ARGRANT = (stateAR == STAR_RUN) ? ar_sel : argrant_reg;

     //-----------------------------------------------------------
     // write-address arbiter
localparam STAW_RUN = 'h0, STAW_WAIT = 'h1,
reg [NUM-1:0]  awgrant_reg;
reg [1:0]      stateAW = STAW_RUN;

always @ (posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        awgrant_reg <= 'h0;
        stateAW     <= STAW_RUN;
    end else begin
        case (stateAW)
            STAW_RUN: begin
                if (|AWGRANT) begin
                   if (~|(AWGRANT & AWREADY)) begin
                       awgrant_reg <= AWGRANT;
                       stateAW     <= STAW_WAIT;
                   end
                end
            end // STAW_RUN
            STAW_WAIT: begin
                 if (|(AWGRANT & AWVALID & AWREADY)) begin
                     stateAW <= STAW_RUN;
                 end
            end // STAW_WAIT
        endcase
    end
end

wire [NUM_M-1:0] AWREQ;
wire [NUM_M-1:0] aw_sel;
assign AWREQ = AWSELECT & AWVALID;

rr_fixed_arbiter u_arbiter_aw(
.clk          (AXI_CLK      ),
.rst_n        (AXI_RSTn     ),
.arbiter_type (1'b1 /*arbiter_type*/ ),
.req          ({1'b0, AWREQ}),
.sel          (aw_sel       ) 
);

assign AWGRANT = (stateAW == STAW_RUN) ? aw_sel : awgrant_reg;

     //-----------------------------------------------------------
     // write-data arbiter
localparam STW_RUN = 'h0, STW_WAIT = 'h1,
reg [NUM-1:0]  wgrant_reg;
reg [1:0]      stateW = STW_RUN;

always @ (posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        wgrant_reg <= 'h0;
        stateW     <= STW_RUN;
    end else begin
        case (stateW)
            STW_RUN: begin
                if (|WGRANT) begin
                   if (~|(WGRANT & WREADY)) begin
                       wgrant_reg <= WGRANT;
                       stateW     <= STW_WAIT;
                   end
                end
            end // STW_RUN
            STW_WAIT: begin
                 if (|(WGRANT & WVALID & WREADY)) begin
                     stateW <= STW_RUN;
                 end
            end // STW_WAIT
        endcase
    end
end

wire [NUM_M-1:0] WREQ;
wire [NUM_M-1:0] w_sel;
assign WREQ = WSELECT & WVALID;

rr_fixed_arbiter u_arbiter_w(
.clk          (AXI_CLK      ),
.rst_n        (AXI_RSTn     ),
.arbiter_type (1'b1 /*arbiter_type*/ ),
.req          ({1'b0, WREQ}),
.sel          (w_sel       ) 
);

assign WGRANT = (stateW == STW_RUN) ? w_sel : wgrant_reg;

endmodule

module axi_arbiter_s2m_m4
     #(parameter W_CID = 6  // Channel ID width in bits
               , W_ID  = 6  // Transaction ID
               , W_SID = (W_CID+W_ID)
               , NUM   = 4 // num of masters
               )
(
       input  wire                  AXI_RSTn
     , input  wire                  AXI_CLK
     
     , input  wire  [NUM:0]         BSELECT  
     , input  wire  [NUM:0]         BVALID
     , input  wire  [NUM:0]         BREADY
     , output wire  [NUM:0]         BGRANT
     
     , input  wire  [NUM-1:0]       RSELECT
     , input  wire  [NUM-1:0]       RVALID
     , input  wire  [NUM-1:0]       RREADY
     , input  wire  [NUM-1:0]       RLAST
     , output reg   [NUM-1:0]       RGRANT
     
);
                                   
// read-data arbiter
localparam STR_RUN = 'h0, STR_WAIT = 'h1,
reg [NUM-1:0]  rgrant_reg;
reg [1:0]      stateR = STR_RUN;

always @ (posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        rgrant_reg <= 'h0;
        stateR     <= STR_RUN;
    end else begin
        case (stateR)
            STR_RUN: begin
                if (|RGRANT) begin
                   if (~|(RGRANT & RREADY)) begin
                       rgrant_reg <= RGRANT;
                       stateR     <= STR_WAIT;
                   end
                end
            end // STR_RUN
            STR_WAIT: begin
                 if (|(RGRANT & RVALID & RREADY)) begin
                     stateR <= STR_RUN;
                 end
            end // STR_WAIT
        endcase
    end
end

wire [NUM_S-1:0] RREQ;
wire [NUM_S-1:0] r_sel;
assign RREQ = RSELECT & RVALID;

rr_fixed_arbiter u_arbiter_r(
.clk          (AXI_CLK      ),
.rst_n        (AXI_RSTn     ),
.arbiter_type (1'b1 /*arbiter_type*/ ),
.req          ({1'b0, RREQ}),
.sel          (r_sel       ) 
);

assign RGRANT = (stateR == STR_RUN) ? r_sel : rgrant_reg;

// write-response arbiter
localparam STB_RUN = 'h0, STB_WAIT = 'h1,
reg [NUM-1:0]  bgrant_reg;
reg [1:0]      stateB = STB_RUN;

always @ (posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        stateB     <= STB_RUN;
    end else begin
        case (stateB)
            STB_RUN: begin
                if (|BGRANT) begin
                   if (~|(BGRANT & BREADY)) begin
                       bgrant_reg <= BGRANT;
                       stateB     <= STB_WAIT;
                   end
                end
            end // STB_RUN
            STB_WAIT: begin
                 if (|(BGRANT & BVALID & BREADY)) begin
                     stateB <= STB_RUN;
                 end
            end // STB_WAIT
        endcase
    end
end

wire [NUM_S-1:0] BREQ;
wire [NUM_S-1:0] b_sel;
assign BREQ = BSELECT & BVALID;

rr_fixed_arbiter u_arbiter_b(
.clk          (AXI_CLK      ),
.rst_n        (AXI_RSTn     ),
.arbiter_type (1'b1 /*arbiter_type*/ ),
.req          ({1'b0, BREQ}),
.sel          (b_sel       ) 
);

assign BGRANT = (stateB == STB_RUN) ? b_sel : bgrant_reg;

endmodule
//---------------------------------------------------------------------------
module axi_m2s_m4
       #(parameter SLAVE_ID      = 0    // for reference
                 , SLAVE_EN      = 1'b1 // the slave is available when 1
                 , ADDR_BASE     = 32'h0000_0000
                 , ADDR_LENGTH   = 12 // effective addre bits
                 , W_CID         = 6  // Channel ID width in bits
                 , W_ID          = 6  // ID width in bits
                 , W_ADDR        = 32 // address width
                 , W_DATA        = 32 // data width
                 , W_STRB        = (W_DATA/8)  // data strobe width
                 , W_SID         = W_CID+W_ID // ID for slave
                 , NUM_MASTER    = 4    // number of master
                 , SLAVE_DEFAULT = 1'b0  // default-salve when 1
        )
(
       input   wire                      AXI_RSTn
     , input   wire                      AXI_CLK

     , input   wire  [W_CID-1:0]         M0_MID
     , input   wire  [W_ID-1:0]          M0_AWID
     , input   wire  [W_ADDR-1:0]        M0_AWADDR
     , input   wire  [ 7:0]              M0_AWLEN
     , input   wire  [ 2:0]              M0_AWSIZE
     , input   wire  [ 1:0]              M0_AWBURST
     , input   wire                      M0_AWVALID
     , output  wire                      M0_AWREADY
     , input   wire  [W_ID-1:0]          M0_WID
     , input   wire  [W_DATA-1:0]        M0_WDATA
     , input   wire  [W_STRB-1:0]        M0_WSTRB
     , input   wire                      M0_WLAST
     , input   wire                      M0_WVALID
     , output  wire                      M0_WREADY
     , input   wire  [W_ID-1:0]          M0_ARID
     , input   wire  [W_ADDR-1:0]        M0_ARADDR
     , input   wire  [ 7:0]              M0_ARLEN
     , input   wire  [ 2:0]              M0_ARSIZE
     , input   wire  [ 1:0]              M0_ARBURST
     , input   wire                      M0_ARVALID
     , output  wire                      M0_ARREADY
     
     , input   wire  [W_CID-1:0]         M1_MID
     , input   wire  [W_ID-1:0]          M1_AWID
     , input   wire  [W_ADDR-1:0]        M1_AWADDR
     , input   wire  [ 7:0]              M1_AWLEN
     , input   wire  [ 2:0]              M1_AWSIZE
     , input   wire  [ 1:0]              M1_AWBURST
     , input   wire                      M1_AWVALID
     , output  wire                      M1_AWREADY
     , input   wire  [W_ID-1:0]          M1_WID
     , input   wire  [W_DATA-1:0]        M1_WDATA
     , input   wire  [W_STRB-1:0]        M1_WSTRB
     , input   wire                      M1_WLAST
     , input   wire                      M1_WVALID
     , output  wire                      M1_WREADY
     , input   wire  [W_ID-1:0]          M1_ARID
     , input   wire  [W_ADDR-1:0]        M1_ARADDR
     , input   wire  [ 7:0]              M1_ARLEN
     , input   wire  [ 2:0]              M1_ARSIZE
     , input   wire  [ 1:0]              M1_ARBURST
     , input   wire                      M1_ARVALID
     , output  wire                      M1_ARREADY
     
     , input   wire  [W_CID-1:0]         M2_MID
     , input   wire  [W_ID-1:0]          M2_AWID
     , input   wire  [W_ADDR-1:0]        M2_AWADDR
     , input   wire  [ 7:0]              M2_AWLEN
     , input   wire  [ 2:0]              M2_AWSIZE
     , input   wire  [ 1:0]              M2_AWBURST
     , input   wire                      M2_AWVALID
     , output  wire                      M2_AWREADY
     , input   wire  [W_ID-1:0]          M2_WID
     , input   wire  [W_DATA-1:0]        M2_WDATA
     , input   wire  [W_STRB-1:0]        M2_WSTRB
     , input   wire                      M2_WLAST
     , input   wire                      M2_WVALID
     , output  wire                      M2_WREADY
     , input   wire  [W_ID-1:0]          M2_ARID
     , input   wire  [W_ADDR-1:0]        M2_ARADDR
     , input   wire  [ 7:0]              M2_ARLEN
     , input   wire  [ 2:0]              M2_ARSIZE
     , input   wire  [ 1:0]              M2_ARBURST
     , input   wire                      M2_ARVALID
     , output  wire                      M2_ARREADY
     
     , input   wire  [W_CID-1:0]         M3_MID
     , input   wire  [W_ID-1:0]          M3_AWID
     , input   wire  [W_ADDR-1:0]        M3_AWADDR
     , input   wire  [ 7:0]              M3_AWLEN
     , input   wire  [ 2:0]              M3_AWSIZE
     , input   wire  [ 1:0]              M3_AWBURST
     , input   wire                      M3_AWVALID
     , output  wire                      M3_AWREADY
     , input   wire  [W_ID-1:0]          M3_WID
     , input   wire  [W_DATA-1:0]        M3_WDATA
     , input   wire  [W_STRB-1:0]        M3_WSTRB
     , input   wire                      M3_WLAST
     , input   wire                      M3_WVALID
     , output  wire                      M3_WREADY
     , input   wire  [W_ID-1:0]          M3_ARID
     , input   wire  [W_ADDR-1:0]        M3_ARADDR
     , input   wire  [ 7:0]              M3_ARLEN
     , input   wire  [ 2:0]              M3_ARSIZE
     , input   wire  [ 1:0]              M3_ARBURST
     , input   wire                      M3_ARVALID
     , output  wire                      M3_ARREADY
     
     , output  reg    [W_SID-1:0]        S_AWID
     , output  reg    [W_ADDR-1:0]       S_AWADDR
     , output  reg    [ 7:0]             S_AWLEN
     , output  reg    [ 2:0]             S_AWSIZE
     , output  reg    [ 1:0]             S_AWBURST
     , output  reg                       S_AWVALID
     , input   wire                      S_AWREADY
     , output  reg    [W_SID-1:0]        S_WID
     , output  reg    [W_DATA-1:0]       S_WDATA
     , output  reg    [W_STRB-1:0]       S_WSTRB
     , output  reg                       S_WLAST
     , output  reg                       S_WVALID
     , input   wire                      S_WREADY
     , output  reg    [W_SID-1:0]        S_ARID
     , output  reg    [W_ADDR-1:0]       S_ARADDR
     , output  reg    [ 7:0]             S_ARLEN
     , output  reg    [ 2:0]             S_ARSIZE
     , output  reg    [ 1:0]             S_ARBURST
     , output  reg                       S_ARVALID
     , input   wire                      S_ARREADY
     
     , output  wire  [NUM_MASTER-1:0]    AWSELECT_OUT
     , output  wire  [NUM_MASTER-1:0]    ARSELECT_OUT
     , input   wire  [NUM_MASTER-1:0]    AWSELECT_IN
     , input   wire  [NUM_MASTER-1:0]    ARSELECT_IN
     
     , input   wire  [2:0]               w_order_grant
);

reg  [NUM_MASTER-1:0] AWSELECT;
reg  [NUM_MASTER-1:0] ARSELECT;
reg  [NUM_MASTER-1:0] WSELECT;
wire [NUM_MASTER-1:0] WSELECT_in;
wire [NUM_MASTER-1:0] AWGRANT, WGRANT, ARGRANT;

assign  AWSELECT_OUT = AWSELECT;
assign  ARSELECT_OUT = ARSELECT;

//-----------------------decode------------------------------------
always @ ( * ) begin
   if (SLAVE_DEFAULT=='h0) begin
       AWSELECT[0] = SLAVE_EN[0]&(M0_AWADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);
       AWSELECT[1] = SLAVE_EN[0]&(M1_AWADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);
       AWSELECT[2] = SLAVE_EN[0]&(M2_AWADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);
       AWSELECT[3] = SLAVE_EN[0]&(M3_AWADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);

       WSELECT[0] = SLAVE_EN[0]&(M0_WID[5:3]==ADDR_BASE[ADDR_LENGTH+2:ADDR_LENGTH]);
       WSELECT[1] = SLAVE_EN[0]&(M1_WID[5:3]==ADDR_BASE[ADDR_LENGTH+2:ADDR_LENGTH]);
       WSELECT[2] = SLAVE_EN[0]&(M2_WID[5:3]==ADDR_BASE[ADDR_LENGTH+2:ADDR_LENGTH]);
       WSELECT[3] = SLAVE_EN[0]&(M3_WID[5:3]==ADDR_BASE[ADDR_LENGTH+2:ADDR_LENGTH]);

       ARSELECT[0] = SLAVE_EN[0]&(M0_ARADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);
       ARSELECT[1] = SLAVE_EN[0]&(M1_ARADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);
       ARSELECT[2] = SLAVE_EN[0]&(M2_ARADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);
       ARSELECT[3] = SLAVE_EN[0]&(M3_ARADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);
   end else begin
       AWSELECT = ~AWSELECT_IN & {M3_AWVALID,M2_AWVALID,M1_AWVALID,M0_AWVALID};
       ARSELECT = ~ARSELECT_IN & {M3_ARVALID,M2_ARVALID,M1_ARVALID,M0_ARVALID};
   end
end

assign WSELECT_in = WSELECT & w_order_grant;

wire [NUM_MASTER-1:0] AWVALID_ALL = {M3_AWVALID,M2_AWVALID,M1_AWVALID,M0_AWVALID};
wire [NUM_MASTER-1:0] AWREADY_ALL = {M3_AWREADY,M2_AWREADY,M1_AWREADY,M0_AWREADY};
wire [NUM_MASTER-1:0] ARVALID_ALL = {M3_ARVALID,M2_ARVALID,M1_ARVALID,M0_ARVALID};
wire [NUM_MASTER-1:0] ARREADY_ALL = {M3_ARREADY,M2_ARREADY,M1_ARREADY,M0_ARREADY};
wire [NUM_MASTER-1:0] WVALID_ALL = {M3_WVALID,M2_WVALID,M1_WVALID,M0_WVALID};
wire [NUM_MASTER-1:0] WREADY_ALL = {M3_WREADY,M2_WREADY,M1_WREADY,M0_WREADY};
wire [NUM_MASTER-1:0] WLAST_ALL = {M3_WLAST,M2_WLAST,M1_WLAST,M0_WLAST};
     
//----------------------arbiter-------------------------
axi_arbiter_m2s_m4 #(.W_CID (W_CID)
                     ,.W_ID (W_ID )
                     )
u_axi_arbiter_m2s_m4 (
      .AXI_RSTn (AXI_RSTn          )
    , .AXI_CLK  (AXI_CLK           )

    , .AWSELECT (AWSELECT          )
    , .AWVALID  (AWVALID_ALL       )
    , .AWREADY  (AWREADY_ALL       )
    , .AWGRANT  (AWGRANT           )

    , .WSELECT  (WSELECT_in        )
    , .WVALID   (WVALID_ALL        )
    , .WREADY   (WREADY_ALL        )
    , .WLAST    (WREADY_ALL        )
    , .WGRANT   (WGRANT            )

    , .ARSELECT (ARSELECT          )
    , .ARVALID  (ARVALID_ALL       )
    , .ARREADY  (ARREADY_ALL       )
    , .ARGRANT  (ARGRANT           )
);

localparam NUM_AW_WIDTH = W_SID + W_ADDR + 8 + 3 + 2 + 1; //S_AWID S_AWADDR S_AWLEN S_AWSIZE S_AWBURST S_AWVALID
localparam NUM_W_WIDTH = W_SID + W_DATA + W_STRB + 1 + 1; //S_WID S_WDATA S_WSTRB S_WLAST S_WVALID
localparam NUM_AR_WIDTH = W_SID + W_ADDR + 8 + 3 + 2 + 1; //S_ARID S_ARADDR S_ARLEN S_ARSIZE S_ARBURST S_ARVALID

wire [NUM_AW_WIDTH-1:0] bus_aw[0:NUM_MASTER-1];
wire [NUM_W_WIDTH-1 :0] bus_w [0:NUM_MASTER-1];
wire [NUM_AR_WIDTH-1:0] bus_ar[0:NUM_MASTER-1];

assign M0_AWREADY = AWGRANT[0] & S_AWREADY;
assign M1_AWREADY = AWGRANT[1] & S_AWREADY;
assign M2_AWREADY = AWGRANT[2] & S_AWREADY;
assign M3_AWREADY = AWGRANT[3] & S_AWREADY;

assign M0_WREADY  = WGRANT [0] & S_WREADY;
assign M1_WREADY  = WGRANT [1] & S_WREADY;
assign M2_WREADY  = WGRANT [2] & S_WREADY;
assign M3_WREADY  = WGRANT [3] & S_WREADY;

assign M0_ARREADY = ARGRANT[0] & S_ARREADY;
assign M1_ARREADY = ARGRANT[1] & S_ARREADY;
assign M2_ARREADY = ARGRANT[2] & S_ARREADY;
assign M3_ARREADY = ARGRANT[3] & S_ARREADY;

assign bus_aw[0] = {ADDR_BASE[14:12], M0_MID, M0_AWID, M0_AWADDR, M0_AWLEN, M0_AWSIZE, M0_AWBURST, M0_AWVALID};
assign bus_aw[1] = {ADDR_BASE[14:12], M1_MID, M1_AWID, M1_AWADDR, M1_AWLEN, M1_AWSIZE, M1_AWBURST, M1_AWVALID};
assign bus_aw[2] = {ADDR_BASE[14:12], M2_MID, M2_AWID, M2_AWADDR, M2_AWLEN, M2_AWSIZE, M2_AWBURST, M2_AWVALID};
assign bus_aw[3] = {ADDR_BASE[14:12], M3_MID, M3_AWID, M3_AWADDR, M3_AWLEN, M3_AWSIZE, M3_AWBURST, M3_AWVALID};

//Format of S_WID: {3-bit slv_addr}, {3-bit mst_ID}, {6-bit M_WID: 3_bit_slv + 3_bit_ID}
assign bus_w[0]  = {ADDR_BASE[14:12], M0_MID, M0_WID, M0_WDATA, M0_WSTRB, M0_WLAST, M0_WVALID};
assign bus_w[1]  = {ADDR_BASE[14:12], M1_MID, M1_WID, M1_WDATA, M1_WSTRB, M1_WLAST, M1_WVALID};
assign bus_w[2]  = {ADDR_BASE[14:12], M2_MID, M2_WID, M2_WDATA, M2_WSTRB, M2_WLAST, M2_WVALID};
assign bus_w[3]  = {ADDR_BASE[14:12], M3_MID, M3_WID, M3_WDATA, M3_WSTRB, M3_WLAST, M3_WVALID};

//Format of S_ARID: {3-bit slv_addr}, {3-bit mst_ID}, {6-bit M_ARID}
assign bus_ar[0] = {ADDR_BASE[14:12], M0_MID, M0_ARID, M0_ARADDR, M0_ARLEN, M0_ARSIZE, M0_ARBURST, M0_ARVALID};
assign bus_ar[1] = {ADDR_BASE[14:12], M1_MID, M1_ARID, M1_ARADDR, M1_ARLEN, M1_ARSIZE, M1_ARBURST, M1_ARVALID};
assign bus_ar[2] = {ADDR_BASE[14:12], M2_MID, M2_ARID, M2_ARADDR, M2_ARLEN, M2_ARSIZE, M2_ARBURST, M2_ARVALID};
assign bus_ar[3] = {ADDR_BASE[14:12], M3_MID, M3_ARID, M3_ARADDR, M3_ARLEN, M3_ARSIZE, M3_ARBURST, M3_ARVALID};

//-------------------router--------------------------
`define S_AWBUS {S_AWID, S_AWADDR, S_AWLEN, S_AWSIZE, S_AWBURST, S_AWVALID}
always @ ( AWGRANT, bus_aw[0], bus_aw[1], bus_aw[2], bus_aw[3] ) begin
       case (AWGRANT)
       4'h1:  `S_AWBUS = bus_aw[0];
       4'h2:  `S_AWBUS = bus_aw[1];
       4'h4:  `S_AWBUS = bus_aw[2];
       4'h8:  `S_AWBUS = bus_aw[3];
       default:    `S_AWBUS = 'h0;
       endcase
end

`define S_WBUS {`define S_WBUS {S_WID, S_WDATA, S_WSTRB, S_WLAST, S_WVALID} }
always @ ( WGRANT, bus_w[0], bus_w[1], bus_w[2], bus_w[3] ) begin
       case (WGRANT)
       4'h1:  `S_WBUS = bus_w[0];
       4'h2:  `S_WBUS = bus_w[1];
       4'h4:  `S_WBUS = bus_w[2];
       4'h8:  `S_WBUS = bus_w[3];
       default:    `S_WBUS = 'h0;
       endcase
end

`define S_ARBUS {`define S_ARBUS {S_ARID, S_ARADDR, S_ARLEN, S_ARSIZE, S_ARBURST, S_ARVALID}}
always @ ( ARGRANT, bus_ar[0], bus_ar[1], bus_ar[2], bus_ar[3] ) begin
       case (ARGRANT)
       4'h1:  `S_ARBUS = bus_ar[0];
       4'h2:  `S_ARBUS = bus_ar[1];
       4'h4:  `S_ARBUS = bus_ar[2];
       4'h8:  `S_ARBUS = bus_ar[3];
       default:    `S_ARBUS = 'h0;
       endcase
end

endmodule

module axi_s2m_s4
       #(parameter MASTER_ID   = 0 // for reference
                 , W_CID       = 6 // Channel ID width in bits
                 , W_ID        = 6 // ID width in bits
                 , W_ADDR      = 32 // address width
                 , W_DATA      = 32 // data width
                 , W_STRB      = (W_DATA/8)  // data strobe width
                 , W_SID       = W_CID+W_ID // ID for slave
        )
(
       input   wire                      AXI_RSTn
     , input   wire                      AXI_CLK
     
     , input   wire  [W_CID-1:0]         M_MID
     , output  reg   [W_ID-1:0]          M_BID
     , output  reg   [ 1:0]              M_BRESP
     , output  reg                       M_BVALID
     , input   wire                      M_BREADY
     , output  reg   [W_ID-1:0]          M_RID
     , output  reg   [W_DATA-1:0]        M_RDATA
     , output  reg   [ 1:0]              M_RRESP
     , output  reg                       M_RLAST
     , output  reg                       M_RVALID
     , input   wire                      M_RREADY
     
     , input   wire   [W_SID-1:0]        S0_BID
     , input   wire   [ 1:0]             S0_BRESP
     , input   wire                      S0_BVALID
     , output  wire                      S0_BREADY
     , input   wire   [W_SID-1:0]        S0_RID
     , input   wire   [W_DATA-1:0]       S0_RDATA
     , input   wire   [ 1:0]             S0_RRESP
     , input   wire                      S0_RLAST
     , input   wire                      S0_RVALID
     , output  wire                      S0_RREADY
     
     , input   wire   [W_SID-1:0]        S1_BID
     , input   wire   [ 1:0]             S1_BRESP
     , input   wire                      S1_BVALID
     , output  wire                      S1_BREADY
     , input   wire   [W_SID-1:0]        S1_RID
     , input   wire   [W_DATA-1:0]       S1_RDATA
     , input   wire   [ 1:0]             S1_RRESP
     , input   wire                      S1_RLAST
     , input   wire                      S1_RVALID
     , output  wire                      S1_RREADY
     
     , input   wire   [W_SID-1:0]        S2_BID
     , input   wire   [ 1:0]             S2_BRESP
     , input   wire                      S2_BVALID
     , output  wire                      S2_BREADY
     , input   wire   [W_SID-1:0]        S2_RID
     , input   wire   [W_DATA-1:0]       S2_RDATA
     , input   wire   [ 1:0]             S2_RRESP
     , input   wire                      S2_RLAST
     , input   wire                      S2_RVALID
     , output  wire                      S2_RREADY
     
     , input   wire   [W_SID-1:0]        S3_BID
     , input   wire   [ 1:0]             S3_BRESP
     , input   wire                      S3_BVALID
     , output  wire                      S3_BREADY
     , input   wire   [W_SID-1:0]        S3_RID
     , input   wire   [W_DATA-1:0]       S3_RDATA
     , input   wire   [ 1:0]             S3_RRESP
     , input   wire                      S3_RLAST
     , input   wire                      S3_RVALID
     , output  wire                      S3_RREADY
     
     , input   wire   [W_SID-1:0]        SD_BID
     , input   wire   [ 1:0]             SD_BRESP
     , input   wire                      SD_BVALID
     , output  wire                      SD_BREADY
     , input   wire   [W_SID-1:0]        SD_RID
     , input   wire   [W_DATA-1:0]       SD_RDATA
     , input   wire   [ 1:0]             SD_RRESP
     , input   wire                      SD_RLAST
     , input   wire                      SD_RVALID
     , output  wire                      SD_RREADY
     
     , input wire [W_SID-1:0]                  r_order_grant
);
localparam NUM = 4;

wire [NUM:0] BSELECT, RSELECT;
wire [NUM:0] RSELECT_in;
wire [NUM:0] BGRANT, RGRANT ;

//-------------------decode-------------------------
assign BSELECT[0] = (S0_BID[W_SID-1:W_ID]==M_MID);
assign BSELECT[1] = (S1_BID[W_SID-1:W_ID]==M_MID);
assign BSELECT[2] = (S2_BID[W_SID-1:W_ID]==M_MID);
assign BSELECT[3] = (S3_BID[W_SID-1:W_ID]==M_MID);
assign BSELECT[4] = (SD_BID[W_SID-1:W_ID]==M_MID);

assign RSELECT[0] = (S0_RID[W_SID-1:W_ID]==M_MID);
assign RSELECT[1] = (S1_RID[W_SID-1:W_ID]==M_MID);
assign RSELECT[2] = (S2_RID[W_SID-1:W_ID]==M_MID);
assign RSELECT[3] = (S3_RID[W_SID-1:W_ID]==M_MID);
assign RSELECT[4] = (SD_RID[W_SID-1:W_ID]==M_MID);

assign RSELECT_in = RSELECT & {1'b1,r_order_grant};

axi_arbiter_s2m_s4 #(.NUM(NUM))
u_axi_arbiter_s2m_s4 (
      .AXI_RSTn (AXI_RSTn  )
    , .AXI_CLK  (AXI_CLK   )

    , .BSELECT  (BSELECT)
    , .BVALID   ({SD_BVALID,S3_BVALID,S2_BVALID,S1_BVALID,S0_BVALID})
    , .BREADY   ({SD_BREADY,S3_BREADY,S2_BREADY,S1_BREADY,S0_BREADY})
    , .BGRANT   (BGRANT )

    , .RSELECT  (RSELECT_in)
    , .RVALID   ({SD_RVALID,S3_RVALID,S2_RVALID,S1_RVALID,S0_RVALID})
    , .RREADY   ({SD_RREADY,S3_RREADY,S2_RREADY,S1_RREADY,S0_RREADY})
    , .RLAST    ({SD_RLAST,S3_RLAST,S2_RLAST,S1_RLAST,S0_RLAST})
    , .RGRANT   (RGRANT )
);

localparam NUM_B_WIDTH = W_ID+2+1 ; // M_BID M_BRESP M_BVALID
localparam NUM_R_WIDTH = W_SID+W_DATA+2+1+1; // M_RSID M_RDATA M_RRESP M_RLAST M_RVALID

wire [NUM_B_WIDTH-1:0] bus_b[0:NUM];
wire [NUM_R_WIDTH-1:0] bus_r[0:NUM];

assign bus_b[0] = {S0_BID[W_ID-1:0], S0_BRESP, S0_BVALID};
assign bus_b[1] = {S1_BID[W_ID-1:0], S1_BRESP, S1_BVALID};
assign bus_b[2] = {S2_BID[W_ID-1:0], S2_BRESP, S2_BVALID};
assign bus_b[3] = {S3_BID[W_ID-1:0], S3_BRESP, S3_BVALID};
assign bus_b[NUM] = {SD_BID[W_ID-1:0], SD_BRESP, SD_BVALID};

assign bus_r[0] = {S0_RID[W_ID-1:0], S0_RDATA, S0_RRESP, S0_RLAST, S0_RVALID};
assign bus_r[1] = {S1_RID[W_ID-1:0], S1_RDATA, S1_RRESP, S1_RLAST, S1_RVALID};
assign bus_r[2] = {S2_RID[W_ID-1:0], S2_RDATA, S2_RRESP, S2_RLAST, S2_RVALID};
assign bus_r[3] = {S3_RID[W_ID-1:0], S3_RDATA, S3_RRESP, S3_RLAST, S3_RVALID};
assign bus_r[NUM] = {SD_RID, SD_RDATA, SD_RRESP, SD_RLAST, SD_RVALID};

//---------------------------router------------------------
`define M_BBUS {M_BID[W_ID-1:0], M_BRESP, M_BVALID }
always @ ( BGRANT, bus_b[0], bus_b[1], bus_b[2], bus_b[3], bus_b[NUM] ) begin
       case (BGRANT)
       5'h1: `M_BBUS = bus_b[0];
       5'h2: `M_BBUS = bus_b[1];
       5'h4: `M_BBUS = bus_b[2];
       5'h8: `M_BBUS = bus_b[3];
       5'h10: `M_BBUS = bus_b[NUM];
       default:    `M_BBUS = 'h0;
       endcase
end

`define M_RBUS {M_RSID, M_RDATA, M_RRESP, M_RLAST, M_RVALID}
always @ ( RGRANT, bus_r[0], bus_r[1], bus_r[2], bus_r[3], bus_r[NUM] ) begin
       case (RGRANT)
       5'h1: `M_RBUS = bus_r[0];
       5'h2: `M_RBUS = bus_r[1];
       5'h4: `M_RBUS = bus_r[2];
       5'h8: `M_RBUS = bus_r[3];
       5'h10: `M_RBUS = bus_r[NUM];
       default:    `M_RBUS = 'h0;
       endcase
end

assign S0_BREADY = BGRANT[0] & M_BREADY;
assign S1_BREADY = BGRANT[1] & M_BREADY;
assign S2_BREADY = BGRANT[2] & M_BREADY;
assign S3_BREADY = BGRANT[3] & M_BREADY;
assign SD_BREADY = BGRANT[NUM] & M_BREADY;

assign S0_RREADY = RGRANT[0] & M_RREADY;
assign S1_RREADY = RGRANT[1] & M_RREADY;
assign S2_RREADY = RGRANT[2] & M_RREADY;
assign S3_RREADY = RGRANT[3] & M_RREADY;
assign SD_RREADY = RGRANT[NUM] & M_RREADY;

endmodule
     
module axi_default_slave
     #(parameter W_CID  = 6         // Channel ID width in bits
               , W_ID   = 6         // ID width in bits
               , W_ADDR = 32        // address width
               , W_DATA = 32        // data width
               , W_STRB = W_DATA/8  // data strobe width
               , W_SID  = W_CID+W_ID
      )
(
       input  wire                 AXI_RSTn
     , input  wire                 AXI_CLK
     , input  wire [W_SID-1:0]     AWID
     , input  wire [W_ADDR-1:0]    AWADDR
     , input  wire [ 7:0]          AWLEN
     , input  wire [ 2:0]          AWSIZE
     , input  wire [ 1:0]          AWBURST
     , input  wire                 AWVALID
     , output reg                  AWREADY
     , input  wire [W_SID-1:0]     WID
     , input  wire [W_DATA-1:0]    WDATA
     , input  wire [W_STRB-1:0]    WSTRB
     , input  wire                 WLAST
     , input  wire                 WVALID
     , output reg                  WREADY
     , output reg  [W_SID-1:0]     BID
     , output wire [ 1:0]          BRESP
     , output reg                  BVALID
     , input  wire                 BREADY
     , input  wire [W_SID-1:0]     ARID
     , input  wire [W_ADDR-1:0]    ARADDR
     , input  wire [ 7:0]          ARLEN
     , input  wire [ 2:0]          ARSIZE
     , input  wire [ 1:0]          ARBURST
     , input  wire                 ARVALID
     , output reg                  ARREADY
     , output reg  [W_SID-1:0]     RID
     , output wire [W_DATA-1:0]    RDATA
     , output wire [ 1:0]          RRESP
     , output reg                  RLAST
     , output reg                  RVALID
     , input  wire                 RREADY
);
     //-----------------------------------------------------------
     // write case
     //-----------------------------------------------------------
     assign BRESP = 2'b11; // DECERR: decode error
     reg [W_SID-1:0] awid_reg;
     reg [8:0] countW, awlen_reg;
     //-----------------------------------------------------------
     localparam STW_IDLE   = 'h0,
                STW_RUN    = 'h1,
                STW_WAIT   = 'h2,
                STW_RSP    = 'h3;
     reg [1:0] stateW=STW_IDLE;
     always @ (posedge AXI_CLK) begin
         if (AXI_RSTn==1'b0) begin
             AWREADY   <= 1'b0;
             WREADY    <= 1'b0;
             BID       <=  'h0;
             BVALID    <= 1'b0;
             countW    <=  'h0;
             awlen_reg <=  'h0;
             awid_reg  <=  'h0;
             stateW    <= STW_IDLE;
         end else begin
             case (stateW)
             STW_IDLE: begin
                 if (AWVALID==1'b1) begin
                     AWREADY <= 1'b1;
                     stateW  <= STW_RUN;
                 end
                 end // STW_IDLE
             STW_RUN: begin
                 if ((AWVALID==1'b1)&&(AWREADY==1'b1)) begin
                      AWREADY   <= 1'b0;
                      WREADY    <= 1'b1;
                      awlen_reg <= {1'b0,AWLEN};
                      awid_reg  <= AWID;
                      stateW    <= STW_WAIT;
                 end else begin
                 end
                 end // STW_IDLE
             STW_WAIT: begin
                 if (WVALID==1'b1) begin
                     if ((countW>=awlen_reg)||(WLAST==1'b1)) begin
                         BID    <= awid_reg;
                         BVALID <= 1'b1;
                         WREADY <= 1'b0;
                         countW <= 'h0;
                         stateW <= STW_RSP;
                         // synopsys translate_off
                         if (WLAST==1'b0) begin
                             $display("%04d %m Error expecting WLAST", $time);
                         end
                         // synopsys translate_on
                     end else begin
                         countW <= countW + 1;
                     end
                 end
                 // synopsys translate_off
                 if ((WVALID==1'b1)&&(WID!=awid_reg)) begin
                     $display("%04d %m Error AWID(0x%x):WID(0x%x) mismatch", $time, awid_reg, WID);
                 end
                 // synopsys translate_on
                 end // STW_WAIT
             STW_RSP: begin
                 if (BREADY==1'b1) begin
                     BVALID  <= 1'b0;
                     if (AWVALID==1'b1) begin
                         AWREADY <= 1'b1;
                         stateW  <= STW_RUN;
                     end else begin
                         stateW  <= STW_IDLE;
                     end
                 end
                 end // STW_RSP
             endcase
         end
     end
     //-----------------------------------------------------------
     // read case
     //-----------------------------------------------------------
     assign RRESP = 2'b11; // DECERR; decode error
     assign RDATA = ~'h0;
     reg [W_SID-1:0] arid_reg;
     reg [8:0] countR, arlen_reg;
     //-----------------------------------------------------------
     localparam STR_IDLE   = 'h0,
                STR_RUN    = 'h1,
                STR_WAIT   = 'h2,
                STR_END    = 'h3;
     reg [1:0] stateR=STR_IDLE;
     always @ (posedge AXI_CLK) begin
         if (AXI_RSTn==1'b0) begin
             ARREADY   <= 1'b0;
             RID       <=  'h0;
             RLAST     <= 1'b0;
             RVALID    <= 1'b0;
             arid_reg  <=  'h0;
             arlen_reg <=  'h0;
             countR    <=  'h0;
             stateR    <= STR_IDLE;
         end else begin
             case (stateR)
             STR_IDLE: begin
                 if (ARVALID==1'b1) begin
                      ARREADY   <= 1'b1;
                      stateR    <= STR_RUN;
                 end
                 end // STR_IDLE
             STR_RUN: begin
                 if ((ARVALID==1'b1)&&(ARREADY==1'b1)) begin
                      ARREADY   <= 1'b0;
                      arlen_reg <= ARLEN+1;
                      arid_reg  <= ARID;
                      RID       <= ARID;
                      RVALID    <= 1'b1;
                      RLAST     <= (ARLEN=='h0) ? 1'b1 : 1'b0;
                      countR    <=  'h2;
                      stateR    <= STR_WAIT;
                 end
                 end // STR_IDLE
             STR_WAIT: begin
                 if (RREADY==1'b1) begin
                     if (countR>=(arlen_reg+1)) begin
                         RVALID  <= 1'b0;
                         RLAST   <= 1'b0;
                         countR  <= 'h0;
                         stateR  <= STR_END;
                     end else begin
                         if (countR==arlen_reg) RLAST  <= 1'b1;
                         countR <= countR + 1;
                     end
                 end
                 end // STR_WAIT
             STR_END: begin
                 if (ARVALID==1'b1) begin
                      ARREADY   <= 1'b1;
                      stateR    <= STR_RUN;
                 end else begin
                      stateR    <= STR_IDLE;
                 end
                 end // STR_END
             endcase
         end
     end
     //-----------------------------------------------------------
endmodule

module rr_fixed_arbiter #( 
    parameter NUM = 4  // 参数化位宽,默认为4 
)( 
    input                   clk         , 
    input                   rst_n       , 
    input                   arbiter_type, // 0: Round Robin, 1: Fixed Priority 
    input      [NUM-1:0]    req         , // 请求信号 
    output reg [NUM-1:0]    sel           // 选择信号 
); 
wire          rr_vld       ;      
reg [NUM-1:0] last_winner   ;      
reg [NUM-1:0] curr_winner   ;      
assign rr_vld = |req;   // 产生调度使能信号  
always @ (posedge clk) begin  
    if (!rst_n)  
        last_winner <= {NUM{1'b0}};  
    else if (rr_vld)   
        last_winner <= curr_winner;           // 记录上一次调度的队列  
end  
// 0: Round Robin  
always @ (*) begin  
    integer i; 
    curr_winner = {NUM{1'b0}}; // 默认当前胜者为0 
    if (last_winner == {NUM{1'b0}}) begin 
        for (i = 0; i < NUM; i = i + 1) begin 
            if (req[i]) begin 
                curr_winner = (1 << i); 
                break; 
            end 
        end 
    end else begin 
        for (i = 0; i < NUM; i = i + 1) begin 
            if (req[(i + 1) % NUM]) begin 
                curr_winner = (1 << ((i + 1) % NUM)); 
                break; 
            end 
        end 
    end 
end 
// 1: Fixed Priority 
function [NUM-1:0] priority_sel; 
     input    [NUM-1:0] request; 
     begin 
          integer i; 
          priority_sel = {NUM{1'b0}}; 
          for (i = NUM-1; i >= 0; i = i - 1) begin 
               if (request[i]) begin 
                    priority_sel = (1 << i); 
                    break; 
               end 
          end 
     end 
endfunction 
always @ (*) begin 
    sel = arbiter_type ? priority_sel(req) : curr_winner; 
end 
endmodule 

module sid_buffer #( 
    parameter NUM = 3 // 参数化写缓冲区接口个数 
)( 
    input            clk          , 
    input            rstn         , 
 
    // 写缓冲区接口 
    input [12-1:0]   s_axid      [NUM-1:0], // 输入AXI ID 
    input            s_axid_vld  [NUM-1:0], // 输入AXI ID有效信号 
    input            s_fifo_rdy  [NUM-1:0], // FIFO就绪信号 
    output           s_push_rdy  [NUM-1:0], // 允许写入信号 
 
    // 清理缓冲区和调整位置接口 
    input            last        [NUM-1:0], // 清理信号 
    input [12-1:0]   sid         [NUM-1:0], // 输入SID 
    input            sid_vld     [NUM-1:0], // 输入SID有效信号 
    output           sid_clr_rdy [NUM-1:0], // 允许清理信号 
 
    output reg [12-1:0] sid_buffer  [0:3]      // SID缓冲区 
); 
 
reg  [NUM-1:0] push_select; 
wire [NUM-1:0] push_grant; 
wire           full; 
 
wire [NUM-1:0] clr_select; 
wire [NUM-1:0] clr_grant; 
wire [3:0]     clr_idx; 
wire           clr_rdy; 
 
// 写缓冲区逻辑 
integer i; 
always @(*) begin 
    if (!rstn) begin 
        push_select = 'd0; 
    end else begin 
        for (i = 0; i < NUM; i = i + 1) begin 
            push_select[i] = s_axid_vld[i] & s_fifo_rdy[i]; 
        end 
    end 
end 
 
assign push_grant = priority_sel(push_select); 
 
assign clr_rdy = (~|clr_grant) && (~full); 
 
generate 
    for (i = 0; i < NUM; i = i + 1) begin : push_ready_gen 
        assign s_push_rdy[i] = ~(push_select[i] ^ push_grant[i]) && clr_rdy; 
    end 
endgenerate 
 
always @(posedge clk) begin 
    if (!rstn) begin 
        sid_buffer[0] <= 1'b0; 
        sid_buffer[1] <= 1'b0; 
        sid_buffer[2] <= 1'b0; 
        sid_buffer[3] <= 1'b0; 
    end else begin 
        for (i = 0; i < NUM; i = i + 1) begin 
            if (push_grant[i] && s_push_rdy[i]) begin 
                if (sid_buffer[0] == 1'b0) begin 
                    sid_buffer[0] <= s_axid[i]; 
                end else if (sid_buffer[1] == 1'b0) begin 
                    sid_buffer[1] <= s_axid[i]; 
                end else if (sid_buffer[2] == 1'b0) begin 
                    sid_buffer[2] <= s_axid[i]; 
                end else if (sid_buffer[3] == 1'b0) begin 
                    sid_buffer[3] <= s_axid[i]; 
                end 
            end 
        end 
    end 
end 
 
assign full = (sid_buffer[3] == 1'b0) ? 0 : 1; 
 
// 清理缓冲区和调整位置逻辑 
generate 
    for (i = 0; i < NUM; i = i + 1) begin : clr_select_gen 
        assign clr_select[i] = last[i] & sid_vld[i]; 
    end 
endgenerate 
 
assign clr_grant = priority_sel(clr_select); 
 
generate 
    for (i = 0; i < NUM; i = i + 1) begin : clr_ready_gen 
        assign sid_clr_rdy[i] = ~(clr_select[i] ^ clr_grant[i]); 
    end 
endgenerate 
 
generate 
    for (i = 0; i < 4; i = i + 1) begin : idx_loop 
        assign clr_idx[i] = (clr_grant[0] && (sid[0] == sid_buffer[i])) ? 1'b1 : 
                            (clr_grant[1] && (sid[1] == sid_buffer[i])) ? 1'b1 : 
                            (clr_grant[2] && (sid[2] == sid_buffer[i])) ? 1'b1 : 
                            (clr_grant[NUM-1] && (sid[NUM-1] == sid_buffer[i])) ? 1'b1 : 1'b0; 
    end 
endgenerate 
 
always @(posedge clk) begin 
    if (clr_idx[0]) begin 
        sid_buffer[0] <= sid_buffer[1]; 
        sid_buffer[1] <= sid_buffer[2]; 
        sid_buffer[2] <= sid_buffer[3]; 
        sid_buffer[3] <= 1'b0; 
    end else if (clr_idx[1]) begin 
        sid_buffer[1] <= sid_buffer[2]; 
        sid_buffer[2] <= sid_buffer[3]; 
        sid_buffer[3] <= 1'b0; 
    end else if (clr_idx[2]) begin 
        sid_buffer[2] <= sid_buffer[3]; 
        sid_buffer[3] <= 1'b0; 
    end else if (clr_idx[3]) begin 
        sid_buffer[3] <= 1'b0; 
    end 
end 
 
// 优先级选择函数 
function [NUM-1:0] priority_sel; 
    input [NUM-1:0] request; 
    integer j; 
    begin 
        priority_sel = 'd0; 
        for (j = NUM-1; j >= 0; j = j - 1) begin 
            if (request[j]) begin 
                priority_sel = (1 << j); 
                break; 
            end 
        end 
    end 
endfunction 
 
endmodule 

module reorder 
 (parameter NUM_SID = 3)
 (
    input            clk        ,
    input            rstn       ,
    
    input [12-1:0]   sid       [NUM_SID-1:0],
    input            sid_vld   [NUM_SID-1:0],
    
    input wire [12-1:0] rob_buffer [0:3] ,
    
    output reg [NUM_SID-1:0] order_grant   
);
 
genvar i, j;
wire [6-1:0] rid_low  [NUM_SID-1:0];
wire [6-1:0] rid_high [NUM_SID-1:0];

generate
    for (i = 0; i < NUM_SID; i++) begin : RID_GEN
        assign rid_low[i][0] = (sid_vld[i] && sid[i][3:0] == rob_buffer[0][3:0]) ? 1'b1 : 1'b0;
        assign rid_low[i][1] = (sid_vld[i] && sid[i][3:0] == rob_buffer[1][3:0]) ? 1'b1 : 1'b0;
        assign rid_low[i][2] = (sid_vld[i] && sid[i][3:0] == rob_buffer[2][3:0]) ? 1'b1 : 1'b0;
        assign rid_low[i][3] = (sid_vld[i] && sid[i][3:0] == rob_buffer[3][3:0]) ? 1'b1 : 1'b0;
        assign rid_low[i][4] = (sid_vld[i] && sid[i][3:0] == rob_buffer[4][3:0]) ? 1'b1 : 1'b0;
        assign rid_low[i][5] = (sid_vld[i] && sid[i][3:0] == rob_buffer[5][3:0]) ? 1'b1 : 1'b0;

        assign rid_high[i][0] = (sid_vld[i] && sid[i][7:4] == rob_buffer[0][7:4]) ? 1'b1 : 1'b0;
        assign rid_high[i][1] = (sid_vld[i] && sid[i][7:4] == rob_buffer[1][7:4]) ? 1'b1 : 1'b0;
        assign rid_high[i][2] = (sid_vld[i] && sid[i][7:4] == rob_buffer[2][7:4]) ? 1'b1 : 1'b0;
        assign rid_high[i][3] = (sid_vld[i] && sid[i][7:4] == rob_buffer[3][7:4]) ? 1'b1 : 1'b0;
        assign rid_high[i][4] = (sid_vld[i] && sid[i][7:4] == rob_buffer[4][7:4]) ? 1'b1 : 1'b0;
        assign rid_high[i][5] = (sid_vld[i] && sid[i][7:4] == rob_buffer[5][7:4]) ? 1'b1 : 1'b0;
    end
endgenerate

generate
    for (i = 0; i < NUM_SID; i++) begin : RID_GEN
        always @(posedge clk) begin
            if (!rstn) begin
                order_grant[i] <= 'd0;
            end else begin
                if (rid_high[i][0] && rid_low[i][0])
                    order_grant[i] <= 1'b1;
                else if (rid_high[i][1:0] == 2'b10 && rid_low[i][1:0] == 2'b10)
                    order_grant[i] <= 1'b1;
                else if (rid_high[i][2:0] == 3'b100 && rid_low[i][2:0] == 3'b100)
                    order_grant[i] <= 1'b1;
                else if (rid_high[i][3:0] == 4'b1000 && rid_low[i][3:0] == 4'b1000)
                    order_grant[i] <= 1'b1;
                else if (rid_high[i][4:0] == 5'b10000 && rid_low[i][4:0] == 5'b10000)
                    order_grant[i] <= 1'b1;
                else if (rid_high[i][5:0] == 6'b100000 && rid_low[i][5:0] == 6'b100000)
                    order_grant[i] <= 1'b1;
                else
                    order_grant[i] <= 1'b0;
            end
        end
    end
endgenerate

endmodule

module axi_fifo_sync
    #(parameter FDW =32, // fifof data width
                FAW =5   // num of entries in 2 to the power FAW
               )
(
    ,input   wire           rstn
    ,input   wire           clr 
    ,input   wire           clk
    ,output  wire           wr_rdy
    ,input   wire           wr_vld
    ,input   wire [FDW-1:0] wr_din
    ,input   wire           rd_rdy
    ,output  wire           rd_vld
    ,output  wire [FDW-1:0] rd_dout
);
    
   localparam FDT = 1 << FAW;
    
   wire           full     ;
   wire           empty    ;
   reg  [FAW:0]   item_cnt ;
   reg  [FAW:0]   fifo_head; // where data to be read
   reg  [FAW:0]   fifo_tail; // where data to be written
   reg  [FAW:0]   next_tail;
   reg  [FAW:0]   next_head;
    
   //---------------------------------------------------
   // synopsys translate_off
   initial fifo_head = 'h0;
   initial fifo_tail = 'h0;
   initial next_head = 'h0;
   initial next_tail = 'h0;
   // synopsys translate_on
   //---------------------------------------------------
    
   // push data item into the entry pointed by fifo_tail
   always @(posedge clk) begin
      if (!rstn) begin
          fifo_tail <= 0;
          next_tail <= 1;
      end else if (clr) begin
          fifo_tail <= 0;
          next_tail <= 1;
      end else begin
          if (!full && wr_vld) begin
              fifo_tail <= next_tail;
              next_tail <= next_tail + 1;
          end 
      end
   end
    
   // pop data item from the entry pointed by fifo_head
   always @(posedge clk) begin
      if (!rstn) begin
          fifo_head <= 0;
          next_head <= 1;
      end else if (clr) begin
          fifo_head <= 0;
          next_head <= 1;
      end else begin
          if (!empty && rd_rdy) begin
              fifo_head <= next_head;
              next_head <= next_head + 1;
          end
      end
   end
    
   always @(posedge clk) begin
      if (!rstn) begin
         item_cnt <= 0;
      end else if (clr) begin
         item_cnt <= 0;
      end else begin
         if (wr_vld && !full && (!rd_rdy || (rd_rdy && empty))) begin
             item_cnt <= item_cnt + 1;
         end else
         if (rd_rdy && !empty && (!wr_vld || (wr_vld && full))) begin
             item_cnt <= item_cnt - 1;
         end
      end
   end
    
   assign rd_vld = ~empty;
   assign wr_rdy = ~full;
   assign empty  = (fifo_head == fifo_tail);
   assign full   = (item_cnt >= FDT);
    
   reg [FDW-1:0] Mem [0:FDT-1];
    
   // synopsys translate_off
   integer i, j;
   initial begin
        for (i = 0; i < FDT; i++) begin
            for (j = 0; j < FDW; j++) begin
                Mem[i][j] = 'd0;
            end
            
        end
   end
   // synopsys translate_on
    
   assign rd_dout  = Mem[fifo_head[FAW-1:0]];
    
   always @(posedge clk) begin
       if (!full && wr_vld) begin
           Mem[fifo_tail[FAW-1:0]] <= wr_din;
       end
   end
    
endmodule

// INCR BURST ONLY
module cross_4k_if #(
      parameter W_ID   = 4           // ID width
              , W_CID  = 4
              , W_ADDR = 32          // address width
              , W_LEN  = 8
              , W_DATA = 32          // data width
              , W_STRB = (W_DATA/8)  // data strobe width
              , W_SID  = (W_CID+W_ID)// slave ID
) (
      input                          clk        
    , input                          rst_n      

    // input
    , input  wire    [W_ID-1 :0]     m_axi_arid    
    , input  wire    [W_ADDR-1:0]    m_axi_araddr  
    , input  wire    [W_LEN-1 :0]    m_axi_arlen   
    , input  wire    [2 :0]          m_axi_arsize  
    , input  wire    [1 :0]          m_axi_arburst 
    , input  wire                    m_axi_arvalid 
    , output reg                     m_axi_arready 

    , input  wire    [W_ID-1 :0]     m_axi_awid    
    , input  wire    [W_ADDR-1:0]    m_axi_awaddr  
    , input  wire    [W_LEN-1 :0]    m_axi_awlen   
    , input  wire    [2 :0]          m_axi_awsize  
    , input  wire    [1 :0]          m_axi_awburst 
    , input  wire                    m_axi_awvalid 
    , output reg                     m_axi_awready 

    // output
    , output  reg    [W_ID-1:0]      s_axi_arid    
    , output  reg    [W_ADDR-1:0]    s_axi_araddr  
    , output  reg    [W_LEN-1:0]     s_axi_arlen   
    , output  reg    [2:0]           s_axi_arsize  
    , output  reg    [1:0]           s_axi_arburst 
    , output  reg                    s_axi_arvalid 
    , input   wire                   s_axi_arready

    , output  reg    [W_ID-1:0]      s_axi_awid    
    , output  reg    [W_ADDR-1:0]    s_axi_awaddr  
    , output  reg    [W_LEN-1:0]     s_axi_awlen   
    , output  reg    [2:0]           s_axi_awsize  
    , output  reg    [1:0]           s_axi_awburst 
    , output  reg                    s_axi_awvalid 
    , input   wire                   s_axi_awready

);

wire [W_ADDR-1 : 0]    m_araddr_end  ;
wire [W_ADDR-1 : 0]    m_awaddr_end  ;

assign m_araddr_end = m_axi_araddr + (m_axi_arlen << 2); //m_axi_arlen*4, 4*8=32
assign m_awaddr_end = m_axi_awaddr + (m_axi_awlen << 2);

assign ar_cross4k_flag = m_axi_araddr[12] ^ m_araddr_end[12];
assign aw_cross4k_flag = m_axi_awaddr[12] ^ m_awaddr_end[12];

//signal for split to 2-transactions
reg [W_ID-1:0]      trans_arid    ; 
reg [2:0]           trans_arsize  ; 
reg [1:0]           trans_arburst ; 
reg [W_ADDR-1:0]    trans1_araddr ; 
reg [W_LEN-1:0]     trans1_arlen  ; 
reg [W_ADDR-1:0]    trans2_araddr ; 
reg [W_LEN-1:0]     trans2_arlen  ; 
reg                 trans_arvalid ; 

reg [W_ID-1:0]      trans_awid    ; 
reg [2:0]           trans_awsize  ; 
reg [1:0]           trans_awburst ; 
reg [W_ADDR-1:0]    trans1_awaddr ; 
reg [W_LEN-1:0]     trans1_awlen  ; 
reg [W_ADDR-1:0]    trans2_awaddr ; 
reg [W_LEN-1:0]     trans2_awlen  ; 
reg                 trans_awvalid ; 
reg                 aw_trans_stall;

always @(*) begin
    if (m_axi_arvalid & ar_cross4k_flag) begin
        trans_arid    = m_axi_arid   ;
        trans_arsize  = m_axi_arsize ;
        trans_arburst = m_axi_arburst;
        trans1_araddr = m_axi_araddr ;
        trans1_arlen  = ({m_axi_araddr[29:12], 12'hfff} - m_axi_araddr + 1'b1) >> 2;
        trans2_araddr = {m_axi_araddr[29:12] + 1'b1, 12'h0};
        trans2_arlen  = (m_araddr_end - {m_axi_araddr[29:12] + 1'b1, 12'h0} + 1'b1) >> 2;
        trans_arvalid = m_axi_arvalid;
    end
    if (m_axi_awvalid & aw_cross4k_flag) begin
        trans_awid    = m_axi_awid   ;
        trans_awsize  = m_axi_awsize ;
        trans_awburst = m_axi_awburst;
        trans1_awaddr = m_axi_awaddr ;
        trans1_awlen  = ({m_axi_awaddr[29:12], 12'hfff} - m_axi_awaddr + 1'b1) >> 2;
        trans2_awaddr = {m_axi_awaddr[29:12] + 1'b1, 12'h0};
        trans2_awlen  = (m_awaddr_end - {m_axi_awaddr[29:12] + 1'b1, 12'h0} + 1'b1) >> 2;
        trans_awvalid = m_axi_awvalid;
    end
end

reg [2:0] ST_AR_C4K, ST_AW_C4K;
parameter IDLE   = 3'h0,
          TRANS1 = 3'h1,
          TRANS2 = 3'h2;

//ARADDR
always @(posedge clk) begin
    if (!rst_n) begin
        ST_AR_C4K <= 0;
    end else begin
        case (ST_AR_C4K)
            IDLE: begin 
                if (ar_cross4k_flag) begin
                    ST_AR_C4K  <= TRANS1;
                end
            end
            TRANS1: begin
                if (s_axi_arready) begin
                    ST_AR_C4K  <= TRANS2;
                end
            end
            TRANS2: if (s_axi_arready) begin
                ST_AR_C4K  <= IDLE;
            end
        endcase
    end
end

always @(*) begin
    if (ST_AR_C4K==TRANS1) begin
        s_axi_arid    = trans_arid   ;
        s_axi_araddr  = trans1_araddr ;
        s_axi_arlen   = trans1_arlen  ;
        s_axi_arsize  = trans_arsize ;
        s_axi_arburst = trans_arburst;
        s_axi_arvalid = trans_arvalid;
        m_axi_arready = 0;
    end
    else if (ST_AR_C4K==TRANS2) begin
        s_axi_arid    = trans_arid   ;
        s_axi_araddr  = trans2_araddr ;
        s_axi_arlen   = trans2_arlen  ;
        s_axi_arsize  = trans_arsize ;
        s_axi_arburst = trans_arburst;
        s_axi_arvalid = trans_arvalid;
        m_axi_arready = 1;
    end
    else if(ST_AR_C4K==IDLE) begin
        if(!ar_cross4k_flag && s_axi_arready) begin
            s_axi_arid    = m_axi_arid   ;
            s_axi_araddr  = m_axi_araddr ;
            s_axi_arlen   = m_axi_arlen  ;
            s_axi_arsize  = m_axi_arsize ;
            s_axi_arburst = m_axi_arburst;
            s_axi_arvalid = m_axi_arvalid;
            m_axi_arready = 1;
        end
        else begin
            s_axi_arid    = 0;
            s_axi_araddr  = 0;
            s_axi_arlen   = 0;
            s_axi_arsize  = 0;
            s_axi_arburst = 0;
            s_axi_arvalid = 0;
            m_axi_arready = 0;
        end
    end
end

//AWADDR
always @(posedge clk) begin
    if (!rst_n) begin
        ST_AW_C4K <= 0;
    end else begin
        case (ST_AW_C4K)
            IDLE: begin 
                if (aw_cross4k_flag) begin
                    ST_AW_C4K  <= TRANS1;
                end
            end
            TRANS1: begin
                if (s_axi_awready) begin
                    ST_AW_C4K  <= TRANS2;
                end
            end
            TRANS2: if (s_axi_awready) begin
                ST_AW_C4K  <= IDLE;
            end
        endcase
    end
end

always @(*) begin
    if (ST_AW_C4K == TRANS1) begin
        s_axi_awid    = trans_awid   ;
        s_axi_awaddr  = trans1_awaddr ;
        s_axi_awlen   = trans1_awlen  ;
        s_axi_awsize  = trans_awsize ;
        s_axi_awburst = trans_awburst;
        s_axi_awvalid = trans_awvalid;
        m_axi_awready = 0;
    end
    else if (ST_AW_C4K == TRANS2) begin
        s_axi_awid    = {(trans_awid[3:2] + 2'b1), trans_awid[1:0]};
        s_axi_awaddr  = trans2_awaddr ;
        s_axi_awlen   = trans2_awlen  ;
        s_axi_awsize  = trans_awsize ;
        s_axi_awburst = trans_awburst;
        s_axi_awvalid = trans_awvalid;
        m_axi_awready = 1;
    end
    else if(ST_AW_C4K == IDLE) begin
        if(!aw_cross4k_flag && s_axi_awready) begin
            s_axi_awid    = m_axi_awid   ;
            s_axi_awaddr  = m_axi_awaddr ;
            s_axi_awlen   = m_axi_awlen  ;
            s_axi_awsize  = m_axi_awsize ;
            s_axi_awburst = m_axi_awburst;
            s_axi_awvalid = m_axi_awvalid;
            m_axi_awready = 1;
        end
        else begin
            s_axi_awid    = 0;
            s_axi_awaddr  = 0;
            s_axi_awlen   = 0;
            s_axi_awsize  = 0;
            s_axi_awburst = 0;
            s_axi_awvalid = 0;
            m_axi_awready = 0;
        end
    end
end

endmodule

