
  wire [ 3: 0] s2 = A[2] ? INIT_VALUE[ 7: 4] : INIT_VALUE[ 3: 0];
  wire [ 1: 0] s1 = A[1] ?   s2[ 3: 2] :   s2[ 1: 0];
  assign Y = A[0] ? s1[1] : s1[0];

