`timescale 1ns / 1ps

module tb_FIFO36E2;

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

  reg         SLEEP;
  wire        WRRSTBUSY, RDRSTBUSY;

  reg         WREN;
  wire [13:0] WRCOUNT;
  wire        PROGFULL, FULL;
  reg [63:0]  DIN;

  reg RDEN;
  wire [13:0] RDCOUNT;
  wire        PROGEMPTY, EMPTY;
  wire [63:0] DOUT;

  integer i;

  initial begin
    #0;
    SLEEP = 0;
    WREN = 0;
    RDEN = 0;

    wait(!RST);
    wait(!RDRSTBUSY);
    wait(!WRRSTBUSY);
    @(negedge WRCLK);

    for(i=0;i<512;i=i+1) begin
      WREN = 1;
      DIN  = 64'hFEDCBA98_76543210 + i;
      @(negedge WRCLK);
    end
    WREN = 0;
    DIN  = 64'd0;
    @(negedge WRCLK);

  end

  FIFO36E2
  #(
    .PROG_EMPTY_THRESH        ( 13'd128      ),
    .PROG_FULL_THRESH         ( 13'd256      ),
    .WRITE_WIDTH              (72),
    .READ_WIDTH               (72),
    .REGISTER_MODE            ("UNREGISTERED"),
    .CLOCK_DOMAINS            ("INDEPENDENT"),
    .FIRST_WORD_FALL_THROUGH  ("TRUE"),
    .INIT                     (72'd0),
    .SRVAL                    (72'd0),
    .WRCOUNT_TYPE             ("SIMPLE_DATACOUNT"),
    .RDCOUNT_TYPE             ("SIMPLE_DATACOUNT"),
    .RSTREG_PRIORITY          ("RSTREG"),
    .CASCADE_ORDER            ("NONE")
  )
  u_FIFO(
    .RST            ( RST           ),

    // Control
    .SLEEP          ( SLEEP         ),
    .RDRSTBUSY      ( RDRSTBUSY     ),
    .WRRSTBUSY      ( WRRSTBUSY     ),

    // Write
    .WRCLK          ( WRCLK         ),
    .WREN           ( WREN          ),
    .WRERR          (),
    .WRCOUNT        ( WRCOUNT[13:0] ),
    .PROGFULL       ( PROGFULL      ),
    .FULL           ( FULL          ),
    .DIN            ( DIN[63:0]     ),
    .DINP           ( 8'h00         ),

    // Read
    .RDCLK          ( RDCLK         ),
    .RDEN           ( RDEN          ),
    .RDCOUNT        ( RDCOUNT       ),
    .RDERR          (),
    .EMPTY          ( EMPTY         ),
    .PROGEMPTY      ( PROGEMPTY     ),
    .DOUT           ( DOUT[63:0]    ),
    .DOUTP          (),

    .REGCE          ( 1'b1          ),
    .RSTREG         ( RST           ),

    // Cascade
    .CASDIN         (),
    .CASDINP        (),
    .CASDOUT        (),
    .CASDOUTP       (),
    .CASPRVEMPTY    (),
    .CASPRVRDEN     (),
    .CASNXTRDEN     (),
    .CASNXTEMPTY    (),
    .CASOREGIMUX    (),
    .CASOREGIMUXEN  (),
    .CASDOMUX       (),
    .CASDOMUXEN     ()
  );

endmodule
