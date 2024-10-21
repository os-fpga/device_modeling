
  assign Y = A ? INIT_VALUE[1] : INIT_VALUE[0];

  `ifndef SYNTHESIS  
    `ifdef TIMED_SIM
      specparam T1 = 0.5;

        specify
          (A => Y) = (T1);
        endspecify
    `endif // `ifdef TIMED_SIM  
  `endif //  `ifndef SYNTHESIS

