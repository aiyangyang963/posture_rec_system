`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: Wei Zongzheng
// 
// Create Date: 2017/08/30 17:08:09
// Design Name: 
// Module Name: rect_linear
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: if data greater than 0, output is original value; or else output is 0.1*data
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module linear_activation(
	clk,
	
	image_data,
	image_valid,
	
	image_q,
	image_q_valid


    );
    
///////////////////////////////////inputs and outputs///////////////////////
input	clk;

input	[`IMAGE_ELE_BITWIDTH-1:0]	image_data;
input	image_valid;

output	reg[`IMAGE_ELE_BITWIDTH-1:0]	image_q;
output	reg image_q_valid;

///////////////////////////////////////////////////////////////////////////   
reg [`IMAGE_ELE_BITWIDTH-1:0] image_data_r, image_data_r1, image_data_r2;
reg image_valid_r, image_valid_r1, image_valid_r2;

//to be synchronized with leacky result
always @(posedge clk)
begin
	image_data_r <= image_data;
	image_data_r1 <= image_data_r;
	image_data_r2 <= image_data_r1;
	image_q <= image_data_r2;	
end
always @(posedge clk)
begin
	image_valid_r <= image_valid;
	image_valid_r1 <= image_valid_r;
	image_valid_r2 <= image_valid_r1;
	image_q_valid <= image_valid_r2;
end
    
    
endmodule
