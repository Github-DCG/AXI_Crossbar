
#include <stdio.h>

int gen_axi_arbiter_s2m( unsigned int num // num of slave
                        , char *prefix
                        , FILE *fo)
{
    int i, j;

    if ((num<2)||(prefix==NULL)) return 1;


fprintf(fo, "\n");
fprintf(fo, "module %saxi_arbiter_s2m_m%d\n", prefix, num);
fprintf(fo, "     #(parameter W_CID = 6  // Channel ID width in bits\n");
fprintf(fo, "               , W_ID  = 6  // Transaction ID\n");
fprintf(fo, "               , W_SID = (W_CID+W_ID)\n");
fprintf(fo, "               , NUM   = %d // num of masters\n", num);
fprintf(fo, "               )\n");
fprintf(fo, "(\n");
fprintf(fo, "       input  wire                  AXI_RSTn\n");
fprintf(fo, "     , input  wire                  AXI_CLK\n");
fprintf(fo, "     \n");
fprintf(fo, "     , input  wire  [NUM:0]         BSELECT  \n");
fprintf(fo, "     , input  wire  [NUM:0]         BVALID\n");
fprintf(fo, "     , input  wire  [NUM:0]         BREADY\n");
fprintf(fo, "     , output wire  [NUM:0]         BGRANT\n");

fprintf(fo, "     \n");
fprintf(fo, "     , input  wire  [NUM-1:0]       RSELECT\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       RVALID\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       RREADY\n");
fprintf(fo, "     , input  wire  [NUM-1:0]       RLAST\n");
fprintf(fo, "     , output reg   [NUM-1:0]       RGRANT\n");

fprintf(fo, "     \n");
// fprintf(fo, "     , input  wire                  arbiter_type\n");
fprintf(fo, ");\n");

fprintf(fo, "                                   \n");
fprintf(fo, "// read-data arbiter\n");
fprintf(fo, "localparam STR_RUN = 'h0, STR_WAIT = 'h1,\n");
fprintf(fo, "reg [NUM-1:0]  rgrant_reg;\n");
fprintf(fo, "reg [1:0]      stateR = STR_RUN;\n\n");

fprintf(fo, "always @ (posedge AXI_CLK) begin\n");
fprintf(fo, "    if (!AXI_RSTn) begin\n");
fprintf(fo, "        rgrant_reg <= 'h0;\n");
fprintf(fo, "        stateR     <= STR_RUN;\n");
fprintf(fo, "    end else begin\n");
fprintf(fo, "        case (stateR)\n");
fprintf(fo, "            STR_RUN: begin\n");
fprintf(fo, "                if (|RGRANT) begin\n");
fprintf(fo, "                   if (~|(RGRANT & RREADY)) begin\n");
fprintf(fo, "                       rgrant_reg <= RGRANT;\n");
fprintf(fo, "                       stateR     <= STR_WAIT;\n");
fprintf(fo, "                   end\n");
fprintf(fo, "                end\n");
fprintf(fo, "            end // STR_RUN\n");
fprintf(fo, "            STR_WAIT: begin\n");
fprintf(fo, "                 if (|(RGRANT & RVALID & RREADY)) begin\n");
fprintf(fo, "                     stateR <= STR_RUN;\n");
fprintf(fo, "                 end\n");
fprintf(fo, "            end // STR_WAIT\n");
fprintf(fo, "        endcase\n");
fprintf(fo, "    end\n");
fprintf(fo, "end\n\n");

fprintf(fo, "wire [NUM_S-1:0] RREQ;\n");
fprintf(fo, "wire [NUM_S-1:0] r_sel;\n");
fprintf(fo, "assign RREQ = RSELECT & RVALID;\n\n");

fprintf(fo, "rr_fixed_arbiter u_arbiter_r(\n");
fprintf(fo, ".clk          (AXI_CLK      ),\n");
fprintf(fo, ".rst_n        (AXI_RSTn     ),\n");
fprintf(fo, ".arbiter_type (1'b1 /*arbiter_type*/ ),\n");
fprintf(fo, ".req          ({1'b0, RREQ}),\n");
fprintf(fo, ".sel          (r_sel       ) \n");
fprintf(fo, ");\n\n");

fprintf(fo, "assign RGRANT = (stateR == STR_RUN) ? r_sel : rgrant_reg;\n\n");

fprintf(fo, "// write-response arbiter\n");
fprintf(fo, "localparam STB_RUN = 'h0, STB_WAIT = 'h1,\n");
fprintf(fo, "reg [NUM-1:0]  bgrant_reg;\n");
fprintf(fo, "reg [1:0]      stateB = STB_RUN;\n\n");

fprintf(fo, "always @ (posedge AXI_CLK) begin\n");
fprintf(fo, "    if (!AXI_RSTn) begin\n");
fprintf(fo, "        stateB     <= STB_RUN;\n");
fprintf(fo, "    end else begin\n");
fprintf(fo, "        case (stateB)\n");
fprintf(fo, "            STB_RUN: begin\n");
fprintf(fo, "                if (|BGRANT) begin\n");
fprintf(fo, "                   if (~|(BGRANT & BREADY)) begin\n");
fprintf(fo, "                       bgrant_reg <= BGRANT;\n");
fprintf(fo, "                       stateB     <= STB_WAIT;\n");
fprintf(fo, "                   end\n");
fprintf(fo, "                end\n");
fprintf(fo, "            end // STB_RUN\n");
fprintf(fo, "            STB_WAIT: begin\n");
fprintf(fo, "                 if (|(BGRANT & BVALID & BREADY)) begin\n");
fprintf(fo, "                     stateB <= STB_RUN;\n");
fprintf(fo, "                 end\n");
fprintf(fo, "            end // STB_WAIT\n");
fprintf(fo, "        endcase\n");
fprintf(fo, "    end\n");
fprintf(fo, "end\n\n");

fprintf(fo, "wire [NUM_S-1:0] BREQ;\n");
fprintf(fo, "wire [NUM_S-1:0] b_sel;\n");
fprintf(fo, "assign BREQ = BSELECT & BVALID;\n\n");

fprintf(fo, "rr_fixed_arbiter u_arbiter_b(\n");
fprintf(fo, ".clk          (AXI_CLK      ),\n");
fprintf(fo, ".rst_n        (AXI_RSTn     ),\n");
fprintf(fo, ".arbiter_type (1'b1 /*arbiter_type*/ ),\n");
fprintf(fo, ".req          ({1'b0, BREQ}),\n");
fprintf(fo, ".sel          (b_sel       ) \n");
fprintf(fo, ");\n\n");

fprintf(fo, "assign BGRANT = (stateB == STB_RUN) ? b_sel : bgrant_reg;\n\n");

fprintf(fo, "endmodule\n");
fprintf(fo, "//---------------------------------------------------------------------------\n");
    return 0;
}