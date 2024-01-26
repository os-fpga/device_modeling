//
// TDP_RAM18KX2 simulation model
//

module TDP_RAM18KX2 #(
    parameter INIT1 = "{18432{1'b0}}" ,
    parameter WRITE_WIDTH_A1 = "18" ,
    parameter WRITE_WIDTH_B1 = "18" ,
    parameter READ_WIDTH_A1 = "18" ,
    parameter READ_WIDTH_B1 = "18" ,
    parameter INIT2 = "{18432{1'b0}}" ,
    parameter WRITE_WIDTH_A2 = "18" ,
    parameter WRITE_WIDTH_B2 = "18" ,
    parameter READ_WIDTH_A2 = "18" ,
    parameter READ_WIDTH_B2 = "18"
    ) (
    input WEN_A1 ,
    input WEN_B1 ,
    input REN_A1 ,
    input REN_B1 ,
    input CLK_A1 ,
    input CLK_B1 ,
    input BE_A1[1:0] ,
    input BE_B1[1:0] ,
    input ADDR_A1[13:0] ,
    input ADDR_B1[13:0] ,
    input WDATA_A1[WRITE_WIDTH_A1-1:0] ,
    input WDATA_B1[WRITE_WIDTH_B1-1:0] ,
    output RDATA_A1[READ_WIDTH_A1-1:0] ,
    output RDATA_B1[READ_WIDTH_B1-1:0] ,
    input WEN_A2 ,
    input WEN_B2 ,
    input REN_A2 ,
    input REN_B2 ,
    input CLK_A2 ,
    input CLK_B2 ,
    input BE_A2[1:0] ,
    input BE_B2[1:0] ,
    input ADDR_A2[13:0] ,
    input ADDR_B2[13:0] ,
    input WDATA_A2[WRITE_WIDTH_A2-1:0] ,
    input WDATA_B2[WRITE_WIDTH_B2-1:0] ,
    output RDATA_A2[READ_WIDTH_A2-1:0] ,
    output RDATA_B2[READ_WIDTH_B2-1:0]
  ) ;

//
// include user code here
//
  initial begin

  end

endmodule
