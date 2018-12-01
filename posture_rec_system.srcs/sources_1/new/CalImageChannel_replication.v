`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/27 20:17:05
// Design Name: 
// Module Name: CalImageChannel_replication
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


module CalImageChannel_replication(
	input	clk,
	input	rst_n,
	input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	data,
	input	[`FILTER_NUM-1:0]	choose,
	input	[`PARALLEL_NUM-1:0]	valid,
	output	reg[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	q,
	output	reg[`PARALLEL_NUM-1:0]	valid_out
    );
    
    

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		q	<=	'h0;
		valid_out	<=	'h0;
	end
	else
		case({valid,choose})

		{`PARALLEL_NUM'h1,`FILTER_NUM'd2}:begin
			valid_out[1:0]	<=	{2{valid[0]}};
			q[`IMAGE_ELE_BITWIDTH*2-1:0]	<=	{2{data[`IMAGE_ELE_BITWIDTH-1:0]}};
		end			
		{`PARALLEL_NUM'h1,`FILTER_NUM'd4}:begin
			valid_out[3:0]	<=	{4{valid[0]}};
			q[`IMAGE_ELE_BITWIDTH*4-1:0]	<=	{4{data[`IMAGE_ELE_BITWIDTH-1:0]}};
		end
		{`PARALLEL_NUM'h1,`FILTER_NUM'd8}:begin
			valid_out[7:0]	<=	{8{valid[0]}};
			q[`IMAGE_ELE_BITWIDTH*8-1:0]	<=	{8{data[`IMAGE_ELE_BITWIDTH-1:0]}};
		end
		
	
		{`PARALLEL_NUM'h3,`FILTER_NUM'd2}:begin
			valid_out[3:0]	<=	{2{valid[1],valid[0]}};
			q[`IMAGE_ELE_BITWIDTH*4-1:0]	<=	{2{data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH],data[`IMAGE_ELE_BITWIDTH-1:0]}};
		end	
		{`PARALLEL_NUM'h3,`FILTER_NUM'd4}:begin
			valid_out[3:0]	<=	{4{valid[1],valid[0]}};
			q[`IMAGE_ELE_BITWIDTH*8-1:0]	<=	{4{data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH],data[`IMAGE_ELE_BITWIDTH-1:0]}};
		end
		

		{`PARALLEL_NUM'h7,`FILTER_NUM'd2}:begin
			valid_out[5:0]	<=	{2{valid[2],valid[1],valid[0]}};
			q[`IMAGE_ELE_BITWIDTH*6-1:0]	<=	{2{data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2],data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH],data[`IMAGE_ELE_BITWIDTH-1:0]}};
		end	
		

		{`PARALLEL_NUM'hF,`FILTER_NUM'd2}:begin
			valid_out[7:0]	<=	{2{valid[3],valid[2],valid[1],valid[0]}};
			q[`IMAGE_ELE_BITWIDTH*8-1:0]	<=	{2{data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*3],data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2],data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH],data[`IMAGE_ELE_BITWIDTH-1:0]}};
		end		
		default:begin
			valid_out	<=	valid;
			q	<=	data;
		end										
		endcase
end    
    
    
    
    
    
    
    
    
endmodule
