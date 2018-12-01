`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An pingbo
// 
// Create Date: 2017/08/26 19:32:46
// Design Name: 
// Module Name: multi_div4
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


module multi_div(
	input	clk,
	input [`IMAGE_SIZE-1:0]	multi1,
	input [`IMAGE_SIZE-1:0]	multi2,
	output reg[`IMAGE_SIZE+`IMAGE_SIZE-1:0]	result
    );

wire [`IMAGE_SIZE+`IMAGE_SIZE-1:0]	multi12;
wire	[`IMAGE_SIZE+`IMAGE_SIZE-1:0]	result_temp;
    
assign multi12	=	multi1 * multi2;
assign result_temp	=	(multi12[0] != 1'b0) ? multi12[`IMAGE_SIZE+`IMAGE_SIZE-1:1] + 1'b1 : multi12[`IMAGE_SIZE+`IMAGE_SIZE-1:1];    
    
always @(posedge clk)
begin
		result	<=	result_temp;
end    
    
    
endmodule

