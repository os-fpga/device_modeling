
  

	// GBOX CLK GEN
	reg core_clk=0;
	reg word_load_en;
	reg [8:0] pll_lock_count;
	reg [3:0] core_clk_count;


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

	// Logic To Be Checked Again for CHANNEL BOND SYNC IN/OUT
	reg fast_clk_sync_out;
	always@(posedge PLL_CLK or negedge RST)
	begin
		if(!RST)
		fast_clk_sync_out<=0;

		else if(CHANNEL_BOND_SYNC_IN && core_clk)
		begin
			fast_clk_sync_out<=1;
		end
		else begin
			fast_clk_sync_out<=0;
		end

	end
	assign CHANNEL_BOND_SYNC_OUT = fast_clk_sync_out;
	// GBOX CLK GEN //

	// Synchronous FIFO
	reg read_en;
	wire afull;
	wire fifo_empty;
	reg fifo_read_en;
	reg word_load_en_sync;
	reg [WIDTH-1:0] data_parallel_reg;
	reg [WIDTH-1:0] data_shift_reg;
	reg oe_parallel_reg;
	reg oe_shift_reg;
	wire fifo_data_oe;
	wire [WIDTH-1:0] fifo_read_data;

	SyncFIFO # (
		.DEPTH(4),
		.DATA_WIDTH(WIDTH)
	  )fifo1 (
		.clk(CLK_IN),
		.reset(RST),
		.wr_en(1'b1),
		.rd_en(fifo_read_en),
		.wr_data({OE_IN,D}),
		.rd_data({fifo_data_oe,fifo_read_data}),
		.empty(fifo_empty),
		.full(),
		.almost_full(afull)
		);

	// Generating read enable signal for fifo				
	always @(posedge CLK_IN or negedge RST) 
	begin
		if(!RST)
			read_en <= 0;  
		else
			read_en <= afull;
	end

	// Word load enable signal to load fifo data
	always @(posedge PLL_CLK or negedge RST) 
	begin
		if(!RST)
			fifo_read_en <= 1'b0;
		else if(fifo_empty)
			fifo_read_en <= 1'b0;
		else if (afull)
			fifo_read_en <= 1'b1;
	end

	assign word_load_en_sync = LOAD_WORD && fifo_read_en ;


	// Parallel data register 
	always @(posedge PLL_CLK or negedge RST) 
	begin
		if(!RST)
		begin
			data_parallel_reg <= 'h0;
			oe_parallel_reg   <= 1'b0;
		end
		else if(word_load_en_sync)
		begin
			data_parallel_reg <= fifo_read_data;
			oe_parallel_reg   <= fifo_data_oe;
		end

	end

	// Shift Register
	always @(posedge PLL_CLK or negedge RST)
	begin
		if(!RST)
		begin
			data_shift_reg <= 0;
			oe_shift_reg   <= 0;
		end
		else if(word_load_en_sync)
		begin
			oe_shift_reg   <= oe_parallel_reg;
			data_shift_reg <= data_parallel_reg;
		end
		else
			data_shift_reg <= {data_shift_reg[WIDTH-2: 0],1'b0};
	end

	always @(negedge PLL_CLK)
	begin
		if(DATA_RATE=="DDR")
			data_shift_reg <= {data_shift_reg[WIDTH-2: 0],1'b0};
	end

	assign OE_OUT = oe_shift_reg;

	assign Q = data_shift_reg[WIDTH - 1];

	