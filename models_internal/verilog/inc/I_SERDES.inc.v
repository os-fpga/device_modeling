
reg clk_0=0;
reg clk_90=0 ;
reg clk_180=0;
reg clk_270=0;
real start_point;
real end_point;
real clk_period;
real period_quarter;
reg  clk_start=0;

// dpa block signals
reg [3:0] clk0_data_reg;
reg [3:0] clk0_data_comp;
reg [3:0] clk90_data_reg;
reg [3:0] clk90_data_comp;
reg [3:0] clk180_data_reg;
reg [3:0] clk180_data_comp;
reg [3:0] clk270_data_reg;
reg [3:0] clk270_data_comp;

reg [4:0] clk0_data_count;
reg [4:0] clk90_data_count;
reg [4:0] clk180_data_count;
reg [4:0] clk270_data_count;

reg [1:0] clk0_reg_data_count;
reg [1:0] clk90_reg_data_count;
reg [1:0] clk180_reg_data_count;
reg [1:0] clk270_reg_data_count;

reg dpa_lock=0;
reg cdr_clk=0;
reg dpa_dout=0;
reg dpa_error=0;

//  dpa fifo signals
wire dpa_fifo_empty;
wire dpa_fifo_full;
reg dpa_fifo_dout;

// bitslip block signals
reg bitslip_din_mux;
reg bitslip_din;
reg bitslip_des_clk;
reg bitslip_adj_1;
reg bitslip_adj_0;
reg bitslip_adj_pulse;
reg bitslip_dout;
reg bitslip_shifter_out;
reg [WIDTH-1:0] bit_shifter;
reg [3:0] bitslip_counter;

// gbox clk gen
// FAST CLK
reg core_clk=0;
reg word_load_en;
reg [8:0] pll_lock_count;
reg [3:0] core_clk_count;

// CDR CLOCK
reg cdr_core_clk=0;
reg cdr_word_load_en;
reg [8:0] cdr_pll_lock_count;
reg [3:0] cdr_core_clk_count;

// deserializer block signals
reg [WIDTH-1:0] des_shifter;
reg [WIDTH-1:0] des_parallel_reg;
reg des_word_load_en;
wire des_fifo_empty;
wire des_fifo_full;

// PLL PHASE SHIFTED CLOCKS
initial 
begin
  @(posedge PLL_CLK);
  start_point= $realtime;
  @(posedge PLL_CLK);
  end_point = $realtime;
  clk_period=end_point-start_point;
  period_quarter=clk_period/4;
  clk_start=1;
  #1;
end

// CLOCK 0
always@(posedge PLL_CLK or negedge PLL_CLK)
begin
  if(clk_start)
  clk_0<=PLL_CLK;
end

// CLOCK 90 & 180
always@(posedge clk_0 or negedge clk_0)
begin
  if(clk_start)
  begin
    #(period_quarter);
    clk_90<=~clk_90;
    #(period_quarter);
    clk_180<=~clk_180;
  end
end

// CLOCK 270
always@(posedge clk_180 or negedge clk_180)
begin
  if(clk_start)
  begin
    #(period_quarter);
    clk_270<=~clk_270;
  end
end

// DPA BLOCK //

// clk 0 check
always@(posedge clk_0 or negedge RST)
begin
  if(!RST)
  begin
    clk0_data_reg<=0;
    clk0_data_comp<=0;
    clk0_data_count<=0;
    clk0_reg_data_count<=0;
  end
  else if(!DPA_LOCK && EN)
  begin
    clk0_data_reg<={clk0_data_reg[2:0],D};
    clk0_reg_data_count<=clk0_reg_data_count+1;
    if(clk0_reg_data_count==3) // fill the 4 bit reg and compare with previous 4 bit data
    begin
      if(clk0_data_comp == clk0_data_reg)
      begin
        clk0_data_count<=clk0_data_count+1;
      end
      else  //if mismatch then update the current reg value and restart dpa counter
      begin
        clk0_data_comp<=clk0_data_reg;
        clk0_data_count<=0;  
      end
    end
  end
end

// clk 90 check
always@(posedge clk_90 or negedge RST)
begin
  if(!RST)
  begin
    clk90_data_reg<=0;
    clk90_data_comp<=0;
    clk90_data_count<=0;
    clk90_reg_data_count<=0;
  end
  else if(!DPA_LOCK && EN)
  begin
    clk90_data_reg<={clk90_data_reg[2:0],D};
    clk90_reg_data_count<=clk90_reg_data_count+1;
    if(clk90_reg_data_count==3) // fill the 4 bit reg and compare with previous 4 bit data
    begin
      if(clk90_data_comp == clk90_data_reg)
      begin
        clk90_data_count<=clk90_data_count+1;
      end
      else  //if mismatch then update the current reg value and restart dpa counter
      begin
        clk90_data_comp<=clk90_data_reg;
        clk90_data_count<=0;  
      end
    end
  end
end

// clk 180 check
always@(posedge clk_180 or negedge RST)
begin
  if(!RST)
  begin
    clk180_data_reg<=0;
    clk180_data_comp<=0;
    clk180_data_count<=0;
    clk180_reg_data_count<=0;
  end
  else if(!DPA_LOCK && EN)
  begin
    clk180_data_reg<={clk180_data_reg[2:0],D};
    clk180_reg_data_count<=clk180_reg_data_count+1;
    if(clk180_reg_data_count==3) // fill the 4 bit reg and compare with previous 4 bit data
    begin
      if(clk180_data_comp == clk180_data_reg)
      begin
        clk180_data_count<=clk180_data_count+1;
      end
      else  //if mismatch then update the current reg value and restart dpa counter
      begin
        clk180_data_comp<=clk180_data_reg;
        clk180_data_count<=0;  
      end
    end
  end
end

// clk 270 check
always@(posedge clk_270 or negedge RST)
begin
  if(!RST)
  begin
    clk270_data_reg<=0;
    clk270_data_comp<=0;
    clk270_data_count<=0;
    clk270_reg_data_count<=0;
  end
  else if(!DPA_LOCK && EN)
  begin
    clk270_data_reg<={clk270_data_reg[2:0],D};
    clk270_reg_data_count<=clk270_reg_data_count+1;
    if(clk270_reg_data_count==3) // fill the 4 bit reg and compare with previous 4 bit data
    begin
      if(clk270_data_comp == clk270_data_reg)
      begin
        clk270_data_count<=clk270_data_count+1;
      end
      else  //if mismatch then update the current reg value and restart dpa counter
      begin
        clk270_data_comp<=clk270_data_reg;
        clk270_data_count<=0;  
      end
    end
  end
end


always@(*)
begin
  if(clk0_data_count==16)
  begin
    cdr_clk=clk_0;
    dpa_lock=1;
    dpa_error=0;
  end
  else if(clk90_data_count==16)
  begin
    cdr_clk=clk_90;
    dpa_lock=1;
    dpa_error=0;
  end
  else if(clk180_data_count==16)
  begin
    cdr_clk=clk_180;
    dpa_lock=1;
    dpa_error=0;
  end
  else if(clk270_data_count==16)
  begin
    cdr_clk=clk_270;
    dpa_lock=1;
    dpa_error=0;
  end
  else
    dpa_lock=0;

  dpa_dout=D;

end

assign DPA_LOCK = dpa_lock;
assign DPA_ERROR= dpa_error;

// DPA BLOCK END //

// GBOX CLK GEN

// FOR FAST CLOCK
// count cycles after PLL LOCK
always@(posedge PLL_CLK or negedge RST)
begin
if(!RST)
  pll_lock_count<=0;
else if(!PLL_LOCK)
  pll_lock_count<=0;

// else if(PLL_LOCK && pll_lock_count<=31+(WIDTH/2)) // delay before clock starting = 32 clocks + rate_sel/2 clocks
else if(PLL_LOCK && pll_lock_count<=255)
  pll_lock_count<=pll_lock_count+1;
end

// Generate Core CLK And Word Load Enable
always@(posedge PLL_CLK or negedge RST)
begin
if(!RST)
begin
  core_clk<=0;
  core_clk_count<=0;
  word_load_en<=0;
end

else if(core_clk_count==WIDTH-1)
begin
  core_clk_count<=0;
  word_load_en<=1;
end
// else if(pll_lock_count>=31+(WIDTH/2))  // if delay before clock starting = 32 clocks + rate_sel/2 clocks
else if(pll_lock_count>=255)
begin
  core_clk_count<=core_clk_count+1;
  core_clk<=(core_clk_count<WIDTH/2)?1'b1:1'b0;
  word_load_en<=0;
end

end
// FOR CDR CLOCK

// count cycles after PLL LOCK
always@(posedge cdr_clk or negedge RST)
begin
if(!RST)
  cdr_pll_lock_count<=0;
else if(!PLL_LOCK)
  cdr_pll_lock_count<=0;

else if(PLL_LOCK && cdr_pll_lock_count<=255)
  cdr_pll_lock_count<=cdr_pll_lock_count+1;
end

// Generate CDR Core CLK And Word Load Enable
always@(posedge cdr_clk or negedge RST)
begin
if(!RST)
begin
  cdr_core_clk<=0;
  cdr_core_clk_count<=0;
  cdr_word_load_en<=0;
end

else if(cdr_core_clk_count==WIDTH-1)
begin
  cdr_core_clk_count<=0;
  cdr_word_load_en<=1;
end
else if(cdr_pll_lock_count>=255)
begin
  cdr_core_clk_count<=cdr_core_clk_count+1;
  cdr_core_clk<=(cdr_core_clk_count<WIDTH/2)?1'b1:1'b0;
  cdr_word_load_en<=0;
end

end

assign des_word_load_en=(DPA_MODE == "CDR")?cdr_word_load_en:word_load_en;
assign CLK_OUT = (DPA_MODE == "CDR")?cdr_core_clk:core_clk;

// GBOX CLK GEN //

// ASYNC FIFO TO SYNC DATA AFTER DPA MODULE
afifo # (
.ADDRSIZE(4),
.DATASIZE(1),
.SYNC_STAGES(2),
.MEM_TYPE(0)
)
afifo_dpa (
.wclk(cdr_clk),
.wr_reset(!RST),
.wr(!dpa_fifo_full),
.wr_data(dpa_dout),
.wr_full(dpa_fifo_full),
.rclk(PLL_CLK),
.rd_reset(!RST),
.rd(!dpa_fifo_empty),
.rd_data(dpa_fifo_dout),
.rd_empty(dpa_fifo_empty)
);
// ASYNC FIFO TO SYNC DATA AFTER DPA MODULE

// MUX TO SELECT BITSLIP INPUT
assign bitslip_din_mux = (DPA_MODE == "CDR")?dpa_dout:(DPA_MODE == "DPA")?dpa_fifo_dout:D;

assign bitslip_din=EN?bitslip_din_mux:0;

// BIT SLIP //

// CLOCK MUX
assign bitslip_des_clk= (DPA_MODE == "CDR")?cdr_clk:PLL_CLK;

// detect 0 to 1 pulse of bitslip adj
always@(posedge PLL_CLK)
begin
bitslip_adj_1<=BITSLIP_ADJ;
bitslip_adj_0<=bitslip_adj_1;
end

assign bitslip_adj_pulse = (bitslip_adj_1) && (!bitslip_adj_0);

// bitslip counter
always @(posedge bitslip_des_clk or negedge RST) 
begin
if(!RST)
begin
  bitslip_counter<=0;
  bitslip_shifter_out<=0;
end
else if(bitslip_adj_pulse)
begin
  if(bitslip_counter==WIDTH-1)
  begin
    bitslip_counter<=0;
  end
  else 
  begin
    bitslip_counter<=bitslip_counter+1;
  end
end
end

// bit shifter
always @(posedge bitslip_des_clk or negedge RST) 
begin
if(!RST)
  bit_shifter<=0;
else
  bit_shifter<={bit_shifter[WIDTH-2:0],bitslip_din};
end

always@(*)
begin
case(bitslip_counter)
  0:bitslip_shifter_out=bit_shifter[WIDTH-1];
  1:bitslip_shifter_out=bit_shifter[WIDTH-2];
  2:bitslip_shifter_out=bit_shifter[WIDTH-3];
  3:bitslip_shifter_out=bit_shifter[WIDTH-4];
  4:bitslip_shifter_out=bit_shifter[WIDTH-5];
  5:bitslip_shifter_out=bit_shifter[WIDTH-6];
  6:bitslip_shifter_out=bit_shifter[WIDTH-7];
  7:bitslip_shifter_out=bit_shifter[WIDTH-8];
  8:bitslip_shifter_out=bit_shifter[WIDTH-9];
  9:bitslip_shifter_out=bit_shifter[WIDTH-10];
endcase
end

always @(posedge bitslip_des_clk or negedge RST)
begin
if(!RST)
  bitslip_dout<=0;
else
  bitslip_dout<=bitslip_shifter_out;
end
// BIT SLIP END //

// DE-SERIALIZER //

// SHIFTER+PARALLEL-REGISTER
always@(posedge bitslip_des_clk or negedge RST)
begin
if(!RST)
begin
  des_shifter<=0;
  des_parallel_reg<=0;
end
else 
begin
  des_shifter<={des_shifter[WIDTH-2:0],bitslip_dout};
  if(des_word_load_en)
    des_parallel_reg<=des_shifter;
end
end

afifo # (
.ADDRSIZE(WIDTH),
.DATASIZE(WIDTH),
.SYNC_STAGES(2),
.MEM_TYPE(0)
)
afifo_inst (
.wclk(bitslip_des_clk),
.wr_reset(!RST),
.wr(!des_fifo_full && des_word_load_en),
.wr_data(des_parallel_reg),
.wr_full(des_fifo_full),
.rclk(CLK_IN),
.rd_reset(!RST),
.rd(!des_fifo_empty),
.rd_data(Q),
.rd_empty(des_fifo_empty)
);

assign DATA_VALID=!des_fifo_empty;

// DE-SERIALIZER END//

