
  reg Q0;
  reg Qp;
  reg Q1;

  always @(negedge R)
    Q <= 1'b0;

  always@(posedge C)
  begin
    if(!R)
    begin
      Qp<=0;
      Q0<=0;
    end

    else 
    begin
      Q0<=D[0];
      Qp<=D[1];
    end
  end

  always@(negedge C)
  begin
    if(!R)
      Q1<=0;
    else
      Q1<=Qp;
  end

  
  always @(*)
    if (!R)
      Q <= 1'b0;
    else if (E) 
      if (C)
        Q <= Q0;
      else
        Q <= Q1;
