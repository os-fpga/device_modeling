//
// PLL simulation model
//

module PLL #(
    parameter DIVIDE_CLK_IN_BY_2 = "FALSE" ,
    parameter PLL_MULT = "16" ,
    parameter PLL_DIV = "1" ,
    parameter CLK_OUT0_DIV = "2" ,
    parameter CLK_OUT1_DIV = "2" ,
    parameter CLK_OUT2_DIV = "2" ,
    parameter CLK_OUT3DIV = "2"
    ) (
    input PLL_EN ,
    input CLK_IN ,
    input CLK_OUT0_EN ,
    input CLK_OUT1_EN ,
    input CLK_OUT2_EN ,
    input CLK_OUT3_EN ,
    output CLK_OUT0 ,
    output CLK_OUT1 ,
    output CLK_OUT2 ,
    output CLK_OUT3 ,
    output GEARBOX_FAST_CLK ,
    output LOCK
  ) ;

//
// include user code here
//
  initial begin
    assert((DIVIDE_CLK_IN_BY_2 == "TRUE") ||
           (DIVIDE_CLK_IN_BY_2 == "FALSE"))
    else $error\("DIVIDE_CLK_IN_BY_2 parameter value invalid.  Valid values are TRUE, FALSE.")
    assert((CLK_OUT0_DIV == "2") ||
           (CLK_OUT0_DIV == "3") ||
           (CLK_OUT0_DIV == "4") ||
           (CLK_OUT0_DIV == "5") ||
           (CLK_OUT0_DIV == "6") ||
           (CLK_OUT0_DIV == "8") ||
           (CLK_OUT0_DIV == "10") ||
           (CLK_OUT0_DIV == "12") ||
           (CLK_OUT0_DIV == "16") ||
           (CLK_OUT0_DIV == "20") ||
           (CLK_OUT0_DIV == "24") ||
           (CLK_OUT0_DIV == "32") ||
           (CLK_OUT0_DIV == "40") ||
           (CLK_OUT0_DIV == "48") ||
           (CLK_OUT0_DIV == "64"))
    else $error\("CLK_OUT0_DIV parameter value invalid.  Valid values are 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64.")
    assert((CLK_OUT1_DIV == "2") ||
           (CLK_OUT1_DIV == "3") ||
           (CLK_OUT1_DIV == "4") ||
           (CLK_OUT1_DIV == "5") ||
           (CLK_OUT1_DIV == "6") ||
           (CLK_OUT1_DIV == "8") ||
           (CLK_OUT1_DIV == "10") ||
           (CLK_OUT1_DIV == "12") ||
           (CLK_OUT1_DIV == "16") ||
           (CLK_OUT1_DIV == "20") ||
           (CLK_OUT1_DIV == "24") ||
           (CLK_OUT1_DIV == "32") ||
           (CLK_OUT1_DIV == "40") ||
           (CLK_OUT1_DIV == "48") ||
           (CLK_OUT1_DIV == "64"))
    else $error\("CLK_OUT1_DIV parameter value invalid.  Valid values are 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64.")
    assert((CLK_OUT2_DIV == "2") ||
           (CLK_OUT2_DIV == "3") ||
           (CLK_OUT2_DIV == "4") ||
           (CLK_OUT2_DIV == "5") ||
           (CLK_OUT2_DIV == "6") ||
           (CLK_OUT2_DIV == "8") ||
           (CLK_OUT2_DIV == "10") ||
           (CLK_OUT2_DIV == "12") ||
           (CLK_OUT2_DIV == "16") ||
           (CLK_OUT2_DIV == "20") ||
           (CLK_OUT2_DIV == "24") ||
           (CLK_OUT2_DIV == "32") ||
           (CLK_OUT2_DIV == "40") ||
           (CLK_OUT2_DIV == "48") ||
           (CLK_OUT2_DIV == "64"))
    else $error\("CLK_OUT2_DIV parameter value invalid.  Valid values are 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64.")
    assert((CLK_OUT3DIV == "2") ||
           (CLK_OUT3DIV == "3") ||
           (CLK_OUT3DIV == "4") ||
           (CLK_OUT3DIV == "5") ||
           (CLK_OUT3DIV == "6") ||
           (CLK_OUT3DIV == "8") ||
           (CLK_OUT3DIV == "10") ||
           (CLK_OUT3DIV == "12") ||
           (CLK_OUT3DIV == "16") ||
           (CLK_OUT3DIV == "20") ||
           (CLK_OUT3DIV == "24") ||
           (CLK_OUT3DIV == "32") ||
           (CLK_OUT3DIV == "40") ||
           (CLK_OUT3DIV == "48") ||
           (CLK_OUT3DIV == "64"))
    else $error\("CLK_OUT3DIV parameter value invalid.  Valid values are 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64.")

  end

endmodule
