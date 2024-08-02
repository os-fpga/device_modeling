
  assign {COUT, O} = {P ? CIN : G, P ^ CIN};

  specify
  
    if (P == 1'b1)
    (CIN => COUT) = (0, 0);
    if (P == 1'b0)
    (G => COUT) = (0, 0);

    ( P, CIN *> O ) = (0, 0);

  endspecify

  