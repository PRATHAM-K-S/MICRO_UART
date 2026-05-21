module u_xmit_ref
	#(
		parameter WORD_LEN = 8,
		parameter BAUD = 115200
	)
	(
		input wire tx_active,
		input wire [WORD_LEN-1:0] tx_data,
		output reg expected_data
	);

	reg [WORD_LEN-1:0] tx_data_reg;

	integer bit_period = (1/BAUD);

	initial expected_data = 1'b1;
	
	always @(posedge tx_active) begin		
		tx_data_reg = tx_data;
		expected_data = 1'b0;
		#bit_period;

		repeat(WORD_LEN) begin
			expected_data = tx_data_reg[0];
			tx_data_reg = tx_data_reg >> 1;
			#bit_period;
		end

		expected_data = 1'b1;
		#bit_period;

	end

endmodule
