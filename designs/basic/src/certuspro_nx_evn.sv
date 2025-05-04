// ----------------------------------------------------------------------------
// certuspro_nx_evn.sv
//
// 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Lattice CertusPro-NX Evaluation Board 'basic' design.
//
// ----------------------------------------------------------------------------
// References
// ----------
//
// [1] Lattice, "CertusPro-NX Evaluation Board", 2025
//     https://www.latticesemi.com/products/developmentboardsandkits/certuspro-nxevaluationboard
//     Ordering Part Number: LFCPNX-EVN
//
// ----------------------------------------------------------------------------

module certuspro_nx_evn (

		// --------------------------------------------------------------------
		// Clock
		// --------------------------------------------------------------------
		//
		input        clk_12mhz,

		// --------------------------------------------------------------------
		// User I/O
		// --------------------------------------------------------------------
		//
		// LEDs
		output [7:0] led
	);

	// ------------------------------------------------------------------------
	// Local parameters
	// ------------------------------------------------------------------------
	//
	// Clock frequency
	localparam real CLK_12MHZ_FREQUENCY = 12.0e6;

	// LED blink rate
	localparam real BLINK_PERIOD = 0.5;

	// Counter width
	//
	// 8 LEDs driven by the 12MHz clock
	localparam integer WIDTH =
		$clog2(integer'(CLK_12MHZ_FREQUENCY*BLINK_PERIOD))+7;

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Counter
	logic [WIDTH-1:0] count;

	// ------------------------------------------------------------------------
	// Counter
	// ------------------------------------------------------------------------
	//
	// The LEDs are turned on using a logic low level.
	// Use a down counter, so that the LEDs show an up count.
	//
	always_ff @(posedge clk_12mhz) begin
		count <= count - 1'b1;
	end

	// ------------------------------------------------------------------------
	// LED outputs
	// ------------------------------------------------------------------------
	//
	assign led = count[(WIDTH-1) -: 8];

endmodule

