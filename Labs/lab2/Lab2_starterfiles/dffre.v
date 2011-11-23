module dffre(clk, d, q, r, en);

parameter n = 1 ; // width
input clk, r, en;
input [n-1:0] d;
output [n-1:0] q;
reg [n-1:0] q;

always @(posedge clk)
	if (en==1)
		q = (r == 1'b0) ? d : 20'b0;
endmodule