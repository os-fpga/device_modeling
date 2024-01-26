//
// FIFO18KX2 simulation model
//

module FIFO18KX2 #(
    parameter DATA_WIDTH1 = "18" ,
    parameter FIFO_TYPE1 = "SYNCHRONOUS" ,
    parameter PROG_EMPTY_THRESH1 = "11'h004" ,
    parameter PROG_FULL_THRESH1 = "11'h8fa" ,
    parameter DATA_WIDTH2 = "18" ,
    parameter FIFO_TYPE2 = "SYNCHRONOUS" ,
    parameter PROG_EMPTY_THRESH2 = "11'h004" ,
    parameter PROG_FULL_THRESH2 = "11'h8fa"
    ) (
    input RESET1 ,
    input WR_CLK1 ,
    input RD_CLK1 ,
    input WR_EN1 ,
    input RD_EN1 ,
    input WR_DATA1[DATA_WIDTH1-1:0] ,
    output RD_DATA1[DATA_WIDTH1-1:0] ,
    output EMPTY1 ,
    output FULL1 ,
    output ALMOST_EMPTY1 ,
    output ALMOST_FULL1 ,
    output PROG_EMPTY1 ,
    output PROG_FULL1 ,
    output OVERFLOW1 ,
    output UNDERFLOW1 ,
    input RESET2 ,
    input WR_CLK2 ,
    input RD_CLK2 ,
    input WR_EN2 ,
    input RD_EN2 ,
    input WR_DATA2[DATA_WIDTH2-1:0] ,
    output RD_DATA2[DATA_WIDTH2-1:0] ,
    output EMPTY2 ,
    output FULL2 ,
    output ALMOST_EMPTY2 ,
    output ALMOST_FULL2 ,
    output PROG_EMPTY2 ,
    output PROG_FULL2 ,
    output OVERFLOW2 ,
    output UNDERFLOW2
  ) ;

//
// include user code here
//
  initial begin
    assert((FIFO_TYPE1 == "SYNCHRONOUS") ||
           (FIFO_TYPE1 == "ASYNCHRONOUS"))
    else $error\("FIFO_TYPE1 parameter value invalid.  Valid values are SYNCHRONOUS, ASYNCHRONOUS.")
    assert((FIFO_TYPE2 == "SYNCHRONOUS") ||
           (FIFO_TYPE2 == "ASYNCHRONOUS"))
    else $error\("FIFO_TYPE2 parameter value invalid.  Valid values are SYNCHRONOUS, ASYNCHRONOUS.")

  end

endmodule
