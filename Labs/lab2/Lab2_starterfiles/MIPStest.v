//******************************************************************************
// EE108b MIPS verilog model
//
// MIPStest.v
//
// testbench setup for MIPS.v
// This module will only be used in MODELSIM
//
//******************************************************************************

`timescale 1ns/10ps
`include "DVI_defines.v"

module MIPStest ();

wire select;


wire chip_hsync, chip_vsync, chip_data_enable, chip_reset;
wire [11:0] chip_data;
wire [`log2NUM_COLS-1:0]x;
wire [`log2NUM_ROWS-1:0]y;


wire clk_i2c, finished, xclk, xclk_bar;

wire mipsalive;

reg MClk;
reg reset;

initial MClk = 0;

initial begin
	reset = 1;
	# 100;
	reset = 0;
	# 100;
	reset = 1;
	# 400;

	#10000000; $stop;
end

always #20 MClk = ~MClk;

MIPS mips (
	.clk			(MClk),
	.rst			(reset),
	.step		(1'b0),
	
	.display_mode	(1'b1),
	.run_mode		(1'b1),
	
	.chip_hsync	(chip_hsync),
	.chip_vsync	(chip_vsync),
	.chip_data_enable(chip_data_enable),
	.chip_reset		(chip_reset),
	.chip_data	(chip_data),
	.x	(x),
	.y (y),
	.clk_i2c(clk_i2c),
   .finished(finished),
   .xclk(xclk),
   .xclk_bar(xclk_bar),
   
   .sda(),
   
	.select		(select),
	//.mipsalive (mipsalive),
	// Feel free to change these
	.right		(1'b1),
	.left		(1'b1),
	.down		(1'b1),
	.up			(1'b1),
	.c_start		(1'b1),
	.a_b			(1'b1)
);

endmodule