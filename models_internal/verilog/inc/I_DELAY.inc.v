
// Adding local variable for delay load
reg dly_ld_0, dly_ld_1;
wire dly_ld_p;

// Adding local variable for delay adjust
reg dly_adj_0, dly_adj_1;
wire dly_adj_p;

// reg counter;
reg [5:0] dly_tap_val = 0;
  
always_ff @(posedge CLK_IN) 
begin
	dly_ld_0 <= DLY_LOAD;
	dly_ld_1 <= dly_ld_0;
	
	dly_adj_0 <= DLY_ADJ;
	dly_adj_1 <= dly_adj_0;
end

// Detecting 0 to 1 transition
assign dly_ld_p = dly_ld_0 && !dly_ld_1;
assign dly_adj_p = dly_adj_0 && !dly_adj_1;

always_ff @(posedge CLK_IN) 
begin
	if (dly_ld_p)
		dly_tap_val <= DELAY;
	else if (dly_adj_p && DLY_INCDEC && dly_tap_val!=63) 
		dly_tap_val <= dly_tap_val + 1;
	else if (dly_adj_p && !DLY_INCDEC && dly_tap_val!=0) 
		dly_tap_val <= dly_tap_val - 1;
end

assign DLY_TAP_VALUE = dly_tap_val;
assign #(30.0ps + (21.56ps*dly_tap_val)) O = I;			// Adjusted Delay for TT corner


`ifndef SYNTHESIS  
 `ifdef TIMED_SIM
   specparam T1 = 0.2;
   specparam T2 = 0.3;
   specparam T3 = 5;
   specparam T4 = 5;

    specify


     (CLK_IN *> DLY_TAP_VALUE) = (T3);
     (CLK_IN => O) = (T4);


     $setuphold (posedge CLK_IN, posedge I  , T1, T2, notifier1);
     $setuphold (posedge CLK_IN, negedge I  , T1, T2, notifier1);
     $setuphold (negedge CLK_IN, posedge I  , T1, T2, notifier1);
     $setuphold (negedge CLK_IN, negedge I  , T1, T2, notifier1);
     $setuphold (posedge CLK_IN, posedge DLY_LOAD  , T1, T2, notifier1);
     $setuphold (posedge CLK_IN, negedge DLY_LOAD  , T1, T2, notifier1);
     $setuphold (negedge CLK_IN, posedge DLY_LOAD  , T1, T2, notifier1);
     $setuphold (negedge CLK_IN, negedge DLY_LOAD  , T1, T2, notifier1);
     $setuphold (posedge CLK_IN, posedge DLY_ADJ  , T1, T2, notifier1);
     $setuphold (posedge CLK_IN, negedge DLY_ADJ  , T1, T2, notifier1);
     $setuphold (negedge CLK_IN, posedge DLY_ADJ  , T1, T2, notifier1);
     $setuphold (negedge CLK_IN, negedge DLY_ADJ  , T1, T2, notifier1);
     $setuphold (posedge CLK_IN, posedge DLY_INCDEC  , T1, T2, notifier1);
     $setuphold (posedge CLK_IN, negedge DLY_INCDEC  , T1, T2, notifier1);
     $setuphold (negedge CLK_IN, posedge DLY_INCDEC  , T1, T2, notifier1);
     $setuphold (negedge CLK_IN, negedge DLY_INCDEC  , T1, T2, notifier1);

    endspecify

  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS

