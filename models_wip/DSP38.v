//
// DSP38 simulation model
//

module DSP38 #(
    parameter COEFF_0 = "20'h00000" ,
    parameter COEFF_1 = "20'h00000" ,
    parameter COEFF_2 = "20'h00000" ,
    parameter COEFF_3 = "20'h00000" ,
    parameter OUTPUT_REG_EN = "TRUE" ,
    parameter INPUT_REG_EN = "TRUE" ,
    parameter ACCUMULATOR_EN = "FALSE" ,
    parameter ADDER_EN = "FALSE"
    ) (
    input A[19:0] ,
    input B[17:0] ,
    input ACC_FIR[5:0] ,
    output Z[37:0] ,
    output DLY_B[17:0] ,
    input CLK ,
    input RESET ,
    input FEEDBACK[2:0] ,
    input LOAD_ACC ,
    input UNSIGNED_A ,
    input UNSIGNED_B ,
    input SATURATE_ENABLE ,
    input SHIFT_RIGHT[5:0] ,
    input ROUND ,
    input SUBTRACT
  ) ;

//
// include user code here
//
  initial begin
    assert((OUTPUT_REG_EN == "TRUE") ||
           (OUTPUT_REG_EN == "FALSE"))
    else $error\("OUTPUT_REG_EN parameter value invalid.  Valid values are TRUE, FALSE.")
    assert((INPUT_REG_EN == "TRUE") ||
           (INPUT_REG_EN == "FALSE"))
    else $error\("INPUT_REG_EN parameter value invalid.  Valid values are TRUE, FALSE.")
    assert((ACCUMULATOR_EN == "TRUE") ||
           (ACCUMULATOR_EN == "FALSE"))
    else $error\("ACCUMULATOR_EN parameter value invalid.  Valid values are TRUE, FALSE.")
    assert((ADDER_EN == "TRUE") ||
           (ADDER_EN == "FALSE"))
    else $error\("ADDER_EN parameter value invalid.  Valid values are TRUE, FALSE.")

  end

endmodule
