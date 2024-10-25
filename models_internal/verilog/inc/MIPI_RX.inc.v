

  wire i_delay_out;
	wire rx_dp_delay;
	wire rx_dn_delay;
	wire rx_dp;
	wire rx_dn;

  I_DELAY # (
    .DELAY(DELAY)
  )
  I_DELAY_inst (
    .I(RX_DP),
    .DLY_LOAD(DLY_LOAD),
    .DLY_ADJ(DLY_ADJ),
    .DLY_INCDEC(DLY_INCDEC),
    .DLY_TAP_VALUE(DLY_TAP_VALUE),
    .CLK_IN(CLK_IN),
    .O(i_delay_out)
  );

  I_SERDES # (
    .DATA_RATE("DDR"),
    .WIDTH(WIDTH),
    .DPA_MODE("NONE")
  )
  I_SERDES_inst (
    .D(rx_dp),
    .RST(RST),
    .BITSLIP_ADJ(BITSLIP_ADJ),
    .EN(HS_EN),
    .CLK_IN(CLK_IN),
    .CLK_OUT(CLK_OUT),
    .Q(HS_RX_DATA),
    .DATA_VALID(HS_RXD_VALID),
    .DPA_LOCK(),
    .DPA_ERROR(),
    .PLL_LOCK(PLL_LOCK),
    .PLL_CLK(RX_CLK)
  );

	assign RX_OE= HS_EN | LP_EN;
	assign rx_dp_delay = (EN_IDLY=="FALSE")? RX_DP:i_delay_out;
  assign rx_dn_delay = (EN_IDLY=="FALSE")? RX_DN:~i_delay_out;
  
	// assign rx_dp = RX_TERM_EN?1'bz:RX_OE?rx_dp_delay:'b0;
	// assign rx_dn = RX_TERM_EN?1'bz:RX_OE?rx_dn_delay:'b0;
  assign rx_dp = RX_OE?rx_dp_delay:'b0;
	assign rx_dn = RX_OE?rx_dn_delay:'b0;

  assign LP_RX_DP = rx_dp;
  assign LP_RX_DN = rx_dn;

