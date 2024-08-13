
   assign O = I ;

  `ifndef SYNTHESIS
      specify
       (I => O) = (0, 0);
      endspecify
  `endif //  `ifndef SYNTHESIS
