//******************************************************************************
// EE108b MIPS verilog model
//
// VGA_ctl.v
//
// Generates display for the VGA monitor
// Contains two modes:
//  1) debug mode: display PC, instruction, and register read/write data
//  2) run mode: write images to a frame buffer, which is then displayed on VGA
//
// If you want to change the display, talk to the TAs before modifying this file
//
// modified by Neil Achtman, 8/15/03
//
//******************************************************************************

module VGA_ctl (
	reset, clka, clkb, instr, pc, opx, opy, result, din, enable, mode, vga_hsync, vga_vsync,
	vga_red0, vga_green0, vga_blue0, 
	vga_red1, vga_green1, vga_blue1,
	x, y
	);

	input 		clka, clkb;		// 50 MHz clock

	input [31:0]	din;		// data for writing color to screen
	input		enable;
	input		mode, reset;	// whether to be in run or debug mode

	// data to be displayed in debugging mode
	input [31:0]	instr;

	input [7:0]	pc;
	input [31:0]	opx, opy, result;

	// VGA control signals
	output		vga_red0, vga_green0, vga_blue0; 
	output		vga_red1, vga_green1, vga_blue1;
	output		vga_hsync, vga_vsync;

	// color select for run mode
	wire [2:0]	color_out_run;

	// color select for debug mode
	wire [7:0]	tcgrom_out;
	reg [5:0]		char_selection;
	reg			color_out_debug;

//*****************************************************************************
// Vga control
//*****************************************************************************
  input [9:0] y;
  input [11:0] x;
        
	wire [9:0] YPos;
	wire [11:0] XPos; //reg [10:0] XPos;
	
	//reg ResetCntX, EnableCntY, ResetCntY;
	reg Valid, vga_hsync, vga_vsync;    

  assign XPos = x;
  assign YPos = y;
  

	// Pixel counters
//	always @ (posedge clka) 
//	begin
//	  if (reset)
//	  begin
//	    XPos <= 0;
//	    YPos <= 0;
//	  end
//	  else
//	  begin
//		if (ResetCntX)
//			XPos[11:1] <= 11'b0;
//		else
//			XPos[11:1] <= XPos[11:1] + 1;
//
//		if (ResetCntY)
//			YPos[9:0] <= 10'b0;
//		else if (EnableCntY)
//			YPos[9:0] <= YPos + 1;
//		else
//			YPos[9:0] <= YPos[9:0];	
//	  end
//	end

	// Synchronizer controller    
//	always @(posedge clka ) 
//	begin
//	  if(reset)
//	  begin
//	     ResetCntX <= 0;
//	     EnableCntY <= 0;
//	     ResetCntY <=0;
//	  end
//	  else
//	  begin   	
//		  ResetCntX <= (XPos[11:0] ==1586);
//		  EnableCntY <= (XPos[11:0] == 1300);
//		  ResetCntY <= (YPos[9:0] ==527);
//		end
//	end


	// Signal synchronizer
	always @(posedge clka) begin
		vga_hsync 	<= ~((XPos[11:0] >= 1304) && (XPos[11:0] <= 1493));
		vga_vsync 	<= ~((YPos[9:0] == 493)  	|| (YPos[9:0]  == 494 ));
		Valid <=	(((XPos == 1587) 	|| (XPos < 1288)) &&
					((YPos ==  527) 	|| (YPos < 480 )) );
	end

//*****************************************************************************
// Frame buffer for writing colors to the VGA grid in run mode
//*****************************************************************************

	framebuffer buffer(.addra({din[13:8], din[5:0]}), .addrb({XPos[10:5], YPos[9:4]}),
				    .clka(clka), .clkb(clkb), .dina(din[18:16]), .wea(enable),
				    .doutb(color_out_run[2:0]));

//*****************************************************************************
// Determine what to write on screen in debugging mode
//*****************************************************************************

	always @(pc or instr or opx or opy or result or XPos or YPos) begin

		if (YPos[9:5] == 5'b00000)						// PC
			if (XPos[10:6] == 5'b00000)
				char_selection = {2'b11, pc[7:4]};
			else if (XPos[10:6] == 5'b00001)
				char_selection = {2'b11, pc[3:0]};
			else
				char_selection = 6'b100000;
		else if (YPos[9:5] == 5'b00010)					// Instruction
			if (XPos[10:6] == 5'b00000)
				char_selection = {2'b11, instr[31:28]}; 
			else if (XPos[10:6] == 5'b00001)
				char_selection = {2'b11, instr[27:24]};
			else if (XPos[10:6] == 5'b00010)
				char_selection = {2'b11, instr[23:20]}; 
			else if (XPos[10:6] == 5'b00011)
				char_selection = {2'b11, instr[19:16]}; 
			else if (XPos[10:6] == 5'b00100)
				char_selection = {2'b11, instr[15:12]}; 
			else if (XPos[10:6] == 5'b00101)
				char_selection = {2'b11, instr[11:8]}; 
			else if (XPos[10:6] == 5'b00110)
				char_selection = {2'b11, instr[7:4]}; 
			else if (XPos[10:6] == 5'b00111)
				char_selection = {2'b11, instr[3:0]};
			else
				char_selection = 6'b100000;
		else if (YPos[9:5] == 5'b00100)					// ALU Op X
			if (XPos[10:6] == 5'b00000)
				char_selection = {2'b11, opx[31:28]}; 
			else if (XPos[10:6] == 5'b00001)
				char_selection = {2'b11, opx[27:24]};
			else if (XPos[10:6] == 5'b00010)
				char_selection = {2'b11, opx[23:20]}; 
			else if (XPos[10:6] == 5'b00011)
				char_selection = {2'b11, opx[19:16]}; 
			else if (XPos[10:6] == 5'b00100)
				char_selection = {2'b11, opx[15:12]}; 
			else if (XPos[10:6] == 5'b00101)
				char_selection = {2'b11, opx[11:8]}; 
			else if (XPos[10:6] == 5'b00110)
				char_selection = {2'b11, opx[7:4]}; 
			else if (XPos[10:6] == 5'b00111)
				char_selection = {2'b11, opx[3:0]};
			else
				char_selection = 6'b100000;
		else if (YPos[9:5] == 5'b00101)					// ALU Op Y
			if (XPos[10:6] == 5'b00000)
				char_selection = {2'b11, opy[31:28]}; 
			else if (XPos[10:6] == 5'b00001)
				char_selection = {2'b11, opy[27:24]};
			else if (XPos[10:6] == 5'b00010)
				char_selection = {2'b11, opy[23:20]}; 
			else if (XPos[10:6] == 5'b00011)
				char_selection = {2'b11, opy[19:16]}; 
			else if (XPos[10:6] == 5'b00100)
				char_selection = {2'b11, opy[15:12]}; 
			else if (XPos[10:6] == 5'b00101)
				char_selection = {2'b11, opy[11:8]}; 
			else if (XPos[10:6] == 5'b00110)
				char_selection = {2'b11, opy[7:4]}; 
			else if (XPos[10:6] == 5'b00111)
				char_selection = {2'b11, opy[3:0]};
			else
				char_selection = 6'b100000;
		else if (YPos[9:5] == 5'b00111)					// Result to be stored in register
			if (XPos[10:6] == 5'b00000)
				char_selection = {2'b11, result[31:28]}; 
			else if (XPos[10:6] == 5'b00001)
				char_selection = {2'b11, result[27:24]};
			else if (XPos[10:6] == 5'b00010)
				char_selection = {2'b11, result[23:20]}; 
			else if (XPos[10:6] == 5'b00011)
				char_selection = {2'b11, result[19:16]}; 
			else if (XPos[10:6] == 5'b00100)
				char_selection = {2'b11, result[15:12]}; 
			else if (XPos[10:6] == 5'b00101)
				char_selection = {2'b11, result[11:8]}; 
			else if (XPos[10:6] == 5'b00110)
				char_selection = {2'b11, result[7:4]}; 
			else if (XPos[10:6] == 5'b00111)
				char_selection = {2'b11, result[3:0]};
			else
				char_selection = 6'b100000;
		else
			char_selection = 6'b100000;
	end	 

	tcgrom char_rom (.clka(clka), .addra({char_selection[5:0], YPos[4:2]}),
				  .douta(tcgrom_out[7:0]));

	always @(XPos or tcgrom_out) begin
		case (XPos[5:3])
			3'h0:	color_out_debug = tcgrom_out[7];
			3'h1:	color_out_debug = tcgrom_out[6];
			3'h2:	color_out_debug = tcgrom_out[5];
			3'h3:	color_out_debug = tcgrom_out[4];
			3'h4:	color_out_debug = tcgrom_out[3];
			3'h5:	color_out_debug = tcgrom_out[2];
			3'h6:	color_out_debug = tcgrom_out[1];
			3'h7:	color_out_debug = tcgrom_out[0];
		endcase
	end

//*****************************************************************************
// Choose what to display (run vs. debug display)
//*****************************************************************************

	assign vga_red0 = (Valid) ? ((mode) ? color_out_debug : color_out_run[0]) : 0;
	assign vga_red1 = (Valid) ? ((mode) ? color_out_debug : color_out_run[0]) : 0;
	assign vga_green0 = (Valid) ? ((mode) ? color_out_debug : color_out_run[1]) : 0;
	assign vga_green1 = (Valid) ? ((mode) ? color_out_debug : color_out_run[1]) : 0;
	assign vga_blue0 = (Valid) ? ((mode) ? color_out_debug : color_out_run[2]) : 0;
	assign vga_blue1 = (Valid) ? ((mode) ? color_out_debug : color_out_run[2]) : 0;

endmodule
