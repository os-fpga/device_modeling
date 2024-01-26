//
// O_BUFT_DS simulation model
//

module O_BUFT_DS #(
    parameter WEAK_KEEPER = "NONE"
`ifdef RS_ENG
    ,parameter IOSTANDARD = "DEFAULT" ,
    parameter DIFFERENTIAL_TERMINATION = "TRUE"
`endif // RS_ENG
    ) (
    input I ,
    input T ,
    output O_P ,
    output O_N
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
           (IOSTANDARD == "BLVDS_DIFF") ||
           (IOSTANDARD == "LVDS_HP_DIFF") ||
           (IOSTANDARD == "LVDS_HR_DIFF") ||
           (IOSTANDARD == "LVPECL_DIFF") ||
           (IOSTANDARD == "HSTL_12_DIFF") ||
           (IOSTANDARD == "HSTL_15_DIFF") ||
           (IOSTANDARD == "HSUL_12_DIFF") ||
           (IOSTANDARD == "MIPI_DIFF") ||
           (IOSTANDARD == "POD_12_DIFF") ||
           (IOSTANDARD == "RSDS_DIFF") ||
           (IOSTANDARD == "SLVS_DIFF") ||
           (IOSTANDARD == "SSTL_15_DIFF") ||
           (IOSTANDARD == "SSTL_18_HP_DIFF") ||
           (IOSTANDARD == "SSTL_18_HR_DIFF"))
    else $error\("IOSTANDARD parameter value invalid.  Valid values are DEFAULT, BLVDS_DIFF, LVDS_HP_DIFF, LVDS_HR_DIFF, LVPECL_DIFF, HSTL_12_DIFF, HSTL_15_DIFF, HSUL_12_DIFF, MIPI_DIFF, POD_12_DIFF, RSDS_DIFF, SLVS_DIFF, SSTL_15_DIFF, SSTL_18_HP_DIFF, SSTL_18_HR_DIFF.")

    assert((DIFFERENTIAL_TERMINATION == "TRUE") ||
           (DIFFERENTIAL_TERMINATION == "FALSE"))
    else $error\("DIFFERENTIAL_TERMINATION parameter value invalid.  Valid values are TRUE, FALSE.")
`endif // RS_ENG

  end

endmodule
