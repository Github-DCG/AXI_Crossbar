#include <stdio.h>
#include "gen_axi_utils.h"

int gen_axi_m2s( unsigned int num // num of masters
                , char *prefix
                , FILE *fo)
{
    int i;

    if ((num<2)||(prefix==NULL)) return 1;

fprintf(fo, "module %saxi_m2s_m%d\n", prefix, num);
fprintf(fo, "       #(parameter SLAVE_ID      = 0    // for reference\n");
fprintf(fo, "                 , SLAVE_EN      = 1'b1 // the slave is available when 1\n");
fprintf(fo, "                 , ADDR_BASE     = 32'h0000_0000\n");
fprintf(fo, "                 , ADDR_LENGTH   = 12 // effective addre bits\n");
fprintf(fo, "                 , W_CID         = 6  // Channel ID width in bits\n");
fprintf(fo, "                 , W_ID          = 6  // ID width in bits\n");
fprintf(fo, "                 , W_ADDR        = 32 // address width\n");
fprintf(fo, "                 , W_DATA        = 32 // data width\n");
fprintf(fo, "                 , W_STRB        = (W_DATA/8)  // data strobe width\n");
fprintf(fo, "                 , W_SID         = W_CID+W_ID // ID for slave\n");
fprintf(fo, "                 , NUM_MASTER    = %d    // number of master\n", num);
fprintf(fo, "                 , SLAVE_DEFAULT = 1'b0  // default-salve when 1\n");
fprintf(fo, "        )\n");
fprintf(fo, "(\n");
fprintf(fo, "       input   wire                      AXI_RSTn\n");
fprintf(fo, "     , input   wire                      AXI_CLK\n\n");

for (i=0; i<num; i++) {
char mp[4]; sprintf(mp, "M%d_", i);
fprintf(fo, "     , input   wire  [W_CID-1:0]         %sMID\n", mp);
gen_axi_mport_aw(mp, "wire", fo);
gen_axi_mport_w (mp, "wire", fo);
gen_axi_mport_ar(mp, "wire", fo);
fprintf(fo, "     \n");
}

gen_axi_sport_aw("S_", "reg", fo);
gen_axi_sport_w ("S_", "reg", fo);
gen_axi_sport_ar("S_", "reg", fo);

fprintf(fo, "     \n");
fprintf(fo, "     , output  wire  [NUM_MASTER-1:0]    AWSELECT_OUT\n");
fprintf(fo, "     , output  wire  [NUM_MASTER-1:0]    ARSELECT_OUT\n");
fprintf(fo, "     , input   wire  [NUM_MASTER-1:0]    AWSELECT_IN\n");
fprintf(fo, "     , input   wire  [NUM_MASTER-1:0]    ARSELECT_IN\n");

fprintf(fo, "     \n");
fprintf(fo, "     , input   wire  [2:0]               w_order_grant\n");
// fprintf(fo, "     , input   wire                      arbiter_type\n");
fprintf(fo, ");\n");

fprintf(fo, "\n");
fprintf(fo, "reg  [NUM_MASTER-1:0] AWSELECT;\n");
fprintf(fo, "reg  [NUM_MASTER-1:0] ARSELECT;\n");
fprintf(fo, "reg  [NUM_MASTER-1:0] WSELECT;\n");
fprintf(fo, "wire [NUM_MASTER-1:0] WSELECT_in;\n");
fprintf(fo, "wire [NUM_MASTER-1:0] AWGRANT, WGRANT, ARGRANT;\n");

fprintf(fo, "\n");
fprintf(fo, "assign  AWSELECT_OUT = AWSELECT;\n");
fprintf(fo, "assign  ARSELECT_OUT = ARSELECT;\n");
fprintf(fo, "\n");

fprintf(fo, "//-----------------------decode------------------------------------\n");
fprintf(fo, "always @ ( * ) begin\n");
fprintf(fo, "   if (SLAVE_DEFAULT=='h0) begin\n");
for (i=0; i<num; i++)
fprintf(fo, "       AWSELECT[%d] = SLAVE_EN[0]&(M%d_AWADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);\n", i, i);
fprintf(fo, "\n");

for (i=0; i<num; i++)
fprintf(fo, "       WSELECT[%d] = SLAVE_EN[0]&(M%d_WID[5:3]==ADDR_BASE[ADDR_LENGTH+2:ADDR_LENGTH]);\n", i, i);
fprintf(fo, "\n");

for (i=0; i<num; i++)
fprintf(fo, "       ARSELECT[%d] = SLAVE_EN[0]&(M%d_ARADDR[W_ADDR-1:ADDR_LENGTH]==ADDR_BASE[W_ADDR-1:ADDR_LENGTH]);\n", i, i);
fprintf(fo, "   end else begin\n");
fprintf(fo, "       AWSELECT = ~AWSELECT_IN & {M%d_AWVALID", num-1);
for (i=num-2; i>=0; i--) fprintf(fo, ",M%d_AWVALID", i); fprintf(fo, "};\n");
fprintf(fo, "       ARSELECT = ~ARSELECT_IN & {M%d_ARVALID", num-1);
for (i=num-2; i>=0; i--) fprintf(fo, ",M%d_ARVALID", i); fprintf(fo, "};\n");
fprintf(fo, "   end\n");
fprintf(fo, "end\n");

fprintf(fo, "\n");
fprintf(fo, "assign WSELECT_in = WSELECT & w_order_grant;\n");
fprintf(fo, "\n");

#define allX(A,B,N)\
fprintf(fo, "wire [NUM_MASTER-1:0] %s_ALL = {M%d_%s", (A), (N)-1, (B));\
for (i=num-2; i>=0; i--) fprintf(fo, ",M%d_%s", i, (B)); fprintf(fo, "};\n");

allX("AWVALID", "AWVALID", num)
allX("AWREADY", "AWREADY", num)
allX("ARVALID", "ARVALID", num)
allX("ARREADY", "ARREADY", num)
allX("WVALID", "WVALID", num)
allX("WREADY", "WREADY", num)
allX("WLAST", "WLAST", num)
fprintf(fo, "     \n");

fprintf(fo, "//----------------------arbiter-------------------------\n");
fprintf(fo, "%saxi_arbiter_m2s_m%d #(.W_CID (W_CID)\n", prefix, num);
fprintf(fo, "                     ,.W_ID (W_ID )\n");
fprintf(fo, "                     )\n");
fprintf(fo, "u_axi_arbiter_m2s_m%d (\n", num);
fprintf(fo, "      .AXI_RSTn (AXI_RSTn          )\n");
fprintf(fo, "    , .AXI_CLK  (AXI_CLK           )\n\n");

fprintf(fo, "    , .AWSELECT (AWSELECT          )\n");
fprintf(fo, "    , .AWVALID  (AWVALID_ALL       )\n");
fprintf(fo, "    , .AWREADY  (AWREADY_ALL       )\n");
fprintf(fo, "    , .AWGRANT  (AWGRANT           )\n\n");

fprintf(fo, "    , .WSELECT  (WSELECT_in        )\n");
fprintf(fo, "    , .WVALID   (WVALID_ALL        )\n");
fprintf(fo, "    , .WREADY   (WREADY_ALL        )\n");
fprintf(fo, "    , .WLAST    (WREADY_ALL        )\n");
fprintf(fo, "    , .WGRANT   (WGRANT            )\n\n");

fprintf(fo, "    , .ARSELECT (ARSELECT          )\n");
fprintf(fo, "    , .ARVALID  (ARVALID_ALL       )\n");
fprintf(fo, "    , .ARREADY  (ARREADY_ALL       )\n");
fprintf(fo, "    , .ARGRANT  (ARGRANT           )\n");
// fprintf(fo, "    , .arbiter_type  (arbiter_type )\n\n");
fprintf(fo, ");\n\n");

fprintf(fo, "localparam NUM_AW_WIDTH = W_SID + W_ADDR + 8 + 3 + 2 + 1; //S_AWID S_AWADDR S_AWLEN S_AWSIZE S_AWBURST S_AWVALID\n");
fprintf(fo, "localparam NUM_W_WIDTH = W_SID + W_DATA + W_STRB + 1 + 1; //S_WID S_WDATA S_WSTRB S_WLAST S_WVALID\n");
fprintf(fo, "localparam NUM_AR_WIDTH = W_SID + W_ADDR + 8 + 3 + 2 + 1; //S_ARID S_ARADDR S_ARLEN S_ARSIZE S_ARBURST S_ARVALID\n");

fprintf(fo, "\n");
fprintf(fo, "wire [NUM_AW_WIDTH-1:0] bus_aw[0:NUM_MASTER-1];\n");
fprintf(fo, "wire [NUM_W_WIDTH-1 :0] bus_w [0:NUM_MASTER-1];\n");
fprintf(fo, "wire [NUM_AR_WIDTH-1:0] bus_ar[0:NUM_MASTER-1];\n");

fprintf(fo, "\n");
for (i=0; i<num; i++)
fprintf(fo, "assign M%d_AWREADY = AWGRANT[%d] & S_AWREADY;\n", i, i);
fprintf(fo, "\n");
for (i=0; i<num; i++)
fprintf(fo, "assign M%d_WREADY  = WGRANT [%d] & S_WREADY;\n", i, i);
fprintf(fo, "\n");
for (i=0; i<num; i++)
fprintf(fo, "assign M%d_ARREADY = ARGRANT[%d] & S_ARREADY;\n", i, i);
fprintf(fo, "\n");

for (i=0; i<num; i++) {
fprintf(fo, "assign bus_aw[%d] = {ADDR_BASE[14:12], M%d_MID, M%d_AWID, M%d_AWADDR, M%d_AWLEN, M%d_AWSIZE, M%d_AWBURST, M%d_AWVALID};\n",i,i,i,i,i,i,i,i);}

fprintf(fo, "\n");
fprintf(fo, "//Format of S_WID: {3-bit slv_addr}, {3-bit mst_ID}, {6-bit M_WID: 3_bit_slv + 3_bit_ID}\n");
for (i=0; i<num; i++) {
fprintf(fo, "assign bus_w[%d]  = {ADDR_BASE[14:12], M%d_MID, M%d_WID, M%d_WDATA, M%d_WSTRB, M%d_WLAST, M%d_WVALID};\n",i,i,i,i,i,i,i);
}

fprintf(fo, "\n");
fprintf(fo, "//Format of S_ARID: {3-bit slv_addr}, {3-bit mst_ID}, {6-bit M_ARID}\n");
for (i=0; i<num; i++) {
fprintf(fo, "assign bus_ar[%d] = {ADDR_BASE[14:12], M%d_MID, M%d_ARID, M%d_ARADDR, M%d_ARLEN, M%d_ARSIZE, M%d_ARBURST, M%d_ARVALID};\n",i,i,i,i,i,i,i,i);
}

fprintf(fo, "\n");
fprintf(fo, "//-------------------router--------------------------\n");
fprintf(fo, "`define S_AWBUS {S_AWID, S_AWADDR, S_AWLEN, S_AWSIZE, S_AWBURST, S_AWVALID}\n");
fprintf(fo, "always @ ( AWGRANT");
for (i=0; i<num; i++) fprintf(fo, ", bus_aw[%d]", i); fprintf(fo, " ) begin\n");
fprintf(fo, "       case (AWGRANT)\n");
for (i=0; i<num; i++)
fprintf(fo, "       %d'h%X:  `S_AWBUS = bus_aw[%d];\n", num, 1<<i, i);
fprintf(fo, "       default:    `S_AWBUS = 'h0;\n");
fprintf(fo, "       endcase\n");
fprintf(fo, "end\n\n");

fprintf(fo, "`define S_WBUS {`define S_WBUS {S_WID, S_WDATA, S_WSTRB, S_WLAST, S_WVALID} }\n");
fprintf(fo, "always @ ( WGRANT");
for (i=0; i<num; i++) fprintf(fo, ", bus_w[%d]", i); fprintf(fo, " ) begin\n");
fprintf(fo, "       case (WGRANT)\n");
for (i=0; i<num; i++)
fprintf(fo, "       %d'h%X:  `S_WBUS = bus_w[%d];\n", num, 1<<i, i);
fprintf(fo, "       default:    `S_WBUS = 'h0;\n");
fprintf(fo, "       endcase\n");
fprintf(fo, "end\n\n");

fprintf(fo, "`define S_ARBUS {`define S_ARBUS {S_ARID, S_ARADDR, S_ARLEN, S_ARSIZE, S_ARBURST, S_ARVALID}}\n");
fprintf(fo, "always @ ( ARGRANT");
for (i=0; i<num; i++) fprintf(fo, ", bus_ar[%d]", i); fprintf(fo, " ) begin\n");
fprintf(fo, "       case (ARGRANT)\n");
for (i=0; i<num; i++)
fprintf(fo, "       %d'h%X:  `S_ARBUS = bus_ar[%d];\n", num, 1<<i, i);
fprintf(fo, "       default:    `S_ARBUS = 'h0;\n");
fprintf(fo, "       endcase\n");
fprintf(fo, "end\n");
fprintf(fo, "\n");

fprintf(fo, "endmodule\n\n");

    return 0;
}
