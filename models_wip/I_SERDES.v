//
// I_SERDES simulation model
//

module I_SERDES #(
    parameter DATA_RATE = "SDR" ,
    parameter WIDTH = "4" ,
    parameter DPA_MODE = "NONE"
    ) (
    input D ,
    input RST ,
    input FIFO_RST ,
    input BITSLIP_ADJ ,
    input EN ,
    input CLK_IN ,
    output CLK_OUT ,
    output Q[WIDTH-1:0] ,
    output DATA_VALID ,
    output DPA_LOCK ,
    output DPA_ERROR ,
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
    assert((DPA_MODE == "NONE") ||
           (DPA_MODE == "DPA") ||
           (DPA_MODE == "CDR"))
    else $error\("DPA_MODE parameter value invalid.  Valid values are NONE, DPA, CDR.")

  end

endmodule
