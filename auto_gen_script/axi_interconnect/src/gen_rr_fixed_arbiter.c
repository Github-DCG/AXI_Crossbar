#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

static char *code[] = {
"module rr_fixed_arbiter #( " 
,"    parameter NUM = 4  // 参数化位宽,默认为4 " 
,")( " 
,"    input                   clk         , " 
,"    input                   rst_n       , " 
,"    input                   arbiter_type, // 0: Round Robin, 1: Fixed Priority " 
,"    input      [NUM-1:0]    req         , // 请求信号 " 
,"    output reg [NUM-1:0]    sel           // 选择信号 " 
,"); " 

,"wire          rr_vld       ;      " 
,"reg [NUM-1:0] last_winner   ;      " 
,"reg [NUM-1:0] curr_winner   ;      " 

,"assign rr_vld = |req;   // 产生调度使能信号  " 

,"always @ (posedge clk) begin  " 
,"    if (!rst_n)  " 
,"        last_winner <= {NUM{1'b0}};  " 
,"    else if (rr_vld)   " 
,"        last_winner <= curr_winner;           // 记录上一次调度的队列  " 
,"end  " 

,"// 0: Round Robin  " 
,"always @ (*) begin  " 
,"    integer i; " 
,"    curr_winner = {NUM{1'b0}}; // 默认当前胜者为0 " 
,"    if (last_winner == {NUM{1'b0}}) begin " 
,"        for (i = 0; i < NUM; i = i + 1) begin " 
,"            if (req[i]) begin " 
,"                curr_winner = (1 << i); " 
,"                break; " 
,"            end " 
,"        end " 
,"    end else begin " 
,"        for (i = 0; i < NUM; i = i + 1) begin " 
,"            if (req[(i + 1) % NUM]) begin " 
,"                curr_winner = (1 << ((i + 1) % NUM)); " 
,"                break; " 
,"            end " 
,"        end " 
,"    end " 
,"end " 

,"// 1: Fixed Priority " 
,"function [NUM-1:0] priority_sel; " 
,"     input    [NUM-1:0] request; " 
,"     begin " 
,"          integer i; " 
,"          priority_sel = {NUM{1'b0}}; " 
,"          for (i = NUM-1; i >= 0; i = i - 1) begin " 
,"               if (request[i]) begin " 
,"                    priority_sel = (1 << i); " 
,"                    break; " 
,"               end " 
,"          end " 
,"     end " 
,"endfunction " 

,"always @ (*) begin " 
,"    sel = arbiter_type ? priority_sel(req) : curr_winner; " 
,"end " 

,"endmodule " 
, NULL
};

int gen_rr_fixed_arbiter( char* prefix, FILE* fo )
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
