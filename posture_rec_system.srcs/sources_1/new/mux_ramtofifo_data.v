`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/22 10:03:33
// Design Name: 
// Module Name: mux_ramtofifo_data
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: choose the image ram output data for writing into the fifo 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_ramtofifo_data(

	input	clk,
	input	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	number,
	input	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	data,
	output	reg	[`POSTIMAGE_BITWIDTH-1:0]	q


    );
    

wire	[`POSTIMAGE_BITWIDTH-1:0]	data_temp[`POSTIMAGE_CHANNEL-1:0];


assign	{data_temp[7], data_temp[6], data_temp[5], data_temp[4],
		data_temp[3], data_temp[2],data_temp[1],data_temp[0]}	=	data;

    
always @(posedge clk)
begin
		case(number)
		`POSTIMAGE_CHANNEL_BITWIDTH'd0:
			q	<=	data_temp[0];
		`POSTIMAGE_CHANNEL_BITWIDTH'd1:
			q	<=	data_temp[1];
		`POSTIMAGE_CHANNEL_BITWIDTH'd2:
			q	<=	data_temp[2];
		`POSTIMAGE_CHANNEL_BITWIDTH'd3:
			q	<=	data_temp[3];
		`POSTIMAGE_CHANNEL_BITWIDTH'd4:
			q	<=	data_temp[4];
		`POSTIMAGE_CHANNEL_BITWIDTH'd5:
			q	<=	data_temp[5];
		`POSTIMAGE_CHANNEL_BITWIDTH'd6:
			q	<=	data_temp[6];
		`POSTIMAGE_CHANNEL_BITWIDTH'd7:
			q	<=	data_temp[7];		
		endcase
end    
    
    
    
    
    
endmodule
