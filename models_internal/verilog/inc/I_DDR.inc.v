
  reg data_pos;
  reg data_neg;

  always @(negedge R)
  begin
    Q <= 2'b00;
    data_pos<=2'b00;
    data_neg<=2'b00;
  end

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
