//******************************************************************************
// EE108b MIPS verilog model
//
// IF.v
//
// Calculates the next PC and retrieves the instruction from memory
//
// verilog written by Daniel L. Rosenband, MIT 10/4/99
// modified by John Kim 3/26/03
// modified by Neil Achtman, 8/15/03
//
//******************************************************************************

module IF (
	// Outputs
	pc, instr,
	// Inputs
	rst_clk, clk, memclk, clken, rst, RsData, JumpBranch, JumpTarget, JumpReg
);

	input 		rst_clk, clk, memclk;
	input		clken;
	input 		rst;			// start from PC = 0

	input 		JumpBranch;	// branch offset should be next PC
	input 		JumpTarget;	// target addr should be next PC
	input 		JumpReg;		// register data should be next PC

	input [31:0]	RsData;		// used for JR instruction
	
	output [31:0]	instr;		// current instruction
	output [31:0]	pc;			// address of instruction
  
	reg [31:0]	pc;			// program counter

//******************************************************************************
// calculate the next PC
//******************************************************************************

	`define	immediate		15:0		// 16-bit immediate, branch or address disp
	`define	targetfield		25:0		// 26-bit jump target address

	wire [15:0] offset;					// offset for next instruction, used with branches
	wire [31:0] signExtendedOffset;		// 32-bit sign extended offset
	wire [25:0] target;					// used with J/JAL instructions
	wire 	  dff_rst;

	dffre dffre(.clk(rst_clk), .d(rst), .q(dff_rst), .r(1'b0), .en(1'b1));

	// MODIFY THE CODE BELOW SO THAT THE PROCESSOR HANDLES JUMPS AND BRANCHES CORRECTLY

	always @(posedge clk) begin
		if (dff_rst)
			pc <= 32'b0;
		else if (clken) begin
				pc <= pc + 3'h4;
		end else
			pc <= pc;
	end

//******************************************************************************
// instruction memory instantiation
//******************************************************************************

	irom irom (.addra(pc[10:2]), .clka(memclk), .douta(instr));

endmodule
