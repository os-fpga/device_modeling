
`ifdef ASYNC_FIFO

module FIFO36K_tb();
  reg RESET; // Asynchrnous FIFO reset
  reg WR_CLK; // Write clock
  reg RD_CLK; // Read clock
  reg WR_EN; // Write enable
  reg RD_EN; // Read enable
  reg [DATA_WRITE_WIDTH-1:0] WR_DATA; // Write data
  wire [DATA_READ_WIDTH-1:0] RD_DATA; // Read data
  wire EMPTY; // FIFO empty flag
  wire FULL; // FIFO full flag
  wire ALMOST_EMPTY; // FIFO almost empty flag
  wire ALMOST_FULL; // FIFO almost full flag
  wire PROG_EMPTY; // FIFO programmable empty flag
  wire PROG_FULL; // FIFO programmable full flag
  wire OVERFLOW; // FIFO overflow error flag
  wire UNDERFLOW;// FIFO underflow error flag

  parameter DATA_WRITE_WIDTH = 36; // FIFO data width (1-36)
  parameter DATA_READ_WIDTH = 36; // FIFO data width (1-36)

  parameter FIFO_TYPE = "ASYNCHRONOUS"; // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'h004; // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'h004;// 12-bit Programmable full depth

  // parameter DATA_WIDTH = 36;
  localparam DEPTH_WRITE = (DATA_WRITE_WIDTH <= 9) ? 4096 :
  (DATA_WRITE_WIDTH <= 18) ? 2048 :
  1024;

  localparam DEPTH_READ = (DATA_READ_WIDTH <= 9) ? 4096 :
  (DATA_READ_WIDTH <= 18) ? 2048 :
  1024;
  // predictor output
  reg [DATA_WRITE_WIDTH-1:0] exp_dout;

parameter W_PTR_WIDTH = $clog2(DEPTH_WRITE);
parameter R_PTR_WIDTH = $clog2(DEPTH_READ);

reg [8:0] pop_data1;
reg [8:0] pop_data2;
reg [8:0] pop_data3;
reg [8:0] pop_data4;

  // testbench variables
  integer error=0;
  integer count_n=0;
  integer count_enteries_push=0;
  integer count_enteries_pop=0;
  integer fwft_data1=0;
  integer fwft_data2=0;
  integer fwft_data3=0;
  integer fwft_data4=0;

  // integer rden_cnt=0;
  integer wren_cnt=0;
  reg [8:0] local_queue [$];
  integer fifo_number;
  bit debug=1;

  //clock//
  initial begin
    WR_CLK = 1'b0;
    forever #3 WR_CLK = ~WR_CLK;
end

  initial begin
      RD_CLK = 1'b0;
      forever #5 RD_CLK = ~RD_CLK;
  end

   FIFO36K #(
    .DATA_WRITE_WIDTH(DATA_WRITE_WIDTH),
    .DATA_READ_WIDTH  (DATA_READ_WIDTH),
    .FIFO_TYPE(FIFO_TYPE),
    .PROG_EMPTY_THRESH(PROG_EMPTY_THRESH), // 12-bit Programmable empty depth
    .PROG_FULL_THRESH(PROG_FULL_THRESH) // 12-bit Programmable full depth
   ) fifo36k_inst(
    .RESET(RESET), // Asynchrnous FIFO reset
    .WR_CLK(WR_CLK), // Write clock
    .RD_CLK(RD_CLK), // Read clock
    // .RD_CLK('h0), // Read clock
    .WR_EN(WR_EN), // Write enable
    .RD_EN(RD_EN), // Read enable
    .WR_DATA(WR_DATA), // Write data
    .RD_DATA(RD_DATA), // Read data
    .EMPTY(EMPTY), // FIFO empty flag
    .FULL(FULL), // FIFO full flag
    .ALMOST_EMPTY(ALMOST_EMPTY), // FIFO almost empty flag
    .ALMOST_FULL(ALMOST_FULL), // FIFO almost full flag
    .PROG_EMPTY(PROG_EMPTY), // FIFO programmable empty flag
    .PROG_FULL(PROG_FULL), // FIFO programmable full flag
    .OVERFLOW(OVERFLOW), // FIFO overflow error flag
    .UNDERFLOW(UNDERFLOW) // FIFO underflow error flag
    );

  initial begin
    $display("FIFO TYPE: %s---------------------", FIFO_TYPE);
    $display("PROG_EMPTY_THRESH = %d", PROG_EMPTY_THRESH);
    $display("PROG_FULL_THRESH = %d", PROG_FULL_THRESH);
    $display("--------------------------------------------");
    $display("check_flags");
    $display("--------------------------------------------");
    check_flags();

    test_status(error);
    #3;
    $finish();
  end

integer idx=0;
integer count=0;
integer count1=0;

  initial begin
    

    // $dumpvars(0,cpu_tb.cpu0.cpu_dp.cpu_regs.data[idx]);
    $dumpfile("wave.vcd"); 
    $dumpvars(0,FIFO36K_tb);
    
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.b_rptr);
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.b_wptr);

    for (int idx = 0; idx < 10; idx = idx + 1)
    $dumpvars(0,FIFO36K_tb.fifo36k_inst.ASYNCRONOUS.FIFO_RAM_inst.RAM_DATA[idx]);
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.FIFO_RAM_inst.RAM_DATA);

    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.g_wptr_sync);
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.g_rptr_next);
  end

  task check_flags();
    integer i;
    // resetting ptrs
    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET PTRS---------------------");
    WR_EN = 0;
    RD_EN = 0;
    RESET = 1;
    repeat(2) @(posedge WR_CLK);
    repeat(2) @(posedge WR_CLK);
    RESET = 0;
//Assertion empty_ewm_fifo_flags failed!
   if(PROG_EMPTY_THRESH>0) begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1010_0000)
      begin $display("ERROR: EMPTY AND PROG EMPTY ARE NOT ASSERTED IN START"); error=error+1; end
    end
    else begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1000_0000)
      begin $display("ERROR: EMPTY SHOULD BE ASSERTED IN START"); error=error+1; end
    end
    
    $display("CHECK FLAGS: Checking Flags on Each PUSH/POP Operation---------------------");

    assign count= (DATA_WRITE_WIDTH>=DATA_READ_WIDTH)?  1: DATA_READ_WIDTH/DATA_WRITE_WIDTH; // For example ? = 4

// Empty De Assert
    repeat(count) begin  // 1-4
    push();
    end
    // if(count>1) begin
    repeat(3)@(posedge RD_CLK);
    @(negedge RD_CLK);
    // end
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0110_0000) begin      
            begin $display("ERROR: EMPTY IS NOT DE-ASSERTED AFTER FIRST PUSH (PUSHED DATA SHOULD BE MATCHED WITH READ DATA PORT WIDTH)"); error=error+1; end
    end
// Almost Empty deassert
    repeat(count) begin // 5-8
    push();
    end
    // if(count>1) begin
    repeat(3)@(posedge RD_CLK);
    @(negedge RD_CLK);
    // end
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0010_0000) begin
            begin $display("ERROR: ALMOST EMPTY IS NOT DE-ASSERTED AFTER 2nd PUSH (PUSHED DATA SHOULD BE MATCHED WITH READ DATA PORT WIDTH)"); error=error+1; end
    end

// prog empty de asset // 9-16
    for (int i=count; i<(count*PROG_EMPTY_THRESH); i++ ) begin
      push();
    end
    // if(count>1) begin
    repeat(3)@(posedge RD_CLK);
    @(negedge RD_CLK);
    // end
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin
            begin $display("ERROR: PROG EMPTY IS NOT DE-ASSERTED AFTER PROG-THRESH HOLD PUSHES (PUSHED DATA SHOULD BE MATCHED WITH READ DATA PORT WIDTH)"); error=error+1; end
    end

// prog full assert // 17-4980
    for (int i= (count*PROG_FULL_THRESH); i< ( DEPTH_WRITE - (count*PROG_FULL_THRESH)-(count) ); i++ ) begin
      push();
    end
    // @(negedge RD_CLK);
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0010) begin
            begin $display("ERROR: PROG FULL IS NOT ASSERTED"); error=error+1; end
    end

 
  // almost full assert 

    for (int i= ( (DEPTH_WRITE) - (count*PROG_FULL_THRESH)-(count) ) ; i< ( DEPTH_WRITE-(count) -count); i++ ) begin
      push();
    end

    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin
      begin $display("ERROR: ALMOST FULL IS NOT ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
    end


  // full assert

   repeat(count) begin
    push();
   end

    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_1010) begin
      begin $display("ERROR: FULL IS NOT ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
    end

// overflow
   repeat(1) begin
    push();
   end
      @(negedge WR_CLK);

  if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_1011) begin
    begin $display("ERROR: OVERFLOW IS NOT ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
  end

// read 
  assign count1= (DATA_READ_WIDTH>=DATA_WRITE_WIDTH)?  1: DATA_WRITE_WIDTH/DATA_READ_WIDTH; // For example ? = 4

  repeat(count1) begin
    pop();
  end
  repeat(3) @(posedge WR_CLK);
  @(negedge WR_CLK);

  if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin
    begin $display("ERROR: OVERFLOW IS DE-ASSERTED AND PROG FULL AND ALMOST FULL ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
  end


  repeat(count1) begin
    pop();
   end
  // if(count1>1) begin
  repeat(3) @(posedge WR_CLK);
  @(negedge WR_CLK);
  // end  
  if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0010) begin
    begin $display("ERROR: ONLY PROG FULL SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
  end

// prog full de asset 
    for (int i=count1; i<(count1*PROG_FULL_THRESH); i++ ) begin
      pop();
    end
    // if(count>1) begin
    repeat(3)@(posedge WR_CLK);
    @(negedge WR_CLK);
    // end
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin
        begin $display("ERROR: NO FLAG SHOULD BE ASSETED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
    end

// prog empty assert 
    for (int i= (count1*PROG_EMPTY_THRESH); i< ( DEPTH_READ - (count1*PROG_EMPTY_THRESH)-(count1) ); i++ ) begin
      pop();
    end
    // @(negedge RD_CLK);
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0010_0000) begin
        begin $display("ERROR: ONLY PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
    end

//  almost empty assert 

    for (int i= ( (DEPTH_READ) - (count1*PROG_EMPTY_THRESH)-(count1) ) ; i< ( DEPTH_READ-(count1) -count1); i++ ) begin
      pop();
    end

    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0110_0000) begin
      begin $display("ERROR: ONLY ALMOST EMPTY PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
    end


  // empty assert

   repeat(count1) begin
    pop();
   end

    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1010_0000) begin
      begin $display("ERROR: ONLY EMPTY AND PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
    end

// underflow
   repeat(1) begin
    pop();
   end
      @(negedge RD_CLK);

  if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1011_0000) begin
    begin $display("ERROR: ONLY UDERFLOW , EMPTY AND PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
  end

  endtask : check_flags 

task push();
      @(negedge WR_CLK);
      WR_EN = 1;
      WR_DATA = $urandom_range(0, 2**DATA_WRITE_WIDTH-1);
      // WR_DATA = $random();
      @(negedge WR_CLK);

/* ----------------------------------- push byte date ---------------------------------- */
// R-9 
   if (DATA_READ_WIDTH==9) begin
   
      if(DATA_WRITE_WIDTH==9) begin  // 9
    
        if (count_enteries_push==0) begin
       
           fwft_data1 = WR_DATA;
        
        end    
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18) begin  // 18
        
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[16],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[15:8]};
        end    
        local_queue.push_back({WR_DATA[16],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[15:8]});  
      end
      else begin     // 36
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[32],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[33],WR_DATA[15:8]};
           fwft_data3 = {WR_DATA[34],WR_DATA[23:16]};
           fwft_data4 = {WR_DATA[35],WR_DATA[31:24]};
        end    
        local_queue.push_back({WR_DATA[32],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[33],WR_DATA[15:8]});  
        local_queue.push_back({WR_DATA[34],WR_DATA[23:16]});  
        local_queue.push_back({WR_DATA[35],WR_DATA[31:24]});  
      end 
   end
// R-18
  if (DATA_READ_WIDTH==18) begin
   
      if(DATA_WRITE_WIDTH==9) begin  // 9
    
        if (count_enteries_push==0) begin
       
           fwft_data1 = WR_DATA;

        end

        else if (count_enteries_push==1) begin

           fwft_data2 = WR_DATA;
        
        end    
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18) begin  // 18
        
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[16],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[15:8]};
        end    
        local_queue.push_back({WR_DATA[16],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[15:8]});  
      end

      else begin     // 36
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[32],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[33],WR_DATA[15:8]};
           fwft_data3 = {WR_DATA[34],WR_DATA[23:16]};
           fwft_data4 = {WR_DATA[35],WR_DATA[31:24]};
        end    
        local_queue.push_back({WR_DATA[32],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[33],WR_DATA[15:8]});  
        local_queue.push_back({WR_DATA[34],WR_DATA[23:16]});  
        local_queue.push_back({WR_DATA[35],WR_DATA[31:24]});  
      end 
  end

// R-36

  if (DATA_READ_WIDTH==36) begin
   
      if(DATA_WRITE_WIDTH==9) begin  // 9
    
        if (count_enteries_push==0) begin
       
           fwft_data1 = WR_DATA;

        end

        else if (count_enteries_push==1) begin

           fwft_data2 = WR_DATA;
        
        end

        else if (count_enteries_push==2) begin

           fwft_data3 = WR_DATA;
        
        end 

        else if (count_enteries_push==3) begin

           fwft_data4 = WR_DATA;
        
        end     
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18) begin  // 18
        
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[16],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[15:8]};
        end
        else if (count_enteries_push==1) begin
           fwft_data3 = {WR_DATA[16],WR_DATA[7:0]};
           fwft_data4 = {WR_DATA[17],WR_DATA[15:8]};
        end   
        local_queue.push_back({WR_DATA[16],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[15:8]});  
      end

      else begin     // 36
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[32],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[33],WR_DATA[15:8]};
           fwft_data3 = {WR_DATA[34],WR_DATA[23:16]};
           fwft_data4 = {WR_DATA[35],WR_DATA[31:24]};
        end    
        local_queue.push_back({WR_DATA[32],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[33],WR_DATA[15:8]});  
        local_queue.push_back({WR_DATA[34],WR_DATA[23:16]});  
        local_queue.push_back({WR_DATA[35],WR_DATA[31:24]});  
      end 
  end

  count_enteries_push=count_enteries_push+1;

/* ----------------------------------------------------------------- */
      // $display("i== %0d ; check WR_DATA %0h; size %0d",i,WR_DATA, $size(WR_DATA));
      WR_EN=0;

endtask : push 


task pop();

// R-9

  if (DATA_READ_WIDTH==9) begin
    
    if(DATA_WRITE_WIDTH==9) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA[8:0], fwft_data1);
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA,exp_dout);
        end
    end

    if(DATA_WRITE_WIDTH==36) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA, fwft_data1);
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA,exp_dout);
        end
    end

    if(DATA_WRITE_WIDTH==18) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA, fwft_data1);
          exp_dout = local_queue.pop_front();
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA,exp_dout);
        end
    end

  end
///////////////////////////////////////////////////////////////////////////////////////

// R-18

  else if (DATA_READ_WIDTH==18 ) begin
    
    if(DATA_WRITE_WIDTH==9) begin
       if (count_enteries_pop==2048) begin

          compare({RD_DATA[16],RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17],RD_DATA[15:8]}, fwft_data2);

        end
        else begin
            pop_data1= local_queue.pop_front();
            pop_data2= local_queue.pop_front();
            compare({RD_DATA[16], RD_DATA[7:0]},  {pop_data1[8], pop_data1[7:0]});
            compare({RD_DATA[17], RD_DATA[15:8]}, {pop_data2[8], pop_data2[7:0]});
        end
    end
  
      if(DATA_WRITE_WIDTH==18) begin

       if (count_enteries_pop==2048) begin
          pop_data1= local_queue.pop_front();
          pop_data2= local_queue.pop_front();
          compare({RD_DATA[16],RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17],RD_DATA[15:8]}, fwft_data2);
        end
        
        else begin
          
          pop_data1= local_queue.pop_front();
          pop_data2= local_queue.pop_front();
          compare({RD_DATA[16], RD_DATA[7:0]},  {pop_data1[8], pop_data1[7:0]});
          compare({RD_DATA[17], RD_DATA[15:8]}, {pop_data2[8], pop_data2[7:0]});
        end
    end

      if(DATA_WRITE_WIDTH==36) begin

       if (count_enteries_pop==2048) begin

          compare({RD_DATA[16], RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17], RD_DATA[15:8]}, fwft_data2);
        end

        else begin
          pop_data1= local_queue.pop_front();
          pop_data2= local_queue.pop_front();
          compare({RD_DATA[16], RD_DATA[7:0]}, {pop_data1[8], pop_data1[7:0]});
          compare( {{RD_DATA[17], RD_DATA[15:8]}}, {{pop_data2[8], pop_data2[7:0]}});
        end
    end

  end 

///////////////////////////////////////////////////////////////////////////////////////

// R-36

  else if (DATA_READ_WIDTH==36 ) begin
    
    if(DATA_WRITE_WIDTH==9) begin

       if (count_enteries_pop==1024) begin

          compare({RD_DATA[32], RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[33], RD_DATA[15:8]}, fwft_data2);
          compare({RD_DATA[34], RD_DATA[23:16]}, fwft_data3);
          compare({RD_DATA[35], RD_DATA[31:24]}, fwft_data4);

        end

        else begin
            pop_data1= local_queue.pop_front();
            pop_data2= local_queue.pop_front();
            pop_data3= local_queue.pop_front();
            pop_data4= local_queue.pop_front();
            compare({RD_DATA[32], RD_DATA[7:0]},  {pop_data1[8], pop_data1[7:0]});
            compare({RD_DATA[33], RD_DATA[15:8]}, {pop_data2[8], pop_data2[7:0]});
            compare({RD_DATA[34], RD_DATA[23:16]}, {pop_data3[8], pop_data3[7:0]});
            compare({RD_DATA[35], RD_DATA[31:24]}, {pop_data4[8], pop_data4[7:0]});
        //  $display("count_enteries_pop %0d  RD_DATA %0h", count_enteries_pop, RD_DATA);
        end
    end
  
      if(DATA_WRITE_WIDTH==18) begin

        if (count_enteries_pop==1024) begin

          compare({RD_DATA[32],RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[33],RD_DATA[15:8]}, fwft_data2);
          compare({RD_DATA[34],RD_DATA[23:16]}, fwft_data3);
          compare({RD_DATA[35],RD_DATA[31:24]}, fwft_data4);

        end
        else begin

          pop_data1= local_queue.pop_front(); 
          pop_data2= local_queue.pop_front();
          pop_data3= local_queue.pop_front();
          pop_data4= local_queue.pop_front();

          compare({RD_DATA[32], RD_DATA[7:0]}, {pop_data1[8], pop_data1[7:0]});
          compare({RD_DATA[33], RD_DATA[15:8]}, {pop_data2[8], pop_data2[7:0]});
          compare({RD_DATA[34], RD_DATA[23:16]}, {pop_data3[8], pop_data3[7:0]});
          compare({RD_DATA[35], RD_DATA[31:24]}, {pop_data4[8], pop_data4[7:0]});

        //  $display("count_enteries_pop %0d  RD_DATA %0h", count_enteries_pop, RD_DATA);
        end
    end

      if(DATA_WRITE_WIDTH==36) begin

       if (count_enteries_pop==1024) begin   // Last enter poped is same as first word fall through

          compare({RD_DATA[32],RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[33],RD_DATA[15:8]}, fwft_data2);
          compare({RD_DATA[34],RD_DATA[23:16]}, fwft_data3);
          compare({RD_DATA[35],RD_DATA[31:24]}, fwft_data4);

        end
        else begin
            pop_data1= local_queue.pop_front();
            pop_data2= local_queue.pop_front();
            pop_data3= local_queue.pop_front();
            pop_data4= local_queue.pop_front();
          compare({RD_DATA[32], RD_DATA[7:0]}, {pop_data1[8], pop_data1[7:0]});
          compare({RD_DATA[33], RD_DATA[15:8]}, {pop_data2[8], pop_data2[7:0]});
          compare({RD_DATA[34], RD_DATA[23:16]}, {pop_data3[8], pop_data3[7:0]});
          compare({RD_DATA[35], RD_DATA[31:24]}, {pop_data4[8], pop_data4[7:0]});
        end
    end

  end 


    count_enteries_pop=count_enteries_pop+1;
    @(negedge RD_CLK);
    RD_EN = 1;
    @(negedge RD_CLK);
    // $display("i== %0d ; check RD_DATA %0h",i,RD_DATA);
    RD_EN=0;

endtask : pop


  task test_status(input logic [31:0] error);
    begin
      if(error === 32'h0)
        begin
          $display(""); 
          $display(""); 
          $display("                     $$$$$$$$$$$              ");
          $display("                    $$          $$            ");
          $display("       $$$        $$              $$          ");
          $display("      $   $      $$                $$         ");
          $display("      $    $    $$    $$      $$    $$        ");
          $display("      $    $   $$    $  $    $  $    $$       ");
          $display("      $    $  $$     $  $    $  $     $$      ");
          $display("     $$    $                           $$     ");
          $display("     $    $$$$$$                       $$     ");
          $display("    $$         $ $$$$$$$$$$$$$$$$$$$$  $$     ");
          $display("   $$    $$$$$$$  $$   $  $  $    $$   $$     ");
          $display("   $            $  $$  $  $  $   $$   $$      ");
          $display("   $     $$$$$$$    $$ $  $  $  $$   $$       ");
          $display("   $            $    $$$  $  $ $$   $$        ");
          $display("   $     $$$$$$$ $$   $$$$$$$$$$   $$         ");
          $display("   $$          $   $$             $$          ");
          $display("     $$$$$$$$$$      $$         $$            ");
          $display("                       $$$$$$$$$              ");
          $display("");
          $display(""); 
          $display("----------------------------------------------");
          $display("                 TEST_PASSED                  ");
          $display("----------------------------------------------");
        end
        else   
        begin
          $display("");
          $display(""); 
          $display("           |||||||||||||");
          $display("         ||| |||      ||");
          $display("|||     ||    || ||||||||||");
          $display("||||||||      ||||       ||");
          $display("||||          ||  ||||||||||");
          $display("||||           |||         ||");
          $display("||||           ||  ||||||||||");
          $display("||||            ||||        |");
          $display("||||             |||  ||||  |");
          $display("|||||||||          ||||     |");
          $display("|||     ||             |||||");
          $display("         |||       ||||||");
          $display("           ||      ||");
          $display("            |||     ||");
          $display("              ||    ||");
          $display("               |||   ||");
          $display("                 ||   |");
          $display("                  |   |");
          $display("                  || ||");
          $display("                   |||");
          $display("");
          $display(""); 
          $display("----------------------------------------------");
          $display("                 TEST_FAILED                  ");
          $display("----------------------------------------------");
        end
    end
endtask

integer count_cmp=0;

task compare(input reg [DATA_READ_WIDTH-1:0] RD_DATA, exp_dout);

  if(RD_DATA !== exp_dout) begin
    $display("RD_DATA mismatch. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA, exp_dout,$time);
    error = error+1;
  end
  else if(debug) begin
    $display("RD_DATA match. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA, exp_dout,$time);
    count_cmp = count_cmp+1;
    $display("counting of byte compared including first word fall through, count is: %0d", count_cmp);
  end
endtask

endmodule

`endif 

`ifdef SYNC_FIFO
module FIFO36K_tb();
  reg RESET; // Asynchrnous FIFO reset
  reg WR_CLK; // Write clock
  reg RD_CLK; // Read clock
  reg WR_EN; // Write enable
  reg RD_EN; // Read enable
  reg [DATA_WIDTH-1:0] WR_DATA; // Write data
  wire [DATA_WIDTH-1:0] RD_DATA; // Read data
  wire EMPTY; // FIFO empty flag
  wire FULL; // FIFO full flag
  wire ALMOST_EMPTY; // FIFO almost empty flag
  wire ALMOST_FULL; // FIFO almost full flag
  wire PROG_EMPTY; // FIFO programmable empty flag
  wire PROG_FULL; // FIFO programmable full flag
  wire OVERFLOW; // FIFO overflow error flag
  wire UNDERFLOW;// FIFO underflow error flag

  parameter DATA_WIDTH = 36; // FIFO data width (1-36)
  parameter FIFO_TYPE = "SYNCHRONOUS"; // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'h004; // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'h004;// 12-bit Programmable full depth

  // Testbench Variables
  parameter R_CLOCK_PERIOD = 20;
  parameter W_CLOCK_PERIOD = 20;
  // parameter DATA_WIDTH = 36;
  localparam DEPTH = (DATA_WIDTH <= 9) ? 4096 :
  (DATA_WIDTH <= 18) ? 2048 :
  1024;
  // predictor output
  reg [DATA_WIDTH-1:0] exp_dout;

  // testbench variables
  integer error=0;
  // integer rden_cnt=0;
  integer wren_cnt=0;
  reg [DATA_WIDTH-1:0] local_queue [$];
  integer fifo_number;
  bit debug=0;

  //clock//
  initial begin
    WR_CLK = 1'b0;
    forever #20 WR_CLK = ~WR_CLK;
end

// initial begin
//  RD_CLK = 1'b0;
//  forever #15 RD_CLK = ~RD_CLK;
// end

  initial begin
      RD_CLK = 1'b0;
      forever #20 RD_CLK = ~RD_CLK;
  end

   FIFO36K #(
    .DATA_WRITE_WIDTH(DATA_WIDTH),
    .DATA_READ_WIDTH(DATA_WIDTH),
    .FIFO_TYPE(FIFO_TYPE),
    .PROG_EMPTY_THRESH(PROG_EMPTY_THRESH), // 12-bit Programmable empty depth
    .PROG_FULL_THRESH(PROG_FULL_THRESH) // 12-bit Programmable full depth
   ) fifo36k_inst(
    .RESET(RESET), // Asynchrnous FIFO reset
    .WR_CLK(WR_CLK), // Write clock
    // .RD_CLK(RD_CLK), // Read clock
    .RD_CLK('h0), // Read clock
    .WR_EN(WR_EN), // Write enable
    .RD_EN(RD_EN), // Read enable
    .WR_DATA(WR_DATA), // Write data
    .RD_DATA(RD_DATA), // Read data
    .EMPTY(EMPTY), // FIFO empty flag
    .FULL(FULL), // FIFO full flag
    .ALMOST_EMPTY(ALMOST_EMPTY), // FIFO almost empty flag
    .ALMOST_FULL(ALMOST_FULL), // FIFO almost full flag
    .PROG_EMPTY(PROG_EMPTY), // FIFO programmable empty flag
    .PROG_FULL(PROG_FULL), // FIFO programmable full flag
    .OVERFLOW(OVERFLOW), // FIFO overflow error flag
    .UNDERFLOW(UNDERFLOW) // FIFO underflow error flag
    );

  initial begin
    $display("FIFO TYPE: %s---------------------", FIFO_TYPE);
    $display("PROG_EMPTY_THRESH = %d", PROG_EMPTY_THRESH);
    $display("PROG_FULL_THRESH = %d", PROG_FULL_THRESH);
    $display("--------------------------------------------");
    $display("check_flags");
    $display("--------------------------------------------");
    check_flags();

    test_status(error);
    #100;
    $finish();
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,FIFO36K_tb);
    for (int idx = 0; idx < DEPTH; idx = idx + 1)
    $dumpvars(0,FIFO36K_tb.fifo36k_inst.SYNCRONOUS.FIFO_RAM_inst.RAM_DATA[idx]);
  end

  task check_flags();
    integer i;
    // resetting ptrs
    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET PTRS---------------------");
    WR_EN = 0;
    RD_EN = 0;
    RESET = 1;
    repeat(2) @(negedge WR_CLK);
    repeat(2) @(negedge WR_CLK);
    RESET = 0;
    @(posedge WR_CLK);
    @(negedge WR_CLK);

    // if(debug) $display("CHECK FLAGS: EMPTY FIFO---------------------");
    $display("CHECK FLAGS: EMPTY FIFO---------------------");
    if(PROG_EMPTY_THRESH>0) begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1010_0000)
      begin $display("Assertion empty_ewm_fifo_flags failed!"); error=error+1; end
    end
    else begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1000_0000)
      begin $display("Assertion empty_fifo_flags failed!"); error=error+1; end
    end

    $display("CHECK FLAGS: Checking Flags on Each PUSH/POP Operation---------------------");
    for(i = 1 ; i<=DEPTH; i=i+1) begin
      push();
      // wren_cnt+=1;
      if(i==(DEPTH-1)) begin
        if(~ALMOST_FULL)
          begin $display("Assertion ALMOST_FULL failed!"); error=error+1; end

      repeat(1) @(posedge WR_CLK);
      repeat(1) @(negedge WR_CLK);
    //  if (PROG_EMPTY)
    //     begin $display("Assertion PROG_EMPTY_pop_fifo_flags failed!"); error=error+1; end
      if (EMPTY)
        begin $display("Assertion EMPTY_pop_fifo_flags failed!"); error=error+1; end
      if (ALMOST_EMPTY)
        begin $display("Assertion ALMOST_EMPTY_pop_fifo_flags failed!"); error=error+1; end
      end
      else begin
        if (ALMOST_FULL)
          begin $display("Assertion notfmo_fifo_flags failed!"); error=error+1; end
      end

      if(i>(DEPTH-PROG_FULL_THRESH)) begin
        if (~PROG_FULL)
          begin $display("Assertion fwm_fifo_flags failed!"); error=error+1; end

        repeat(2) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        // if (PROG_EMPTY)
        //   begin $display("Assertion PROG_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        if (EMPTY)
          begin $display("Assertion not_empty_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY)
          begin $display("Assertion not_epo_pop_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (PROG_FULL)
          begin $display("Assertion notfwm_fifo_flags failed!"); error=error+1; end
    end

      if(i==DEPTH) begin
        if (~FULL)
          begin $display("Assertion full_fifo_flags failed!"); error=error+1; end

        repeat(1) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        // if (PROG_EMPTY)
        //   begin $display("Assertion ewm_pop_fifo_flags failed!"); error=error+1; end
        if (EMPTY)
          begin $display("Assertion not_empty_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY)
          begin $display("Assertion not_epo_pop_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (FULL)
          begin $display("Assertion notfull_fifo_flags failed!"); error=error+1; end
      end

      if (OVERFLOW)
        begin $display("Assertion no_overrun_fifo_flag failed!"); error=error+1; end
      repeat(1) @(posedge WR_CLK);
      repeat(1) @(negedge WR_CLK);
      if (UNDERFLOW)
        begin $display("Assertion no_underrun_fifo_flag failed!"); error=error+1; end
    end
    for(i = DEPTH ; i>=1; i=i-1) begin
      pop();

      if(PROG_EMPTY_THRESH>=i) begin
        if (~PROG_EMPTY)
          begin $display("Assertion PROG_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        repeat(1) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        if (ALMOST_FULL)
          begin $display("Assertion ALMOST_FULL_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL)
        //   begin $display("Assertion PROG_FULL_fifo_flags failed!"); error=error+1; end
        if (FULL)
          begin $display("Assertion FULL_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (PROG_EMPTY)
          begin $display("Assertion PROG_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        end

      if(i==1) begin
        if (~EMPTY)
          begin $display("Assertion EMPTY_pop_fifo_flags failed!"); error=error+1; end
        repeat(1) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        if (ALMOST_FULL)
          begin $display("Assertion ALMOST_FULL_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL)
        //   begin $display("Assertion PROG_FULL_fifo_flags failed!"); error=error+1; end
        if (FULL)
          begin $display("Assertion FULL_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (EMPTY)
          begin $display("Assertion EMPTY_pop_fifo_flags failed!"); error=error+1; end
        end

      if(i==2) begin
        if (~ALMOST_EMPTY)
          begin $display("Assertion ALMOST_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        repeat(2) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        if (ALMOST_FULL)
          begin $display("Assertion ALMOST_FULL_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL)
        //   begin $display("Assertion PROG_FULL_fifo_flags failed!"); error=error+1; end
        if (FULL)
          begin $display("Assertion FULL_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (ALMOST_EMPTY)
          begin $display("Assertion ALMOST_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        end

      if (UNDERFLOW)
        begin $display("Assertion UNDERFLOW_pop_fifo_flag failed!"); error=error+1; end
      repeat(1) @(posedge WR_CLK);
      repeat(1) @(negedge WR_CLK);
      if (OVERFLOW)
        begin $display("Assertion OVERFLOW_pop_fifo_flag failed!"); error=error+1; end
    // rden_cnt+=1;
    end
    $display("CHECK FLAGS: Read from EMPTY FIFO and Check UNDERFLOW Status---------------------");
    repeat (1) begin
    pop();
    // rden_cnt+=1;
    end
    if (~UNDERFLOW)
      begin $display("Assertion UNDERFLOW_fifo_flag failed!"); error=error+1; end

    $display("CHECK FLAGS: RESET PTRS after UNDERFLOW---------------------");
    RESET = 1;
    repeat(2) @(negedge WR_CLK);
    RESET = 0;
    @(posedge WR_CLK);
    @(negedge WR_CLK);

    $display("CHECK FLAGS: Push Data Into FIFO Until FULL---------------------");
    repeat(DEPTH) push();

    $display("CHECK FLAGS: Write into a FULL FIFO and Check OVERFLOW Status---------------------");
    repeat (1)push();
    if (~OVERFLOW)
      begin $display("Assertion OVERFLOW_fifo_flag failed!"); error=error+1; end


    repeat(20) @(negedge WR_CLK);

    $display("CHECK FLAGS: RESET PTRS after OVERFLOW---------------------");
    RESET = 1;
    repeat(2) @(negedge WR_CLK);
    RESET = 0;
    @(posedge WR_CLK);
    @(negedge WR_CLK);
    $display("CHECK FLAGS: EXIT---------------------------");

  endtask

  task pop();
    @(negedge WR_CLK);
    RD_EN = 1;
    if(debug) $display(" RD_EN = ",RD_EN, " RD_DATA = ",RD_DATA);
    if (UNDERFLOW)
      $display("FIFO is UNDERFLOW, POPing is UNDERFLOW");
    else if(EMPTY) begin
      $display("FIFO is EMPTY, POPing is UNDERFLOW");
      local_queue.delete();
    end
    else begin
      exp_dout = local_queue.pop_front();
      compare(RD_DATA, exp_dout);
    end
    @(negedge WR_CLK);
    RD_EN =0;
  endtask
  
  //task push(reg [32-1:0] in_din=$urandom_range(0, 2**32-1)); 
  task push(reg [DATA_WIDTH-1:0] in_din=$urandom_range(0, 2**DATA_WIDTH-1)); 
    @(negedge WR_CLK);
    WR_EN = 1; 
    WR_DATA = in_din;
    if(debug) $display(" WR_EN = ",WR_EN, " WR_DATA = ",WR_DATA);
    if (OVERFLOW) begin
      $display("FIFO is OVERFLOW, PUSHing is OVERFLOW");
    end
    else if(FULL) begin
      $display("FIFO is FULL, PUSHing is OVERFLOW");
      local_queue.delete();
    end
    else begin
      local_queue.push_back(WR_DATA);
    end
    @(negedge WR_CLK);
    WR_EN = 0;
  endtask

  task test_status(input logic [31:0] error);
    begin
      if(error === 32'h0)
        begin
          $display(""); 
          $display(""); 
          $display("                     $$$$$$$$$$$              ");
          $display("                    $$          $$            ");
          $display("       $$$        $$              $$          ");
          $display("      $   $      $$                $$         ");
          $display("      $    $    $$    $$      $$    $$        ");
          $display("      $    $   $$    $  $    $  $    $$       ");
          $display("      $    $  $$     $  $    $  $     $$      ");
          $display("     $$    $                           $$     ");
          $display("     $    $$$$$$                       $$     ");
          $display("    $$         $ $$$$$$$$$$$$$$$$$$$$  $$     ");
          $display("   $$    $$$$$$$  $$   $  $  $    $$   $$     ");
          $display("   $            $  $$  $  $  $   $$   $$      ");
          $display("   $     $$$$$$$    $$ $  $  $  $$   $$       ");
          $display("   $            $    $$$  $  $ $$   $$        ");
          $display("   $     $$$$$$$ $$   $$$$$$$$$$   $$         ");
          $display("   $$          $   $$             $$          ");
          $display("     $$$$$$$$$$      $$         $$            ");
          $display("                       $$$$$$$$$              ");
          $display("");
          $display(""); 
          $display("----------------------------------------------");
          $display("                 TEST_PASSED                  ");
          $display("----------------------------------------------");
        end
        else   
        begin
          $display("");
          $display(""); 
          $display("           |||||||||||||");
          $display("         ||| |||      ||");
          $display("|||     ||    || ||||||||||");
          $display("||||||||      ||||       ||");
          $display("||||          ||  ||||||||||");
          $display("||||           |||         ||");
          $display("||||           ||  ||||||||||");
          $display("||||            ||||        |");
          $display("||||             |||  ||||  |");
          $display("|||||||||          ||||     |");
          $display("|||     ||             |||||");
          $display("         |||       ||||||");
          $display("           ||      ||");
          $display("            |||     ||");
          $display("              ||    ||");
          $display("               |||   ||");
          $display("                 ||   |");
          $display("                  |   |");
          $display("                  || ||");
          $display("                   |||");
          $display("");
          $display(""); 
          $display("----------------------------------------------");
          $display("                 TEST_FAILED                  ");
          $display("----------------------------------------------");
        end
    end
endtask

task compare(input reg [DATA_WIDTH-1:0] RD_DATA, exp_dout);
  if(RD_DATA !== exp_dout) begin
    $display("RD_DATA mismatch. DUT_Out: %0d, Expected_Out: %0d, Time: %0t", RD_DATA, exp_dout,$time);
    error = error+1;
  end
  else if(debug)
    $display("RD_DATA match. DUT_Out: %0d, Expected_Out: %0d, Time: %0t", RD_DATA, exp_dout,$time);
endtask

endmodule

`endif 
