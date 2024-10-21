  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(I);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(I);
    end
  endgenerate

  assign O = EN ? I : 1'b0;

  `ifndef SYNTHESIS  
    `ifdef TIMED_SIM
        specify
        specparam T1 = 0.5;
        
          if (EN == 1'b1)
          (I => O) = (T1);
        endspecify
    `endif // `ifdef TIMED_SIM  
  `endif //  `ifndef SYNTHESIS


