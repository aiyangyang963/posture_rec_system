`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: Wei Zongzheng
// 
// Create Date: 2017/08/30 16:04:36
// Design Name: 
// Module Name: conv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: convolution module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module conv(
	
	clk,
	rst_n,
	
	infor_update,
	channel_choose,
	kernel_size,
	image_size,
	
	image_data,
	kernel_data,
	conv_en,
	conv_ready,
	
	image_q,
	image_q_valid




    );
  
///////////////////////////////inputs and outputs////////////////////////////////////    
input	clk;    
input	rst_n;

input infor_update;
input channel_choose;
input [`KERNEL_SIZE-1:0] kernel_size;
input	[`IMAGE_SIZE-1:0]	image_size;
input	[`IMAGE_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0]    image_data;
input	[`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0]	kernel_data;


input	conv_en;//enbale convolution
output	reg conv_ready;

output	reg [`IMAGE_ELE_BITWIDTH-1:0]	image_q;
output	reg image_q_valid;//valid signal
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////生成9个乘法器/////////////////////////////////////////
wire[`IMAGE_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0] mul_result;// 9个乘法器的输出
wire[8:0] mul_result_valid;//乘法运算结果有效，可以作为之后加法器的输入
wire [`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0] kernel_data_trans;
assign kernel_data_trans={
	kernel_data[`KERNEL_ELE_BITWIDTH*9-1:`KERNEL_ELE_BITWIDTH*8],
	kernel_data[`KERNEL_ELE_BITWIDTH*6-1:`KERNEL_ELE_BITWIDTH*5],
	kernel_data[`KERNEL_ELE_BITWIDTH*3-1:`KERNEL_ELE_BITWIDTH*2],
	kernel_data[`KERNEL_ELE_BITWIDTH*8-1:`KERNEL_ELE_BITWIDTH*7],
	kernel_data[`KERNEL_ELE_BITWIDTH*5-1:`KERNEL_ELE_BITWIDTH*4],
	kernel_data[`KERNEL_ELE_BITWIDTH*2-1:`KERNEL_ELE_BITWIDTH],
	kernel_data[`KERNEL_ELE_BITWIDTH*7-1:`KERNEL_ELE_BITWIDTH*6],
	kernel_data[`KERNEL_ELE_BITWIDTH*4-1:`KERNEL_ELE_BITWIDTH*3],
	kernel_data[`KERNEL_ELE_BITWIDTH-1:0]
};

generate
	genvar i;
	for(i=0; i<=8; i=i+1)
		begin: multiply_loop
			float_multiply float_multiply_m1
			(
				 .aclk(clk),
				 .s_axis_a_tvalid(conv_en),
				 .s_axis_a_tdata(image_data[((i+1)*`IMAGE_ELE_BITWIDTH-1):(i*`IMAGE_ELE_BITWIDTH)]),
				 .s_axis_b_tvalid(conv_en),
				 .s_axis_b_tdata(kernel_data_trans[((i+1)*`IMAGE_ELE_BITWIDTH-1):(i*`IMAGE_ELE_BITWIDTH)]),
				 .m_axis_result_tvalid(mul_result_valid[i]),
				 .m_axis_result_tdata(mul_result[(i+1)*`IMAGE_ELE_BITWIDTH-1:i*`IMAGE_ELE_BITWIDTH])								
			);
		end
endgenerate




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////执行9个加法//////////////////////////////////////////////////

wire[`IMAGE_ELE_BITWIDTH-1:0] mul_result_add;//累加结果
wire mult_result_add_valid;//累加结果有效信号







mul_results_adder result_adder(
	.Clk(clk),
	.rst_n(rst_n),
	
	.kernel_size(kernel_size),
	.a(mul_result),
	.add_en(mul_result_valid),
	.b(mul_result_add),
	.b_valid(mult_result_add_valid)
);//sum all the 9 multiplied data



always @(posedge clk)
begin
	image_q <= mul_result_add;
end
always @(posedge clk)
begin
	image_q_valid <= mult_result_add_valid;
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////operation of conv is ready////////////////////////////////////////////
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			conv_ready <= 1'b1;
		else if(mult_result_add_valid)
			conv_ready <= 1'b1;
		else if(conv_en)
			conv_ready <= 1'b0;
end


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    
 
 

 
 
 
 
 
    
    
endmodule


	