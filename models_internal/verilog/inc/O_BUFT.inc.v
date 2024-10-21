
  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(O);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(O);
    end
  endgenerate

  assign O = T ? I : 1'bz; 

  `ifndef SYNTHESIS  
    `ifdef TIMED_SIM
      specparam T1 = 0.5;

        specify
          (I => O) = (T1);
          (T => O) = (T1);

        endspecify
    `endif // `ifdef TIMED_SIM  
  `endif //  `ifndef SYNTHESIS
      