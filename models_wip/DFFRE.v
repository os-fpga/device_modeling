//
// DFFRE simulation model
//

module DFFRE (
  input D,
  input R,
  input E,
  input C,
  output Q
);

  reg Q = 1'b0;
  
  always @(posedge C, negedge R)
    if (!R)
      Q <= 1'b0;
    else if (E)
      Q <= D;

endmodule
