
  wire [15: 0] s4 = A[4] ? INIT_VALUE[31:16] : INIT_VALUE[15: 0];
  wire [ 7: 0] s3 = A[3] ?   s4[15: 8] :   s4[ 7: 0];
  wire [ 3: 0] s2 = A[2] ?   s3[ 7: 4] :   s3[ 3: 0];
  wire [ 1: 0] s1 = A[1] ?   s2[ 3: 2] :   s2[ 1: 0];
  assign Y = A[0] ? s1[1] : s1[0];


  `ifndef SYNTHESIS  
    `ifdef TIMED_SIM
      specparam T1 = 0.5;

        specify
          (A *> Y) = (T1);
        endspecify
    `endif // `ifdef TIMED_SIM  
  `endif //  `ifndef SYNTHESIS
