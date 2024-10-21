  
  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(O_P);
      pullup(O_N);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(O_P);
      pulldown(O_N);
    end
  endgenerate

  assign O_P = T ? I  : 'hz;
  assign O_N = T ? ~I : 'hz;

  `ifndef SYNTHESIS  
    `ifdef TIMED_SIM

      specify
        (I => O_P) = (0.8, 0.8);
        (I => O_N) = (0.8, 0.8);
      endspecify

    `endif // `ifdef TIMED_SIM  
  `endif //  `ifndef SYNTHESIS

  