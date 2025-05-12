// ----------------------------------------------------------------------------
// cdc_async_bit_no_rst.sv
//
// 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Synchronizer.
//
// The Radiant "Physical Designer" view shows that without a constraint the
// registers are not placed next to each other. The GUI can be used to
// group the registers within the component, and that forces them to
// be within a single slice.
//
// Example Tcl for group creation:
//
// ldc_create_group -name group_cdc_g1_0 [get_cells {g1[0].u1 g1[0].u1/meta_i1.ff_inst g1[0].u1/meta_i2.ff_inst}]
//
// ----------------------------------------------------------------------------

module cdc_async_bit_no_rst #(
		parameter int LENGTH = 2
	) (
		input  clk,
		input  d,
		output q
	);

	logic [LENGTH-1:0] meta = '0;
	always_ff @(posedge clk) begin
		meta <= {meta[LENGTH-2:0], d};
	end
	assign q = meta[LENGTH-1];

endmodule

