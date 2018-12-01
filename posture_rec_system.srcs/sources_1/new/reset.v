`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/03 21:31:41
// Design Name: 
// Module Name: reset
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


module reset(
	input clk,
	input rst_n,
	output reg[7:0] soft_rstArray_n
    );
    
    
reg [7:0] cnt;
reg [7:0] soft_rstArray_n_temp;

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			cnt <= 8'h0;
		else if(cnt == 8'hFF)
			cnt <= cnt;
		else
			cnt <= cnt + 1'b1;
end    
    
always @(posedge clk)
begin
		if(cnt == 8'hFF)
			soft_rstArray_n_temp <= 8'hFF;
		else
			soft_rstArray_n_temp <=8'h0;
end    
always @(posedge clk)
begin
	soft_rstArray_n <= soft_rstArray_n_temp;
end    
    
    
    
    
endmodule
