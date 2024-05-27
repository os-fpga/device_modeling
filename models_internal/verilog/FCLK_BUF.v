`timescale 1ns/1ps
`celldefine
//
// FCLK_BUF simulation model
// Loopback clock buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module FCLK_BUF (
  input I, // Clock input
  output O // Clock output
);

   assign O = I ;

endmodule
`endcelldefine
