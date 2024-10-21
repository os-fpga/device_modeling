`timescale 1ns/1ps
`celldefine
//
// LATCHN simulation model
// Negative level-sensitive latch
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module LATCHN (
  input D, // Data Input
  input G,
  output Q // Data Output
);

`ifndef SYNTHESIS  
  `ifdef TIMED_SIM
    specparam T1 = 0.5;

      specify
        (D => Q) = (T1);
        (G => Q) = (T1);
      endspecify
  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS


endmodule
`endcelldefine
