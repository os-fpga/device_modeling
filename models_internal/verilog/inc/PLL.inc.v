
localparam      FAST_LOCK      = 0; // Reduce lock time

	localparam real REF_MAX_PERIOD = PLL_MULT_FRAC ? 100000: 200000; //10 MHz or 5 MHz
	localparam real REF_MIN_PERIOD = 833.33                        ; //1200 MHz

	localparam real VCO_MAX_PERIOD = 62500; //16 MHz
	localparam real VCO_MIN_PERIOD = 312.5; //3200 MHz


	localparam LOCK_TIMER = FAST_LOCK ? 10 : 500;

	logic [ 2:0] PLL_POST_DIV0;
	logic [ 2:0] PLL_POST_DIV1;

	assign PLL_POST_DIV0 = PLL_POST_DIV[2:0];
	assign PLL_POST_DIV1 = PLL_POST_DIV[6:4];
//---------------------------
  real         t0                ;
  real         t1                ;
  real         ref_period        ;
  real         vco_period        ;
  real         postdiv_period    ;
  real         old_ref_period    ;
  logic          clk_pll           ;
  logic          pllen_rse         ;
  logic          pllstart       = 0;
  logic          pllstart_ff1   = 0;
  logic          pllstart_ff2   = 0;
  logic          vcostart       = 0;
  logic          vcostart_ff    = 0;
  logic          lose_lock      = 0;
  logic          clk_out_div2   = 0;
  logic          clk_out_div3   = 0;
  logic          clk_out_div4   = 0;
  logic          clk_vco           ;
  logic          clk_postdiv       ;
  integer        div3_count     = 1;
  logic   [ 5:0] PLL_DIV_ff     = 0;
  logic   [11:0] PLL_MULT_ff    = 0;

	logic [$clog2(LOCK_TIMER)-1:0] lock_counter = 0;


	assign pllen_rse = pllstart==1 && pllstart_ff2==0;

	always @ (posedge  CLK_IN) begin
		if(PLL_EN) pllstart <= 1;
		else      pllstart <= 0;

		pllstart_ff1 <= pllstart;
		pllstart_ff2 <= pllstart_ff1;

	end

	always @ (posedge  CLK_IN) begin
		if(pllstart_ff2) vcostart <= 1;
		else             vcostart <= 0;

		vcostart_ff <= vcostart;
	end


	always @ (posedge  CLK_IN) begin
		@(posedge CLK_IN) t0 = $realtime;
		@(posedge CLK_IN) t1 = $realtime;
		ref_period = t1 - t0;
		vco_period = DIVIDE_CLK_IN_BY_2=="TRUE" ? (ref_period*PLL_DIV*2)/PLL_MULT : (ref_period*PLL_DIV)/PLL_MULT;
    postdiv_period = DIVIDE_CLK_IN_BY_2=="TRUE" ? (ref_period*PLL_DIV*2*PLL_POST_DIV0*PLL_POST_DIV1)/PLL_MULT : (ref_period*PLL_DIV*PLL_POST_DIV0*PLL_POST_DIV1)/PLL_MULT;
	end

	always @ (posedge  CLK_IN) begin
		old_ref_period = ref_period;
	end

	initial begin
		clk_vco = 0;
		forever begin
			wait(vcostart_ff)
				#(vco_period/2) clk_vco = PLL_EN ? ~clk_vco : '0;
		end
	end


  initial begin
    clk_postdiv = 0;
    forever begin
      wait(vcostart_ff)
        #(postdiv_period/2) clk_postdiv = PLL_EN ? ~clk_postdiv : '0;
    end
  end  


	always @(posedge CLK_IN) begin
		PLL_DIV_ff  <= PLL_DIV;
		PLL_MULT_ff <= PLL_MULT;
	end

	always @ (posedge  CLK_IN, negedge PLL_EN) begin
		if(LOCK==0 & vcostart) lock_counter <= lock_counter + 1;
		else if(lose_lock || PLL_EN==0 || PLL_MULT_ff!=PLL_MULT || PLL_DIV_ff!=PLL_DIV )     lock_counter <= 0;
	end


	always @(posedge CLK_OUT, negedge PLL_EN)
		if(PLL_EN==0) clk_out_div2 = 1'b0;
		else          clk_out_div2 = ~clk_out_div2;

	always @(CLK_OUT, negedge PLL_EN)
		if(PLL_EN==0) clk_out_div3 = 1'b0;
		else begin
			if (div3_count==2) begin
				clk_out_div3 = ~clk_out_div3;
				div3_count   = 0;
			end else
			div3_count = div3_count + 1;
		end

	always @(posedge clk_out_div2, negedge PLL_EN)
		if(PLL_EN==0) clk_out_div4 = 1'b0;
		else          clk_out_div4 = ~clk_out_div4;


	assign CLK_OUT      = (PLL_POST_DIV0==1 && PLL_POST_DIV0==1) ? clk_vco : clk_postdiv;
	assign CLK_OUT_DIV2 = clk_out_div2;
	assign CLK_OUT_DIV3 = clk_out_div3;
	assign CLK_OUT_DIV4 = clk_out_div4;
	assign FAST_CLK     = clk_vco;
	assign LOCK         = lock_counter >= LOCK_TIMER;



	// Checking for proper CLK_IN and VCO frequencies
	always @ (posedge CLK_IN) begin
		if(pllstart_ff2)begin
			if (ref_period<VCO_MIN_PERIOD) begin
				$fatal(1,"\nError at time %t: PLL instance %m REF clock period %0d fs violates minimum period.\nMust be greater than %0d fs.\n", $realtime, ref_period, VCO_MIN_PERIOD);
			end
			else if (ref_period>VCO_MAX_PERIOD) begin
				$fatal(1,"\nError at time %t: PLL instance %m REF clock period %0d fs violates maximum period.\nMust be less than %0d fs.\n", $realtime, ref_period, VCO_MAX_PERIOD);
			end
		end
	end


	always @ (posedge CLK_IN) begin
		if ((LOCK==1'b1) && (ref_period > old_ref_period*1.05) || (ref_period < old_ref_period*0.95)) begin
			$display("Warning at time %t: PLL instance %m input clock, CLK_IN, changed frequency and lost lock. Current value = %0d fs, old value = %d fs.\n", $realtime, ref_period, old_ref_period);
			lose_lock = 1;
		end
		else lose_lock = 0;
	end

	always @ (posedge FAST_CLK) begin
		if(vcostart_ff) begin
			if (vco_period<VCO_MIN_PERIOD) begin
				$fatal(1,"\nError at time %t: PLL instance %m VCO clock period %0d fs violates minimum period.\nMust be greater than %0d fs.\nTry increasing PLL_DIV or decreasing PLL_MULT values.\n", $realtime, vco_period, VCO_MIN_PERIOD);
			end
			else if (vco_period>VCO_MAX_PERIOD) begin
				$fatal(1,"\nError at time %t: PLL instance %m VCO clock period %0d fs violates maximum period.\nMust be less than %0d fs.\nTry increasing PLL_MULT or decreasing PLL_DIV values.\n", $realtime, vco_period, VCO_MAX_PERIOD);
			end
		end
	end



	// Checking control inputs
	always @ (posedge CLK_IN, posedge PLL_EN) begin
		if(PLL_EN)begin
			if(PLL_POST_DIV0==0)begin
				$fatal(1,"Error at time %t: \n \t PLL instance %m, PLL_POST_DIV0 is equal to zero.\n \t Must be greater than 0", $realtime);
			end

			else if(PLL_POST_DIV1==0)begin
				$fatal(1,"Error at time %t: \n \t PLL instance %m, PLL_POST_DIV1 is equal to zero.\n \t Must be greater than 0", $realtime);
			end


			else if(PLL_POST_DIV1>PLL_POST_DIV0) begin
				$fatal(1,"Error at time %t: PLL_POST_DIV1 > PLL_POST_DIV0\n", $realtime);
			end
		end
	end

  