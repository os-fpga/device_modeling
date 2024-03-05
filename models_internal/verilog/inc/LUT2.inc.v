
  wire [ 1: 0] s1 = A[1] ? INIT_VALUE[ 3: 2] : INIT_VALUE[ 1: 0];
  assign Y = A[0] ? s1[1] : s1[0];

