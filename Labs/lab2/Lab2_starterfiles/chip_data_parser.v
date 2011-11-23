/*******************************************************************************
 Module: chip_data_parser.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: 
 
 Created: 2010/10/18 17:52:18 
 ******************************************************************************/

module chip_data_parser(/*AUTOARG*/
   // Outputs
   chip_data,
   // Inputs
   xclk, r, g, b
   );
   /* Inputs */
   input xclk;
   input [7:0] r, g, b;
   
   /* Outputs */
   output [11:0] chip_data;
 
   /* Inouts */

   /* Parameters */

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [11:0]		chip_data;
   // End of automatics
   /*AUTOWIRE*/


   reg [1:0] 			counter;
   wire 			toggle_every4 = counter[1];   
   
   /* Regs and Wires */
   always @(posedge xclk) begin
      counter <= counter + 1;
   end

   always @(posedge xclk) begin
      if(toggle_every4)
	chip_data <= {r[7:0], g[3:0]};
      
      else
	chip_data <= {g[7:4], b[7:0]};
      
   end
   
   /*always @(posedge xclk or negedge xclk) begin
      if(xclk)
	chip_data <= {b[7:0], g[3:0]};
      else
	chip_data <= {g[7:4], r[7:0]};
   end*/
endmodule //chip_data_parser
