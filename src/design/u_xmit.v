module u_xmit
	#(
		WORD_LEN = 8
	)
	(
		input wire clk,
		input wire rst,
		input wire xmitH,
		input wire [WORD_LEN-1:0] xmit_dataH,
		output reg uart_XMIT_dataH,
		output reg xmit_active,
		output reg xmit_doneH
	);

	localparam SAMPLE 	= 2'b00;
	localparam START 		= 2'b01;
	localparam TRANSMIT = 2'b10;
	localparam STOP 		= 2'b11;

	reg [WORD_LEN-1:0] data;
	reg [3:0] count;
	reg [$clog2(WORD_LEN)-1:0] data_sent;
	reg [1:0] state;

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			count <= 'b0;
		end
		else begin
			count <= (state == SAMPLE)? 4'b0000: (count + 1'b1);
		end
	end

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			state 					<= SAMPLE;
			uart_XMIT_dataH	<= 1'b1;
			data 						<= 'b0;
			data_sent 			<= 'b0;
			xmit_active			<= 1'b0;
			xmit_doneH			<= 1'b0;
		end
		else begin
			case(state)
				SAMPLE:
					begin
						xmit_doneH	<= 1'b0;
						data_sent		<= 'b0;
						if (xmitH) begin
							data				<= xmit_dataH;
							xmit_active	<= 1'b1;
							state				<= START;
						end
						else begin
							uart_XMIT_dataH	<= 1'b1;
							xmit_active			<= 1'b0;
						end
					end
				START:
					begin
						uart_XMIT_dataH <= 1'b0;
						state <= (count == 15)? TRANSMIT: START;
					end
				TRANSMIT:
					begin
						uart_XMIT_dataH <= data[0];
						if(count == 15) begin
							data 			<= data >> 1'b1;
							data_sent	<= 1'b1;
							if(data_sent == (WORD_LEN-1)) begin
								state <= STOP;
							end
						end
						else begin
							data			<= data;
							data_sent	<= data_sent;
						end
					end
				STOP:
					begin
						uart_XMIT_dataH <= 1'b1;
						if(count == 15) begin
							xmit_active	<= 1'b0;
							xmit_doneH	<= 1'b1;
							state				<= SAMPLE;
						end
						else begin
							state <= STOP;
						end
					end
				default: state <= SAMPLE;
			endcase
		end
	end

endmodule
