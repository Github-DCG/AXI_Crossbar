#include <stdio.h>
#include "gen_axi_utils.h"

int gen_axi_s2m( unsigned int num // num of slaves
                , char* prefix // num of slaves for the module
                , FILE* fo)
{
    int i;

    if ((num<2)||(prefix==NULL)) return 1;

fprintf(fo, "module %saxi_s2m_s%d\n", prefix, num);
fprintf(fo, "       #(parameter MASTER_ID   = 0 // for reference\n");
fprintf(fo, "                 , W_CID       = 6 // Channel ID width in bits\n");
fprintf(fo, "                 , W_ID        = 6 // ID width in bits\n");
fprintf(fo, "                 , W_ADDR      = 32 // address width\n");
fprintf(fo, "                 , W_DATA      = 32 // data width\n");
fprintf(fo, "                 , W_STRB      = (W_DATA/8)  // data strobe width\n");
fprintf(fo, "                 , W_SID       = W_CID+W_ID // ID for slave\n");
fprintf(fo, "        )\n");
fprintf(fo, "(\n");
fprintf(fo, "       input   wire                      AXI_RSTn\n");
fprintf(fo, "     , input   wire                      AXI_CLK\n");
fprintf(fo, "     \n");

fprintf(fo, "     , input   wire  [W_CID-1:0]         M_MID\n");
gen_axi_mport_b("M_", "reg", fo);
gen_axi_mport_r("M_", "reg", fo);
fprintf(fo, "     \n");

for (i=0; i<num; i++) {
char sp[4]; sprintf(sp, "S%d_", i);
gen_axi_sport_b(sp, "wire", fo);
gen_axi_sport_r(sp, "wire", fo);
fprintf(fo, "     \n");
}

gen_axi_sport_b("SD_", "wire", fo);
gen_axi_sport_r("SD_", "wire", fo);

fprintf(fo, "     \n");
fprintf(fo, "     , input wire [W_SID-1:0]                  r_order_grant\n");
// fprintf(fo, "     , input wire                        arbiter_type\n");
fprintf(fo, ");\n");

fprintf(fo, "localparam NUM = %d;\n", num);

fprintf(fo, "\n");
fprintf(fo, "wire [NUM:0] BSELECT, RSELECT;\n");
fprintf(fo, "wire [NUM:0] RSELECT_in;\n");
fprintf(fo, "wire [NUM:0] BGRANT, RGRANT ;\n");

fprintf(fo, "\n");
fprintf(fo, "//-------------------decode-------------------------\n");
for (i=0; i<num; i++)
fprintf(fo, "assign BSELECT[%d] = (S%d_BID[W_SID-1:W_ID]==M_MID);\n", i, i);
fprintf(fo, "assign BSELECT[%d] = (SD_BID[W_SID-1:W_ID]==M_MID);\n", i);
fprintf(fo, "\n");

for (i=0; i<num; i++)
fprintf(fo, "assign RSELECT[%d] = (S%d_RID[W_SID-1:W_ID]==M_MID);\n", i, i);
fprintf(fo, "assign RSELECT[%d] = (SD_RID[W_SID-1:W_ID]==M_MID);\n", i);
fprintf(fo, "\n");
fprintf(fo, "assign RSELECT_in = RSELECT & {1'b1,r_order_grant};\n");
fprintf(fo, "\n");

fprintf(fo, "%saxi_arbiter_s2m_s%d #(.NUM(NUM))\n", prefix, num);
fprintf(fo, "u_axi_arbiter_s2m_s%d (\n", num);
fprintf(fo, "      .AXI_RSTn (AXI_RSTn  )\n");
fprintf(fo, "    , .AXI_CLK  (AXI_CLK   )\n\n");

fprintf(fo, "    , .BSELECT  (BSELECT)\n");
fprintf(fo, "    , .BVALID   ({SD_BVALID");
for (i=num-1; i>=0; i--) fprintf(fo, ",S%d_BVALID", i); fprintf(fo, "})\n");
fprintf(fo, "    , .BREADY   ({SD_BREADY");
for (i=num-1; i>=0; i--) fprintf(fo, ",S%d_BREADY", i); fprintf(fo, "})\n");
fprintf(fo, "    , .BGRANT   (BGRANT )\n\n");

fprintf(fo, "    , .RSELECT  (RSELECT_in)\n");
fprintf(fo, "    , .RVALID   ({SD_RVALID");
for (i=num-1; i>=0; i--) fprintf(fo, ",S%d_RVALID", i); fprintf(fo, "})\n");
fprintf(fo, "    , .RREADY   ({SD_RREADY");
for (i=num-1; i>=0; i--) fprintf(fo, ",S%d_RREADY", i); fprintf(fo, "})\n");
fprintf(fo, "    , .RLAST    ({SD_RLAST");
for (i=num-1; i>=0; i--) fprintf(fo, ",S%d_RLAST", i); fprintf(fo, "})\n");
fprintf(fo, "    , .RGRANT   (RGRANT )\n");
// fprintf(fo, "    , .arbiter_type (arbiter_type)\n");
fprintf(fo, ");\n");

fprintf(fo, "\n");
fprintf(fo, "localparam NUM_B_WIDTH = W_ID+2+1 ; // M_BID M_BRESP M_BVALID\n");
fprintf(fo, "localparam NUM_R_WIDTH = W_SID+W_DATA+2+1+1; // M_RSID M_RDATA M_RRESP M_RLAST M_RVALID\n");

fprintf(fo, "\n");
fprintf(fo, "wire [NUM_B_WIDTH-1:0] bus_b[0:NUM];\n");
fprintf(fo, "wire [NUM_R_WIDTH-1:0] bus_r[0:NUM];\n");

fprintf(fo, "\n");
for (i=0; i<num; i++) {
fprintf(fo, "assign bus_b[%d] = {S%d_BID[W_ID-1:0], S%d_BRESP, S%d_BVALID};\n", i, i, i, i);
}
fprintf(fo, "assign bus_b[NUM] = {SD_BID[W_ID-1:0], SD_BRESP, SD_BVALID};\n");

fprintf(fo, "\n");
for (i=0; i<num; i++) {
fprintf(fo, "assign bus_r[%d] = {S%d_RID[W_ID-1:0], S%d_RDATA, S%d_RRESP, S%d_RLAST, S%d_RVALID};\n", i, i, i, i, i, i);
}
fprintf(fo, "assign bus_r[NUM] = {SD_RID, SD_RDATA, SD_RRESP, SD_RLAST, SD_RVALID};\n");

fprintf(fo, "\n");
fprintf(fo, "//---------------------------router------------------------\n");
fprintf(fo, "`define M_BBUS {M_BID[W_ID-1:0], M_BRESP, M_BVALID }\n");
fprintf(fo, "always @ ( BGRANT");
for (i=0; i<num; i++) fprintf(fo, ", bus_b[%d]", i); fprintf(fo, ", bus_b[NUM] ) begin\n");
fprintf(fo, "       case (BGRANT)\n");
for (i=0; i<num; i++)
fprintf(fo, "       %d'h%X: `M_BBUS = bus_b[%d];\n", (num+1), (1<<i), i);
fprintf(fo, "       %d'h%X: `M_BBUS = bus_b[NUM];\n", (num+1), (1<<num));
fprintf(fo, "       default:    `M_BBUS = 'h0;\n");
fprintf(fo, "       endcase\n");
fprintf(fo, "end\n\n");

fprintf(fo, "`define M_RBUS {M_RSID, M_RDATA, M_RRESP, M_RLAST, M_RVALID}\n");
fprintf(fo, "always @ ( RGRANT");
for (i=0; i<num; i++) fprintf(fo, ", bus_r[%d]", i); fprintf(fo, ", bus_r[NUM] ) begin\n");
fprintf(fo, "       case (RGRANT)\n");
for (i=0; i<num; i++)
fprintf(fo, "       %d'h%X: `M_RBUS = bus_r[%d];\n", num+1, 1<<i, i);
fprintf(fo, "       %d'h%X: `M_RBUS = bus_r[NUM];\n", num+1, 1<<num);
fprintf(fo, "       default:    `M_RBUS = 'h0;\n");
fprintf(fo, "       endcase\n");
fprintf(fo, "end\n");

fprintf(fo, "\n");
for (i=0; i<num; i++)
fprintf(fo, "assign S%d_BREADY = BGRANT[%d] & M_BREADY;\n", i, i);
fprintf(fo, "assign SD_BREADY = BGRANT[NUM] & M_BREADY;\n");
fprintf(fo, "\n");
for (i=0; i<num; i++)
fprintf(fo, "assign S%d_RREADY = RGRANT[%d] & M_RREADY;\n", i, i);
fprintf(fo, "assign SD_RREADY = RGRANT[NUM] & M_RREADY;\n\n");
fprintf(fo, "endmodule\n");
fprintf(fo, "     \n");
    return 0;
}
