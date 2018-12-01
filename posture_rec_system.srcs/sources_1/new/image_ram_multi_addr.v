`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/20 19:19:46
// Design Name: 
// Module Name: image_ram_multi_addr
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


module image_ram_multi_addr(
	input	[`IMAGE_SIZE-1:0]	size,
	input	[`IMAGE_SIZE-1:0]	multi1,
	input	[`IMAGE_SIZE-1:0]	multi2,
	output	[`IMAGE_SIZE*2-1:0]	result
	
    );

wire	[`IMAGE_SIZE*2-1:0] result_temp;  
assign	result_temp	=	multi2*size + multi1;    
assign  result = result_temp[`IMAGE_SIZE*2-1:1];        
    
    
endmodule
