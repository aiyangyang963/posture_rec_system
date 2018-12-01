`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/26 10:53:39
// Design Name: 
// Module Name: user_update_fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module user_update_fifo_tb( );
    
reg clk;
initial begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end    
    
reg rst;
initial begin
	rst = 1'b1;
	repeat(40) @(posedge clk);
	rst = 1'b0;
end    
    
    
logic [`IMAGE_ELE_BITWIDTH*2-1:0] din;
logic wr_en;
logic [`IMAGE_ELE_BITWIDTH-1:0] dout;
logic rd_en;
logic full;
logic prog_full;
logic empty;  
 
assign wr_en = !prog_full && !rst;

initial begin
	rd_en <= 1'b0;
	@(negedge rst);
	repeat(100) @(posedge clk);
	while(1)begin
		if(!empty)
			rd_en <= 1'b1;
		else
			rd_en <= 1'b0;
		@(posedge clk);
	end
end 

always @(posedge clk)
begin
	if(rst)
		din <= 0;
	else if(wr_en)
		din <= din + 1;
end

 
 
user_update_fifo user_update_fifo_m(
    .wr_clk(clk),
	.rd_clk(clk),
	.rst(rst),
	.din(din),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.dout(dout),
	.prog_full(prog_full),
	.full(full),
	.empty(empty)

); 
 
 
    
    
endmodule
