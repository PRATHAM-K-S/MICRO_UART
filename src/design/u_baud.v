module u_baud
	#(
  	XTAL_CLK = 50000000, //main clock frequency
    BAUD = 115200 // required baud rate
  )
  (
  input wire clk, //main system clock
  input wire rst_l, //main system reset
  output reg uart_clk //baud-clock 16 X baud_rate
	);
  
  localparam COUNT_VAL = XTAL_CLK/(BAUD*16*2); // count value to get baud_rate
  localparam CW = $clog2(COUNT_VAL); // count width
  
  reg [CW-1:0] count; //count decleration
  
	//baud clock generator logic
  always @(posedge clk or negedge rst_l) begin
    if(!rst_l) begin
    	count <= 0;
      	uart_clk <= 0;
    end
    else begin
      if(count == COUNT_VAL-1) begin
        uart_clk <= ~uart_clk;
        count <= 0;
      end
      else
        count <= count + 1;
    end
  end
  
endmodule
