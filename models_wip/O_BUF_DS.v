//
// O_BUF_DS simulation model
//

module O_BUF_DS #(
`ifdef RS_ENG
    parameter IOSTANDARD = "DEFAULT" ,
    parameter DIFFERENTIAL_TERMINATION = "TRUE"
`endif // RS_ENG
    ) (
    input I ,
    output O_P ,
    output O_N
  ) ;

//
// include user code here
//
  initial begin

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
