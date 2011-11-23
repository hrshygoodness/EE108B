/*******************************************************************************
 Module: sync_generators.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: HSYNC and VSYNC generators
 
 Created: 2010/10/04 06:46:18 
 ******************************************************************************/

`include "DVI_defines.v"

module sync_generators(/*AUTOARG*/
   // Outputs
   hsync, vsync, valid_data, y, x,
   // Inputs
   xclk, reset, enable
   );
   /* Inputs */
   input xclk;
   input reset;
   input enable;
   
   /* Outputs */
   output hsync, vsync;
   output valid_data;
   output [`log2NUM_ROWS - 1:0] y;
   output [`log2NUM_COLS - 1:0] x;
   
   /* Inouts */

   /* Parameters */

   /*AUTOREG*/
   /*AUTOWIRE*/
   
   /* Regs and Wires */
   reg [`log2NUM_COLS - 1:0] pixel_counter;
   reg [`log2NUM_COLS:0]     vsync_pulse_counter;
   reg [`log2NUM_LINES_IN_FRAME-1:0]     hsync_counter;
   wire 		     vsync, hsync;
   wire 		     valid_data;
   wire 		     valid_h, valid_v;
   reg [`log2NUM_ROWS - 1:0] y;
   reg [`log2NUM_COLS - 1:0] x;
   
   /* Logic for X, Y Outputs */
   assign valid_data = valid_h & valid_v;
   
   /* Counts pixels in a row...row counter is incemented every 
      row */
   always @(posedge xclk) begin
      if (reset)
        pixel_counter <= 0;
      else if((pixel_counter == `NUM_XCLKS_IN_ROW-1))  //add back reset
	pixel_counter <= 0;
      else if((pixel_counter != `NUM_XCLKS_IN_ROW-1)&&enable)
	pixel_counter <= pixel_counter + 1;
   end

   /* Combinational Logic for hsync */
   assign hsync = pixel_counter >= `SYNC_PULSE; 

   /* Count the hsyncs */
   always @(posedge xclk) begin
     if(reset)
       hsync_counter <= 0;
    else if((hsync_counter == (`NUM_LINES_IN_FRAME)))  //add back reset
	hsync_counter <= 0;
      else if(enable & (pixel_counter == `NUM_XCLKS_IN_ROW-1))
	hsync_counter <= hsync_counter + 1;
   end

   /* Comb L for vsync */
   assign vsync = (hsync_counter != `NUM_LINES_IN_FRAME) & (hsync_counter >= (`V_SYNC_PULSE));

   assign valid_h = (pixel_counter >= (`SYNC_PULSE + `BACK_PORCH)) & (pixel_counter <= (`NUM_XCLKS_IN_ROW - `FRONT_PORCH));
   assign valid_v = (hsync_counter >= (`V_SYNC_PULSE + `V_BACK_PORCH)) & (hsync_counter <= (`NUM_LINES_IN_FRAME - `V_FRONT_PORCH));


   /* X & Y Generation */
   always @(posedge xclk) begin
      if(~valid_h)
	x<=0;
      else
	x<= ((pixel_counter - `SYNC_PULSE - `BACK_PORCH) >> 2);
      
   end

   always @(posedge xclk) begin
      if(~valid_v)
	y <= 0;
      else if(enable & (pixel_counter == `NUM_XCLKS_IN_ROW-1))
	y <= y+1;
   end
endmodule //sync_generators
