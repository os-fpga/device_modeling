//
// I_BUF simulation model
//

module I_BUF #(
    parameter WEAK_KEEPER = "NONE"
`ifdef RS_ENG
    ,parameter IOSTANDARD = "DEFAULT"
`endif // RS_ENG
    ) (
    input I ,
    input EN ,
    output O
  ) ;

//
// include user code here
//
  initial begin
    assert((WEAK_KEEPER == "NONE") ||
           (WEAK_KEEPER == "PULLUP") ||
           (WEAK_KEEPER == "PULLDOWN"))
    else $error\("WEAK_KEEPER parameter value invalid.  Valid values are NONE, PULLUP, PULLDOWN.")

`ifdef RS_ENG

    assert((IOSTANDARD == "DEFAULT") ||
           (IOSTANDARD == "LVCMOS_12") ||
           (IOSTANDARD == "LVCMOS_15") ||
           (IOSTANDARD == "LVCMOS_18_HP") ||
           (IOSTANDARD == "LVCMOS_18_HR") ||
           (IOSTANDARD == "LVCMOS_25") ||
           (IOSTANDARD == "LVCMOS_33") ||
           (IOSTANDARD == "LVTTL") ||
           (IOSTANDARD == "HSTL_I_12") ||
           (IOSTANDARD == "HSTL_II_12") ||
           (IOSTANDARD == "HSTL_I_15") ||
           (IOSTANDARD == "HSTL_II_15") ||
           (IOSTANDARD == "HSUL_12") ||
           (IOSTANDARD == "PCI66") ||
           (IOSTANDARD == "PCIX133") ||
           (IOSTANDARD == "POD_12") ||
           (IOSTANDARD == "SSTL_I_15") ||
           (IOSTANDARD == "SSTL_II_15") ||
           (IOSTANDARD == "SSTL_I_18_HP") ||
           (IOSTANDARD == "SSTL_II_18_HP") ||
           (IOSTANDARD == "SSTL_I_18_HR") ||
           (IOSTANDARD == "SSTL_II_18_HR") ||
           (IOSTANDARD == "SSTL_I_25") ||
           (IOSTANDARD == "SSTL_II_25") ||
           (IOSTANDARD == "SSTL_I_33") ||
           (IOSTANDARD == "SSTL_II_33"))
    else $error\("IOSTANDARD parameter value invalid.  Valid values are DEFAULT, LVCMOS_12, LVCMOS_15, LVCMOS_18_HP, LVCMOS_18_HR, LVCMOS_25, LVCMOS_33, LVTTL, HSTL_I_12, HSTL_II_12, HSTL_I_15, HSTL_II_15, HSUL_12, PCI66, PCIX133, POD_12, SSTL_I_15, SSTL_II_15, SSTL_I_18_HP, SSTL_II_18_HP, SSTL_I_18_HR, SSTL_II_18_HR, SSTL_I_25, SSTL_II_25, SSTL_I_33, SSTL_II_33.")
`endif // RS_ENG

  end

endmodule
