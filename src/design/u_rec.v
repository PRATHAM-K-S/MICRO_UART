module u_rec
	#(
		parameter WORD_LEN = 8
	)
	(
		input wire clk,
		input wire rst_l,
		input wire uart_REC_dataH,
		output reg [WORD_LEN-1:0] rec_dataH,
		output reg rec_readyH,
		output reg rec_busy
	);
	
	//fsm states
	localparam GET_START = 0;
	localparam GOT_START = 1;
	localparam RECEIVE = 2;
	localparam GET_STOP = 3;
	
	//registers
	reg [3:0] count;
	reg [$clog2(WORD_LEN):0] data_received;
	reg [1:0] state;
	reg [WORD_LEN-1:0] data;

	//synchronizer registers
	reg sync_ff1;
	reg sync_ff2;

	//Two flip flop synchronizer
	always @(posedge clk or negedge rst_l) begin
		if(!rst_l) begin
			sync_ff1 <= 1'b1;
			sync_ff2 <= 1'b1;
		end
		else begin
			sync_ff1 <= uart_REC_dataH;
			sync_ff2 <= sync_ff1;
		end
	end

	//counter
	always @(posedge clk or negedge rst_l) begin
		if(!rst_l) begin
			count <= 0;
		end
		else begin
			case(state)
				GET_START:
					count <= 0;
				GOT_START:
					begin
						if(count == 7)
							count <= 0;
						else 
							count <= count + 1;
					end
				RECEIVE,
				GET_STOP:
					begin
						if(count == 15)
							count <= 0;
						else
							count <= count + 1;
					end
			endcase
		end
	end

	always @(posedge clk or negedge rst_l) begin
		if(!rst_l) begin
			state <= GET_START;
			rec_dataH <= 'b0;
			rec_readyH <= 1'b1;
			rec_busy <= 1'b0;
			data_received <= 0;
			data <= 0;
		end
		else begin
			case(state)
				GET_START://detect start bit
					begin
						rec_busy <= 1'b0;
						rec_readyH <= 1'b1;
                      state <= (uart_REC_dataH == 1'b0)? GOT_START: GET_START;
					end
				GOT_START:
					begin
						rec_readyH <= 1'b0;
						rec_busy <= 1'b1;	
						state <= (count == 7)?((sync_ff2 == 1'b0)? RECEIVE: GET_START):GOT_START;
					end
				RECEIVE:
					begin
                      if(count == 14) begin
							data <= {sync_ff2, data[WORD_LEN-1:1]};
							if(data_received == WORD_LEN-1) begin
								data_received <= 0;
								state <= GET_STOP;
							end
							else begin
								data_received <= data_received + 1'b1;
								state <= RECEIVE;
							end
						end
						else begin
							state <= RECEIVE;
						end
					end
				GET_STOP:
					begin
                      if ((count == 14) && (sync_ff2 == 1'b1)) begin
								state <= GET_START;
								rec_busy <= 1'b0;
								rec_dataH <= data;
								rec_readyH <= 1'b1;
							end
                      else if((count == 14) && (sync_ff2 == 1'b0)) begin
								state <= GET_START;
							end
							else begin
								state <= GET_STOP;
								rec_dataH <= rec_dataH;
							end
					end
				default: state <= GET_START;
			endcase
		end
	end

endmodule
