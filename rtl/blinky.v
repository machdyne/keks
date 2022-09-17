module blinky #()
(
	input CLK_100,

	output LED_R, LED_G, LED_B,

	inout PMOD_A1, PMOD_A2, PMOD_A3, PMOD_A4,
		PMOD_A7, PMOD_A8, PMOD_A9, PMOD_A10,

);

	wire clk = CLK_100;

	reg [26:0] counter = 0;

	assign LED_R = ~counter[26];
	assign LED_G = ~counter[25];
	assign LED_B = ~counter[24];

	always @(posedge clk) begin

		counter <= counter + 1;

	end

endmodule
