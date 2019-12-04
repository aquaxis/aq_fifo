`timescale 1ns / 1ps

module tb_sample_fifo_rtl;

  reg RST;
  reg WRCLK, RDCLK;

  localparam CLK100M = 10;
  localparam CLK200M = 5;

  // Clock
  always  begin
	  #(CLK100M/2) WRCLK <= ~WRCLK;
  end

  always  begin
	  #(CLK200M/2) RDCLK <= ~RDCLK;
  end

  initial begin
    #0;
    RST = 1;
    WRCLK = 0;
    RDCLK = 0;

    #100;
    RST = 0;
  end

  reg         WREN;
  wire        AFULL, FULL;
  reg [63:0]  DIN;

  reg RDEN;
  wire        AEMPTY, EMPTY;
  wire [63:0] DOUT;

  integer i;

  initial begin
    #0;
    WREN = 0;
    RDEN = 0;

    wait(!RST);
    @(posedge WRCLK);

    for(i=0;i<512;i=i+1) begin
      WREN = 1;
      DIN  = 64'hFEDCBA98_76543210 + i;
      @(posedge WRCLK);
    end
    WREN = 0;
    DIN  = 64'd0;
    @(posedge WRCLK);

  end

  sample_fifo_rtl
  #(
    .FIFO_DEPTH       (  9      ),
    .FIFO_WIDTH       ( 65      )
  )
  u_sample_fifo_rtl
  (
    .RST_N             ( ~RST    ),

    .FIFO_WR_CLK       ( WRCLK   ),
    .FIFO_WR_ENA       ( WREN    ),
    .FIFO_WR_DATA      ( DIN     ),
    .FIFO_WR_LAST      ( 1'b1    ),
    .FIFO_WR_FULL      ( FULL    ),
    .FIFO_WR_ALM_FULL  ( AFULL   ),
    .FIFO_WR_ALM_COUNT ( 13'd128 ),

    .FIFO_RD_CLK       ( RDCLK   ),
    .FIFO_RD_ENA       ( RDEN    ),
    .FIFO_RD_DATA      ( DOUT    ),
    .FIFO_RD_EMPTY     ( EMPTY   ),
    .FIFO_RD_ALM_EMPTY ( AEMPTY  ),
    .FIFO_RD_ALM_COUNT ( 13'd256 )
  );

endmodule
