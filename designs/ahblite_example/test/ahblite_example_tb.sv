// ----------------------------------------------------------------------------
// ahblite_example_tb.sv
//
// 5/18/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Testbench to demonstrate the Lattice AHB-Lite BFM.
//
// ----------------------------------------------------------------------------

module  ahblite_example_tb;

	// ------------------------------------------------------------------------
	// Local parameters
	// ------------------------------------------------------------------------
	//
	// Clock frequencies
	localparam real CLK_FREQUENCY = 100.0e6;

	// Clock periods
	localparam time CLK_PERIOD = (1.0e9/CLK_FREQUENCY)*1ns;

	// ------------------------------------------------------------------------
	// Local types
	// ------------------------------------------------------------------------
	//
	typedef virtual AHBL_Master_Lite_IF AHBL_Master_Lite_VIF;

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Reset and clock
	logic         rst_n;
	logic         clk;

	// AHB-Lite
	logic        hready;
	logic        hresp;
	logic [31:0] hrdata;
	logic [1:0]  htrans;
	logic        hwrite;
	logic [2:0]  hsize;
	logic [2:0]  hburst;
	logic [31:0] haddr;
	logic [31:0] hwdata;
	logic [3:0]  hprot;
	logic        hmastlock;
	logic        hsel;

	// Pipelined inputs
	logic  [3:0] r_haddr;
	logic        r_hwrite;
	logic        r_hsel;

	// Registers
	logic [31:0] hregs[16];
	logic [3:0]  hregs_addr;

	// -------------------------------------------------------------------------
	// Clock generator
	// -------------------------------------------------------------------------
	//
	initial begin
		clk = 1'b0;
		forever begin
			#(CLK_PERIOD/2) clk = ~clk;
		end
	end

	// ------------------------------------------------------------------------
	// AHB-Lite Master BFM
	// ------------------------------------------------------------------------
	//
	AHBL_Master_Lite_IF u1 (
		.ref_clk_i   (clk      ),
		.ref_rst_n_i (rst_n    ),
		.hready      (hready   ),
		.hresp       (hresp    ),
		.hrdata      (hrdata   ),
		.htrans      (htrans   ),
		.hwrite      (hwrite   ),
		.hsize       (hsize    ),
		.hburst      (hburst   ),
		.haddr       (haddr    ),
		.hwdata      (hwdata   ),
		.hprot       (hprot    ),
		.hmastlock   (hmastlock)
	);

	// Address decode
	// * 16 locations
	assign hsel = (haddr[31:6] == 26'h0000000) ? 1'b1 : 1'b0;

	// ------------------------------------------------------------------------
	// AHB-Lite Registers Slave
	// ------------------------------------------------------------------------
	//
	// This is a VERY basic registers slave. It currently ignores HTRANS.
	//

	// Write pipelined signals
	always_ff @(negedge rst_n or posedge clk) begin
		if (~rst_n) begin
			r_hsel   <= 1'b0;
			r_haddr  <= '0;
			r_hwrite <= 1'b0;
		end
		else begin
			r_hsel   <= hsel;
			r_haddr  <= haddr[5:2];
			r_hwrite <= hwrite;
		end
	end

	// Registers write/read
	always_ff @(negedge rst_n or posedge clk) begin
		if (~rst_n) begin
			hregs  <= '{default: '0};
			hrdata <= '0;
		end
		else if (r_hsel) begin
			// Write
			if (r_hwrite) begin
				hregs[hregs_addr] <= hwdata;
			end

			// Read
			hrdata <= hregs[hregs_addr];
		end
	end

	// Registers address
	// * multiplexed read or write address
	assign hregs_addr = r_hwrite ? r_haddr : haddr[5:2];

	// Ready
	assign hready = 1'b1;

	// No error
	assign hresp  = 1'b0;

	// ========================================================================
	// Stimulus
	// ========================================================================
	//
	AHBL_Master_Lite_VIF m_vif;
	logic [31:0] addr;
	logic [31:0] rdata;
	logic [31:0] wdata;
	logic [31:0] wbdata[];
	logic [31:0] rbdata[];
	int len;
	initial begin
		$timeformat(-9,3,"ns",5);

		$display(" ");
		$display("==========================================================");
		$display("AHB-Lite BFM stimulus");
		$display("==========================================================");
		$display(" ");

		// --------------------------------------------------------------------
		// Defaults
		// --------------------------------------------------------------------
		//
		rst_n  = 1'b0;

		// --------------------------------------------------------------------
		// Virtual Interfaces
		// --------------------------------------------------------------------
		//
		m_vif = u1;

		// --------------------------------------------------------------------
		// Reset
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("Reset");
		$display("----------------------------------------------------------");
		$display(" ");

		#(10*CLK_PERIOD);
		@(posedge clk);
		$display("Deassert reset");
		rst_n = 1'b1;

		// Wait
		repeat(10) @(posedge clk);

		// --------------------------------------------------------------------
		// Write single
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("write single");
		$display("----------------------------------------------------------");
		$display(" ");

		len = 16;
		$display("write %0d locations", len);
		for (int i = 0; i < len; i++) begin
			addr = 4*i;
			wdata = 32'h12340000 + i;
			m_vif.write_word_single(addr, wdata);
			$display("(addr, data) = (%.8X, %.8X)", addr, wdata);
		end

		// Wait
		repeat(10) @(posedge clk);

		// --------------------------------------------------------------------
		// Read single
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("Read single");
		$display("----------------------------------------------------------");
		$display(" ");

		$display("Read %0d locations", len);
		for (int i = 0; i < len; i++) begin
			addr = 4*i;
			m_vif.read_word_single(addr, rdata);
			$display("(addr, data) = (%.8X, %.8X)", addr, rdata);
		end

		// Wait
		repeat(10) @(posedge clk);

		// --------------------------------------------------------------------
		// Write burst
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("write burst");
		$display("----------------------------------------------------------");
		$display(" ");

		// Write burst data
		wbdata = new[len];
		for (int i = 0; i < len; i++) begin
			wbdata[i] = 32'h56780000 + i;
		end

		$display("write %0d locations using burst INCR", len);
		addr = '0;
		m_vif.write_word_burst_incr(addr, len, wbdata);

		// Wait
		repeat(10) @(posedge clk);


		// 5/18/2025: The read burst API is broken.
		// Use read single to confirm write data.

		// --------------------------------------------------------------------
		// Read single
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("Read single");
		$display("----------------------------------------------------------");
		$display(" ");

		$display("Read %0d locations", len);
		for (int i = 0; i < len; i++) begin
			addr = 4*i;
			m_vif.read_word_single(addr, rdata);
			$display("(addr, data) = (%.8X, %.8X)", addr, rdata);
		end

		// Wait
		repeat(10) @(posedge clk);


/*
		// --------------------------------------------------------------------
		// Read burst
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("Read burst");
		$display("----------------------------------------------------------");
		$display(" ");

		// 5/18/2025: The read burst API is broken.
		// read_word_burst_incr() needs to return an ARRAY of read responses

		// Read burst data (pre-allocate the array)
		rbdata = new[len];
		m_vif.read_word_burst_incr(addr, len, rbdata);

		$display("Read %0d locations", len);
		for (int i = 0; i < len; i++) begin
			addr = 4*i;
			$display("(addr, data) = (%.8X, %.8X)", addr, rbdata[i]);
		end

		// Wait
		repeat(10) @(posedge clk);
*/
		// --------------------------------------------------------------------
		// End simulation
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("End simulation");
		$display("----------------------------------------------------------");
		$display(" ");
		$stop(0);
	end

endmodule
