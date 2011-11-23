/*******************************************************************************
 Module: DVI_defines.v
 Author: David Gal
 Email: david.gal84@gmail.com
 Project: ee108a DVI Stuff
 Descritpion: Going to drive 60 Hz 640 x 480 VGA.  Going to use 100 MHz clock
 for sync generation.  Hence the x4 factor for timing.
 
 Created: 2010/10/04 06:14:18 
 ******************************************************************************/

`define COLOR_WIDTH 8
`define COLOR_ZERO_PAD 6
`define DATA_WIDTH 24
`define NUM_COLS 2560/* 640 */
`define NUM_ROWS 480
`define log2NUM_COLS 12/* 10 */
`define log2NUM_ROWS 9
`define SYNC_PULSE 384/*96*/
`define BACK_PORCH 192/*48*/
`define FRONT_PORCH 64/*16*/
`define NUM_XCLKS_IN_ROW `NUM_COLS + `SYNC_PULSE + `BACK_PORCH + `FRONT_PORCH

`define HSYNC_PORCH 64

`define V_FRONT_PORCH 10
`define V_SYNC_PULSE 2
`define V_BACK_PORCH 33
`define NUM_LINES_IN_FRAME `NUM_ROWS + `V_FRONT_PORCH + `V_SYNC_PULSE + `V_BACK_PORCH
`define log2NUM_LINES_IN_FRAME 10

/*I2C Defines*/
`define CLOCK_RATIO 1024
`define log2DIVIDE_RATIO 10
`define DEVICE_ADDR 7'b11101

/*I2C Regs*/
`define MAX_REG_NUM 9
`define i2c_device_addr 7'h76
`define i2c_addr0 {1'b1, 7'h1C}
`define i2c_addr1 {1'b1, 7'h1D}
//`define i2c_addr2 {1'b1, 7'h1E}
`define i2c_addr3 {1'b1, 7'h1F}

//`define i2c_addr4 {1'b1, 7'h20}
`define i2c_addr5 {1'b1, 7'h21}
//`define i2c_addr6 {1'b1, 7'h23}

//`define i2c_addr7 8'h31
`define i2c_addr8 {1'b1, 7'h33}
`define i2c_addr9 {1'b1, 7'h34}
`define i2c_addr10 {1'b1, 7'h36}

`define i2c_addr11 {1'b1, 7'h48}
`define i2c_addr12 {1'b1, 7'h49}

`define i2c_data0 8'b0000_0000 /*1C*/
`define i2c_data1 8'b0100_1000 /*1D*/
//`define i2c_data2 8'b1100_0000 /*1E*/
`define i2c_data3 8'b1000_0000 /*1F*/

//`define i2c_data4 8'b0000_0000 /*20*/
`define i2c_data5 8'b0000_1111 /*21 - rgb bypass - enable sync outs!*/
//`define i2c_data6 8'b0000_0100 /*23*/

//`define i2c_data7 8'b1000_0000 /*31*/
`define i2c_data8 8'b0000_1000 /*33*/
`define i2c_data9 8'b0001_0110 /*34*/
`define i2c_data10 8'b0110_0000 /*36*/

`define i2c_data11 8'b0001_1000 /*48 set to color bars*/
`define i2c_data12 8'b0000_0000 /*49 - PM*/