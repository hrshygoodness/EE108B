module clkdiv (reset, source_clk, destclk, destclk_n);
  input source_clk, reset;
  output destclk, destclk_n;
  
  reg [1:0]temp;
  
  //reg destclk, destclk_n;
  
  assign destclk = temp[1];
  assign destclk_n = ~destclk;
  
  always @ (posedge source_clk)
  begin
    if(reset)
      temp<= 2'b0;
    else
      temp <= temp + 1;
  end
  
endmodule 
  