`timescale 1ns/1ps
`celldefine
//
// LATCHS simulation model
// Positive level-sensitive latch with active-high asyncronous set
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module LATCHS (
  input D, // Data Input
  input G, // Active-high asyncronous set
  input R, // Active-high asyncronous reset
  output Q // Data Output
);

`ifndef SYNTHESIS  
  `ifdef TIMED_SIM
    specparam T1 = 0.5;

      specify
        (D => Q) = (T1);
        (G => Q) = (T1);
        (R => Q) = (T1);
      endspecify
  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS

endmodule
`endcelldefine
