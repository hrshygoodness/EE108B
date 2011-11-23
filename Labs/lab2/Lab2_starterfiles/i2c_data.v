/*******************************************************************************
 Module: i2c_data.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: 
 
 Created: 2010/10/22 21:53:09 
 ******************************************************************************/

`include "DVI_defines.v"

module i2c_data(/*AUTOARG*/
   // Outputs
   shift_reg_out,
   // Inputs
   clk, fsm_enable, middle_low_cycle_pulse, reg_num, read,
   use_mem_data, byte_select, load
   );
   /* Inputs */
   input clk;
   input fsm_enable;
   input middle_low_cycle_pulse;
   input [3:0] reg_num;
   input       read;
   input       use_mem_data;
   input       byte_select;
   input       load;
   
   /* Outputs */
   output      shift_reg_out;
   
   /* Inouts */

   /* Parameters */

   /*AUTOREG*/
   /*AUTOWIRE*/
   
   /* Regs and Wires */
  

   //Small Memory to Hold Values
   reg [15:0] mem [`MAX_REG_NUM-1:0];
   reg [15:0] mem_data_out;
   wire [7:0]  shift_reg_data;
   wire        shift_reg_out;
   reg [7:0]   shift_reg_contents;

   wire [7:0]  register_address = mem_data_out[15:8];
   wire [7:0]  register_data = mem_data_out[7:0];
   
   assign shift_reg_out = shift_reg_contents[7];
   
   assign shift_reg_data = use_mem_data ? (byte_select ? mem_data_out[15:8] : mem_data_out[7:0]) : {`i2c_device_addr, read};

   always @(posedge clk) begin
      if(load)
	shift_reg_contents <= shift_reg_data;
      else if(fsm_enable & middle_low_cycle_pulse)
	shift_reg_contents <= (shift_reg_contents << 1);//{shift_reg_contents[7:1], 1'b0};
      else
	shift_reg_contents <= shift_reg_contents;
      
    end
   
   initial begin	      
      mem[0]  = {`i2c_addr0, `i2c_data0};
      mem[1] = {`i2c_addr1, `i2c_data1};
      //mem[2] = {`i2c_addr2, `i2c_data2};
      mem[2] = {`i2c_addr3, `i2c_data3};
      //mem[4] = {`i2c_addr4, `i2c_data4};
      mem[3] = {`i2c_addr5, `i2c_data5};
      //mem[6] = {`i2c_addr6, `i2c_data6};
      //mem[7] = {`i2c_addr7, `i2c_data7};
      mem[4] = {`i2c_addr8, `i2c_data8};
      mem[5] = {`i2c_addr9, `i2c_data9};
      mem[6] = {`i2c_addr10, `i2c_data10};
      mem[7] = {`i2c_addr11, `i2c_data11};
      mem[8] = {`i2c_addr12, `i2c_data12};
   end
   
   always @(posedge clk) begin
      mem_data_out <= mem[reg_num];
   end
      
endmodule //i2c_data
