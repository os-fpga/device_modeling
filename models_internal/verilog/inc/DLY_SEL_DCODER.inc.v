

always @(*) 
begin
  for(integer i=0; i<32;i=i+1)
  begin
    DLY_CNTRL[i] = 3'b000;
  end
  if (DLY_ADDR < 5'd20) 
  begin
    DLY_CNTRL[DLY_ADDR] = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
  end
end

