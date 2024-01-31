`timescale 1ns/1ps
`celldefine
//
// I_SERDES simulation model
// Input Serial Deserializer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module I_SERDES #(
  parameter DATA_RATE = "SDR", // Single or double data rate (SDR/DDR)
  parameter WIDTH = 4, // Width of Deserialization (3-10)
  parameter DPA_MODE = "NONE" // Select Dynamic Phase Alignment or Clock Data Recovery (NONE/DPA/CDR)
) (
  input D, // Data input (connect to input port, buffer or I_DELAY)
  input RX_RST, // Active-low asycnhronous reset
  input BITSLIP_ADJ, // BITSLIP_ADJ input
  input EN, // EN input data (input data is low when driven low)
  input CLK_IN, // Fabric clock input
  output CLK_OUT, // Fabric clock output
  output [WIDTH-1:0] Q, // Data output
  output DATA_VALID, // DATA_VALID output
  output DPA_LOCK, // DPA_LOCK output
  output DPA_ERROR, // DPA_ERROR output
  input PLL_LOCK, // PLL lock input
  input PLL_CLK // PLL clock input
);
 initial begin
    case(DATA_RATE)
      "SDR" ,
      "DDR": begin end
      default: begin
        $display("\nError: I_SERDES instance %m has parameter DATA_RATE set to %s.  Valid values are SDR, DDR\n", DATA_RATE);
        #1 $stop ;
      end
    endcase

    if ((WIDTH < 3) || (WIDTH > 10)) begin
       $display("I_SERDES instance %m WIDTH set to incorrect value, %d.  Values must be between 3 and 10.", WIDTH);
    #1 $stop;
    end
    case(DPA_MODE)
      "NONE" ,
      "DPA" ,
      "CDR": begin end
      default: begin
        $display("\nError: I_SERDES instance %m has parameter DPA_MODE set to %s.  Valid values are NONE, DPA, CDR\n", DPA_MODE);
        #1 $stop ;
      end
    endcase

  end

endmodule
`endcelldefine
