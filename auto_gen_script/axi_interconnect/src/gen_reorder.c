#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

static char *code[] = {
 "module reorder "
," (parameter NUM_SID = 3)"
," ("
,"    input            clk        ,"
,"    input            rstn       ,"
,"    "
,"    input [12-1:0]   sid       [NUM_SID-1:0],"
,"    input            sid_vld   [NUM_SID-1:0],"
,"    "
,"    input wire [12-1:0] rob_buffer [0:3] ,"
,"    "
,"    output reg [NUM_SID-1:0] order_grant   "
,");"
," "
,"genvar i, j;"
,"wire [6-1:0] rid_low  [NUM_SID-1:0];"
,"wire [6-1:0] rid_high [NUM_SID-1:0];"
,""
,"generate"
,"    for (i = 0; i < NUM_SID; i++) begin : RID_GEN"
,"        assign rid_low[i][0] = (sid_vld[i] && sid[i][3:0] == rob_buffer[0][3:0]) ? 1'b1 : 1'b0;"
,"        assign rid_low[i][1] = (sid_vld[i] && sid[i][3:0] == rob_buffer[1][3:0]) ? 1'b1 : 1'b0;"
,"        assign rid_low[i][2] = (sid_vld[i] && sid[i][3:0] == rob_buffer[2][3:0]) ? 1'b1 : 1'b0;"
,"        assign rid_low[i][3] = (sid_vld[i] && sid[i][3:0] == rob_buffer[3][3:0]) ? 1'b1 : 1'b0;"
,"        assign rid_low[i][4] = (sid_vld[i] && sid[i][3:0] == rob_buffer[4][3:0]) ? 1'b1 : 1'b0;"
,"        assign rid_low[i][5] = (sid_vld[i] && sid[i][3:0] == rob_buffer[5][3:0]) ? 1'b1 : 1'b0;"
,""
,"        assign rid_high[i][0] = (sid_vld[i] && sid[i][7:4] == rob_buffer[0][7:4]) ? 1'b1 : 1'b0;"
,"        assign rid_high[i][1] = (sid_vld[i] && sid[i][7:4] == rob_buffer[1][7:4]) ? 1'b1 : 1'b0;"
,"        assign rid_high[i][2] = (sid_vld[i] && sid[i][7:4] == rob_buffer[2][7:4]) ? 1'b1 : 1'b0;"
,"        assign rid_high[i][3] = (sid_vld[i] && sid[i][7:4] == rob_buffer[3][7:4]) ? 1'b1 : 1'b0;"
,"        assign rid_high[i][4] = (sid_vld[i] && sid[i][7:4] == rob_buffer[4][7:4]) ? 1'b1 : 1'b0;"
,"        assign rid_high[i][5] = (sid_vld[i] && sid[i][7:4] == rob_buffer[5][7:4]) ? 1'b1 : 1'b0;"
,"    end"
,"endgenerate"
,""
,"generate"
,"    for (i = 0; i < NUM_SID; i++) begin : RID_GEN"
,"        always @(posedge clk) begin"
,"            if (!rstn) begin"
,"                order_grant[i] <= 'd0;"
,"            end else begin"
,"                if (rid_high[i][0] && rid_low[i][0])"
,"                    order_grant[i] <= 1'b1;"
,"                else if (rid_high[i][1:0] == 2'b10 && rid_low[i][1:0] == 2'b10)"
,"                    order_grant[i] <= 1'b1;"
,"                else if (rid_high[i][2:0] == 3'b100 && rid_low[i][2:0] == 3'b100)"
,"                    order_grant[i] <= 1'b1;"
,"                else if (rid_high[i][3:0] == 4'b1000 && rid_low[i][3:0] == 4'b1000)"
,"                    order_grant[i] <= 1'b1;"
,"                else if (rid_high[i][4:0] == 5'b10000 && rid_low[i][4:0] == 5'b10000)"
,"                    order_grant[i] <= 1'b1;"
,"                else if (rid_high[i][5:0] == 6'b100000 && rid_low[i][5:0] == 6'b100000)"
,"                    order_grant[i] <= 1'b1;"
,"                else"
,"                    order_grant[i] <= 1'b0;"
,"            end"
,"        end"
,"    end"
,"endgenerate"
,""
,"endmodule"
, NULL
};

int gen_reorder( char* prefix, FILE* fo )
{
    int i=0;

    if (prefix==NULL) return 1;

    while (code[i] != NULL) {
         fprintf(fo, "%s\n", code[i]);
         i++;
    }
    fprintf(fo, "\n");
    return 0;
}
