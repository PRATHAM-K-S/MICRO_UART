module uart
	#(
		XTAL_CLK = 50000000,
		BAUD = 115200,
		WORD_LEN = 8
	)
	(
		input wire sys_clk,
		input wire sys_rst_l,
		input wire xmitH,
		input wire [WORD_LEN-1:0] xmit_dataH,
		input wire uart_REC_dataH,
		input [WORD_LEN-1:0] rec_dataH,
		output wire uart_XMIT_dataH,
		output wire xmit_active,
		output wire xmit_doneH,
		output wire rec_readyH,
		output wire rec_busy
	);

	wire uart_clk;

	u_baud
	#(
		.XTAL_CLK(XTAL_CLK),
		.BAUD(BAUD)
	)
	baud (
		.clk(sys_clk),
		.rst_l(sys_rst_l),
		.uart_clk(uart_clk)
	);

	u_xmit
	#(
		.WORD_LEN(WORD_LEN)
	)
	tx (
		.clk(uart_clk),
		.rst_l(sys_rst_l),
		.xmitH(xmitH),
		.xmit_dataH(xmit_dataH),
		.uart_XMIT_dataH(uart_XMIT_dataH),
		.xmit_doneH(xmit_doneH)
	);

	u_rec
	#(
		.WORD_LEN(WORD_LEN)
	)
	rx (
		.clk(uart_clk),
		.rst_l(sys_rst_l),
		.uart_REC_dataH(uart_REC_dataH),
		.rec_dataH(rec_dataH),
		.rec_readyH(rec_readyH),
		.rec_busy(rec_busy)
	);

endmodule
