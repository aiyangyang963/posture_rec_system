`timescale 1ns / 1ns
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/20 17:09:29
// Design Name: 
// Module Name: postImage_channel_choose
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: choose the write and read channels
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module postImage_channel_choose(
	input	clk,
	input	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	num1,//one image occupying number of rams
	input	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	num2,//filter num
	output	reg	[`POSTIMAGE_CHANNEL-1:0]	channel



    );
    
   
   
   
always @(posedge clk)
begin
		case({num1[`POSTIMAGE_CHANNEL_BITWIDTH-1:0], num2[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]})
		{`POSTIMAGE_CHANNEL_BITWIDTH'd1,`POSTIMAGE_CHANNEL_BITWIDTH'd2}:
			channel	<=	`POSTIMAGE_CHANNEL'h03;
		{`POSTIMAGE_CHANNEL_BITWIDTH'd1,`POSTIMAGE_CHANNEL_BITWIDTH'd3}:
			channel	<=	`POSTIMAGE_CHANNEL'h07;
		{`POSTIMAGE_CHANNEL_BITWIDTH'd1,`POSTIMAGE_CHANNEL_BITWIDTH'd4}:
			channel	<=	`POSTIMAGE_CHANNEL'h0F;
		{`POSTIMAGE_CHANNEL_BITWIDTH'd1,`POSTIMAGE_CHANNEL_BITWIDTH'd5}:
			channel	<=	`POSTIMAGE_CHANNEL'h1F;	
		{`POSTIMAGE_CHANNEL_BITWIDTH'd1,`POSTIMAGE_CHANNEL_BITWIDTH'd6}:
			channel	<=	`POSTIMAGE_CHANNEL'h3F;	
		{`POSTIMAGE_CHANNEL_BITWIDTH'd1,`POSTIMAGE_CHANNEL_BITWIDTH'd7}:
			channel	<=	`POSTIMAGE_CHANNEL'h7F;		
		{`POSTIMAGE_CHANNEL_BITWIDTH'd1,`POSTIMAGE_CHANNEL_BITWIDTH'd8}:
			channel	<=	`POSTIMAGE_CHANNEL'hFF;	
		

		{`POSTIMAGE_CHANNEL_BITWIDTH'd2,`POSTIMAGE_CHANNEL_BITWIDTH'd2}:
			channel	<=	`POSTIMAGE_CHANNEL'h05;	
		{`POSTIMAGE_CHANNEL_BITWIDTH'd2,`POSTIMAGE_CHANNEL_BITWIDTH'd3}:
			channel	<=	`POSTIMAGE_CHANNEL'h15;	
		{`POSTIMAGE_CHANNEL_BITWIDTH'd2,`POSTIMAGE_CHANNEL_BITWIDTH'd4}:
			channel	<=	`POSTIMAGE_CHANNEL'h55;
			

		{`POSTIMAGE_CHANNEL_BITWIDTH'd3,`POSTIMAGE_CHANNEL_BITWIDTH'd2}:
			channel	<=	`POSTIMAGE_CHANNEL'h09;
				

		{`POSTIMAGE_CHANNEL_BITWIDTH'd4,`POSTIMAGE_CHANNEL_BITWIDTH'd2}:
			channel	<=	`POSTIMAGE_CHANNEL'h011;
		default:
			channel	<=	`POSTIMAGE_CHANNEL'h01;																		
		endcase
end   
   
   
   
    
    
    
    
endmodule
