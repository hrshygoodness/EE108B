//******************************************************************************
// EE108b MIPS verilog model
//
// ALU.v
//
// The ALU performs all the arithmetic/logical integer operations 
// specified by the ALUsel from the decoder. 
// 
// verilog written by Daniel L. Rosenband, MIT 10/4/99
// modified by John Kim 3/26/03
// modified by Neil Achtman 8/15/03
//
//******************************************************************************

module ALU (
	// Outputs
	ALUResult, ALUZero, ALUNeg,

	// Inputs
	ALUOp, ALUOpX, ALUOpY
);



	input [3:0]	ALUOp;				// Operation select
	input [31:0]	ALUOpX, ALUOpY;		// operands

	output [31:0]	ALUResult;			// result of operation
	output		ALUZero, ALUNeg;		// result is 0 or negative

//******************************************************************************
// Shift operation: ">>>" will perform an arithmetic shift, but the operand
// must be reg signed
//******************************************************************************
	reg signed [31:0] signedALUOpY;
	
	always @(ALUOpY) begin
		signedALUOpY = ALUOpY;
	end

//******************************************************************************
// Set operation
//******************************************************************************
	wire			aNbP, aPbN, sameSign;	// x < 0 and y > 0, x > 0 and y < 0, x and y are both > 0 or < 0
	wire [31:0]	subRes;				// x - y
	wire			isSLT, isSLTU;			// x < y, x < y unsigned
	
	reg[31:0] PC, Regs[0:31], IMemory[0:1023], DMemory[0:1023], // separate memories
IFIDIR, IDEXA, IDEXB, IDEXIR, EXMEMIR, EXMEMB, // pipeline registers
EXMEMALUOut, MEMWBValue, MEMWBIR; // pipeline registers
wire [4:0] IDEXrs, IDEXrt, EXMEMrd, MEMWBrd, MEMWBrt; // Access register fi elds
wire [5:0] EXMEMop, MEMWBop, IDEXop; // Access opcodes
wire [31:0] Ain, Bin; // the ALU inputs
// These assignments defi ne fi elds from the pipeline registers
assign IDEXrs = IDEXIR[25:21]; // rs fi eld
assign IDEXrt = IDEXIR[15:11]; // rt fi eld
assign EXMEMrd = EXMEMIR[15:11]; // rd fi eld
assign MEMWBrd = MEMWBIR[20:16]; //rd fi eld
assign MEMWBrt = MEMWBIR[25:20]; //rt fi eld--used for loads
assign EXMEMop = EXMEMIR[31:26]; // the opcode
assign MEMWBop = MEMWBIR[31:26]; // the opcode
assign IDEXop = IDEXIR[31:26] ; // the opcode
// Inputs to the ALU come directly from the ID/EX pipeline registers
assign Ain = IDEXA;
assign Bin = IDEXB;
reg [5:0] i; //used to initialize registers
	
	// DETERMINE RESULT FROM SLT/SLTU/SLTI/SLTIU OPERATIONS
	
//******************************************************************************
// ALU datapath
//******************************************************************************
		
	// Decoded ALU operation select (ALUsel) signals
	`define	select_alu_add		4'b0000
	`define	select_alu_and		4'b0001
	`define	select_alu_xor		4'b0010
	`define	select_alu_or		4'b0011
	`define	select_alu_nor		4'b0100
	`define	select_alu_sub		4'b0101
	`define	select_alu_sltu		4'b0110
	`define	select_alu_slt		4'b0111
	`define	select_alu_srl		4'b1000
	`define	select_alu_sra		4'b1001
	`define	select_alu_sll		4'b1010
	`define select_alu_passa	4'b1011
	`define	select_alu_passb	4'b1100
	
	reg [31:0]		ALUResult;
	
	always @(ALUOpX or ALUOpY or ALUOp or isSLTU or isSLT or signedALUOpY) begin

		case (ALUOp)

			// PERFORM ALU OPERATIONS DEFINED ABOVE

			default:			ALUResult = 32'bxxxxxxxx;			// Undefined
		endcase
	end

	assign ALUZero = (ALUResult[31:0] == 32'b0);
	assign ALUNeg = ALUResult[31];

endmodule
