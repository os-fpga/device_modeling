
  reg data_pos;
  reg data_neg;

  always @(negedge R)
    Q <= 2'b00;

  always@(posedge C)
  begin
    if(!R)
      data_pos<=0;
    else
      data_pos<=D;
  end

  always@(negedge C)
  begin
    if(!R)
      data_neg<=0;
    else
      data_neg<=D;
  end

  always @(posedge C) 
  begin
    if(!R)
      Q<=0;
    else if(E)
    begin
      Q[1]<=data_pos;
      Q[0]<=data_neg;
    end
    
  end
