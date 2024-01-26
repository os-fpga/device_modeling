//
// FIFO36K simulation model
//

module FIFO36K #(
    parameter DATA_WIDTH = "36" ,
    parameter FIFO_TYPE = "SYNCHRONOUS" ,
    parameter PROG_EMPTY_THRESH = "12'h004" ,
    parameter PROG_FULL_THRESH = "12'hffa"
    ) (
    input RESET ,
    input WR_CLK ,
    input RD_CLK ,
    input WR_EN ,
    input RD_EN ,
    input WR_DATA[DATA_WIDTH-1:0] ,
    output RD_DATA[DATA_WIDTH-1:0] ,
    output EMPTY ,
    output FULL ,
    output ALMOST_EMPTY ,
    output ALMOST_FULL ,
    output PROG_EMPTY ,
    output PROG_FULL ,
    output OVERFLOW ,
    output UNDERFLOW
  ) ;

//
// include user code here
//
  initial begin
    assert((FIFO_TYPE == "SYNCHRONOUS") ||
           (FIFO_TYPE == "ASYNCHRONOUS"))
    else $error\("FIFO_TYPE parameter value invalid.  Valid values are SYNCHRONOUS, ASYNCHRONOUS.")

  end

endmodule
