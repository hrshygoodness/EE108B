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

wire tb_select;


wire tb_chip_hsync, tb_chip_vsync, tb_chip_data_enable, tb_chip_reset;
wire [11:0] tb_chip_data;
wire [`log2NUM_COLS-1:0]tb_x;
wire [`log2NUM_ROWS-1:0]tb_y;


wire tb_clk_i2c, tb_finished, tb_xclk, tb_xclk_bar;

//wire mipsalive;

reg tb_MClk;
reg tb_reset_n;

initial tb_MClk = 0;

initial begin
	tb_reset_n = 1;
	# 100;
	tb_reset_n = 0;
	# 100;
	tb_reset_n = 1;
	# 400;

	#10000000; $stop;
end

always #20 tb_MClk = ~tb_MClk;

MIPS mips_inst0 (
	.clk			(tb_MClk),
	.rst			(tb_reset_n),
	.step		(1'b0),
	
	.display_mode	(1'b1),
	.run_mode		(1'b1),
	
	.chip_hsync	(tb_chip_hsync),
	.chip_vsync	(tb_chip_vsync),
	.chip_data_enable(tb_chip_data_enable),
	.chip_reset		(tb_chip_reset),
	.chip_data	(tb_chip_data),
	.x	(tb_x),
	.y (tb_y),
	.clk_i2c(tb_clk_i2c),
   .finished(tb_finished),
   .xclk(tb_xclk),
   .xclk_bar(tb_xclk_bar),
   
   .sda(),
   
	.select		(tb_select),
	//.mipsalive (mipsalive),
	// Feel free to chanWge these
	.right		(1'b1),
	.left		(1'b1),
	.down		(1'b1),
	.up			(1'b1),
	.c_start		(1'b1),
	.a_b			(1'b1)
);

initial
    $monitor("time=%t, rst=%b, clk=%b, count=%b\n", $time, rst, clk, count);
 

endmodule