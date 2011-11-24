//******************************************************************************
// EE108b MIPS verilog model
//
// MIPS.v
//
// Top-level module for MIPS processor implementation.
//
// verilog written by Daniel L. Rosenband, MIT 10/4/99
// modified by John Kim, 3/26/03
// modified by Neil Achtman, 8/15/03
//
//******************************************************************************

`include "DVI_defines.v"
module MIPS (
	chip_hsync, chip_vsync, chip_data, chip_data_enable, chip_reset, x, y,
	clk, rst, right, left, down, up, c_start, a_b, select,
	display_mode, run_mode, step, clk_i2c, sda, finished, xclk, xclk_bar
);

	input		clk;				// 100 MHz --> might have to reduce to 50 if doesn't work
	input		rst;				// active low reset

	// Input from Sega gamepad
	input		right, left, down, up, c_start, a_b;
	output		select;

	// Mode control
	input		display_mode;		// toggle between debug and run
	input		run_mode;			// whether to step through 1 instruction at a time
	input		step;			// step through 1 instruction

	// VGA-related signals
	output  		chip_hsync, chip_vsync;
	wire  		vga_red0, vga_green0, vga_blue0, vga_red1, vga_green1, vga_blue1;
	output chip_data_enable, chip_reset;
	output [11:0] chip_data;
  output [`log2NUM_COLS-1:0] x;
  output [`log2NUM_ROWS-1:0] y;
  output xclk, xclk_bar; // 25 MHz -- has to be 25
	
	// i2c signals
	output clk_i2c, finished;
	inout sda;
	
	
	wire clk_i2c, sda, finished;

	// Clock signals
	wire 		mipsclk;			// clock for processor (12.5 MHz)
	wire 		memclk; 			// clock for memory (25 MHz, inverted)
	wire			step_pulse;		// one cycle pulse from step button

	// IF input
	wire 		JumpBranch;		// use the branch offset for next pc
	wire	  		JumpTarget;		// use the target field for next pc
	wire	  		JumpReg;			// use data in Rs for next pc
	
	// IF output
	wire [31:0]	instr;			// current instruction
	wire [31:0]	pc;				// current pc

	// Regfile input
	wire [31:0]	RegWriteData;		// data to be written to register file
	wire [4:0] 	RegWriteAddr;		// address of register to be written to
	wire 	 	RegWriteEn;		// whether to write to a register
	
	// Regfile output
	wire [31:0]	RsData;
	wire [31:0]	RtData;

	// ALU input
	wire [31:0]	ALUOpX, ALUOpY;	// ALU operands
	wire [3:0]	ALUOp;			// ALU operation to perform
	
	// ALU output
	wire			ALUZero, ALUNeg;	// whether ALU result is 0 or negative
	wire [31:0]	ALUResult;		// ALU result

	// Data memory interface
	wire [31:0]	DMemAddr;			// address to access in memory
	wire 	 	DMemWE;			// whether to write to memory
	wire			VgaWE;			// whether to write to VGA interface
	wire [31:0]	SegaData;			// data from Sega gamepad
	wire clk_50mhz;

//******************************************************************************
// Instruction Fetch unit
//******************************************************************************


	IF IF_inst0 (
		// Outputs
		.pc				(pc),        
		.instr			(instr),
		
		// Inputs
		.rst_clk (clk),
		.clk				(mipsclk),
		.memclk			(memclk),
		.clken			(run_mode || step_pulse),
		.rst           	(~rst),
		.JumpBranch		(JumpBranch), 
		.JumpTarget 		(JumpTarget),
		.JumpReg			(JumpReg),
		.RsData			(RsData)
	);

//******************************************************************************
// Instruction Decode unit
//******************************************************************************
	Decode Decode_inst0(
		// Outputs
   		.JumpBranch		(JumpBranch), 
		.JumpTarget 		(JumpTarget),
		.JumpReg			(JumpReg),
		.ALUOp			(ALUOp),
		.ALUOpX			(ALUOpX),
		.ALUOpY			(ALUOpY),
		.MemToReg			(MemToReg),
		.MemWrite			(MemWrite),
		.RegWriteAddr		(RegWriteAddr),
		.RegWriteEn		(RegWriteEn),
	
		// Inputs
		.instr			(instr),
		.pc				(pc),
		.RsData			(RsData),
		.RtData			(RtData),
		.ALUZero			(ALUZero),
		.ALUNeg			(ALUNeg)
	);

//******************************************************************************
// Register File
//******************************************************************************

	`define	rs			25:21	// 5-bit source register specifier
	`define	rt			20:16	// 5-bit source/dest register specifier

	RegFile RegFile_inst0 (
		// Outputs
		.RsData			(RsData),
		.RtData			(RtData),

		// Inputs
		.clk				(mipsclk),
		.clken			(run_mode || step_pulse),
		.RegWriteData		(RegWriteData),
		.RegWriteAddr		(RegWriteAddr),
		.RegWriteEn		(RegWriteEn),
		.RsAddr			(instr[`rs]),
		.RtAddr			(instr[`rt])
	);

//******************************************************************************
// ALU (Execution Unit)
//******************************************************************************

	ALU ALU_inst0 (
		// Outputs
		.ALUResult		(ALUResult),
		.ALUZero			(ALUZero),
		.ALUNeg			(ALUNeg),
		
		// Inputs
		.ALUOp			(ALUOp),
		.ALUOpX			(ALUOpX),
		.ALUOpY			(ALUOpY)
	);

//******************************************************************************
// Interface with Data Memory
//******************************************************************************

	MemStage MemStage_inst0 (
		// Outputs
		.VgaWE			(VgaWE),
		.RegWriteData		(RegWriteData),

		// Inputs			
		.clk				(memclk),
		.MemToReg			(MemToReg),
		.MemWrite			(MemWrite),
		.ALUResult		(ALUResult),
		.RtData			(RtData),
		.SegaData			(SegaData)
	);

//******************************************************************************
// Clock generator
//******************************************************************************

	// CLK = 50Mhz : main clock coming from the XSA board
	// CLK/2 = memclk (25Mhz) (inverted)
	// Clk/4 = mipsclk (12.5MHz)

	CLKgen  CLKgen_inst0 (
		// Outputs
		.mipsclk			(mipsclk),
		.memclk			(memclk),
		.step_pulse		(step_pulse),
	  .clk_out (clk_50mhz),
		// Inputs
		.clk_in				(clk),
		.rst				(~rst),
		.step			(~step)
	);

//******************************************************************************
// VGA interface
//******************************************************************************

	VGA_ctl VGA_ctl_inst0 (
		// Outputs
		.vga_hsync		(),
		.vga_vsync		(),
		.vga_red0			(vga_red0),
		.vga_green0		(vga_green0),
		.vga_blue0		(vga_blue0), 
		.vga_red1			(vga_red1),
		.vga_green1		(vga_green1),
		.vga_blue1		(vga_blue1),
		
		// Inputs
		.reset(~rst),
		.clka				(mipsclk),
		.clkb (clk),
		.mode			(display_mode),
		.din				(RtData),
		.enable			(VgaWE),
		.instr			(instr),
		.pc				(pc[9:2]),
		.opx				(ALUOpX),
		.opy				(ALUOpY),
		.result			(RegWriteData),
		.x ({x, 1'b0}),
		.y (y)
	);

//******************************************************************************
// Sega controller interface
//******************************************************************************

	Sega_ctl sega_ctl_inst0 (
		// Outputs
		.move			(SegaData),
		
		// Inputs
		.clk				(clk_50mhz),
		.up				(up),
		.down			(down),
		.left			(left),
		.right			(right),
		.a_b				(a_b),
		.c_start			(c_start),
		.select			(select)
	);
	
  //******************************************************************************
  // i2c controller interface
  //******************************************************************************
  
  i2c_top i2c_controller_inst0(
    // Outputs
      .clk_i2c(clk_i2c),
      .finished(finished),
    // Inouts
      .sda(sda),
    // Inputs
      .clk(clk),
      .external_go(~rst),
      .reset(~rst)
      );
      
//******************************************************************************
// DVI controller interface
//******************************************************************************

  DVI_Controller_Top dvi_ctrl_inst0(/*AUTOINST*/
    // Outputs
      .chip_data_enable(chip_data_enable),
      .chip_hsync(chip_hsync),
      .chip_vsync(chip_vsync),
      .chip_reset(chip_reset),
      .chip_data(chip_data),
      .x(x),
      .y(y),
    // Inputs
      .xclk(clk),
      .enable(1'b1),
      .r({vga_red1, vga_red0, `COLOR_ZERO_PAD'b0}),
      .g({vga_green1, vga_green0, `COLOR_ZERO_PAD'b0}),
      .b({vga_blue1, vga_blue0, `COLOR_ZERO_PAD'b0}),
      .reset(~rst)
      );
      
  clkdiv clk_divider_inst0(
    // Outputs
      .reset(~rst),
      .source_clk(clk),
      .destclk(xclk),
      .destclk_n(xclk_bar)
      );

endmodule
