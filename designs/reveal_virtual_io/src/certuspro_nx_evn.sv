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
		// Push buttons
		input  [2:0] pb,

		// DIP switches
		input  [7:0] sw,

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

	// I/O registers
	logic [2:0] pb_iob /* synthesis syn_preserve = 1 syn_useioff = 1 */;
	logic [7:0] sw_iob /* synthesis syn_preserve = 1 syn_useioff = 1 */;

	// Asynchronous input synchronizers
	logic [2:0] pb_sync;
	logic [7:0] sw_sync;

	// LED fabric registers
	logic [7:0] led_fabric_g;
	logic [7:0] led_fabric_r;
	logic [7:0] led_fabric_y;

	// LED fabric registers for Reveal multiplexing
	logic [7:0] led_mux_g;
	logic [7:0] led_mux_r;
	logic [7:0] led_mux_y;

	// LED duty cycled registers
	logic [7:0] led_duty_g;
	logic [7:0] led_duty_r;
	logic [7:0] led_duty_y;

	// LED output registers
	logic [7:0] led_iob_g /* synthesis syn_preserve = 1 syn_useioff = 1 */;
	logic [7:0] led_iob_r /* synthesis syn_preserve = 1 syn_useioff = 1 */;
	logic [7:0] led_iob_y /* synthesis syn_preserve = 1 syn_useioff = 1 */;

	// LED brightness control
	logic led_duty;

	// Reveal (Asynchronous) Virtual I/O
	wire        rvl_led_sel;
	wire  [7:0] rvl_led_g;
	wire  [7:0] rvl_led_r;
	wire  [7:0] rvl_led_y;
	wire  [2:0] rvl_pb;
	wire  [7:0] rvl_sw;

	// ------------------------------------------------------------------------
	// Input I/O Registers
	// ------------------------------------------------------------------------
	//
	always_ff @(posedge clk_12mhz) begin
		pb_iob <= pb;
		sw_iob <= sw;
	end

	// ------------------------------------------------------------------------
	// Input synchronizers
	// ------------------------------------------------------------------------
	//
	// Push buttons
	for (genvar i = 0; i < 3; i++) begin: g1
		cdc_async_bit_no_rst #(
			.LENGTH (2)
		) u1 (
			.clk (clk_12mhz ),
			.d   (pb_iob[i] ),
			.q   (pb_sync[i])
		);
	end

	// DIP switches
	for (genvar i = 0; i < 8; i++) begin: g2
		cdc_async_bit_no_rst #(
			.LENGTH (2)
		) u2 (
			.clk (clk_12mhz ),
			.d   (sw_iob[i] ),
			.q   (sw_sync[i])
		);
	end

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
	// LED brightness control
	// ------------------------------------------------------------------------
	//
	// 12.5% duty-cycle
	assign led_duty = (count[(WIDTH-16) +: 3] == 3'h0) ? 1'b1 : 1'b0;

	// ------------------------------------------------------------------------
	// LED fabric registers
	// ------------------------------------------------------------------------
	//
	always_ff @(posedge clk_12mhz) begin
		led_fabric_g <= count[(WIDTH-1) -: 8] ^ {5'h00, ~pb_sync};
		led_fabric_r <= count[(WIDTH-1) -: 8] ^ ~sw_sync;
		led_fabric_y <= count[(WIDTH-1) -: 8];
	end

	// ------------------------------------------------------------------------
	// Reveal Control and Status
	// ------------------------------------------------------------------------
	//
	// The rvl_led_sel and rvl_led_X signals are asynchronous, and would
	// usually be synchronized to the destination clock domain to avoid
	// metastability. Synchronizers were not used in this example.
	//
	// Invert the Reveal LED controls, since the LEDs are active low.
	//
	// LED control multiplexers
	always_ff @(posedge clk_12mhz) begin
		led_mux_g <= rvl_led_sel ? ~rvl_led_g : led_fabric_g;
		led_mux_r <= rvl_led_sel ? ~rvl_led_r : led_fabric_r;
		led_mux_y <= rvl_led_sel ? ~rvl_led_y : led_fabric_y;
	end

	// PB and SW status
	assign rvl_pb = pb_sync;
	assign rvl_sw = sw_sync;

	// ------------------------------------------------------------------------
	// Duty cycle registers
	// ------------------------------------------------------------------------
	//
	always_ff @(posedge clk_12mhz) begin

		// Reduce the brightness of the Green and Red LEDs
		led_duty_g <= led_duty ? led_mux_g : 8'hFF;
		led_duty_r <= led_duty ? led_mux_r : 8'hFF;

		// The Yellow (Amber) LEDs are not as bright as the Green and Red
		led_duty_y <= led_mux_y;
	end

	// ------------------------------------------------------------------------
	// LED output I/O registers
	// ------------------------------------------------------------------------
	//
	always_ff @(posedge clk_12mhz) begin
		led_iob_g <= led_duty_g;
		led_iob_r <= led_duty_r;
		led_iob_y <= led_duty_y;
	end
	assign led_g = led_iob_g;
	assign led_r = led_iob_r;
	assign led_y = led_iob_y;

endmodule

