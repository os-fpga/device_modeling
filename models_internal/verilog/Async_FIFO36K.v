`timescale 1ns/1ps
`celldefine
`include "TDP_RAM36K.v"
//
// Asynchronous FIFO36K simulation model
// 36Kb FIFO
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
////////////////////////////////////////////////////////////
module FIFO36K #(
  parameter DATA_WRITE_WIDTH = 36, // FIFO data write width (9, 18, 36)
  parameter DATA_READ_WIDTH = 36, // FIFO data read width (9, 18, 36)
  parameter FIFO_TYPE = "ASYNCHRONOUS", // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'h004, // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'hffa // 12-bit Programmable full depth
) (
  input RESET, // Active high asynchronous FIFO reset
  input WR_CLK, // Write clock
  input RD_CLK, // Read clock
  input WR_EN, // Write enable
  input RD_EN, // Read enable
  input [DATA_WRITE_WIDTH-1:0] WR_DATA, // Write data
  output [DATA_READ_WIDTH-1:0] RD_DATA, // Read data
  output reg EMPTY, // FIFO empty flag
  output reg FULL, // FIFO full flag
  output reg ALMOST_EMPTY, // FIFO almost empty flag
  output reg ALMOST_FULL, // FIFO almost full flag
  output reg PROG_EMPTY, // FIFO programmable empty flag
  output reg PROG_FULL , // FIFO programmable full flag
  output reg OVERFLOW , // FIFO overflow error flag
  output reg UNDERFLOW // FIFO underflow error flag
);
  
  localparam DATA_WIDTH = DATA_WRITE_WIDTH;
  localparam  fifo_depth = (DATA_WIDTH <= 9) ? 4096 :
                           (DATA_WIDTH <= 18) ? 2048 :
                           1024;
  
  localparam  fifo_addr_width = (DATA_WIDTH <= 9) ? 12 :
                                (DATA_WIDTH <= 18) ? 11 :
                                10;

  reg [fifo_addr_width-1:0] fifo_wr_addr = {fifo_addr_width{1'b0}};
  reg [fifo_addr_width-1:0] fifo_rd_addr = {fifo_addr_width{1'b0}};

  wire [31:0] ram_wr_data;
  wire [3:0] ram_wr_parity;

  reg fwft = 1'b0;
  reg fall_through;
  reg wr_data_fwft;

  reg [DATA_WIDTH-1:0] fwft_data = {DATA_WIDTH{1'b0}};
  reg [DATA_WIDTH-1:0] fwft_data1 = {DATA_WIDTH{1'b0}};

  wire [31:0] ram_rd_data; 
  wire [3:0]  ram_rd_parity;
  wire ram_clk_b;
  
  integer number_entries = 0;
  reg underrun_status = 0;
  reg overrun_status = 0;

//////////////////////////////////////  ADDING LOGIC /////////////////////////


parameter PTR_WIDTH = $clog2(fifo_depth);

wire [PTR_WIDTH:0] b_wptr_sync, b_rptr_sync, b_rptr_next;
wire [PTR_WIDTH:0] b_wptr, b_rptr;



synchronizer #(PTR_WIDTH) sync_wptr (.clk(RD_CLK), 
                                     .rst_n(RESET), 
                                     .d_in(b_wptr), 
                                     .d_out(b_wptr_sync)); //write pointer to read clock domain

synchronizer #(PTR_WIDTH) sync_rptr (.clk(WR_CLK), 
                                     .rst_n(RESET), 
                                     .d_in(b_rptr), 
                                     .d_out(b_rptr_sync)); //read pointer to write clock domain

wptr_handler #(PTR_WIDTH, PROG_FULL_THRESH) wptr_h(.wclk(WR_CLK), 
                                 .wrst_n(RESET), 
                                 .w_en(WR_EN),
                                 .b_rptr_sync(b_rptr_sync),
                                 .b_wptr(b_wptr),  // this wire will go to mem input
                                 .full(FULL),
                                 .prog_full  (PROG_FULL),
                                 .almost_full(ALMOST_FULL));

rptr_handler #(PTR_WIDTH, PROG_EMPTY_THRESH) rptr_h(.rclk(RD_CLK), 
                                 .rrst_n(RESET), 
                                 .r_en(RD_EN),
                                 .prog_empty  (PROG_EMPTY),
                                 .b_rptr_next (b_rptr_next),
                                 .b_wptr_sync(b_wptr_sync),
                                 .b_rptr(b_rptr),  // this wire will go to mem input
                                 .empty(EMPTY),
                                 .almost_empty(ALMOST_EMPTY));

  generate

    if ((DATA_WIDTH == 9)|| (DATA_WIDTH == 17) || (DATA_WIDTH == 25)) begin: one_parity
      assign ram_wr_data = {{32-DATA_WIDTH{1'b0}}, WR_DATA};
      assign ram_wr_parity = {3'b000, WR_DATA[DATA_WIDTH-1]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[0], ram_rd_data[DATA_WIDTH-2:0]};
    end else if (DATA_WIDTH == 33) begin: width_33
      assign ram_wr_data = WR_DATA[31:0];
      assign ram_wr_parity = {3'b000, WR_DATA[32]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[0], ram_rd_data[31:0]};
    end else if ((DATA_WIDTH == 18) || (DATA_WIDTH == 26)) begin: two_parity
      assign ram_wr_data = {{32-DATA_WIDTH{1'b0}}, WR_DATA};
      assign ram_wr_parity = {2'b00, WR_DATA[DATA_WIDTH-1:DATA_WIDTH-2]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[1:0], ram_rd_data[DATA_WIDTH-3:0]};
    end else if (DATA_WIDTH == 34) begin: width_34
      assign ram_wr_data = WR_DATA[31:0];
      assign ram_wr_parity = {2'b00, WR_DATA[33:32]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[1:0], ram_rd_data[31:0]};
    end else if (DATA_WIDTH == 27) begin: width_27
      assign ram_wr_data = {8'h00, WR_DATA[23:0]};
      assign ram_wr_parity = {1'b0, WR_DATA[26:24]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[2:0], ram_rd_data[23:0]};
    end else if (DATA_WIDTH == 35) begin: width_35
      assign ram_wr_data = WR_DATA[31:0];
      assign ram_wr_parity = {1'b0, WR_DATA[34:32]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[2:0], ram_rd_data[31:0]};
    end else if (DATA_WIDTH == 36) begin: width_36
      assign ram_wr_data = WR_DATA[31:0];
      assign ram_wr_parity = WR_DATA[35:32];
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[3:0], ram_rd_data[31:0]};
    end else begin: no_parity
      assign ram_wr_data = fall_through ? wr_data_fwft : {{32-DATA_WIDTH{1'b0}}, WR_DATA};
      assign ram_wr_parity = 4'h0;
      assign RD_DATA = fwft ? fwft_data : ram_rd_data[DATA_WIDTH-1:0];
    end


/* Adding logic of First word fall through */

    always@(posedge WR_CLK) begin
      fwft <= (EMPTY && WR_EN && !fwft)? 1 : fwft;
      fwft_data1 <= (EMPTY && WR_EN && !fwft)? WR_DATA : fwft_data1;
    end

    always @ (posedge RD_CLK) begin
      if(RD_EN) begin
        fwft =0;
      end
    end

    always @(posedge RD_CLK) begin 
      fwft_data <= fwft_data1;
    end

/*----------------------------------------*/

/* Adding logic of OVERFLOW and UNDERFLOW */

always @(posedge WR_CLK) begin
  if (RESET) begin
   OVERFLOW <= 0;
  end
  else if (FULL & WR_EN ) begin
   OVERFLOW <= 1;
  end
  else begin 
     OVERFLOW <= OVERFLOW;
   end
end

always @(posedge RD_CLK) begin 
    if (RESET) begin
      OVERFLOW <= 0;
    end
    else if(RD_EN & OVERFLOW) begin
      OVERFLOW <= 0;
    end
    else begin
      OVERFLOW <= OVERFLOW;
    end
end

always @(posedge RD_CLK) begin

  if (RESET) begin
    UNDERFLOW <= 0;
  end
  else if (EMPTY & RD_EN) begin
     UNDERFLOW <= 1;
  end
  else begin
     UNDERFLOW <= UNDERFLOW;
  end

end

always @(posedge WR_CLK) begin
  if (RESET) begin
   UNDERFLOW <= 0;
  end
  else if (EMPTY & WR_EN ) begin
   UNDERFLOW <= 0;
  end
  else begin
   UNDERFLOW <= UNDERFLOW;
  end
end

/*----------------------------------------*/

endgenerate

  // Use BRAM

  TDP_RAM36K #(
    .INIT({32768{1'b0}}), // Initial Contents of memory
    .INIT_PARITY({2048{1'b0}}), // Initial Contents of memory
    .WRITE_WIDTH_A(DATA_WIDTH), // Write data width on port A (1-36)
    .READ_WIDTH_A(DATA_WIDTH), // Read data width on port A (1-36)
    .WRITE_WIDTH_B(DATA_WIDTH), // Write data width on port B (1-36)
    .READ_WIDTH_B(DATA_WIDTH) // Read data width on port B (1-36)
  ) FIFO_RAM_inst (
    .WEN_A(WR_EN & !OVERFLOW & !FULL), // Write-enable port A
    .WEN_B(1'b0), // Write-enable port B
    .REN_A(1'b0), // Read-enable port A
    .REN_B(RD_EN & !UNDERFLOW & !EMPTY), // Read-enable port B
    .CLK_A(WR_CLK), // Clock port A
    .CLK_B(RD_CLK), // Clock port B
    .BE_A(4'hf), // Byte-write enable port A
    .BE_B(4'h0), // Byte-write enable port B
    // .ADDR_A({fifo_wr_addr, {15-fifo_addr_width{1'b0}}}), // Address port A, align MSBs and connect unused MSBs to logic 0
    .ADDR_A({b_wptr,{15-fifo_addr_width{1'b0}}}), // Address port A, align MSBs and connect unused MSBs to logic 0
    // .ADDR_B({fifo_rd_addr, {15-fifo_addr_width{1'b0}}}), // Address port B, align MSBs and connect unused MSBs to logic 0
    .ADDR_B({b_rptr_next,{15-fifo_addr_width{1'b0}}}), // Address port B, align MSBs and connect unused MSBs to logic 0
    .WDATA_A(ram_wr_data), // Write data port A
    .WPARITY_A(ram_wr_parity), // Write parity data port A
    .WDATA_B(32'h00000000), // Write data port B
    .WPARITY_B(4'h0), // Write parity port B
    .RDATA_A(), // Read data port A
    .RPARITY_A(), // Read parity port A
    .RDATA_B(ram_rd_data), // Read data port B
    .RPARITY_B(ram_rd_parity) // Read parity port B
  ); initial begin
    case(DATA_WRITE_WIDTH)
      9 ,
      18 ,
      36: begin end
      default: begin
        $display("\nError: FIFO36K instance %m has parameter DATA_WRITE_WIDTH set to %d.  Valid values are 9, 18, 36\n", DATA_WRITE_WIDTH);
        #1 $stop ;
      end
    endcase
    case(DATA_READ_WIDTH)
      9 ,
      18 ,
      36: begin end
      default: begin
        $display("\nError: FIFO36K instance %m has parameter DATA_READ_WIDTH set to %d.  Valid values are 9, 18, 36\n", DATA_READ_WIDTH);
        #1 $stop ;
      end
    endcase
    case(FIFO_TYPE)
      "SYNCHRONOUS" ,
      "ASYNCHRONOUS": begin end
      default: begin
        $display("\nError: FIFO36K instance %m has parameter FIFO_TYPE set to %s.  Valid values are SYNCHRONOUS, ASYNCHRONOUS\n", FIFO_TYPE);
        #1 $stop ;
      end
    endcase

  end

endmodule

//////// Modules for Clock domain crossing in Asynchronous FIFO  ///////////////////////

module synchronizer #(parameter WIDTH=3) (input clk, rst_n, [WIDTH:0] d_in, output reg [WIDTH:0] d_out);
  reg [WIDTH:0] q1;
  always@(posedge clk) begin
    if(rst_n) begin
      q1 <= 0;
      d_out <= 0;
    end
    else begin
      q1 <= d_in;
      d_out <= q1;
    end
  end
endmodule

module wptr_handler #(parameter PTR_WIDTH=3, PROG_FULL_THRESH) (
  input wclk, wrst_n, w_en,
  input [PTR_WIDTH:0] b_rptr_sync,
  output reg [PTR_WIDTH:0] b_wptr,
  output reg full,
  output reg prog_full,
  output reg almost_full

);

  wire [PTR_WIDTH:0] b_wptr_next;

  wire wfull, al_full, p_full; 

  wire [PTR_WIDTH:0] diff_ptr0;

  assign b_wptr_next = b_wptr+(w_en & !full);

  
  assign diff_ptr0 =(((b_wptr_next  >= b_rptr_sync)? (b_wptr_next-b_rptr_sync): (b_wptr_next+(1<<(PTR_WIDTH+1))-b_rptr_sync)));
  
  assign wfull = (diff_ptr0 == (1<<PTR_WIDTH));
 
  assign al_full = (diff_ptr0 == (1<<PTR_WIDTH)-1);

  assign p_full = (diff_ptr0 == ((1<<PTR_WIDTH)-PROG_FULL_THRESH)) || (diff_ptr0 >= ((1<<PTR_WIDTH)-PROG_FULL_THRESH));


  always@(posedge wclk or posedge wrst_n) begin
    if(wrst_n) begin
      b_wptr <= 0; // set default value
    end
    else begin
      b_wptr <= b_wptr_next; // incr binary write pointer
    end
  end
  
  always@(posedge wclk or posedge wrst_n) begin
    if(wrst_n) begin
     full <= 0;
     almost_full <= 'b0;
     prog_full <= 0;
    end
    else begin
           full        <= wfull;
           almost_full <= al_full;
           prog_full <= p_full;
    end
  end

endmodule

module rptr_handler #(parameter PTR_WIDTH=3, PROG_EMPTY_THRESH) (
  input rclk, rrst_n, r_en,
  input [PTR_WIDTH:0] b_wptr_sync,
  output reg [PTR_WIDTH:0]  b_rptr_next,
  output reg [PTR_WIDTH:0] b_rptr,
  output reg empty,
  output reg prog_empty,
  output reg almost_empty
);

wire [PTR_WIDTH:0] diff_ptr0;

always @(*) begin

    if(rrst_n) begin
      b_rptr_next =0;
    end
    if((r_en & !empty)) begin
      if (b_rptr_next==(1<<PTR_WIDTH)) begin  
         b_rptr_next <=0;
      end
      else begin
        b_rptr_next = b_rptr_next+1;      
      end
    end
end

assign diff_ptr0 =(b_wptr_sync >= b_rptr_next)? (b_wptr_sync-b_rptr_next): (b_wptr_sync+(1<<(PTR_WIDTH+1))-b_rptr_next);

assign rempty= (diff_ptr0==0)?1:0;

assign al_empty = (diff_ptr0 ==1)? 1:0;

assign p_empty = (diff_ptr0 ==PROG_EMPTY_THRESH || diff_ptr0 <=PROG_EMPTY_THRESH )? 1:0;


  always@(posedge rclk or posedge rrst_n) begin

    if(rrst_n) begin
      b_rptr <= 0;
    end
    else begin
      b_rptr <= b_rptr_next;
    end
  end
  
  always@(posedge rclk or posedge rrst_n) begin

    if(rrst_n) begin 
      empty <= 1;
      almost_empty <= 0;
      prog_empty <=1;
    end
    else begin
      empty <= rempty;
      almost_empty <= al_empty;
      prog_empty <= p_empty;
    end 
  end
endmodule

`endcelldefine
