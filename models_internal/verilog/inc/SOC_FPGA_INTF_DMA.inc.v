

reg [3:0] dma_ack;
assign DMA_ACK = dma_ack;

always@(posedge DMA_CLK) begin
  if(!DMA_RST_N) begin
    dma_ack <= 4'b0;
  end 
  else begin
    dma_ack <= DMA_REQ;
  end
end
