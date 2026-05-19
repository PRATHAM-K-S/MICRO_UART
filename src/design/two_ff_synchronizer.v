module two_ff_synchoronizer (
	input wire clk_dest,
	input wire rst_n,
	input wire async_data,
	output wire sync_data
);

	reg sync_ff1, sync_ff2;

	always @(posedge clk_dest or negedge rst_n) begin
		if(!rst_n) begin
			sync_ff1 <= 1'b0;
			sync_ff2 <= 1'b0;
		end
		else begin
			sync_ff1 <= async_data;
			sync_ff2 <= sync_ff1;
		end
	end

	assign sync_data = sync_ff2;

endmodule
