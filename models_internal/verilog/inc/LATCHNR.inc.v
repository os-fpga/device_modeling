

`ifndef SYNTHESIS  
  `ifdef TIMED_SIM
    specparam T1 = 0.5;

      specify
        (D => Q) = (T1);
        (G => Q) = (T1);
        (R => Q) = (T1);
      endspecify
  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS
