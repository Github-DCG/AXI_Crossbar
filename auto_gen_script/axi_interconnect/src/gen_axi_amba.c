
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "gen_axi_utils.h"
#include "gen_amba_axi.h"

int gen_axi_interconnect(unsigned int numM, unsigned int numS, char *prefix, FILE *fo);

int gen_axi_amba( unsigned int numM // num of masters
                , unsigned int numS // num of slaves
                , char *module
                , char *prefix
                , FILE *fo)
{
    int ret=0;

    ret += gen_axi_interconnect(numM, numS, prefix, fo);
    ret += gen_axi_crossbar(numM, numS, prefix, fo);
    ret += gen_axi_arbiter_m2s(numM, prefix, fo);
    ret += gen_axi_arbiter_s2m(numS, prefix, fo);
    ret += gen_axi_m2s(numM, prefix, fo);
    ret += gen_axi_s2m(numS, prefix, fo);
    ret += gen_axi_default_slave(prefix, fo);
    ret += gen_rr_fixed_arbiter(prefix, fo);
    ret += gen_sid_buffer(prefix, fo);
    ret += gen_reorder(prefix, fo);
    ret += gen_axi_fifo_sync(prefix, fo);
    ret += gen_cross_4k_if(prefix, fo);

    return ret;
}

int gen_axi_interconnect(unsigned int numM, 
                         unsigned int numS, 
                         char *prefix, 
                         FILE *fo)
{
    int i, j;
    unsigned int start=0x00001000;

    if ((numM<2)||(numS<2)||(prefix==NULL)) return 1;

// fprintf(fo, "`define APB_CFG\n");
fprintf(fo, "module axi_interconnect\n");
fprintf(fo, "      #(parameter W_CID  = 6           // Channel ID width, 3-bits for slv, 3-bits for mst\n");
fprintf(fo, "                , W_ID   = 6           // ID width in bits\n");
fprintf(fo, "                , W_ADDR = 32          // address width\n");
fprintf(fo, "                , W_LEN  = 8           // burst len\n");
fprintf(fo, "                , W_DATA = 32          // data width\n");
fprintf(fo, "                , W_STRB = (W_DATA/8)  // data strobe width\n");
fprintf(fo, "                , W_SID  = (W_CID+W_ID)// ID for slave\n");

for (i=0; i<numS; i++) {
fprintf(fo, "                , SLAVE_EN%d  = 1, ADDR_BASE%d = 32'h%08X, ADDR_LENGTH%d = 12 // effective addre bits\n", i, i, start, i);
start += 0x1000;
}
fprintf(fo, "                , NUM_M = %d\n", numM);
fprintf(fo, "                , NUM_S = %d\n", numS);
fprintf(fo, "       )\n");
fprintf(fo, "(\n");
fprintf(fo, "         input   wire                      AXI_RSTn\n");
fprintf(fo, "       , input   wire                      AXI_CLK\n\n");

fprintf(fo, "       //AXI from master\n");
fprintf(fo, "       , input   wire  [W_ID-1:0]          M_AXI_AWID     [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [W_ADDR-1:0]        M_AXI_AWADDR   [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [W_LEN-1:0]         M_AXI_AWLEN    [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [2:0]               M_AXI_AWSIZE   [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [1:0]               M_AXI_AWBURST  [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire                      M_AXI_AWVALID  [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire                      M_AXI_AWREADY  [0:NUM_M-1]\n\n");

fprintf(fo, "       , input   wire  [W_ID-1:0]          M_AXI_WID      [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [W_DATA-1:0]        M_AXI_WDATA    [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [W_STRB-1:0]        M_AXI_WSTRB    [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire                      M_AXI_WLAST    [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire                      M_AXI_WVALID   [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire                      M_AXI_WREADY   [0:NUM_M-1]\n\n");

fprintf(fo, "       , output  wire  [W_ID-1:0]          M_AXI_BID      [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire  [1:0]               M_AXI_BRESP    [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire                      M_AXI_BVALID   [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire                      M_AXI_BREADY   [0:NUM_M-1]\n\n");

fprintf(fo, "       , input   wire  [W_ID-1:0]          M_AXI_ARID     [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [W_ADDR-1:0]        M_AXI_ARADDR   [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [W_LEN-1:0]         M_AXI_ARLEN    [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [2:0]               M_AXI_ARSIZE   [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire  [1:0]               M_AXI_ARBURST  [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire                      M_AXI_ARVALID  [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire                      M_AXI_ARREADY  [0:NUM_M-1]\n\n");

fprintf(fo, "       , output  wire  [W_ID-1:0]          M_AXI_RID      [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire  [W_DATA-1:0]        M_AXI_RDATA    [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire  [W_STRB-1:0]        M_AXI_RRESP    [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire                      M_AXI_RLAST    [0:NUM_M-1]\n");
fprintf(fo, "       , output  wire                      M_AXI_RVALID   [0:NUM_M-1]\n");
fprintf(fo, "       , input   wire                      M_AXI_RREADY   [0:NUM_M-1]\n\n");

fprintf(fo, "       //AXI from slaver\n");
fprintf(fo, "       , output  wire   [W_SID-1:0]        S_AXI_AWID     [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [W_ADDR-1:0]       S_AXI_AWADDR   [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [W_LEN-1:0]        S_AXI_AWLEN    [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [2:0]              S_AXI_AWSIZE   [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [1:0]              S_AXI_AWBURST  [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire                      S_AXI_AWVALID  [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire                      S_AXI_AWREADY  [0:NUM_S-1]\n\n");

fprintf(fo, "       , output  wire   [W_SID-1:0]        S_AXI_WID      [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [W_DATA-1:0]       S_AXI_WDATA    [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [W_STRB-1:0]       S_AXI_WSTRB    [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire                      S_AXI_WLAST    [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire                      S_AXI_WVALID   [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire                      S_AXI_WREADY   [0:NUM_S-1]\n\n");

fprintf(fo, "       , input   wire   [W_SID-1:0]        S_AXI_BID      [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire   [1:0]              S_AXI_BRESP    [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire                      S_AXI_BVALID   [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire                      S_AXI_BREADY   [0:NUM_S-1]\n\n");
 
fprintf(fo, "       , output  wire   [W_SID-1:0]        S_AXI_ARID     [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [W_ADDR-1:0]       S_AXI_ARADDR   [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [W_LEN-1:0]        S_AXI_ARLEN    [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [2:0]              S_AXI_ARSIZE   [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire   [1:0]              S_AXI_ARBURST  [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire                      S_AXI_ARVALID  [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire                      S_AXI_ARREADY  [0:NUM_S-1]\n\n");

fprintf(fo, "       , input   wire   [W_SID-1:0]        S_AXI_RID      [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire   [W_DATA-1:0]       S_AXI_RDATA    [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire   [1:0]              S_AXI_RRESP    [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire                      S_AXI_RLAST    [0:NUM_S-1]\n");
fprintf(fo, "       , input   wire                      S_AXI_RVALID   [0:NUM_S-1]\n");
fprintf(fo, "       , output  wire                      S_AXI_RREADY   [0:NUM_S-1]\n\n");

// fprintf(fo, "       //APB config port\n");
// fprintf(fo, "       `ifdef APB_CFG\n");
// fprintf(fo, "       , input  wire                     pwrite\n");
// fprintf(fo, "       , input  wire                     psel\n");
// fprintf(fo, "       , input  wire                     penable \n");
// fprintf(fo, "       , input  wire    [W_ADDR-1:0]     paddr \n");
// fprintf(fo, "       , input  wire    [W_DATA-1:0]     pwdata \n");
// fprintf(fo, "       , output reg     [W_DATA-1:0]     prdata\n");
// fprintf(fo, "       `endif\n");
fprintf(fo, ");\n\n");

fprintf(fo, "wire [W_ID-1:0]       M_AWID    [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_ADDR-1:0]     M_AWADDR  [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_LEN-1:0]      M_AWLEN   [0:NUM_M-1] ;\n");
fprintf(fo, "wire [2:0]            M_AWSIZE  [0:NUM_M-1] ;\n");
fprintf(fo, "wire [1:0]            M_AWBURST [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_AWVALID [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_AWREADY [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_ID-1:0]       M_WID     [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_DATA-1:0]     M_WDATA   [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_STRB-1:0]     M_WSTRB   [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_WLAST   [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_WVALID  [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_WREADY  [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_ID-1:0]       M_BID     [0:NUM_M-1] ;\n");
fprintf(fo, "wire [1:0]            M_BRESP   [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_BVALID  [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_BREADY  [0:NUM_M-1] ;\n\n");

fprintf(fo, "wire [W_ID-1:0]       M_ARID    [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_ADDR-1:0]     M_ARADDR  [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_LEN-1:0]      M_ARLEN   [0:NUM_M-1] ;\n");
fprintf(fo, "wire [2:0]            M_ARSIZE  [0:NUM_M-1] ;\n");
fprintf(fo, "wire [1:0]            M_ARBURST [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_ARVALID [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_ARREADY [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_SID-1:0]      M_RSID    [0:NUM_M-1] ;\n");
fprintf(fo, "wire [W_DATA-1:0]     M_RDATA   [0:NUM_M-1] ;\n");
fprintf(fo, "wire [1:0]            M_RRESP   [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_RLAST   [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_RVALID  [0:NUM_M-1] ;\n");
fprintf(fo, "wire                  M_RREADY  [0:NUM_M-1] ;\n\n");

fprintf(fo, "wire [W_SID-1:0]      S_AWID    [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_ADDR-1:0]     S_AWADDR  [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_LEN-1:0]      S_AWLEN   [0:NUM_S-1] ;\n");
fprintf(fo, "wire [2:0]            S_AWSIZE  [0:NUM_S-1] ;\n");
fprintf(fo, "wire [1:0]            S_AWBURST [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_AWVALID [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_AWREADY [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_SID-1:0]      S_WID     [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_DATA-1:0]     S_WDATA   [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_STRB-1:0]     S_WSTRB   [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_WLAST   [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_WVALID  [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_WREADY  [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_SID-1:0]      S_BID     [0:NUM_S-1] ;\n");
fprintf(fo, "wire [1:0]            S_BRESP   [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_BVALID  [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_BREADY  [0:NUM_S-1] ;\n\n");

fprintf(fo, "wire [W_SID-1:0]      S_ARID    [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_ADDR-1:0]     S_ARADDR  [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_LEN-1:0]      S_ARLEN   [0:NUM_S-1] ;\n");
fprintf(fo, "wire [2:0]            S_ARSIZE  [0:NUM_S-1] ;\n");
fprintf(fo, "wire [1:0]            S_ARBURST [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_ARVALID [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_ARREADY [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_SID-1:0]      S_RID     [0:NUM_S-1] ;\n");
fprintf(fo, "wire [W_DATA-1:0]     S_RDATA   [0:NUM_S-1] ;\n");
fprintf(fo, "wire [1:0]            S_RRESP   [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_RLAST   [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_RVALID  [0:NUM_S-1] ;\n");
fprintf(fo, "wire                  S_RREADY  [0:NUM_S-1] ;\n\n");

//for cross 4k process
fprintf(fo, "wire      [W_ID-1:0]       c4k_arid    [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [W_ADDR-1:0]     c4k_araddr  [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [W_LEN-1:0]      c4k_arlen   [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [2:0]            c4k_arsize  [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [1:0]            c4k_arburst [0:NUM_M-1] ;\n");
fprintf(fo, "wire                       c4k_arvalid [0:NUM_M-1] ;\n");
fprintf(fo, "wire                       c4k_arready [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [W_ID-1:0]       c4k_awid    [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [W_ADDR-1:0]     c4k_awaddr  [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [W_LEN-1:0]      c4k_awlen   [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [2:0]            c4k_awsize  [0:NUM_M-1] ;\n");
fprintf(fo, "wire      [1:0]            c4k_awburst [0:NUM_M-1] ;\n");
fprintf(fo, "wire                       c4k_awvalid [0:NUM_M-1] ;\n");
fprintf(fo, "wire                       c4k_awready [0:NUM_M-1] ;\n\n");

//-------for r reorder-------
fprintf(fo, "wire [NUM_S-1:0] s_push_srid_rdy    ;\n");
fprintf(fo, "wire [W_SID-1:0] ar_sid_buffer [0:3];\n");
fprintf(fo, "wire [NUM_S-1:0] r_order_grant      ;\n");
fprintf(fo, "\n");

fprintf(fo, "wire [NUM_M-1:0] m_rsid_clr_rdy     ;\n");

fprintf(fo, "wire [NUM_S-1:0] S_ARREADY_in       ; \n");
fprintf(fo, "wire [NUM_M-1:0] M_RREADY_in        ; \n");
fprintf(fo, "                                      \n");
fprintf(fo, "wire [NUM_S-1:0] fifo_ar_sx_vld     ; \n");
fprintf(fo, "wire [NUM_M-1:0] fifo_r_mx_vld      ; \n");

//-------for w reorder-------
fprintf(fo, "wire [NUM_S-1:0] s_push_swid_rdy    ;\n");
fprintf(fo, "wire [W_SID-1:0] aw_sid_buffer [0:3];\n");
fprintf(fo, "wire [NUM_M-1:0] w_order_grant      ;\n");
fprintf(fo, "\n");

fprintf(fo, "wire [NUM_S-1:0] s_wsid_clr_rdy     ;\n");

fprintf(fo, "wire [NUM_S-1:0] S_AWREADY_in       ;\n");
fprintf(fo, "wire [NUM_S-1:0] S_WREADY_in        ;\n");
fprintf(fo, "                                     \n");
fprintf(fo, "wire [NUM_S-1:0] fifo_aw_sx_vld     ;\n");
fprintf(fo, "wire [NUM_S-1:0] fifo_w_sx_vld      ;\n\n");

fprintf(fo, "//-------for r reorder-------                                        \n");                                           
fprintf(fo, "genvar i;                                                            \n");                       
fprintf(fo, "generate;                                                            \n");                       
fprintf(fo, "    for (i = 0; i < NUM_S; i = i + 1) begin                          \n");                                                       
fprintf(fo, "        assign S_ARREADY_in  [i] = S_ARREADY[i] & s_push_srid_rdy[i];\n");                                                                                   
fprintf(fo, "        assign fifo_ar_sx_vld[i] = S_ARVALID[i] & s_push_srid_rdy[i];\n");                                                                                   
fprintf(fo, "end                                                                  \n");               
fprintf(fo, "endgenerate                                                          \n");                       
fprintf(fo, "                                                                     \n");               
fprintf(fo, "generate;                                                            \n");                       
fprintf(fo, "    for (i = 0; i < NUM_M; i = i + 1) begin                          \n");                                                       
fprintf(fo, "        assign M_RREADY_in  [i] = M_RREADY[i] & m_rsid_clr_rdy[i];   \n");                                                                               
fprintf(fo, "        assign fifo_r_mx_vld[i] = M_RVALID[i] & m_rsid_clr_rdy[i];   \n");                                                                               
fprintf(fo, "end                                                                  \n");               
fprintf(fo, "endgenerate                                                          \n");                       
fprintf(fo, "                                                                     \n");               
fprintf(fo, "                                                                     \n");               
fprintf(fo, "//-------for w reorder-------                                        \n");                                           
fprintf(fo, "generate;                                                            \n");                       
fprintf(fo, "    for (i = 0; i < NUM_S; i = i + 1) begin                          \n");                                                       
fprintf(fo, "        assign S_AWREADY_in  [i] = S_AWREADY[i] & s_push_swid_rdy[i];\n");                                                                                   
fprintf(fo, "        assign fifo_aw_sx_vld[i] = S_AWVALID[i] & s_push_swid_rdy[i];\n");                                                                                   
fprintf(fo, "        assign S_WREADY_in   [i] = S_WREADY[i] & s_wsid_clr_rdy      \n");                                                                           
fprintf(fo, "        assign fifo_w_sx_vld [i] = S_WVALID[i] & s_wsid_clr_rdy;     \n");                                                                               
fprintf(fo, "end                                                                  \n");               
fprintf(fo, "endgenerate                                                          \n\n");                       


fprintf(fo, "//--------------------CROSS 4K PROCESS---------------     \n");
fprintf(fo, "genvar i;                                                 \n");
fprintf(fo, "generate                                                  \n");
fprintf(fo, "    for (i = 0; i < NUM_M; i++) begin:mx_cross_4k_if          \n");
fprintf(fo, "        cross_4k_if #()                                   \n");
fprintf(fo, "        mx_cross_4k_if(                                   \n");
fprintf(fo, "            .clk                       (AXI_CLK         ),\n");
fprintf(fo, "            .rst_n                     (AXI_RSTn        ),\n");
fprintf(fo, "            // input                                      \n"); 
fprintf(fo, "            .m_axi_arid                (M_AXI_ARID   [i]),\n");
fprintf(fo, "            .m_axi_araddr              (M_AXI_ARADDR [i]),\n");
fprintf(fo, "            .m_axi_arlen               (M_AXI_ARLEN  [i]),\n");
fprintf(fo, "            .m_axi_arsize              (M_AXI_ARSIZE [i]),\n");
fprintf(fo, "            .m_axi_arburst             (M_AXI_ARBURST[i]),\n");
fprintf(fo, "            .m_axi_arvalid             (M_AXI_ARVALID[i]),\n");
fprintf(fo, "            .m_axi_arready             (M_AXI_ARREADY[i]),\n");

fprintf(fo, "\n");
fprintf(fo, "            .m_axi_awid                (M_AXI_AWID   [i]),\n");
fprintf(fo, "            .m_axi_awaddr              (M_AXI_AWADDR [i]),\n");
fprintf(fo, "            .m_axi_awlen               (M_AXI_AWLEN  [i]),\n");
fprintf(fo, "            .m_axi_awsize              (M_AXI_AWSIZE [i]),\n");
fprintf(fo, "            .m_axi_awburst             (M_AXI_AWBURST[i]),\n");
fprintf(fo, "            .m_axi_awvalid             (M_AXI_AWVALID[i]),\n");
fprintf(fo, "            .m_axi_awready             (M_AXI_AWREADY[i]),\n");
fprintf(fo, "            // output                                     \n"); 
fprintf(fo, "            .s_axi_arid                (c4k_arid   [i]  ),\n");
fprintf(fo, "            .s_axi_araddr              (c4k_araddr [i]  ),\n");
fprintf(fo, "            .s_axi_arlen               (c4k_arlen  [i]  ),\n");
fprintf(fo, "            .s_axi_arsize              (c4k_arsize [i]  ),\n");
fprintf(fo, "            .s_axi_arburst             (c4k_arburst[i]  ),\n");
fprintf(fo, "            .s_axi_arvalid             (c4k_arvalid[i]  ),\n");
fprintf(fo, "            .s_axi_arready             (c4k_arready[i]  ),\n");

fprintf(fo, "\n");
fprintf(fo, "            .s_axi_awid                (c4k_awid   [i]  ),\n");
fprintf(fo, "            .s_axi_awaddr              (c4k_awaddr [i]  ),\n");
fprintf(fo, "            .s_axi_awlen               (c4k_awlen  [i]  ),\n");
fprintf(fo, "            .s_axi_awsize              (c4k_awsize [i]  ),\n");
fprintf(fo, "            .s_axi_awburst             (c4k_awburst[i]  ),\n");
fprintf(fo, "            .s_axi_awvalid             (c4k_awvalid[i]  ),\n");
fprintf(fo, "            .s_axi_awready             (c4k_awready[i]  ) \n");
fprintf(fo, "        );                                                \n");
fprintf(fo, "    end                                                   \n");
fprintf(fo, "endgenerate                                               \n\n");


fprintf(fo, "//---------------------AR_* fifo----------------------                                             \n");
fprintf(fo, "//axi_interconnect slave interface, signals from mst                                               \n");
fprintf(fo, "generate                                                                                           \n");
fprintf(fo, "    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_ar_mx                                             \n");
fprintf(fo, "        axi_fifo_sync #(.FDW(W_ID+W_ADDR+W_LEN+3+2), .FAW(2)) //fifo depth == 4                    \n");
fprintf(fo, "        u_fifo_ar_mx(                                                                              \n");
fprintf(fo, "              .rstn     (AXI_RSTn      )                                                           \n");
fprintf(fo, "            , .clr      (1'b0          )                                                           \n");
fprintf(fo, "            , .clk      (AXI_CLK       )                                                           \n");
fprintf(fo, "            , .wr_rdy   (c4k_arready[i])                                                           \n");
fprintf(fo, "            , .wr_vld   (c4k_arvalid[i])                                                           \n");
fprintf(fo, "            , .wr_din   ({c4k_arid[i], c4k_araddr[i], c4k_arlen[i], c4k_arsize[i], c4k_arburst[i]})\n");
fprintf(fo, "            , .rd_rdy   (M_ARREADY[i])                                                             \n");
fprintf(fo, "            , .rd_vld   (M_ARVALID[i])                                                             \n");
fprintf(fo, "            , .rd_dout  ({M_ARID[i], M_ARADDR[i], M_ARLEN[i], M_ARSIZE[i], M_ARBURST[i]})          \n");
fprintf(fo, "        );                                                                                         \n");
fprintf(fo, "    end                                                                                            \n");
fprintf(fo, "endgenerate                                                                                        \n");
fprintf(fo, "//axi_interconnect master interface, signals to slv                                                \n");
fprintf(fo, "generate                                                                                           \n");
fprintf(fo, "    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_ar_sx                                             \n");
fprintf(fo, "        axi_fifo_sync #(.FDW(W_SID+W_ADDR+W_LEN+3+2), .FAW(2))                                     \n");
fprintf(fo, "        u_fifo_ar_sx(                                                                              \n");
fprintf(fo, "              .rstn     (AXI_RSTn    )                                                             \n");
fprintf(fo, "            , .clr      (1'b0        )                                                             \n");
fprintf(fo, "            , .clk      (AXI_CLK     )                                                             \n");
fprintf(fo, "            , .wr_rdy   (S_ARREADY[i])                                                             \n");
fprintf(fo, "            , .wr_vld   (fifo_ar_sx_vld[i])                                                        \n");
fprintf(fo, "            , .wr_din   ({S_ARID[i], S_ARADDR[i], S_ARLEN[i], S_ARSIZE[i], S_ARBURST[i]})          \n");
fprintf(fo, "            , .rd_rdy   (S_AXI_ARREADY[i])                                                         \n");
fprintf(fo, "            , .rd_vld   (S_AXI_ARVALID[i])                                                         \n");
fprintf(fo, "            , .rd_dout  ({S_AXI_ARID[i], S_AXI_ARADDR[i], S_AXI_ARLEN[i], S_AXI_ARSIZE[i], S_AXI_ARBURST[i]})\n");
fprintf(fo, "        );                                                                                         \n");
fprintf(fo, "    end                                                                                            \n");
fprintf(fo, "endgenerate                                                                                        \n\n");

fprintf(fo, "//---------------------R_* fifo----------------------                                   \n");
fprintf(fo, "//axi_interconnect slave interface, signals from slv                                    \n");
fprintf(fo, "generate                                                                                \n");  
fprintf(fo, "    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_r_sx                                   \n");
fprintf(fo, "        axi_fifo_sync #(.FDW(W_SID+W_DATA+2+1), .FAW(2))                                \n");
fprintf(fo, "        u_fifo_r_sx(                                                                    \n");
fprintf(fo, "              .rstn     (AXI_RSTn  )                                                    \n");
fprintf(fo, "            , .clr      (1'b0      )                                                    \n");
fprintf(fo, "            , .clk      (AXI_CLK   )                                                    \n");
fprintf(fo, "            , .wr_rdy   (S_AXI_RREADY[i])                                               \n");
fprintf(fo, "            , .wr_vld   (S_AXI_RVALID[i])                                               \n");
fprintf(fo, "            , .wr_din   ({S_AXI_RID[i], S_AXI_RDATA[i], S_AXI_RRESP[i], S_AXI_RLAST[i]})\n");
fprintf(fo, "            , .rd_rdy   (S_RREADY[i])                                                   \n");
fprintf(fo, "            , .rd_vld   (S_RVALID[i])                                                   \n");
fprintf(fo, "            , .rd_dout  ({S_RID[i], S_RDATA[i], S_RRESP[i], S_RLAST[i]})                \n");
fprintf(fo, "        );                                                                              \n");
fprintf(fo, "    end                                                                                 \n");
fprintf(fo, "endgenerate                                                                             \n");
fprintf(fo, "//axi_interconnect master interface, signals to mst                                     \n");
fprintf(fo, "generate                                                                                \n");
fprintf(fo, "    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_r_mx                                   \n");
fprintf(fo, "        axi_fifo_sync #(.FDW(W_ID+W_DATA+2+1), .FAW(2))                                     \n");
fprintf(fo, "        u_fifo_r_mx(                                                                    \n");
fprintf(fo, "            .rstn     (AXI_RSTn   )                                                     \n");
fprintf(fo, "          , .clr      (1'b0       )                                                     \n");
fprintf(fo, "          , .clk      (AXI_CLK    )                                                     \n");
fprintf(fo, "          , .wr_rdy   (M_RREADY[i])                                                     \n");
fprintf(fo, "          , .wr_vld   (fifo_r_mx_vld[i])                                                \n");
fprintf(fo, "          , .wr_din   ({M_RSID[i][W_ID-1:0], M_RDATA[i], M_RRESP[i], M_RLAST[i]})       \n");
fprintf(fo, "          , .rd_rdy   (M_AXI_RREADY[i])                                                 \n");
fprintf(fo, "          , .rd_vld   (M_AXI_RVALID[i])                                                 \n");
fprintf(fo, "          , .rd_dout  ({M_AXI_RID[i], M_AXI_RDATA[i], M_AXI_RRESP[i], M_AXI_RLAST[i]})  \n");
fprintf(fo, "      );                                                                                \n");  
fprintf(fo, "    end                                                                                 \n"); 
fprintf(fo, "endgenerate                                                                             \n\n");

fprintf(fo, "//---------------------AW_* fifo----------------------                                                       \n"); 
fprintf(fo, "//axi slave interface, signals from master                                                                   \n");  
fprintf(fo, "generate                                                                                                     \n"); 
fprintf(fo, "    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_aw_mx                                                       \n"); 
fprintf(fo, "        axi_fifo_sync #(.FDW(W_ID+W_ADDR+W_LEN+3+2), .FAW(2))                                                \n"); 
fprintf(fo, "        u_fifo_aw_mx(                                                                                        \n"); 
fprintf(fo, "              .rstn     (AXI_RSTn      )                                                                     \n"); 
fprintf(fo, "            , .clr      (1'b0          )                                                                     \n"); 
fprintf(fo, "            , .clk      (AXI_CLK       )                                                                     \n"); 
fprintf(fo, "            , .wr_rdy   (c4k_awready[i])                                                                     \n"); 
fprintf(fo, "            , .wr_vld   (c4k_awvalid[i])                                                                     \n"); 
fprintf(fo, "            , .wr_din   ({c4k_awid[i], c4k_awaddr[i], c4k_awlen[i], c4k_awsize[i], c4k_awburst[i]})          \n"); 
fprintf(fo, "                                                                                                             \n"); 
fprintf(fo, "            , .rd_rdy   (M_AWREADY[i])                                                                       \n"); 
fprintf(fo, "            , .rd_vld   (M_AWVALID[i])                                                                       \n"); 
fprintf(fo, "            , .rd_dout  ({M_AWID[i], M_AWADDR[i], M_AWLEN[i], M_AWSIZE[i], M_AWBURST[i]})                    \n"); 
fprintf(fo, "        );                                                                                                   \n"); 
fprintf(fo, "    end                                                                                                      \n");                                                                               
fprintf(fo, "endgenerate                                                                                                  \n");                                                                               
fprintf(fo, "//axi master interface, signals to slaver                                                                    \n");                                                                       
fprintf(fo, "generate                                                                                                     \n");                                                                               
fprintf(fo, "    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_aw_sx                                                       \n");                                                                                                       
fprintf(fo, "        axi_fifo_sync #(.FDW(W_SID+W_ADDR+W_LEN+3+2), .FAW(2))                                               \n");                                                                                               
fprintf(fo, "        u_fifo_aw_sx(                                                                                        \n");                                                                                                   
fprintf(fo, "              .rstn     (AXI_RSTn)                                                                           \n");           
fprintf(fo, "            , .clr      (1'b0   )                                                                            \n");           
fprintf(fo, "            , .clk      (AXI_CLK   )                                                                         \n");           
fprintf(fo, "            , .wr_rdy   (S_AWREADY[i])                                                                       \n");               
fprintf(fo, "            , .wr_vld   (fifo_aw_sx_vld[i])                                                                  \n");                   
fprintf(fo, "            , .wr_din   ({S_AWID[i], S_AWADDR[i], S_AWLEN[i], S_AWSIZE[i], S_AWBURST[i]})                    \n");                                                                   
fprintf(fo, "            , .rd_rdy   (S_AXI_AWREADY[i])                                                                   \n");                                   
fprintf(fo, "            , .rd_vld   (S_AXI_AWVALID[i])                                                                   \n");                                   
fprintf(fo, "            , .rd_dout  ({S_AXI_AWID[i], S_AXI_AWADDR[i], S_AXI_AWLEN[i], S_AXI_AWSIZE[i], S_AXI_AWBURST[i]})\n"); 
fprintf(fo, "        );                                                                                                   \n");                                   
fprintf(fo, "    end                                                                                                      \n");                                   
fprintf(fo, "endgenerate                                                                                                  \n\n");                                       

fprintf(fo, "//---------------------W_* fifo----------------------                                   \n");                                                    
fprintf(fo, "generate                                                                                \n");        
fprintf(fo, "    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_w_mx                                   \n");                                                    
fprintf(fo, "        axi_fifo_sync #(.FDW(W_ID+W_DATA+4+1), .FAW(2))                                 \n");                                                    
fprintf(fo, "        u_fifo_w_mx(                                                                    \n");                    
fprintf(fo, "              .rstn     (AXI_RSTn)                                                      \n");                                
fprintf(fo, "            , .clr      (1'b0   )                                                       \n");                                
fprintf(fo, "            , .clk      (AXI_CLK   )                                                    \n");                                    
fprintf(fo, "            , .wr_rdy   (M_AXI_WREADY[i])                                               \n");                                        
fprintf(fo, "            , .wr_vld   (M_AXI_WVALID[i])                                               \n");                                        
fprintf(fo, "            , .wr_din   ({M_AXI_WID[i], M_AXI_WDATA[i], M_AXI_WSTRB[i], M_AXI_WLAST[i]})\n");                                                                                       
fprintf(fo, "            , .rd_rdy   (M_WREADY[i])                                                   \n");                                    
fprintf(fo, "            , .rd_vld   (M_WVALID[i])                                                   \n");                                    
fprintf(fo, "            , .rd_dout  ({M_WID[i], M_WDATA[i], M_WSTRB[i], M_WLAST[i]})                \n");                                                                        
fprintf(fo, "        );                                                                              \n");        
fprintf(fo, "    end                                                                                 \n");    
fprintf(fo, "endgenerate                                                                             \n");        
fprintf(fo, "generate                                                                                \n");        
fprintf(fo, "    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_w_sx                                   \n");                                                    
fprintf(fo, "        axi_fifo_sync #(.FDW(W_SID+W_DATA+4+1), .FAW(2))                                \n");                                                        
fprintf(fo, "        u_fifo_w_sx(                                                                    \n");                    
fprintf(fo, "              .rstn     (AXI_RSTn)                                                      \n");                                
fprintf(fo, "            , .clr      (1'b0   )                                                       \n");                                
fprintf(fo, "            , .clk      (AXI_CLK   )                                                    \n");                                    
fprintf(fo, "            , .wr_rdy   (S_WREADY[i])                                                   \n");                                    
fprintf(fo, "            , .wr_vld   (fifo_w_sx_vld[i])                                              \n");                                        
fprintf(fo, "            , .wr_din   ({S_WID[i], S_WDATA[i], S_WSTRB[i], S_WLAST[i]})                \n");                                                                        
fprintf(fo, "            , .rd_rdy   (S_AXI_WREADY[i])                                               \n");                                        
fprintf(fo, "            , .rd_vld   (S_AXI_WVALID[i])                                               \n");                                        
fprintf(fo, "            , .rd_dout  ({S_AXI_WID[i], S_AXI_WDATA[i], S_AXI_WSTRB[i], S_AXI_WLAST[i]})\n");                                                                                        
fprintf(fo, "        );                                                                              \n");        
fprintf(fo, "    end                                                                                 \n");    
fprintf(fo, "endgenerate                                                                             \n\n");        

fprintf(fo, "//---------------------B_* fifo----------------------   \n");                                                    
fprintf(fo, "generate                                                \n");        
fprintf(fo, "    for (i = 0; i < NUM_S; i = i + 1) begin:fifo_b_sx   \n");                                                    
fprintf(fo, "        axi_fifo_sync #(.FDW(W_SID+2), .FAW(2))         \n");                                            
fprintf(fo, "        u_fifo_b_sx(                                    \n");                    
fprintf(fo, "              .rstn     (AXI_RSTn)                      \n");                                
fprintf(fo, "            , .clr      (1'b0   )                       \n");                                
fprintf(fo, "            , .clk      (AXI_CLK   )                    \n");                                    
fprintf(fo, "            , .wr_rdy   (S_AXI_BREADY[i])               \n");                                        
fprintf(fo, "            , .wr_vld   (S_AXI_BVALID[i])               \n");                                        
fprintf(fo, "            , .wr_din   ({S_AXI_BID[i], S_AXI_BRESP[i]})\n");                                                       
fprintf(fo, "            , .rd_rdy   (S_BREADY[i])                   \n");                                    
fprintf(fo, "            , .rd_vld   (S_BVALID[i])                   \n");                                    
fprintf(fo, "            , .rd_dout  ({S_BID[i], S_BRESP[i]})        \n");                                                
fprintf(fo, "        );                                              \n");        
fprintf(fo, "    end                                                 \n");    
fprintf(fo, "endgenerate                                             \n");        
fprintf(fo, "generate                                                \n");        
fprintf(fo, "    for (i = 0; i < NUM_M; i = i + 1) begin:fifo_b_mx   \n");                                                    
fprintf(fo, "        axi_fifo_sync #(.FDW(W_ID+2), .FAW(2))          \n");                                            
fprintf(fo, "        u_fifo_b_mx(                                    \n");                    
fprintf(fo, "              .rstn     (AXI_RSTn)                      \n");                                
fprintf(fo, "            , .clr      (1'b0   )                       \n");                                
fprintf(fo, "            , .clk      (AXI_CLK   )                    \n");                                    
fprintf(fo, "            , .wr_rdy   (M_BREADY[i])                   \n");                                    
fprintf(fo, "            , .wr_vld   (M_BVALID[i])                   \n");                                    
fprintf(fo, "            , .wr_din   ({M_BID[i], M_BRESP[i]})        \n");                                                
fprintf(fo, "            , .rd_rdy   (M_AXI_BREADY[i])               \n");                                        
fprintf(fo, "            , .rd_vld   (M_AXI_BVALID[i])               \n");                                        
fprintf(fo, "            , .rd_dout  ({M_AXI_BID[i], M_AXI_BRESP[i]})\n");                                                        
fprintf(fo, "        );                                              \n");        
fprintf(fo, "    end                                                 \n");    
fprintf(fo, "endgenerate                                             \n\n");        

//CROSSBAR
fprintf(fo, "axi_crossbar #(\n");
fprintf(fo, ")\n");
fprintf(fo, "    u_axi_crossbar(                                                     \n");
fprintf(fo, "      .AXI_RSTn                           (AXI_RSTn                    )\n");
fprintf(fo, "    , .AXI_CLK                            (AXI_CLK                     )\n\n");

for (i=0; i<numM; i++) {
fprintf(fo, "    , .M%d_MID                             (3'b001 + %d                  )\n", i, i);
fprintf(fo, "    , .M%d_AWID                            (M_AWID    [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_AWADDR                          (M_AWADDR  [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_AWLEN                           (M_AWLEN   [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_AWSIZE                          (M_AWSIZE  [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_AWBURST                         (M_AWBURST [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_AWVALID                         (M_AWVALID [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_AWREADY                         (M_AWREADY [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_WID                             (M_WID     [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_WDATA                           (M_WDATA   [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_WSTRB                           (M_WSTRB   [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_WLAST                           (M_WLAST   [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_WVALID                          (M_WVALID  [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_WREADY                          (M_WREADY  [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_BID                             (M_BID     [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_BRESP                           (M_BRESP   [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_BVALID                          (M_BVALID  [%d]               )\n", i, i);
fprintf(fo, "    , .M%d_BREADY                          (M_BREADY  [%d]               )\n", i, i);

fprintf(fo, "\n");
fprintf(fo, "    , .M%d_ARID                            (M_ARID     [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_ARADDR                          (M_ARADDR   [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_ARLEN                           (M_ARLEN    [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_ARSIZE                          (M_ARSIZE   [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_ARBURST                         (M_ARBURST  [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_ARVALID                         (M_ARVALID  [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_ARREADY                         (M_ARREADY  [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_RSID                            (M_RSID     [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_RDATA                           (M_RDATA    [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_RRESP                           (M_RRESP    [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_RLAST                           (M_RLAST    [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_RVALID                          (M_RVALID   [%d]              )\n", i, i);
fprintf(fo, "    , .M%d_RREADY                          (M_RREADY_in[%d]              )\n\n", i, i);
}

for (i=0; i<numS; i++) {
fprintf(fo, "    , .S%d_AWID                            (S_AWID      [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_AWADDR                          (S_AWADDR    [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_AWLEN                           (S_AWLEN     [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_AWSIZE                          (S_AWSIZE    [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_AWBURST                         (S_AWBURST   [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_AWVALID                         (S_AWVALID   [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_AWREADY                         (S_AWREADY_in[%d]             )\n", i, i);
fprintf(fo, "    , .S%d_WID                             (S_WID       [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_WDATA                           (S_WDATA     [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_WSTRB                           (S_WSTRB     [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_WLAST                           (S_WLAST     [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_WVALID                          (S_WVALID    [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_WREADY                          (S_WREADY_in [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_BID                             (S_BID       [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_BRESP                           (S_BRESP     [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_BVALID                          (S_BVALID    [%d]             )\n", i, i);
fprintf(fo, "    , .S%d_BREADY                          (S_BREADY    [%d]             )\n", i, i);

fprintf(fo, "\n");
fprintf(fo, "    , .S%d_ARID                            (S_ARID      [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_ARADDR                          (S_ARADDR    [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_ARLEN                           (S_ARLEN     [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_ARSIZE                          (S_ARSIZE    [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_ARBURST                         (S_ARBURST   [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_ARVALID                         (S_ARVALID   [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_ARREADY                         (S_ARREADY_in[%d]               )\n", i, i);
fprintf(fo, "    , .S%d_RID                             (S_RID       [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_RDATA                           (S_RDATA     [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_RRESP                           (S_RRESP     [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_RLAST                           (S_RLAST     [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_RVALID                          (S_RVALID    [%d]               )\n", i, i);
fprintf(fo, "    , .S%d_RREADY                          (S_RREADY    [%d]               )\n\n", i, i);
}

fprintf(fo, ", .r_order_grant                      (r_order_grant               ) //input   wire  [11:0]  [0:3]\n");    
fprintf(fo, ", .w_order_grant                      (w_order_grant               )\n");

fprintf(fo, "\n");
// fprintf(fo, "`ifdef APB_CFG\n");
// fprintf(fo, "//APB Config\n");
// fprintf(fo, ", .arbiter_type                       (arbiter_type                )\n");
// fprintf(fo, ", .aw_decode_err                      (aw_decode_err               )\n");
// fprintf(fo, ", .ar_decode_err                      (ar_decode_err               )\n");
// // fprintf(fo, ", .slaver0_en                         (slaver0_en                  )\n");
// // fprintf(fo, ", .slaver1_en                         (slaver1_en                  )\n");
// // fprintf(fo, ", .slaver2_en                         (slaver2_en                  )\n");
// fprintf(fo, "`endif\n");

fprintf(fo, "    );\n\n");




//u_ar_sid_buffer
fprintf(fo, "//{{ ******* READ TRANSACTION REORDER *********\n");
fprintf(fo, "sid_buffer #(.NUM(NUM_M)) u_ar_sid_buffer(\n");
fprintf(fo, ".clk             (AXI_CLK           ),     //input\n");
fprintf(fo, ".rstn            (AXI_RSTn          ),     //input\n");
fprintf(fo, "\n");

fprintf(fo, "// --------------Write buffer------------\n");
fprintf(fo, ".s_axid         (S_ARID         ),     //input [12-1:0]\n");      
fprintf(fo, ".s_axid_vld     (S_ARVALID      ),     //input      \n");      
fprintf(fo, ".s_fifo_rdy     (S_ARREADY      ),     //input      \n");      
fprintf(fo, ".s_push_rdy     (s_push_srid_rdy),     //output     \n");      
fprintf(fo, "\n");

fprintf(fo, "//------Clean buffer and ajust position--------\n");
fprintf(fo, ".last          (M_RLAST        ),     //input          \n");  
fprintf(fo, ".sid           (M_RSID         ),     //input [11:0]    \n");  
fprintf(fo, ".sid_vld       (M_RVALID       ),     //input          \n");  
fprintf(fo, ".sid_clr_rdy   (m_rsid_clr_rdy ),     //output       \n");    
fprintf(fo, ".sid_buffer      (ar_sid_buffer)      //output reg [11:0] [0:3]\n");
fprintf(fo, ");\n\n");

//ar_reorder
fprintf(fo, "reorder #(.NUM_SID(NUM_S)) ar_reorder(\n");
fprintf(fo, ".clk            (AXI_CLK       ),    //input      \n");      
fprintf(fo, ".rstn           (AXI_RSTn      ),    //input      \n");      
fprintf(fo, "\n");

fprintf(fo, ".sid            (S_RID         ),    //input [11:0]\n");      
fprintf(fo, ".sid_vld        (S_RVALID      ),    //input      \n");      
fprintf(fo, ".rob_buffer     (ar_sid_buffer ),    //input [11:0] [0:3]\n");
fprintf(fo, ".order_grant    (r_order_grant )     //output reg [2:0]\n");
fprintf(fo, ");\n\n");

//u_aw_sid_buffer
fprintf(fo, "//{{ ******* WRITE TRANSACTION REORDER *********\n");
fprintf(fo, "sid_buffer #(.NUM(NUM_M)) u_aw_sid_buffer(\n");
fprintf(fo, ".clk           (AXI_CLK      ),     //input            \n");
fprintf(fo, ".rstn          (AXI_RSTn     ),     //input  \n");
fprintf(fo, "\n");

fprintf(fo, "//--------------Write buffer------------\n");
fprintf(fo, ".s_axid         (S_AWID         ),     //input [11:0]      \n");
fprintf(fo, ".s_axid_vld     (S_AWVALID      ),     //input            \n");
fprintf(fo, ".s_fifo_rdy     (S_AWREADY      ),     //input            \n");
fprintf(fo, ".s_push_rdy     (s_push_swid_rdy),     //output           \n");
fprintf(fo, "\n");

fprintf(fo, "//------Clean buffer and ajust position--------\n");
fprintf(fo, ".last          (S_WLAST        ),     //input            \n");
fprintf(fo, ".sid           (S_WID          ),     //input [11:0]      \n");
fprintf(fo, ".sid_vld       (S_WVALID       ),     //input            \n");
fprintf(fo, ".sid_clr_rdy   (s_wsid_clr_rdy ),     //output           \n");
fprintf(fo, ".sid_buffer      (aw_sid_buffer)      //output reg [11:0] [0:3]\n");
fprintf(fo, ");\n");

//for 
fprintf(fo, "wire [W_SID-1:0] sid_array[NUM_M-1:0];\n");
fprintf(fo, "wire [NUM_M-1:0] sid_vld_array;\n");
fprintf(fo, "\n");

fprintf(fo, "generate\n");
fprintf(fo, "    genvar i;\n");
fprintf(fo, "    for (i = 0; i < NUM_M; i = i + 1) begin : GEN_SID\n");
fprintf(fo, "        assign sid_array[i] = {M_WID[i][5:3], (3'b001 + i), M_WID[i]};\n");
fprintf(fo, "        assign sid_vld_array[i] = M_WVALID[i];\n");
fprintf(fo, "    end\n");
fprintf(fo, "endgenerate\n");
fprintf(fo, "\n");

//aw_reorder
fprintf(fo, "reorder #(.NUM_SID(NUM_M)) aw_reorder (\n");
fprintf(fo, "    .clk         (AXI_CLK),            // input            \n");
fprintf(fo, "    .rstn        (AXI_RSTn),           // input            \n");
fprintf(fo, "    .sid         (sid_array),          // input [11:0] [NUM_M-1:0]\n");
fprintf(fo, "    .sid_vld     (sid_vld_array),      // input [NUM_M-1:0]\n");
fprintf(fo, "    .rob_buffer  (aw_sid_buffer),      // input [11:0] [0:3]\n");
fprintf(fo, "    .order_grant (w_order_grant)       // output reg\n");
fprintf(fo, ");\n");
fprintf(fo, "//}} ******* WRITE TRANSACTION REORDER *********\n\n");

// //u_apb_cfg
// fprintf(fo, "`ifdef APB_CFG\n");
// fprintf(fo, "apb_regs_cfg u_apb_cfg(\n");
// fprintf(fo, "      .clk               (AXI_CLK)\n");
// fprintf(fo, "    , .rst_n             (AXI_RSTn)\n");
// fprintf(fo, " \n");

// fprintf(fo, "    , .pwrite            (pwrite )\n");
// fprintf(fo, "    , .psel              (psel   )\n");
// fprintf(fo, "    , .penable           (penable)\n");
// fprintf(fo, "    , .paddr             (paddr  )\n");
// fprintf(fo, "    , .pwdata            (pwdata )\n");
// fprintf(fo, "    , .prdata            (prdata )\n");
// fprintf(fo, " \n");

// fprintf(fo, "    , .aw_decode_err_reg    (|aw_decode_err)\n");
// fprintf(fo, "    , .ar_decode_err_reg    (|ar_decode_err)\n");
// fprintf(fo, "    , .aw_sid_buffer3       (aw_sid_buffer[3])\n");
// fprintf(fo, "    , .aw_sid_buffer2       (aw_sid_buffer[2])\n");
// fprintf(fo, "    , .aw_sid_buffer1       (aw_sid_buffer[1])\n");
// fprintf(fo, "    , .aw_sid_buffer0       (aw_sid_buffer[0])\n");
// fprintf(fo, "    , .ar_sid_buffer3       (ar_sid_buffer[3])\n");
// fprintf(fo, "    , .ar_sid_buffer2       (ar_sid_buffer[2])\n");
// fprintf(fo, "    , .ar_sid_buffer1       (ar_sid_buffer[1])\n");
// fprintf(fo, "    , .ar_sid_buffer0       (ar_sid_buffer[0])\n");
// fprintf(fo, "    , .aw_transation_count  (|aw_sid_buffer[0] + |aw_sid_buffer[1] + |aw_sid_buffer[2] + |aw_sid_buffer[3])\n");
// fprintf(fo, "    , .ar_transation_count  (|ar_sid_buffer[0] + |ar_sid_buffer[1] + |ar_sid_buffer[2] + |ar_sid_buffer[3])\n");
// fprintf(fo, "    , .arbiter_type         (arbiter_type    )\n");
// fprintf(fo, ");\n");
// fprintf(fo, "`endif\n\n");

fprintf(fo, "endmodule\n");

return 0;
};
