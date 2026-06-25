//---------------------------------------------------------------------------
module axi_arbiter_stom_s3
#(parameter NUM=3)
(
  input  wire           ARESETn
, input  wire           ACLK

, input  wire  [NUM:0]  BSELECT  // selected by comparing trans_id
, input  wire  [NUM:0]  BVALID
, input  wire  [NUM:0]  BREADY
, output wire  [NUM:0]  BGRANT

, input  wire  [NUM:0]  RSELECT  // selected by comparing trans_id
, input  wire  [NUM:0]  RVALID
, input  wire  [NUM:0]  RREADY
, input  wire  [NUM:0]  RLAST
, output wire  [NUM:0]  RGRANT
);

//-----------------------------------------------------------
// read-data arbiter
//-----------------------------------------------------------
//-----------------------------------------------------------
localparam  STR_RUN = 'h0, STR_WAIT= 'h1;
reg [NUM:0] rgrant_reg;
reg         stateR = STR_RUN;

always @ (posedge ACLK or negedge ARESETn) begin
      if (ARESETn == 1'b0) begin
          rgrant_reg  <= 'h0;
          stateR      <= STR_RUN;
      end else begin
          case (stateR)
          STR_RUN: begin
               if (|RGRANT) begin
                  if (~|(RGRANT & RREADY/* & RLAST*/)) begin
                      rgrant_reg <= RGRANT;
                      stateR     <= STR_WAIT;
                  end
               end
               end // STR_RUN
          STR_WAIT: begin
               if (|(RGRANT & RVALID & RREADY/* & RLAST*/)) begin
                   rgrant_reg <= 'h0;
                   stateR     <= STR_RUN;
               end
               end // STR_WAIT
          endcase
      end
end

wire [3:0] RREQ;
wire [3:0] r_sel;
assign RREQ = RSELECT & RVALID;

round_robin_s2m u_arbiter_r(
.clk    (ACLK   ),
.rst_n  (ARESETn),
.req    (RREQ  ),
.sel    (r_sel ) 
);

assign RGRANT = (stateR==STR_RUN) ? r_sel : rgrant_reg;

//-----------------------------------------------------------
// write-response arbiter
//-----------------------------------------------------------
localparam  STB_RUN = 'h0, STB_WAIT = 'h1;
reg [NUM:0] bgrant_reg;
reg         stateB = STB_RUN;

always @ (posedge ACLK or negedge ARESETn) begin
      if (ARESETn==1'b0) begin
          bgrant_reg  <= 'h0;
          stateB      <= STB_RUN;
      end else begin
          case (stateB)
          STB_RUN: begin
               if (|BGRANT) begin
                  if (~|(BGRANT&BREADY)) begin
                      bgrant_reg <= BGRANT;
                      stateB     <= STB_WAIT;
                  end
               end
               end // STB_RUN
          STB_WAIT: begin
               if (|(BGRANT&BVALID&BREADY)) begin
                   bgrant_reg <= 'h0;
                   stateB     <= STB_RUN;
               end
               end // STB_WAIT
          endcase
      end
end

wire [3:0] BREQ;
wire [3:0] b_sel;
assign BREQ = BSELECT & BVALID;

round_robin_s2m u_arbiter_b(
.clk    (ACLK   ),
.rst_n  (ARESETn),
.req    (BREQ  ),
.sel    (b_sel ) 
);

assign BGRANT = (stateB==STB_RUN) ? b_sel : bgrant_reg;

endmodule