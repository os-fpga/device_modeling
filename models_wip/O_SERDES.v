//
// O_SERDES simulation model
//

module O_SERDES #(
    parameter DATA_RATE = "SDR" ,
    parameter WIDTH = "4" ,
    parameter CLOCK_PHASE = "0"
    ) (
    input D[WIDTH-1:0] ,
    input RST ,
    input LOAD_WORD ,
    input OE ,
    input CLK_EN ,
    input CLK_IN ,
    output CLK_OUT ,
    output Q ,
    input CHANNEL_BOND_SYNC_IN ,
    output CHANNEL_BOND_SYNC_OUT ,
    input PLL_LOCK ,
    input PLL_FAST_CLK
  ) ;

//
// include user code here
//
  initial begin
    assert((DATA_RATE == "SDR") ||
           (DATA_RATE == "DDR"))
    else $error\("DATA_RATE parameter value invalid.  Valid values are SDR, DDR.")
    assert((WIDTH == "3") ||
           (WIDTH == "4") ||
           (WIDTH == "6") ||
           (WIDTH == "7") ||
           (WIDTH == "8") ||
           (WIDTH == "9") ||
           (WIDTH == "10"))
    else $error\("WIDTH parameter value invalid.  Valid values are 3, 4, 6, 7, 8, 9, 10.")
    assert((CLOCK_PHASE == "0") ||
           (CLOCK_PHASE == "90") ||
           (CLOCK_PHASE == "180") ||
           (CLOCK_PHASE == "270"))
    else $error\("CLOCK_PHASE parameter value invalid.  Valid values are 0, 90, 180, 270.")

  end

endmodule
