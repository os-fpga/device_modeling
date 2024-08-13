  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(I);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(I);
    end
  endgenerate

  assign O = EN ? I : 1'b0;

  `ifndef SYNTHESIS
    specify
      if (EN == 1'b1)
      (I => O) = (0, 0);
    endspecify
  `endif //  `ifndef SYNTHESIS

