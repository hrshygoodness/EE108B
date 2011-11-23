/*******************************************************************************
 Module: i2c_top.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: 
 
 Created: 2010/10/24 01:51:08 
 ******************************************************************************/

`include "DVI_defines.v"

module i2c_top(/*AUTOARG*/
   // Outputs
   clk_i2c, finished,
   // Inouts
   sda,
   // Inputs
   clk, external_go, reset
   );
   /* Inputs */
   input clk;
   input external_go;
   input reset;
   
   /* Outputs */
   output clk_i2c;
   output finished;
   
   /* Inouts */
   inout sda;
   
   /* Parameters */

   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			i2c_clk_high_low;	// From gen_i2c_clk of i2c_clk_gen.v
   wire			i2c_clk_low_high;	// From gen_i2c_clk of i2c_clk_gen.v
   wire			middle_high_cycle_pulse;// From gen_i2c_clk of i2c_clk_gen.v
   wire			middle_low_cycle_pulse;	// From gen_i2c_clk of i2c_clk_gen.v
   // End of automatics
   
   /* Regs and Wires */
   //write everything
   wire 		done_one_reg;
   reg 			fsm_go;
   wire 		go = external_go;
   
   wire  read = 0;
   reg [3:0] reg_num;
   wire      finished = reg_num == `MAX_REG_NUM;
   wire [1:0] fsm_select;
   
   always @(posedge clk) begin
      if(reset)
	reg_num <= 0;
      if(done_one_reg)
	reg_num <= reg_num + 1;
   end

   always @(posedge clk) begin
      if(reg_num < `MAX_REG_NUM & done_one_reg)
	fsm_go <= 1;
      else
	fsm_go <= 0;
   end
   
   i2c_fsm fsm(/**/
	       // Outputs
	       .output_shift_reg_enable	(output_shift_reg_enable),
	       .fsm_out_sda		(fsm_out_sda),
	       .use_mem_data		(use_mem_data),
	       .fsm_drive_sda		(fsm_drive_sda),
	       .fsm_select		(fsm_select[1:0]),
	       .i2c_clock_enable	(i2c_clock_enable),
	       .done_one_reg		(done_one_reg),
	       .byte_select		(byte_select),
	       .load			(load),
	       // Inputs
	       .clk			(clk),
	       .go			(fsm_go | (external_go & reg_num == 0)),
	       .read			(read),
	       .middle_low_cycle_pulse	(middle_low_cycle_pulse),
	       .middle_high_cycle_pulse	(middle_high_cycle_pulse),
	       .i2c_clk_high_low	(i2c_clk_high_low));

   i2c_data i2c_data_path(/**/
			  // Outputs
			  .shift_reg_out	(shift_reg_out),
			  // Inputs
			  .clk			(clk),
			  .fsm_enable		(output_shift_reg_enable),
			  .middle_low_cycle_pulse(middle_low_cycle_pulse),
			  .reg_num		(reg_num[3:0]),
			  .read			(read),
			  .use_mem_data		(use_mem_data),
			  .byte_select		(byte_select),
			  .load			(load));

   i2c_sda_mux sda_mux(/**/
		       // Outputs
		       .sda_in		(sda_in),
		       // Inouts
		       .sda		(sda),
		       // Inputs
		       .clk		(clk),
		       .shift_reg_out	(shift_reg_out),
		       .fsm_select	(fsm_select[1:0]),
		       .fsm_drive_sda	(fsm_drive_sda));

   i2c_clk_gen gen_i2c_clk(/*AUTOINST*/
			   // Outputs
			   .clk_i2c		(clk_i2c),
			   .middle_low_cycle_pulse(middle_low_cycle_pulse),
			   .middle_high_cycle_pulse(middle_high_cycle_pulse),
			   .i2c_clk_high_low	(i2c_clk_high_low),
			   .i2c_clk_low_high	(i2c_clk_low_high),
			   // Inputs
			   .clk			(clk),
			   .i2c_clock_enable	(i2c_clock_enable));

endmodule //i2c_top
