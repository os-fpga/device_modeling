

  wire o_serdes_dout;
  wire o_delay_dout;

  O_SERDES # (
    .DATA_RATE("DDR"),
    .WIDTH(WIDTH)
  )
  O_SERDES_inst (
    .D(HS_TX_DATA),
    .RST(RST),
    .DATA_VALID(HS_TXD_VALID),
    .CLK_IN(CLK_IN),
    .OE_IN(),
    .OE_OUT(),
    .Q(o_serdes_dout),
    .CHANNEL_BOND_SYNC_IN(CHANNEL_BOND_SYNC_IN),
    .CHANNEL_BOND_SYNC_OUT(CHANNEL_BOND_SYNC_OUT),
    .PLL_LOCK(PLL_LOCK),
    .PLL_CLK(RX_CLK)
  );

O_DELAY # (
  .DELAY(DELAY)
)
O_DELAY_inst (
  .I(tx_dp),
  .DLY_LOAD(DLY_LOAD),
  .DLY_ADJ(DLY_ADJ),
  .DLY_INCDEC(DLY_INCDEC),
  .DLY_TAP_VALUE(),
  .CLK_IN(CLK_IN),
  .O(o_delay_dout)
);
  reg tx_dp;
  reg tx_dn;
  assign TX_OE = LP_EN | HS_EN;

  always @(*) 
  begin
    if(HS_EN && TX_OE)
    begin
      tx_dp = o_serdes_dout;
      tx_dn = ~tx_dp;
    end
    else if (LP_EN && TX_OE) 
    begin
      tx_dp = TX_LP_DP;
      tx_dn = TX_LP_DN;
    end
  end

  assign TX_DP = (EN_ODLY=="FALSE")? tx_dp:o_delay_dout;
  assign TX_DN = (EN_ODLY=="FALSE")? tx_dn:~o_delay_dout;
  
  // assign TX_DP = tx_dp;
  // assign TX_DN = tx_dn;

  always@(*)
  begin
    if(LP_EN && HS_EN)
      $fatal(1,"\nERROR: MIPI TX instance %m LP_EN and HS_EN can't be hight at same time");
  end