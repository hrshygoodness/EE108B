/*******************************************************************************
 Module: i2c_clk_gen.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: Clock division to realize I2C clock.  Assumed input clock of
 100 MHz.  Divided by a factor defined in DVI_defines.v
 
 Created: 2010/10/22 18:11:29 
 ******************************************************************************/

//`include "DVI_defines.v"
`define CLOCK_RATIO 1024
`define log2DIVIDE_RATIO 10

module i2c_clk_gen(/*AUTOARG*/
   // Outputs
   clk_i2c, middle_low_cycle_pulse, middle_high_cycle_pulse,
   i2c_clk_high_low, i2c_clk_low_high,
   // Inputs
   clk, i2c_clock_enable
   );
   /* Inputs */
   input clk;
   input i2c_clock_enable;
   
   /* Outputs */
   output clk_i2c;
   output middle_low_cycle_pulse;
   output middle_high_cycle_pulse;
   output i2c_clk_high_low;
   output i2c_clk_low_high;
   
   /* Inouts */

   /* Parameters */

   /*AUTOREG*/
   /*AUTOWIRE*/
   
   /* Regs and Wires */
   reg [`log2DIVIDE_RATIO-1:0] counter;
   wire 		       clk_i2c;
   wire 		       middle_cycle_pulse;
   wire 		       i2c_clk_high_low, i2c_clk_low_high;
   
   always @(posedge clk) begin
      if(~i2c_clock_enable)
	counter <= 10'b10_0000_0000;
      else
	counter <= counter + 1;
   end

   //50% duty cycle i2c clock
   assign clk_i2c = counter[`log2DIVIDE_RATIO - 1];

   //System Clock width pulses
   assign middle_low_cycle_pulse = counter == 256;
   assign middle_high_cycle_pulse = counter == 768;
   assign i2c_clk_high_low = counter == 0;
   assign i2c_clk_low_high = counter == 512;
endmodule //i2c_clk_gen
