/*
 * Zucker SOC
 * Copyright (c) 2021 Lone Dynamics Corporation. All rights reserved.
 *
 * SPI slave controller
 *
 * This receives the gamepad/joystick reports from Keks firmware as
 * 40-bit words and makes them available as 32-bit registers.
 *
 */

module rpint #()
(
	input clk,
	input resetn,

	output [31:0] rdata,
	input [1:0] rreg,

	input sclk,
	input mosi,
);

	reg [31:0] r [1:0];
	reg [39:0] xfer_buffer;
	reg [5:0] xfer_bits = 0;
	reg xfer_done = 0;
	reg xfer_done_r1;
	reg xfer_done_r2;
	reg xfer_done_r3;

	assign rdata = r[rreg];

	always @(posedge clk) begin

		xfer_done_r1 <= xfer_done;
		xfer_done_r2 <= xfer_done_r1;
		xfer_done_r3 <= xfer_done_r2;

		if (!resetn) begin
			xfer_done_r1 <= 0;
			xfer_done_r2 <= 0;
			xfer_done_r3 <= 0;
		end else if (xfer_done_r3 == 1'b0 && xfer_done_r2 == 1'b1) begin
			if (xfer_buffer[7:0] == 8'h00) begin
				r[0] <= xfer_buffer[39:8];
			end else if (xfer_buffer[7:0] == 8'h01) begin
				r[1] <= xfer_buffer[39:8];
			end
		end

	end

	always @(posedge sclk) begin

		if (xfer_bits == 39) begin
			xfer_buffer <= { xfer_buffer, mosi };
			xfer_bits <= 0;
			xfer_done <= 1;
		end else begin
			xfer_buffer <= { xfer_buffer, mosi };
			xfer_bits <= xfer_bits + 1;
			xfer_done <= 0;
		end

	end

endmodule
