/*******************************************************************************
 Module: DVI_Controller_Top.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: 
 
 Created: 2010/10/04 05:54:02 
 ******************************************************************************/

`include "DVI_defines.v"

module DVI_Controller_Top(/*AUTOARG*/
   // Outputs
   chip_data_enable, chip_hsync, chip_vsync, chip_reset, chip_data, x,
   y,
   // Inputs
   xclk, enable, reset, r, g, b
   );
   /* Inputs */
   input xclk;
   input enable;
   input reset;
   input [`COLOR_WIDTH - 1:0] r, g, b;
   
   /* Outputs */
   output chip_data_enable;
   output chip_hsync;
   output chip_vsync;
   output chip_reset;
   output [11:0] chip_data;
   output [`log2NUM_COLS-1:0] x;
   output [`log2NUM_ROWS-1:0] y;
   
   /* Inouts */

   /* Parameters */

   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			valid_data;		// From gen_sync of sync_generators.v
   // End of automatics
   
   /* Regs and Wires */
   wire [`log2NUM_COLS-1:0] x;
   wire [`log2NUM_ROWS-1:0] y;
   wire 		    hsync, vsync;
   
   wire [11:0] 		    chip_data;
   wire 		    chip_hsync = hsync;
   wire 		    chip_vsync = vsync;
   /* Active Output */
   wire 		    chip_reset = 1;
   wire 		    chip_data_enable = valid_data;
   wire 		    enable;
   
   /* Sync Generator */
   sync_generators gen_sync(/*AUTOINST*/
			    // Outputs
			    .hsync		(hsync),
			    .vsync		(vsync),
			    .valid_data		(valid_data),
			    .y			(y[`log2NUM_ROWS-1:0]),
			    .x			(x[`log2NUM_COLS-1:0]),
			    // Inputs
			    .xclk		(xclk),
			    .reset		(reset),
			    .enable		(enable));
   
   /* Double Pumped Flops */
   chip_data_parser make_chip_data(/*AUTOINST*/
				   // Outputs
				   .chip_data		(chip_data[11:0]),
				   // Inputs
				   .xclk		(xclk),
				   .r			(r[7:0]),
				   .g			(g[7:0]),
				   .b			(b[7:0]));
   
endmodule //DVI_Controller_Top
