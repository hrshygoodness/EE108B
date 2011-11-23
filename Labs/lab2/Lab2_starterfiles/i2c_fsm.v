/*******************************************************************************
 Module: i2c_fsm.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: 
 
 Created: 2010/10/22 21:15:07 
 ******************************************************************************/

`include "DVI_defines.v"

module i2c_fsm(/*AUTOARG*/
   // Outputs
   output_shift_reg_enable, fsm_out_sda, use_mem_data, fsm_drive_sda,
   fsm_select, i2c_clock_enable, done_one_reg, byte_select, load,
   // Inputs
   clk, go, read, middle_low_cycle_pulse, middle_high_cycle_pulse,
   i2c_clk_high_low
   );
   /* Inputs */
   input clk;
   input go;
   input read;
   input middle_low_cycle_pulse;
   input middle_high_cycle_pulse;
   input i2c_clk_high_low;
   
   /* Outputs */
   output output_shift_reg_enable;
   output fsm_out_sda;
   output use_mem_data;
   output fsm_drive_sda;
   output [1:0] fsm_select;
   output 	i2c_clock_enable;
   output 	done_one_reg;
   output 	byte_select;
   output 	load;
   
   /* Inouts */

   /* Parameters */
   localparam IDLE = 0;
   localparam START = 1;
   localparam DEVICE_ADDR = 2;
   localparam WAIT_ACK_STATE = 3;
   localparam ADDR_STATE = 4;
   localparam WAIT_ACK_STATE2 = 5;
   localparam DATA_STATE = 6;
   localparam WAIT_ACK_STATE3 = 7;
   localparam STOP = 8;

   localparam LOW_SDA_VALUE = 0;
   localparam HIGH_SDA_VALUE = 1;
   localparam ACTIVE_SDA_VALUE = 2;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			fsm_drive_sda;
   reg			i2c_clock_enable;
   reg			load;
   reg			output_shift_reg_enable;
   // End of automatics
   /*AUTOWIRE*/

   /* Regs and Wires */
   reg [3:0] state, next_state;
   reg 	     fsm_out_sda;
   reg [3:0] state_counter;
   reg 	     use_mem_data;
   reg [1:0] fsm_select;
   reg 	     got_middle_high_pulse;
   reg 	     enable_state_counter;
   reg 	     done_one_reg;
   reg 	     byte_select;
   
   always @(posedge clk) begin
      if(state == IDLE | middle_low_cycle_pulse)
	got_middle_high_pulse <= 0;
      else if(middle_high_cycle_pulse)
	got_middle_high_pulse <= 1;
   end
   always @(posedge clk) begin
      if(state == IDLE | ~enable_state_counter)
	state_counter <= 0;
      else if(middle_low_cycle_pulse & enable_state_counter)
	state_counter <= state_counter + 1;
   end
   
   always @(posedge clk) begin
      state <= next_state;
   end

   always @(*) begin
      use_mem_data = 0;
      fsm_drive_sda = 1;
      fsm_select = HIGH_SDA_VALUE;
      i2c_clock_enable = 1;
      done_one_reg = 0;
      output_shift_reg_enable = 0;
      
      enable_state_counter = 0;
      fsm_out_sda = 1;
      next_state = IDLE;

      byte_select = 1;
      load = 0;
      
      case(state)
	IDLE: begin
	   i2c_clock_enable = 0;
	   if(go)
	     next_state = START;
	end

	START: begin
	   next_state = START;
	   enable_state_counter = 0;
	   if(got_middle_high_pulse) begin
	      fsm_select = LOW_SDA_VALUE;
	      
	   end

	   //Transition state half way through the low clock
	   if(middle_low_cycle_pulse) begin
	      next_state = DEVICE_ADDR;
	      load = 1;
	      
	   end
	end

	DEVICE_ADDR: begin
	   next_state = DEVICE_ADDR;
	  
	   
	   fsm_select = ACTIVE_SDA_VALUE;
	   enable_state_counter = 1;
	   output_shift_reg_enable = 1;
	   use_mem_data = 0;
	   if(state_counter == 7 & middle_low_cycle_pulse) begin
	     next_state = WAIT_ACK_STATE;
	      use_mem_data = 1;
	   end
	     
	end

	WAIT_ACK_STATE: begin
	   enable_state_counter = 0;
	   use_mem_data = 1;
	   
	   //fsm_select = ACTIVE_SDA_VALUE;	   
	   next_state = WAIT_ACK_STATE;
	   fsm_drive_sda = 0;
	   if(i2c_clk_high_low) begin
	      next_state = ADDR_STATE;
	      load = 1;
	   end
      	end
	
	ADDR_STATE: begin
	   fsm_select = ACTIVE_SDA_VALUE;
	   
	   next_state = ADDR_STATE;
	   enable_state_counter = 1;
	   output_shift_reg_enable = 1;
	   use_mem_data = 1;
	   
	   if(state_counter == 7 & middle_low_cycle_pulse)
	     next_state = WAIT_ACK_STATE2;
	end

	WAIT_ACK_STATE2: begin
	   next_state = WAIT_ACK_STATE2;
	   enable_state_counter = 0;
	   use_mem_data = 1;
	   
	   fsm_drive_sda = 0;
	   if(i2c_clk_high_low) begin
	      next_state = DATA_STATE;
	      byte_select = 0;
	      
	      load = 1;
	   end
	end

	DATA_STATE: begin
	   byte_select = 0;
	   
	   next_state = DATA_STATE;
	   fsm_select = ACTIVE_SDA_VALUE;
	   enable_state_counter = 1;
	   output_shift_reg_enable = 1;
	   use_mem_data = 1;
	   
	   if(state_counter == 7 & middle_low_cycle_pulse)
	     next_state = WAIT_ACK_STATE3;
	   
	end

	WAIT_ACK_STATE3: begin
	   next_state = WAIT_ACK_STATE3;
	   fsm_drive_sda = 0;
	   if(i2c_clk_high_low)
	     next_state = STOP;
	   
	end

	STOP: begin
	   next_state = STOP;
	   fsm_drive_sda = 1;
	   fsm_select = LOW_SDA_VALUE;
	   
	   if(middle_high_cycle_pulse) begin
	      fsm_drive_sda = 1;
	      fsm_select = HIGH_SDA_VALUE;
	      next_state = IDLE;
	      done_one_reg = 1;
	      
	   end
	   
	end
      endcase // case (state)
   end
endmodule //i2c_fsm
