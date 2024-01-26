//
// O_BUF simulation model
//

module O_BUF #(
`ifdef RS_ENG
    parameter IOSTANDARD = "DEFAULT" ,
    parameter DRIVE_STRENGTH = "2" ,
    parameter SLEW_RATE = "SLOW"
`endif // RS_ENG
    ) (
    input I ,
    output O
  ) ;

//
// include user code here
//
  initial begin

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

    assert((DRIVE_STRENGTH == "2") ||
           (DRIVE_STRENGTH == "4") ||
           (DRIVE_STRENGTH == "6") ||
           (DRIVE_STRENGTH == "8") ||
           (DRIVE_STRENGTH == "12") ||
           (DRIVE_STRENGTH == "16"))
    else $error\("DRIVE_STRENGTH parameter value invalid.  Valid values are 2, 4, 6, 8, 12, 16.")

    assert((SLEW_RATE == "SLOW") ||
           (SLEW_RATE == "FAST"))
    else $error\("SLEW_RATE parameter value invalid.  Valid values are SLOW, FAST.")
`endif // RS_ENG

  end

endmodule
