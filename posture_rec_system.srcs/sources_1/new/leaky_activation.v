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


module leaky_activation(
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


   
       
reg [`IMAGE_ELE_BITWIDTH-1:0]	image_data_r;
reg [`IMAGE_ELE_BITWIDTH-1:0]	image_data_r1, image_data_r2;
reg image_valid_r;
reg image_valid_r1, image_valid_r2;
wire [`IMAGE_ELE_BITWIDTH-1:0] image_q_temp;
wire image_q_valid_temp;   
    


always @(posedge clk)
begin
		image_data_r <= image_data;	
		image_data_r1 <= image_data_r;
		image_data_r2 <= image_data_r1;	
end

always @(posedge clk)
begin
		image_valid_r <= image_valid;
		image_valid_r1 <= image_valid_r;
		image_valid_r2 <= image_valid_r1;
end



wire[31:0] leacky_num = 32'h3DCCCCCD;//0.1


float_multiply float_multiply_m (
  .aclk(clk),                                  // input wire aclk
  .s_axis_a_tvalid(image_valid_r),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(image_data_r),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(image_valid_r),            // input wire s_axis_b_tvalid
  .s_axis_b_tdata(leacky_num),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(image_q_valid_temp),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(image_q_temp)    // output wire [31 : 0] m_axis_result_tdata
);

always @(posedge clk)
begin
	if(image_data_r2[`IMAGE_ELE_BITWIDTH-1])begin
		image_q <= image_q_temp;
		image_q_valid <= image_q_valid_temp;
	end
	else begin
		image_q <= image_data_r2;
		image_q_valid <= image_valid_r2;
	end
end   

    
    
    
endmodule
