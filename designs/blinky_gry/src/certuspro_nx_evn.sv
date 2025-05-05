// ----------------------------------------------------------------------------
// certuspro_nx_evn.sv
//
// 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Lattice CertusPro-NX Evaluation Board 'blinky_gry' design.
//
// Blink the green, red, and yellow LEDs.
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

module certuspro_nx_evn #(
		// Use I/O Register
		parameter int USEIOFF = 1
	) (

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
		output [7:0] led_g,
		output [7:0] led_r,
		output [7:0] led_y
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
	// Pipelined through registers, so the registers can be placed near the
	// output pins to investigate clock-to-output delay.
	//
	// Lattice Radiant does not have a .PDC constraint for using I/O registers,
	// so the parameter USEIOFF was added to the design to allow a parameter to
	// control the use of the I/O registers.
	//
	// To change the USEIOFF parameter:
	// * Select "Project > Active Implementation > Set Top-Level Unit"
	// * Set "HDL Parameters" to USEIOFF=0 or USEIOFF=1
	//
	// The equivalent Tcl is:
	// > prj_set_impl_opt -impl "impl_1" {HDL_PARAM} {USEIOFF=0}
	// > prj_set_impl_opt -impl "impl_1" {HDL_PARAM} {USEIOFF=1}
	//
	// HDL_PARAM can have multiple values separated by semicolons.

	// Fabric Register
	if (USEIOFF == 0) begin: g0
		logic [7:0] led_iob_g /* synthesis syn_preserve = 1 syn_useioff = 0 */;
		logic [7:0] led_iob_r /* synthesis syn_preserve = 1 syn_useioff = 0 */;
		logic [7:0] led_iob_y /* synthesis syn_preserve = 1 syn_useioff = 0 */;
		always_ff @(posedge clk_12mhz) begin
			led_iob_g <= count[(WIDTH-1) -: 8];
			led_iob_r <= count[(WIDTH-1) -: 8];
			led_iob_y <= count[(WIDTH-1) -: 8];
		end
		assign led_g = led_iob_g;
		assign led_r = led_iob_r;
		assign led_y = led_iob_y;
	end

	// I/O Register
	if (USEIOFF == 1) begin: g1
		logic [7:0] led_iob_g /* synthesis syn_preserve = 1 syn_useioff = 1 */;
		logic [7:0] led_iob_r /* synthesis syn_preserve = 1 syn_useioff = 1 */;
		logic [7:0] led_iob_y /* synthesis syn_preserve = 1 syn_useioff = 1 */;
		always_ff @(posedge clk_12mhz) begin
			led_iob_g <= count[(WIDTH-1) -: 8];
			led_iob_r <= count[(WIDTH-1) -: 8];
			led_iob_y <= count[(WIDTH-1) -: 8];
		end
		assign led_g = led_iob_g;
		assign led_r = led_iob_r;
		assign led_y = led_iob_y;
	end

endmodule

