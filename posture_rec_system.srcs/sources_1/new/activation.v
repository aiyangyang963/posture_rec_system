`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/22 14:17:28
// Design Name: 
// Module Name: activation
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


module activation(
	clk,
	activation_en,
	data,
	activation_choose,
	q,
	q_valid
    );
    
///////////////////////////////inputs and outputs////////////////////////////////////    
input clk;
input activation_en;
input [`IMAGE_ELE_BITWIDTH-1:0] data;
(*DONT_TOUCH="TRUE"*)input activation_choose;
output reg [`IMAGE_ELE_BITWIDTH-1:0] q;
output reg q_valid;
/////////////////////////////////////////////////////////////////////////////////////    

/////////////////////////////////////activation/////////////////////////////////////
wire [`IMAGE_ELE_BITWIDTH-1:0] leaky_result, linear_result;
wire leaky_result_valid, linear_result_valid;
wire [`IMAGE_ELE_BITWIDTH-1:0] activation_result;
wire activation_result_valid;
leaky_activation leaky_activation_m(
	.clk(clk),
	.image_data(data),
	.image_valid(activation_en && !activation_choose),
	
	.image_q(leaky_result),
	.image_q_valid(leaky_result_valid)
);//通过activation 函数

linear_activation linear_activation_m(
	.clk(clk),
	.image_data(data),
	.image_valid(activation_en && activation_choose),
	
	.image_q(linear_result),
	.image_q_valid(linear_result_valid)
);//通过activation 函数

assign activation_result = 	activation_choose ? linear_result: leaky_result;
assign activation_result_valid = activation_choose ? linear_result_valid : leaky_result_valid;
always @(posedge clk)
begin
	q <= activation_result;
end
always @(posedge clk)
begin
	q_valid <= activation_result_valid;
end
/////////////////////////////////////////////////////////////////////////////////////










    
    
endmodule
