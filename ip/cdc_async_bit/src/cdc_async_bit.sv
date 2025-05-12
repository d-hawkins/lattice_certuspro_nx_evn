// ----------------------------------------------------------------------------
// cdc_async_bit.sv
//
// 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Synchronizer.
//
// ----------------------------------------------------------------------------

module cdc_async_bit #(
		parameter int LENGTH = 2
	) (
		input  rst_n,
		input  clk,
		input  d,
		output q
	);

	logic [LENGTH-1:0] meta = '0;
	always_ff @(negedge rst_n or posedge clk) begin
		if (~rst_n) begin
			meta <= '0;
		end
		else begin
			meta <= {meta[LENGTH-2:0], d};
		end
	end
	assign q = meta[LENGTH-1];

endmodule

