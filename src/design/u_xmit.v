module xmit
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
		output reg xmit_done
	);

	localparam SAMPLE = 0;
	localparam START = 1;
	localparam TRANSMIT = 2;
	localparam STOP = 3;

	reg [WORD_LEN-1:0] data;
	reg [3:0] count;
	reg [$clog2(WORD_LEN):0] data_sent;
	reg transmitting;
	reg [1:0] state;

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			count <= 'b0;
		end
		else begin
			if(!transmitting)
				count <= 0;
			else
				count <= count + 1;
		end
	end

	always @(posedge clk or posedge rst) begin
		if(!rst) begin
			state <= SAMPLE;
			uart_XMIT_dataH <= 1'b1;
			data <= 'b0;
			data_sent <= 'b0;
			transmitting <= 1'b0;
		end
		else begin
			case(state)
				SAMPLE:
					begin
						data_sent <= 'b0;
						data <= xmitH? xmit_dataH: 'b0;
						state <= xmitH? START: SAMPLE;
					end
				START:
					begin
						uart_XMIT_dataH <= 1'b0;
						state <= (count == 15)? TRANSMIT: START;
					end
				TRANSMIT:
					begin
						if(!transmitting) begin
							uart_XMIT_dataH <= data[0];
							data <= data >> 1;
							transmitting <= 1'b1;
						end
						else begin
							data_sent <= ((data_sent <= WORD_LEN) && (count == 15))? (data_sent + 1): data_sent;
							transmitting <= (count == 15)? 1'b0: 1'b1;
						end
						state <= ((data_sent == WORD_LEN) && (count == 15))? STOP: TRANSMIT;
					end
				STOP:
					begin
						uart_XMIT_dataH <= 1'b1;
						state <= (count == 15)? SAMPLE: STOP;
					end
				default: state <= SAMPLE;
			endcase
		end
	end

endmodule
