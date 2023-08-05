/*
 * Zucker SOC
 * Copyright (c) 2021 Lone Dynamics Corporation. All rights reserved.
 *
 * SPI slave controller
 *
 * This receives 16 byte gamepad/joystick reports from Keks firmware as
 * makes them available as 120-bit registers.
 *
 */

module rpint #()
(
	input clk,
	input resetn,

	output reg [127:0] ldata,
	output reg [127:0] rdata,

	input sclk,
	input mosi,
);

	reg [127:0] xfer_buffer;
	reg [7:0] xfer_bits = 0;
	reg xfer_done = 0;
	reg xfer_done_r1;
	reg xfer_done_r2;
	reg xfer_done_r3;

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
				ldata <= xfer_buffer[127:0];
			end else if (xfer_buffer[7:0] == 8'h01) begin
				rdata <= xfer_buffer[127:0];
			end
		end

	end

	always @(posedge sclk) begin

		if (xfer_bits == 127) begin
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
