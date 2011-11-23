/*******************************************************************************
 Module: i2c_sda_mux.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: 
 
 Created: 2010/10/23 20:25:35 
 ******************************************************************************/

module i2c_sda_mux(/*AUTOARG*/
   // Outputs
   sda_in,
   // Inouts
   sda,
   // Inputs
   clk, shift_reg_out, fsm_select, fsm_drive_sda
   );
   /* Inputs */
   input clk;
   input       shift_reg_out;
   input [1:0] fsm_select;
   input       fsm_drive_sda;
   
   /* Outputs */
   output      sda_in;
   
   /* Inouts */
   inout       sda;
   
   /* Parameters */

   /*AUTOREG*/
   /*AUTOWIRE*/
   
   /* Regs and Wires */
   wire        sda, sda_in;
   reg 	       sda_out;
   
   always @(*) begin
      case(fsm_select)
	0: sda_out = 0;
	1: sda_out = 1;
	2: sda_out = shift_reg_out;
	default: sda_out = 1;
      endcase // case (fsm_select)
   end
   
   /* Tri state buffer for sda */
   assign sda = fsm_drive_sda ? sda_out : 1'bz;
   assign sda_in = sda;
   
endmodule //i2c_sda_mux
