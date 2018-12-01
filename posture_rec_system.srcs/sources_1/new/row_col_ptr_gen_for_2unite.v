`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/23 15:02:12
// Design Name: 
// Module Name: row_col_ptr_gen_for_2unite
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


module row_col_ptr_gen_for_2unite(
	input clk,
	input rst_n,
	input [`IMAGE_SIZE-1:0] odd_size,
	input [`IMAGE_SIZE-1:0] even_size,
	input en,
	(*DONT_TOUCH="TRUE"*)output reg[`IMAGE_SIZE-1:0] col,
	(*DONT_TOUCH="TRUE"*)output reg[`IMAGE_SIZE-1:0] row,
	output reach_end


    );
    
wire is_odd;
wire col_end;
assign is_odd = odd_size[0];   

always @(posedge clk)
begin
	if(!rst_n)
		col <= `IMAGE_SIZE'h0;
	else if(((col == even_size - 2'b10 && !is_odd) || (col == odd_size - 2'b10 && is_odd) || (col == odd_size - 1'b1 && is_odd && row == odd_size - 1'b1)) && en)
		col <= `IMAGE_SIZE'h0;
	else if(col == odd_size - 1'b1 && is_odd && en)
		col <= `IMAGE_SIZE'h1;
	else if(en)
		col <= col + 2'b10;
end   
   
assign col_end = ((col == even_size - 2'b10 && !is_odd) || (col == odd_size - 2'b10 && is_odd) || (col == odd_size - 1'b1 && is_odd)) && en;    
   
always @(posedge clk)
begin
	if(!rst_n)
		row <= `IMAGE_SIZE'h0;
	else if(col_end && row == odd_size - 1'b1 && en)
		row <= `IMAGE_SIZE'h0;
	else if(en && col_end)
		row <= row + 1'b1;
end   
    
assign reach_end = col_end && row == odd_size - 1'b1 && en;    
    
endmodule
