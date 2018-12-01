`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/22 13:19:13
// Design Name: 
// Module Name: batch_norm
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


module batch_norm(

	clk,
	norm_en,
	data,
	bias,
	mean,
	mul,
	q,
	q_valid


    );
    
///////////////////////////////inputs and outputs////////////////////////////////////    
input clk;
input norm_en;
input [`IMAGE_ELE_BITWIDTH-1:0] data;
input [`BIAS_ELE_BITWIDTH-1:0] bias;
input [`BIAS_ELE_BITWIDTH-1:0] mean;
input [`DIV_ELE_BITWIDTH-1:0] mul;
output reg [`IMAGE_ELE_BITWIDTH-1:0] q;
output reg q_valid;

/////////////////////////////////////////////////////////////////////////////////////    
    
    
///////////////////////////////////+bias///////////////////////////////////////
reg [`BIAS_ELE_BITWIDTH-1:0] bias_r;
reg [`BIAS_ELE_BITWIDTH-1:0] mean_r;
reg [`DIV_ELE_BITWIDTH-1:0] mul_r;
wire [`BIAS_ELE_BITWIDTH-1:0] mean_result;
wire mean_result_valid;
reg [`BIAS_ELE_BITWIDTH-1:0] mean_result_r;
reg mean_result_valid_r;
always @(posedge clk)
begin
	bias_r <= bias;
end
always @(posedge clk)
begin
	mean_r <= mean;
end
always @(posedge clk)
begin
	mul_r <= mul;
end


float_add_IP_use_DSP_multilatency rollingmean(
	.aclk(clk),
	.s_axis_a_tvalid(norm_en),
	.s_axis_a_tdata(data),
	.s_axis_b_tvalid(norm_en),
	.s_axis_b_tdata(mean_r),
	.m_axis_result_tvalid(mean_result_valid),
	.m_axis_result_tdata(mean_result)
);//bias
always @(posedge clk)
begin
	mean_result_r <= mean_result;
end
always @(posedge clk)
begin
	mean_result_valid_r <= mean_result_valid;
end
/////////////////////////////////////////////////////////////////////////////////////    
    
///////////////////////////////////+mean///////////////////////////////////////
wire [`DIV_ELE_BITWIDTH-1:0] mul_result;
wire mul_result_valid;
reg [`DIV_ELE_BITWIDTH-1:0] mul_result_r;
reg mul_result_valid_r;
float_multiply multiply(
	.aclk(clk),
	.s_axis_a_tvalid(mean_result_valid_r),
	.s_axis_a_tdata(mean_result_r),
	.s_axis_b_tvalid(mean_result_valid_r),
	.s_axis_b_tdata(mul_r),
	.m_axis_result_tvalid(mul_result_valid),
	.m_axis_result_tdata(mul_result)
	);    
always @(posedge clk)
begin
	mul_result_r <= mul_result;
end  
always @(posedge clk)
begin
	mul_result_valid_r <= mul_result_valid;
end  
////////////////////////////////////////////////////////////////////////////////////    

/////////////////////////////////////*mul//////////////////////////////////////// 
wire [`IMAGE_ELE_BITWIDTH-1:0] q_temp;
wire q_valid_temp;   
float_add_IP_use_DSP_multilatency biasadder(
	.aclk(clk),
	.s_axis_a_tvalid(mul_result_valid_r),
	.s_axis_a_tdata(mul_result_r),
	.s_axis_b_tvalid(mul_result_valid_r),
	.s_axis_b_tdata(bias_r),
	.m_axis_result_tvalid(q_valid_temp),
	.m_axis_result_tdata(q_temp));

always @(posedge clk)
begin
	q <= q_temp;
end
always @(posedge clk)
begin
	q_valid <= q_valid_temp;
end
     
///////////////////////////////////////////////////////////////////////////////////////    
    
endmodule
