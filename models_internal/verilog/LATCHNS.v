`timescale 1ns/1ps
`celldefine
//
// LATCHNS simulation model
// Negative level-sensitive latch with active-high asyncronous set
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module LATCHNS (
  input D, // Data Input
  input G, // Active-high asyncronous set
  input R, // Active-high asyncronous reset
  output Q // Data Output
);

endmodule
`endcelldefine
