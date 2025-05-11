// ----------------------------------------------------------------------------
// certuspro_nx_evn.sv
//
// 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Lattice CertusPro-NX Evaluation Board 'blinky_gry' design.
//
// Blink the green, red, and yellow LEDs using different clock sources.
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
	// Clock frequencies
	localparam real CLK_12MHZ_FREQUENCY = 12.0e6;
	localparam real CLK_HFOSC_FREQUENCY = 50.0e6; // 450MHz/9
	localparam real CLK_LFOSC_FREQUENCY = 32.0e3;

	// LED blink rate
	localparam real BLINK_PERIOD = 0.5;

	// Counter width
	//
	// 8 LEDs driven by the 12MHz clock
	localparam integer WIDTH_12MHZ =
		$clog2(integer'(CLK_12MHZ_FREQUENCY*BLINK_PERIOD))+7;
	//
	// 8 LEDs driven by the HFOSC clock
	localparam integer WIDTH_HFOSC =
		$clog2(integer'(CLK_HFOSC_FREQUENCY*BLINK_PERIOD))+7;
	//
	// 8 LEDs driven by the LFOSC clock
	localparam integer WIDTH_LFOSC =
		$clog2(integer'(CLK_LFOSC_FREQUENCY*BLINK_PERIOD))+7;

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Internal oscillator
	wire clk_hfosc;
	wire clk_lfosc;

	// Counters
	logic [WIDTH_12MHZ-1:0] count_g;
	logic [WIDTH_HFOSC-1:0] count_r;
	logic [WIDTH_LFOSC-1:0] count_y;

	// LED brightness control
	logic led_duty_g;
	logic led_duty_r;

	// LED fabric registers
	logic [7:0] led_fabric_g;
	logic [7:0] led_fabric_r;
	logic [7:0] led_fabric_y;

	// ------------------------------------------------------------------------
	// Internal Oscillator
	// ------------------------------------------------------------------------
	//
	// Implementation details:
	//  * C:/lscc/radiant/2024.2/cae_library/simulation/verilog/lfcpnx/OSCA.v
	//  * The IP Catalog was used to create an IP instance, that was
	//    added to the design and synthesized, and the hierarchy reviewed
	//    to determine the low-level component used, the parameter settings,
	//    and the timing constraints format. The IP instance was then replaced
	//    with the low-level component.
	//
	OSCA #(
		.HF_CLK_DIV     ("9"      ), // 450MHz/9 = 50MHz
		.HF_SED_SEC_DIV ("1"      ),
		.HF_OSC_EN      ("ENABLED"),
		.LF_OUTPUT_EN   ("ENABLED")
	) u1 (
		.HFOUTEN  (1'b1     ),
		.HFSDSCEN (1'b0     ),
		.HFCLKOUT (clk_hfosc),
		.LFCLKOUT (clk_lfosc),
		.HFCLKCFG (         ),
		.HFSDCOUT (         )
	);

	// ------------------------------------------------------------------------
	// Counters
	// ------------------------------------------------------------------------
	//
	// The LEDs are turned on using a logic low level.
	// Use a down counter, so that the LEDs show an up count.
	//
	always_ff @(posedge clk_12mhz) begin
		count_g <= count_g - 1'b1;
	end

	always_ff @(posedge clk_hfosc) begin
		count_r <= count_r - 1'b1;
	end

	always_ff @(posedge clk_lfosc) begin
		count_y <= count_y - 1'b1;
	end

	// ------------------------------------------------------------------------
	// LED brightness control
	// ------------------------------------------------------------------------
	//
	// 12.5% duty-cycle
	assign led_duty_g = (count_g[(WIDTH_12MHZ-16) +: 3] == 3'h0) ? 1'b1 : 1'b0;
	assign led_duty_r = (count_r[(WIDTH_HFOSC-16) +: 3] == 3'h0) ? 1'b1 : 1'b0;

	// ------------------------------------------------------------------------
	// LED fabric registers
	// ------------------------------------------------------------------------
	//
	// Reduce the brightness of the Green and Red LEDs
	always_ff @(posedge clk_12mhz) begin
		led_fabric_g <= led_duty_g ? count_g[(WIDTH_12MHZ-1) -: 8] : 8'hFF;
	end

	always_ff @(posedge clk_hfosc) begin
		led_fabric_r <= led_duty_r ? count_r[(WIDTH_HFOSC-1) -: 8] : 8'hFF;
	end

	always_ff @(posedge clk_lfosc) begin
		led_fabric_y <= count_y[(WIDTH_LFOSC-1) -: 8];
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
			led_iob_g <= led_fabric_g;
		end
		always_ff @(posedge clk_hfosc) begin
			led_iob_r <= led_fabric_r;
		end
		always_ff @(posedge clk_lfosc) begin
			led_iob_y <= led_fabric_y;
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
			led_iob_g <= led_fabric_g;
		end
		always_ff @(posedge clk_hfosc) begin
			led_iob_r <= led_fabric_r;
		end
		always_ff @(posedge clk_lfosc) begin
			led_iob_y <= led_fabric_y;
		end
		assign led_g = led_iob_g;
		assign led_r = led_iob_r;
		assign led_y = led_iob_y;
	end

endmodule

