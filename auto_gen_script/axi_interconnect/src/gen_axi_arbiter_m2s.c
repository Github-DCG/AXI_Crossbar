#include <stdio.h>

int gen_axi_arbiter_m2s( unsigned int num // num of master
                        , char *prefix
                        , FILE *fo)
{
    int i, j;

    if ((num<2)||(prefix==NULL)) return 1;

fprintf(fo, "\n");
fprintf(fo, "module %saxi_arbiter_m2s_m%d\n", prefix, num);
fprintf(fo, "     #(parameter W_CID = 6  // Channel ID width in bits\n");
fprintf(fo, "               , W_ID  = 6  // Transaction ID\n");
fprintf(fo, "               , W_SID = (W_CID+W_ID)\n");
fprintf(fo, "               , NUM   = %d // num of masters\n", num);
fprintf(fo, "               )\n");
fprintf(fo, "(\n");
fprintf(fo, "       input  wire                  AXI_RSTn\n");
fprintf(fo, "     , input  wire                  AXI_CLK\n");
fprintf(fo, "     \n");
fprintf(fo, "     , input  wire  [NUM-1:0]       AWSELECT  \n");
fprintf(fo, "     , input  wire  [NUM-1:0]       AWVALID\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       AWREADY\n");
fprintf(fo, "     , output wire  [NUM-1:0]       AWGRANT\n");

fprintf(fo, "     \n");
fprintf(fo, "     , input  wire  [NUM-1:0]       WSELECT\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       WVALID\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       WREADY\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       WLAST\n");
fprintf(fo, "     , output reg   [NUM-1:0]       WGRANT\n");

fprintf(fo, "     \n");
fprintf(fo, "     , input  wire  [NUM-1:0]       ARSELECT\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       ARVALID\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       ARREADY\n");
fprintf(fo, "     , output wire  [NUM-1:0]       ARGRANT\n");

fprintf(fo, "     \n");
fprintf(fo, "     , input  wire                  arbiter_type\n");
fprintf(fo, ");\n");

fprintf(fo, "                                   \n");
fprintf(fo, "// read-address arbiter\n");
fprintf(fo, "localparam STAR_RUN = 'h0, STAR_WAIT = 'h1,\n");
fprintf(fo, "reg [NUM-1:0]  argrant_reg;\n");
fprintf(fo, "reg [1:0]      stateAR = STAR_RUN;\n\n");

fprintf(fo, "always @ (posedge AXI_CLK) begin\n");
fprintf(fo, "    if (!AXI_RSTn) begin\n");
fprintf(fo, "        argrant_reg <= 'h0;\n");
fprintf(fo, "        stateAR     <= STAR_RUN;\n");
fprintf(fo, "    end else begin\n");
fprintf(fo, "        case (stateAR)\n");
fprintf(fo, "            STAR_RUN: begin\n");
fprintf(fo, "                if (|ARGRANT) begin\n");
fprintf(fo, "                   // prevent the case that the granted-one is not completed due to ~ARREADY\n");
fprintf(fo, "                   // and new higher-priority-one joined, then things can go wrong.\n");
fprintf(fo, "                   if (~|(ARGRANT & ARREADY)) begin\n");
fprintf(fo, "                       argrant_reg <= ARGRANT;\n");
fprintf(fo, "                       stateAR     <= STAR_WAIT;\n");
fprintf(fo, "                   end\n");
fprintf(fo, "                end\n");
fprintf(fo, "            end // STAR_RUN\n");
fprintf(fo, "            STAR_WAIT: begin\n");
fprintf(fo, "                 if (|(ARGRANT & ARVALID & ARREADY)) begin\n");
fprintf(fo, "                     stateAR <= STAR_RUN;\n");
fprintf(fo, "                 end\n");
fprintf(fo, "            end // STAR_WAIT\n");
fprintf(fo, "        endcase\n");
fprintf(fo, "    end\n");
fprintf(fo, "end\n\n");

fprintf(fo, "wire [NUM_M-1:0] ARREQ;\n");
fprintf(fo, "wire [NUM_M-1:0] ar_sel;\n");
fprintf(fo, "assign ARREQ = ARSELECT & ARVALID;\n\n");

fprintf(fo, "rr_fixed_arbiter u_arbiter_ar(\n");
fprintf(fo, ".clk          (AXI_CLK      ),\n");
fprintf(fo, ".rst_n        (AXI_RSTn     ),\n");
fprintf(fo, ".arbiter_type (1'b1 /*arbiter_type*/ ),\n");
fprintf(fo, ".req          ({1'b0, ARREQ}),\n");
fprintf(fo, ".sel          (ar_sel       ) \n");
fprintf(fo, ");\n\n");

fprintf(fo, "assign ARGRANT = (stateAR == STAR_RUN) ? ar_sel : argrant_reg;\n\n");

fprintf(fo, "     //-----------------------------------------------------------\n");
fprintf(fo, "     // write-address arbiter\n");
fprintf(fo, "localparam STAW_RUN = 'h0, STAW_WAIT = 'h1,\n");
fprintf(fo, "reg [NUM-1:0]  awgrant_reg;\n");
fprintf(fo, "reg [1:0]      stateAW = STAW_RUN;\n\n");

fprintf(fo, "always @ (posedge AXI_CLK) begin\n");
fprintf(fo, "    if (!AXI_RSTn) begin\n");
fprintf(fo, "        awgrant_reg <= 'h0;\n");
fprintf(fo, "        stateAW     <= STAW_RUN;\n");
fprintf(fo, "    end else begin\n");
fprintf(fo, "        case (stateAW)\n");
fprintf(fo, "            STAW_RUN: begin\n");
fprintf(fo, "                if (|AWGRANT) begin\n");
fprintf(fo, "                   if (~|(AWGRANT & AWREADY)) begin\n");
fprintf(fo, "                       awgrant_reg <= AWGRANT;\n");
fprintf(fo, "                       stateAW     <= STAW_WAIT;\n");
fprintf(fo, "                   end\n");
fprintf(fo, "                end\n");
fprintf(fo, "            end // STAW_RUN\n");
fprintf(fo, "            STAW_WAIT: begin\n");
fprintf(fo, "                 if (|(AWGRANT & AWVALID & AWREADY)) begin\n");
fprintf(fo, "                     stateAW <= STAW_RUN;\n");
fprintf(fo, "                 end\n");
fprintf(fo, "            end // STAW_WAIT\n");
fprintf(fo, "        endcase\n");
fprintf(fo, "    end\n");
fprintf(fo, "end\n\n");

fprintf(fo, "wire [NUM_M-1:0] AWREQ;\n");
fprintf(fo, "wire [NUM_M-1:0] aw_sel;\n");
fprintf(fo, "assign AWREQ = AWSELECT & AWVALID;\n\n");

fprintf(fo, "rr_fixed_arbiter u_arbiter_aw(\n");
fprintf(fo, ".clk          (AXI_CLK      ),\n");
fprintf(fo, ".rst_n        (AXI_RSTn     ),\n");
fprintf(fo, ".arbiter_type (1'b1 /*arbiter_type*/ ),\n");
fprintf(fo, ".req          ({1'b0, AWREQ}),\n");
fprintf(fo, ".sel          (aw_sel       ) \n");
fprintf(fo, ");\n\n");

fprintf(fo, "assign AWGRANT = (stateAW == STAW_RUN) ? aw_sel : awgrant_reg;\n\n");

fprintf(fo, "     //-----------------------------------------------------------\n");
fprintf(fo, "     // write-data arbiter\n");
fprintf(fo, "localparam STW_RUN = 'h0, STW_WAIT = 'h1,\n");
fprintf(fo, "reg [NUM-1:0]  wgrant_reg;\n");
fprintf(fo, "reg [1:0]      stateW = STW_RUN;\n\n");

fprintf(fo, "always @ (posedge AXI_CLK) begin\n");
fprintf(fo, "    if (!AXI_RSTn) begin\n");
fprintf(fo, "        wgrant_reg <= 'h0;\n");
fprintf(fo, "        stateW     <= STW_RUN;\n");
fprintf(fo, "    end else begin\n");
fprintf(fo, "        case (stateW)\n");
fprintf(fo, "            STW_RUN: begin\n");
fprintf(fo, "                if (|WGRANT) begin\n");
fprintf(fo, "                   if (~|(WGRANT & WREADY)) begin\n");
fprintf(fo, "                       wgrant_reg <= WGRANT;\n");
fprintf(fo, "                       stateW     <= STW_WAIT;\n");
fprintf(fo, "                   end\n");
fprintf(fo, "                end\n");
fprintf(fo, "            end // STW_RUN\n");
fprintf(fo, "            STW_WAIT: begin\n");
fprintf(fo, "                 if (|(WGRANT & WVALID & WREADY)) begin\n");
fprintf(fo, "                     stateW <= STW_RUN;\n");
fprintf(fo, "                 end\n");
fprintf(fo, "            end // STW_WAIT\n");
fprintf(fo, "        endcase\n");
fprintf(fo, "    end\n");
fprintf(fo, "end\n\n");

fprintf(fo, "wire [NUM_M-1:0] WREQ;\n");
fprintf(fo, "wire [NUM_M-1:0] w_sel;\n");
fprintf(fo, "assign WREQ = WSELECT & WVALID;\n\n");

fprintf(fo, "rr_fixed_arbiter u_arbiter_w(\n");
fprintf(fo, ".clk          (AXI_CLK      ),\n");
fprintf(fo, ".rst_n        (AXI_RSTn     ),\n");
fprintf(fo, ".arbiter_type (1'b1 /*arbiter_type*/ ),\n");
fprintf(fo, ".req          ({1'b0, WREQ}),\n");
fprintf(fo, ".sel          (w_sel       ) \n");
fprintf(fo, ");\n\n");

fprintf(fo, "assign WGRANT = (stateW == STW_RUN) ? w_sel : wgrant_reg;\n\n");

fprintf(fo, "endmodule\n");

    return 0;
}