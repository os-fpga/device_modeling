`timescale 1ns/1ps
`celldefine
//
// SOC_FPGA_INTF_DMA simulation model
// SOC DMA interface
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module SOC_FPGA_INTF_DMA_tb;

  reg[3:0] DMA_REQ; // DMA request
  wire [3:0] DMA_ACK; // DMA acknowledge
  reg DMA_CLK; // DMA clock
  reg DMA_RST_N; // DMA reset

  reg dma_req;

SOC_FPGA_INTF_DMA_tb soc_fpga_intf_dma_tb (
  .DMA_REQ(DMA_REQ), // DMA request
  .DMA_ACK(DMA_ACK), // DMA acknowledge
  .DMA_CLK(DMA_CLK), // DMA clock
  .DMA_RST_N(DMA_RST_N) // DMA reset
);

  initial begin
    DMA_REQ = 0;
    DMA_CLK = 0;
    DMA_RST_N = 0;

    repeat(2) @(posedge DMA_CLK);
    DMA_RST_N = 1;

    for (int i=0; i<10; i++) begin
      DMA_REQ = $random();
      @(posedge DMA_CLK);
    end

    $finish;

  end

  initial begin
    forever #10 DMA_CLK = ~DMA_CLK;
  end

  always@(posedge DMA_CLK) dma_req <= DMA_REQ;

  initial begin 
    forever begin
      if(DMA_RST_N) assert (DMA_ACK == dma_req) else $error("False DMA_ACK");
    end
  end
  

  // assert property (
  //   @(posedge DMA_CLK) disable iff (!DMA_RST_N)
  //   DMA_REQ[1] |=> DMA_ACK[1]; 
  // );

endmodule
`endcelldefine
