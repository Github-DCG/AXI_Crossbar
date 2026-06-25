
interface axi_intf #(
    int WIDTH = 32,
    SIZE = 3
) (
    input bit clk,
    reset
);
 // From Master
  logic M_AWREADY                   [0:2];
  logic M_AWVALID                   [0:2];
  logic [SIZE-2:0] M_AWBURST        [0:2];
  logic [SIZE-1:0] M_AWSIZE         [0:2];
  logic [7:0]      M_AWLEN          [0:2];
  logic [WIDTH-1:0] M_AWADDR        [0:2];
  logic [(WIDTH/8)-1:0] M_AWID      [0:2];

  int que_WLEN[$];

  // DATA WRITE CHANNEL
  logic M_WREADY                    [0:2];
  logic M_WVALID                    [0:2];
  logic M_WLAST                     [0:2];
  logic [(WIDTH/8)-1:0] M_WSTRB     [0:2];
  logic [WIDTH-1:0] M_WDATA         [0:2];
  logic	[(WIDTH/8)-1:0]	M_WID       [0:2];

  // WRITE RESPONSE CHANNEL
  logic [(WIDTH/8)-1:0] M_BID       [0:2];
  logic [SIZE-2:0] M_BRESP          [0:2];
  logic M_BVALID                    [0:2];
  logic M_BREADY                    [0:2];

  // READ ADDRESS CHANNEL
  logic M_ARVALID                   [0:2];
  logic M_ARREADY                   [0:2];
  logic [(WIDTH/8)-1:0] M_ARID      [0:2];
  logic [WIDTH-1:0] M_ARADDR        [0:2];
  logic [7:0] M_ARLEN               [0:2];
  logic [SIZE-1:0] M_ARSIZE         [0:2];
  logic [SIZE-2:0] M_ARBURST        [0:2];

  // READ DATA CHANNEL
  logic [(WIDTH/8)-1:0] M_RID       [0:2];
  logic [WIDTH-1:0] M_RDATA         [0:2];
  logic [SIZE-2:0] M_RRESP          [0:2];
  logic M_RLAST                     [0:2];
  logic M_RVALID                    [0:2];
  logic M_RREADY                    [0:2];
  
  bit                has_checks = 1;
  

  // From Slave
  logic S_AWREADY                   [0:2];
  logic S_AWVALID                   [0:2];
  logic [SIZE-2:0] S_AWBURST        [0:2];
  logic [SIZE-1:0] S_AWSIZE         [0:2];
  logic [7:0]      S_AWLEN          [0:2];
  logic [WIDTH-1:0] S_AWADDR        [0:2];
  logic [(WIDTH/4)-1:0] S_AWID      [0:2];


  // DATA WRITE CHANNEL
  logic S_WREADY                    [0:2];
  logic S_WVALID                    [0:2];
  logic S_WLAST                     [0:2];
  logic [(WIDTH/8)-1:0] S_WSTRB     [0:2];
  logic [WIDTH-1:0] S_WDATA         [0:2];
  logic	[(WIDTH/4)-1:0]	S_WID       [0:2];

  // WRITE RESPONSE CHANNEL
  logic [(WIDTH/4)-1:0] S_BID       [0:2];
  logic [SIZE-2:0] S_BRESP          [0:2] ;
  logic S_BVALID                    [0:2];
  logic S_BREADY                    [0:2];

  // READ ADDRESS CHANNEL
  logic S_ARVALID                   [0:2];
  logic S_ARREADY                   [0:2];
  logic [(WIDTH/4)-1:0] S_ARID      [0:2];
  logic [WIDTH-1:0] S_ARADDR        [0:2];
  logic [7:0] S_ARLEN               [0:2];
  logic [SIZE-1:0] S_ARSIZE         [0:2];
  logic [SIZE-2:0] S_ARBURST        [0:2];

  // READ DATA CHANNEL
  logic [(WIDTH/4)-1:0] S_RID       [0:2];
  logic [WIDTH-1:0] S_RDATA         [0:2];
  logic [SIZE-2:0] S_RRESP          [0:2];
  logic S_RLAST                     [0:2];
  logic S_RVALID                    [0:2];
  logic S_RREADY                    [0:2];
  
endinterface


