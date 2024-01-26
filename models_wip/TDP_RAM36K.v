//
// TDP_RAM36K simulation model
//

module TDP_RAM36K #(
    parameter INIT = {36864{1'b0}} ,
    parameter WRITE_WIDTH_A = 36 ,
    parameter WRITE_WIDTH_B = 36 ,
    parameter READ_WIDTH_A = 36 ,
    parameter READ_WIDTH_B = 36
    ) (
    input WEN_A ,
    input WEN_B ,
    input REN_A ,
    input REN_B ,
    input CLK_A ,
    input CLK_B ,
    input [3:0] BE_A ,
    input [3:0] BE_B ,
    input [14:0] ADDR_A ,
    input [14:0] ADDR_B ,
    input [WRITE_WIDTH_A-1:0] WDATA_A ,
    input [WRITE_WIDTH_B-1:0] WDATA_B ,
    output [READ_WIDTH_A-1:0] RDATA_A ,
    output [READ_WIDTH_B-1:0] RDATA_B
  ) ;

//
// include user code here
//
  initial begin
    if ((WRITE_WIDTH_A < 1) || (WRITE_WIDTH_A > 36) begin
      $display("\nTDP_RAM36K instnace %m WRITE_WIDTH_A set to incorrect value, %d.  Values must be between 1 and 36.\n", WRITE_WIDTH_A);
      #1 $stop;
    end
  end

endmodule
