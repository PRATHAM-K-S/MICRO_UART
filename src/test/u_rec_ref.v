module u_rec_ref
	#(
		parameter BAUD = 115200,
		parameter WORD_LEN = 8
	)
	(
		input wire rx_serial,
		input wire [WORD_LEN-1:0] tx_data,
		output reg expected_rx_serial,
		output reg [WORD_LEN-1:0] expected_data,
		output reg expected_ready,
		output reg expected_busy
	);

	integer bit_period = (1/BAUD);

	reg [WORD_LEN-1:0] tx_data_reg;

	initial begin
		expected_ready = 1'b1;
		expected_data = 'b0;
		expected_busy = 1'b0;
	end

	always @(negedge rx_serial) begin
		tx_data_reg = tx_data;
		#(bit_period/2);
		expected_ready = 0;
		expected_busy = 1;
		expected_rx_serial = 0;
		
		repeat(WORD_LEN) begin
			#bit_period;
			expected_rx_serial = tx_data_reg[0];
			tx_data_reg = tx_data_reg >> 1;
		end

		#bit_period
		expected_rx_serial = 1'b1;
		expected_data = tx_data;
		expected_ready = 1'b1;
		expected_busy = 1'b0;
	end

endmodule
