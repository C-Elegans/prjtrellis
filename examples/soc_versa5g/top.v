module top(
    input 	 clkin,
    output [7:0] led,
    output 	 uart_tx,
    output 	 clk_50,
    input 	 uart_rx,
);

wire clk;
wire [7:0] int_led;

   reg 	   clk_div = 0;
   assign clk_50 = 1'b1;
   always @(posedge clk) 
     clk_div <= ~clk_div;

pll_100_50 pll(
    .clki(clkin),
    .clko(clk)
);

attosoc soc(
    .clk(clk),
    .led(int_led),
    .uart_tx(uart_tx),
    .uart_rx(uart_rx)
);

assign led = ~int_led;
endmodule
