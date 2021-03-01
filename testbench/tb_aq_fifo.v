`timescale 1ns / 1ps

module tb_aq_fifo;

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

  integer i, k;

  integer write_end;

  initial begin
    #0;
    WREN = 0;

    write_end = 0;

    wait(!RST);

    @(negedge WRCLK);
    @(negedge WRCLK);
    @(negedge WRCLK);
    @(negedge WRCLK);
    @(negedge WRCLK);

    for(i=0;i<520;i=i+1) begin
      WREN = 1;
      DIN  = 64'hFEDCBA98_00000000 + i;
      @(negedge WRCLK);
    end

    WREN = 0;
    DIN  = 64'd0;
    @(negedge WRCLK);

    write_end = 1;

  end

  initial begin
    #0;
    RDEN = 0;

    wait(!RST);

    @(negedge RDCLK);

    wait(write_end);

    @(negedge RDCLK);

    for(k=0;k<520;k=k+1) begin
      RDEN = 1;
      if(!EMPTY && (DOUT != (64'hFEDCBA98_00000000 + k))) $display("ERROR: %16h:%16h", 64'hFEDCBA98_00000000 + k, DOUT);
      @(negedge RDCLK);
    end

    RDEN = 0;
    @(negedge RDCLK);

    @(negedge RDCLK);
    @(negedge RDCLK);
    @(negedge RDCLK);
    @(negedge RDCLK);
    @(negedge RDCLK);
    @(negedge RDCLK);
    @(negedge RDCLK);
    @(negedge RDCLK);
    @(negedge RDCLK);
    @(negedge RDCLK);

    $finish();

  end

  aq_axis_fifo
  #(
    .FIFO_DEPTH       (  9      ),
    .FIFO_WIDTH       ( 64      )
  )
  u_aq_axis_fifo
  (
    .RST_N             ( ~RST    ),

    .S_AXIS_ACLK       ( WRCLK   ),
    .S_AXIS_TVALID     ( WREN    ),
    .S_AXIS_TREADY     (),
    .S_AXIS_TLAST      ( 1'b1    ),
    .S_AXIS_TDATA      ( DIN     ),

    .FIFO_WR_FULL      ( FULL    ),
    .FIFO_WR_ALM_FULL  ( AFULL   ),
    .FIFO_WR_ALM_COUNT ( 13'd128 ),

    .M_AXIS_ACLK       ( RDCLK   ),
    .M_AXIS_TVALID     (),
    .M_AXIS_TREADY     ( RDEN    ),
    .M_AXIS_TDATA      ( DOUT    ),

    .FIFO_RD_EMPTY     ( EMPTY   ),
    .FIFO_RD_ALM_EMPTY ( AEMPTY  ),
    .FIFO_RD_ALM_COUNT ( 13'd256 )
  );

endmodule
