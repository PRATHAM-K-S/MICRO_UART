module u_rec
	#(
		parameter WORD_LEN = 8
	)
	(
		input wire clk,
		input wire rst,
		input wire uart_REC_dataH,
		output reg [WORD_LEN-1:0] rec_dataH,
		output reg rec_readyH,
		output reg rec_busy
	);

	localparam GET_START = 0;
	localparam GOT_START = 1;
	localparam RECEIVE = 2;
	localparam GET_STOP = 3;

	reg [3:0] count;
	reg [$clog2(WORD_LEN)-1:0] data_received;
	reg [1:0] state;
	reg [WORD_LEN-1:0] data;

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			count <= 0;
		end
		else begin
			if (state == GET_START)
				count <= 0;
			else if (state == GOT_START) begin
				if(count == 7)
					count <= 0;
				else
					count <= count + 1'b1;
			end
			else 
				count <= count + 1'b1;
		end
	end

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= GET_START;
			rec_dataH <= 'b0;
			rec_readyH <= 1'b0;
			rec_busy <= 1'b0;
		end
		else begin
			case(state)
				GET_START:
					begin
						rec_busy <= 1'b0;
						rec_readyH <= 1'b0;
						state <= (uart_REC_dataH == 1'b0)? GOT_START: GET_START;
					end
				GOT_START:
					begin
						rec_busy <= 1'b1;
						state <= (count == 7)?((uart_REC_dataH == 1'b0)? RECEIVE: GET_START):GOT_START;
					end
				RECEIVE:
					begin
						if(count == 15) begin
							if(data_received < WORD_LEN) begin
								data <= data >> 1;
								data[WORD_LEN-1] <= uart_REC_dataH;
								data_received <= data_received + 1'b1;
								state <= RECEIVE;
							end
							else begin
								state <= GET_STOP;
							end
						end
						else begin
							state <= RECEIVE;
						end
					end
				GET_STOP:
					begin
							if ((count == 15) && (uart_REC_dataH == 1'b1)) begin
								state <= GET_START;
								rec_dataH <= data;
								rec_readyH <= 1'b1;
							end
							else if((count == 15) && (uart_REC_dataH == 1'b1)) begin
								state <= GET_START;
							end
							else begin
								state <= GET_STOP;
								rec_dataH <= rec_dataH;
							end
					end
			endcase
		end
	end

endmodule
