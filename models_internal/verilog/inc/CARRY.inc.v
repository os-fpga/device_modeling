
assign {COUT, O} = {P ? CIN : G, P ^ CIN};

`ifndef SYNTHESIS  
 `ifdef TIMED_SIM
 
   specparam T1 = 0.3;
   specparam T2 = 0.4;


    specify
    
      if (P == 1'b1)
      (CIN => COUT) = (T1, T2);
      if (P == 1'b0)
      (G => COUT) = (T1, T2);

      ( P, CIN *> O ) = (T1, T2);

    endspecify

  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS
    