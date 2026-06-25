#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "gen_axi_utils.h"


int gen_axi_crossbar( unsigned int numM // num of masters
                     , unsigned int numS // num of slaves
                     , char *prefix
                     , FILE *fo)
{
    int i, j;
    unsigned int start=0x00001000;

    if ((numM<2)||(numS<2)||(prefix==NULL)) return 1;

fprintf(fo, "\n");
// fprintf(fo, "module %s\n", module);
fprintf(fo, "module axi_crossbar\n");
fprintf(fo, "      #(parameter W_CID      = 6           // Channel ID width in bits\n");
fprintf(fo, "                , W_ID       = 6           // ID width in bits\n");
fprintf(fo, "                , W_ADDR     = 32          // address width\n");
fprintf(fo, "                , W_DATA     = 32          // data width\n");
fprintf(fo, "                , W_STRB     = (W_DATA/8)  // data strobe width\n");
fprintf(fo, "                , W_SID      = (W_CID+W_ID)// ID for slave\n");

for (i=0; i<numS; i++) {
fprintf(fo, "                , SLAVE_EN%d  = 1, ADDR_BASE%d = 32'h%08X, ADDR_LENGTH%d = 12 // effective addre bits\n", i, i, start, i);
start += 0x1000;
}
fprintf(fo, "                , NUM_MASTER = %d\n", numM);
fprintf(fo, "                , NUM_SLAVE  = %d\n", numS);
fprintf(fo, "       )\n");
fprintf(fo, "(\n");
fprintf(fo, "       input   wire                      AXI_RSTn\n");
fprintf(fo, "     , input   wire                      AXI_CLK\n");
for (i=0; i<numM; i++) {
char mp[4]; sprintf(mp, "M%d_", i);
fprintf(fo, "\n     //--------------------------------------------------------------\n");
fprintf(fo, "     , input   wire  [W_CID-1:0]         M%d_MID   // if not sure use 'h%x\n", i, i);
gen_axi_mport_aw(mp, "wire", fo);
gen_axi_mport_w (mp, "wire", fo);
gen_axi_mport_b (mp, "wire", fo);
gen_axi_mport_ar(mp, "wire", fo);
gen_axi_mport_r (mp, "wire", fo);
}
for (i=0; i<numS; i++) {
char sp[4]; sprintf(sp, "S%d_", i);
fprintf(fo, "\n     //--------------------------------------------------------------\n");
gen_axi_sport_aw(sp, "wire", fo);
gen_axi_sport_w (sp, "wire", fo);
gen_axi_sport_b (sp, "wire", fo);
gen_axi_sport_ar(sp, "wire", fo);
gen_axi_sport_r (sp, "wire", fo);
}
fprintf(fo, "\n     //--------------For reorder----------------------\n");
fprintf(fo, "     , input   wire  [NUM_S-1:0]               r_order_grant\n");
fprintf(fo, "     , input   wire  [NUM_M-1:0]               w_order_grant\n");
// fprintf(fo, "\n     //--------------For apb config----------------------\n");
// fprintf(fo, "     , input   wire  [0:0]               arbiter_type\n");
// fprintf(fo, "     , output  wire  [2:0]               aw_decode_err\n");
// fprintf(fo, "     , output  wire  [2:0]               ar_decode_err\n");
fprintf(fo, ");\n");

fprintf(fo, "     // default slave signal\n");
gen_axi_signal( "SD_", fo );
fprintf(fo, "\n");

fprintf(fo, "     // driven by axi_mtos_s\n");

#define MMX(A)\
sprintf(str, "M%d_%s_S0", i, (A)); fprintf(fo, "     wire %-15s", str);\
for (j=1; j<numS; j++) { sprintf(str, "M%d_%s_S%d", i, (A), j); fprintf(fo, ",%-15s", str); }\
sprintf(str, "M%d_%s_SD", i, (A)); fprintf(fo, ",%-15s;\n", str);\

for (i=0; i<numM; i++) {
    char str[32];
    MMX("AWREADY")
    MMX("WREADY")
    MMX("ARREADY")
}
fprintf(fo, "\n");

#define MMY(A)\
sprintf(str, "M%d_%s", i, (A)); fprintf(fo, "     assign %-11s", str);\
sprintf(str, "M%d_%s_S0", i, (A)); fprintf(fo, " = %-15s", str);\
for (j=1; j<numS; j++) {\
sprintf(str, "M%d_%s_S%d", i, (A), j); fprintf(fo, "|%-15s", str); }\
sprintf(str, "M%d_%s_SD", i, (A)); fprintf(fo, "|%-15s;\n", str);

for (i=0; i<numM; i++) {
char str[32];
MMY("AWREADY")
MMY("WREADY")
MMY("ARREADY")
}
fprintf(fo, "\n");
fprintf(fo, "     // driven by axi_stom_m\n");

#define MMZ(A)\
fprintf(fo, "     wire S%d_%s_M0", i, (A));\
for (j=1; j<numM; j++) fprintf(fo, ",S%d_%s_M%d", i, (A), j); fprintf(fo, ";\n");

for (i=0; i<numS; i++) {
MMZ("BREADY")
MMZ("RREADY")
}

fprintf(fo, "     wire SD_BREADY_M0");
for (i=1; i<numM; i++) fprintf(fo, ",SD_BREADY_M%d", i); fprintf(fo, ";\n");
fprintf(fo, "     wire SD_RREADY_M0");
for (i=1; i<numM; i++) fprintf(fo, ",SD_RREADY_M%d", i); fprintf(fo, ";\n");

fprintf(fo, "     //-----------------------------------------------------------\n");

#define XXZ(A)\
fprintf(fo, "     assign S%d_%s = S%d_%s_M0", i, (A), i, (A));\
for (j=1; j<numM; j++) fprintf(fo, "|S%d_%s_M%d", i, (A), j); fprintf(fo, ";\n");

for (i=0; i<numS; i++) {
XXZ("BREADY")
XXZ("RREADY")
}
fprintf(fo, "     assign SD_BREADY = SD_BREADY_M0");
for (i=1; i<numM; i++) fprintf(fo, "|SD_BREADY_M%d", i); fprintf(fo, ";\n");
fprintf(fo, "     assign SD_RREADY = SD_RREADY_M0");
for (i=1; i<numM; i++) fprintf(fo, "|SD_RREADY_M%d", i); fprintf(fo, ";\n");
fprintf(fo, "     //-----------------------------------------------------------\n");
fprintf(fo, "     // drivne by axi_mtos_m?\n");
fprintf(fo, "     wire [NUM_MASTER-1:0] AWSELECT_OUT[0:NUM_SLAVE-1];\n");
fprintf(fo, "     wire [NUM_MASTER-1:0] ARSELECT_OUT[0:NUM_SLAVE-1];\n");
fprintf(fo, "     wire [NUM_MASTER-1:0] AWSELECT; // goes to default slave\n");
fprintf(fo, "     wire [NUM_MASTER-1:0] ARSELECT; // goes to default slave\n");
fprintf(fo, "     //-----------------------------------------------------------\n");

for (i=0; i<numM; i++) {
fprintf(fo, "     assign AWSELECT[%d] = AWSELECT_OUT[0][%d]", i, i);
for (j=1; j<numS; j++) fprintf(fo, "|AWSELECT_OUT[%d][%d]", j, i); fprintf(fo, ";\n");
}
for (i=0; i<numM; i++) {
fprintf(fo, "     assign ARSELECT[%d] = ARSELECT_OUT[0][%d]", i, i);
for (j=1; j<numS; j++) fprintf(fo, "|ARSELECT_OUT[%d][%d]", j, i); fprintf(fo, ";\n");
}

for (i=0; i<numS; i++) {
fprintf(fo, "     //-----------------------------------------------------------\n");
fprintf(fo, "     // masters to slave for slave %d\n", i);
fprintf(fo, "     %saxi_m2s_m%d #(.SLAVE_ID       (%d            )\n", prefix, numM, i);
fprintf(fo, "                  ,.SLAVE_EN      (SLAVE_EN%d    )\n", i);
fprintf(fo, "                  ,.ADDR_BASE     (ADDR_BASE%d   )\n", i);
fprintf(fo, "                  ,.ADDR_LENGTH   (ADDR_LENGTH%d )\n", i);
fprintf(fo, "                  ,.W_CID         (W_CID        )\n" );
fprintf(fo, "                  ,.W_ID          (W_ID         )\n" );
fprintf(fo, "                  ,.W_ADDR        (W_ADDR       )\n");
fprintf(fo, "                  ,.W_DATA        (W_DATA       )\n");
fprintf(fo, "                  ,.W_STRB        (W_STRB       )\n");
fprintf(fo, "                  ,.W_SID         (W_SID        )\n");
fprintf(fo, "                  ,.SLAVE_DEFAULT (1'b0         )\n");
fprintf(fo, "                 )\n");
fprintf(fo, "     u_axi_m2s_s%d (\n", i);
fprintf(fo, "                                .AXI_RSTn             (AXI_RSTn     )\n");
fprintf(fo, "                              , .AXI_CLK              (AXI_CLK      )\n\n");
char sp[5]; sprintf(sp, "_S%d", i);
for (j=0; j<numM; j++) {
char mp[5]; sprintf(mp, "M%d_", j);
gen_axi_m2s_mcon_aw( mp, mp, sp, fo );
gen_axi_m2s_mcon_w ( mp, mp, sp, fo );
gen_axi_m2s_mcon_ar( mp, mp, sp, fo );
fprintf(fo, "\n");
}
fprintf(fo, "                              , .w_order_grant        (w_order_grant)\n");
// fprintf(fo, "                              , .arbiter_type         (arbiter_type )\n");

sprintf(sp, "S%d_", i);
gen_axi_m2s_scon_aw("S_", sp, fo);
gen_axi_m2s_scon_w ("S_", sp, fo);
gen_axi_m2s_scon_ar("S_", sp, fo);
fprintf(fo, "         , .AWSELECT_OUT         (AWSELECT_OUT[%d])\n", i);
fprintf(fo, "         , .ARSELECT_OUT         (ARSELECT_OUT[%d])\n", i);
fprintf(fo, "         , .AWSELECT_IN          (AWSELECT_OUT[%d])// not used since non-default-slave\n", i);
fprintf(fo, "         , .ARSELECT_IN          (ARSELECT_OUT[%d])// not used since non-default-slave\n", i);
fprintf(fo, "     );\n");
}

fprintf(fo, "     \n");
fprintf(fo, "     // masters to slave for default slave\n");
fprintf(fo, "     %saxi_mtos_m%d #(.SLAVE_ID      (NUM_SLAVE   )\n", prefix, numM);
fprintf(fo, "                  ,.SLAVE_EN      (1'b1        ) // always enabled\n");
fprintf(fo, "                  ,.ADDR_BASE     (ADDR_BASE1  )\n");
fprintf(fo, "                  ,.ADDR_LENGTH   (ADDR_LENGTH1)\n");
fprintf(fo, "                  ,.W_CID         (W_CID       )\n");
fprintf(fo, "                  ,.W_ID          (W_ID        )\n");
fprintf(fo, "                  ,.W_ADDR        (W_ADDR      )\n");
fprintf(fo, "                  ,.W_DATA        (W_DATA      )\n");
fprintf(fo, "                  ,.W_STRB        (W_STRB      )\n");
fprintf(fo, "                  ,.W_SID         (W_SID       )\n");
fprintf(fo, "                  ,.SLAVE_DEFAULT (1'b1        )\n");
fprintf(fo, "                 )\n");
fprintf(fo, "     u_axi_m2s_sd (\n");
fprintf(fo, "                                .AXI_RSTn             (AXI_RSTn     )\n");
fprintf(fo, "                              , .AXI_CLK              (AXI_CLK      )\n");
for (j=0; j<numM; j++) {
char mp[5]; sprintf(mp, "M%d_", j);
gen_axi_m2s_mcon_aw( mp, mp, "_SD", fo );
gen_axi_m2s_mcon_w ( mp, mp, "_SD", fo );
gen_axi_m2s_mcon_ar( mp, mp, "_SD", fo );
fprintf(fo, "\n");
}
fprintf(fo, "                              , .w_order_grant        (w_order_grant)\n");
// fprintf(fo, "                              , .arbiter_type         (arbiter_type )\n");
gen_axi_m2s_scon_aw("S_", "SD_", fo);
gen_axi_m2s_scon_w ("S_", "SD_", fo);
gen_axi_m2s_scon_ar("S_", "SD_", fo);
fprintf(fo, "         , .AWSELECT_OUT         (aw_decode_err)\n");
fprintf(fo, "         , .ARSELECT_OUT         (ar_decode_err)\n");
fprintf(fo, "         , .AWSELECT_IN          (AWSELECT     )\n");
fprintf(fo, "         , .ARSELECT_IN          (ARSELECT     )\n");
fprintf(fo, "     );\n");

fprintf(fo, "     //--------------default slave-------------------- \n");
fprintf(fo, "     %saxi_default_slave #(.W_CID  (W_CID)// Channel ID width in bits\n", prefix);
fprintf(fo, "                        ,.W_ID   (W_ID )  // ID width in bits\n");
fprintf(fo, "                        ,.W_ADDR (W_ADDR )// address width\n");
fprintf(fo, "                        ,.W_DATA (W_DATA )// data width\n");
fprintf(fo, "                        )\n");
fprintf(fo, "     u_axi_default_slave (\n");
fprintf(fo, "            .AXI_RSTn (AXI_RSTn   )\n");
fprintf(fo, "          , .AXI_CLK  (AXI_CLK    )\n");
fprintf(fo, "          , .AWID     (SD_AWID    )\n");
fprintf(fo, "          , .AWADDR   (SD_AWADDR  )\n");
fprintf(fo, "          , .AWLEN    (SD_AWLEN   )\n");
fprintf(fo, "          , .AWSIZE   (SD_AWSIZE  )\n");
fprintf(fo, "          , .AWBURST  (SD_AWBURST )\n");
fprintf(fo, "          , .AWVALID  (SD_AWVALID )\n");
fprintf(fo, "          , .AWREADY  (SD_AWREADY )\n");
fprintf(fo, "          , .WID      (SD_WID     )\n");
fprintf(fo, "          , .WDATA    (SD_WDATA   )\n");
fprintf(fo, "          , .WSTRB    (SD_WSTRB   )\n");
fprintf(fo, "          , .WLAST    (SD_WLAST   )\n");
fprintf(fo, "          , .WVALID   (SD_WVALID  )\n");
fprintf(fo, "          , .WREADY   (SD_WREADY  )\n");
fprintf(fo, "          , .BID      (SD_BID     )\n");
fprintf(fo, "          , .BRESP    (SD_BRESP   )\n");
fprintf(fo, "          , .BVALID   (SD_BVALID  )\n");
fprintf(fo, "          , .BREADY   (SD_BREADY  )\n");
fprintf(fo, "          , .ARID     (SD_ARID    )\n");
fprintf(fo, "          , .ARADDR   (SD_ARADDR  )\n");
fprintf(fo, "          , .ARLEN    (SD_ARLEN   )\n");
fprintf(fo, "          , .ARSIZE   (SD_ARSIZE  )\n");
fprintf(fo, "          , .ARBURST  (SD_ARBURST )\n");
fprintf(fo, "          , .ARVALID  (SD_ARVALID )\n");
fprintf(fo, "          , .ARREADY  (SD_ARREADY )\n");
fprintf(fo, "          , .RID      (SD_RID     )\n");
fprintf(fo, "          , .RDATA    (SD_RDATA   )\n");
fprintf(fo, "          , .RRESP    (SD_RRESP   )\n");
fprintf(fo, "          , .RLAST    (SD_RLAST   )\n");
fprintf(fo, "          , .RVALID   (SD_RVALID  )\n");
fprintf(fo, "          , .RREADY   (SD_RREADY  )\n");
fprintf(fo, "     );\n");


for (i=0; i<numM; i++) {
fprintf(fo, "     \n");
fprintf(fo, "     // slaves to master for master %d\n", i);
fprintf(fo, "     %saxi_stom_s%d #(.MASTER_ID (%d         )\n", prefix, numS, i);
fprintf(fo, "                  ,.W_CID     (W_CID     )\n");
fprintf(fo, "                  ,.W_ID      (W_ID      )\n");
fprintf(fo, "                  ,.W_ADDR    (W_ADDR    )\n");
fprintf(fo, "                  ,.W_DATA    (W_DATA    )\n");
fprintf(fo, "                  ,.W_STRB    (W_STRB    )\n");
fprintf(fo, "                  ,.W_SID     (W_SID     )\n");
fprintf(fo, "                 )\n");
fprintf(fo, "     u_axi_stom_m%d (\n", i);
fprintf(fo, "           .AXI_RSTn             (AXI_RSTn    )\n");
fprintf(fo, "         , .AXI_CLK              (AXI_CLK     )\n");
char mp[5]; sprintf(mp, "M%d_", i);
gen_axi_s2m_mcon_b( "M_", mp, fo);
gen_axi_s2m_mcon_r( "M_", mp, fo);
char pf[5]; sprintf(pf, "_M%d", i);
for (j=0; j<numS; j++) {
char sp[5]; sprintf(sp, "S%d_", j);
gen_axi_s2m_scon_b( sp, sp, pf, fo );
gen_axi_s2m_scon_r( sp, sp, pf, fo );
fprintf(fo, "\n");
}
gen_axi_s2m_scon_b( "SD_", "SD_", pf, fo );
gen_axi_s2m_scon_r( "SD_", "SD_", pf, fo );
fprintf(fo, "                           , .r_order_grant        (r_order_grant) //input wire [12-1:0] [3:0]\n");
// fprintf(fo, "                           , .arbiter_type         (arbiter_type)\n");
fprintf(fo, "        );\n");
}


fprintf(fo, "endmodule\n");

    return 0;
}