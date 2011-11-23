module dffar(clk, d, r, q);

input clk, d, r;
output q;
reg temp_q;
wire q;

and(q, temp_q, ~r);

always @(posedge clk)
		temp_q = d;
endmodule