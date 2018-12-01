`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/29 09:33:29
// Design Name: 
// Module Name: load_data
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: load head, kernel, image data for convolution algorithm
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module load_data(
	clk,
	axi_clk,
	rst_n,
	
	load_head_begin,
	load_head_rd,
	load_head_rd_q,
	load_head_empty,
	image_num,
	image_size,
	image_size_after_maxpooling,
	image_sum_en,
	image_update,
	image_next_read_en,
	filter_num,
	kernel_num,
	kernel_size,
	kernel_step,
	maxpooling_en,
	image_return_axi,
	infor_update,
	image_one_return_finish,

	load_image_begin,
	load_image_finish,
	maxpooling_finish,
	image_rd_ready,
	buffer_image_rd,
	buffer_image_rd_addr,
	buffer_image_rd_q,
	buffer_image_rd_valid,
	image_need,
	image_rd_q,
	image_valid,

	load_kernel_begin,
	load_kernel_finish,
	
	
	buffer_kernel_rd,
	buffer_kernel_rd_q,
	buffer_kernel_empty,
	

	kernel_q,
	bias1_q,
	bias2_q,
	div_q,
	kernel_valid

    );
    
    
input	clk;//data deal clock
input	axi_clk;
input	rst_n;//global reset

//load_head module
input	load_head_begin;//request to load head information from fifo

output	 	load_head_rd;//read request to head fifo
input	[`HEAD_WIDTH-1:0]	load_head_rd_q;//output head data from fifo
input	load_head_empty;//empty tag of the fifo hold head data

output	[`IMAGE_NUM-1:0]	image_num;//image number operated at this round
output	[`IMAGE_SIZE-1:0]	image_size;//image size
output	[`IMAGE_SIZE-1:0]	image_size_after_maxpooling;
output	image_sum_en;//indicate whether perform summation of all the convolution channels
output	image_update;//indicate whether update the image ram
output	image_next_read_en;//next round, need to read image

output	[`FILTER_NUM-1:0]	filter_num;//the filter number
output	[`KERNEL_NUM-1:0]	kernel_num;//number of kernel in one filter 
output	[`KERNEL_SIZE-1:0]	kernel_size;//the kernel size
output	[`KERNEL_STEP-1:0]	kernel_step;//convolution step

output	maxpooling_en;//enable maxpooling
output	image_return_axi;//return image to axi
output		infor_update;//the head information have been updated    



//load_image module 
input	image_one_return_finish;
input	load_image_begin;//begin to load an image
output	load_image_finish;//finishing loading an image
input	maxpooling_finish;
input	image_rd_ready;//the ram is ready for reading image data
output	 	buffer_image_rd;//read the ram 
output	 	[`IMAGE_SIZE*2+7:0]	buffer_image_rd_addr;//{row,column] of the image 
input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	buffer_image_rd_q;//all the channel image data
input	[`PARALLEL_NUM-1:0]	buffer_image_rd_valid;//indicate valid channel data
input	image_need;//cal_image part need read image request
output	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	image_rd_q;//output image data
output	 	[`PARALLEL_NUM-1:0]	image_valid;//the valid image data    
    
  
//load_kernel
input	load_kernel_begin;//begin signal for loading kernel
output	load_kernel_finish;//finishing load kernel


output		buffer_kernel_rd;//read request for reading kernel buffer
input	[`KERNEL_BITWIDTH*`PARALLEL_NUM-1:0]	buffer_kernel_rd_q;//output kernel
input	buffer_kernel_empty;


output		[`KERNEL_ELE_BITWIDTH*`PARALLEL_NUM*`MAX_KERNEL_SIZE-1:0]	kernel_q;//kernel output
output	 	[`BIAS_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	bias1_q;
output	 	[`BIAS_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	bias2_q;
output	 	[`DIV_ELE_BITWIDTH*`PARALLEL_NUM-1:0]		div_q;
output	kernel_valid;//valid signal  
  
  
    
wire	image_addr_inputRAM_increase;

    
load_head load_head_m1(
    	.clk(clk),
    	.rst_n(rst_n),
    	
    	.load_head_begin(load_head_begin),
    	
    	.load_head_rd(load_head_rd),
    	.load_head_rd_q(load_head_rd_q),
    	.load_head_empty(load_head_empty),
    	
    	.image_num(image_num),
    	.image_size(image_size),
    	.image_size_after_maxpooling(image_size_after_maxpooling),
    	.image_sum_en(image_sum_en),
    	.image_update(image_update),
    	.image_next_read_en(image_next_read_en),
    	.image_addr_inputRAM_increase(image_addr_inputRAM_increase),
    	
    	.filter_num(filter_num),
    	.kernel_num(kernel_num),
    	.kernel_size(kernel_size),
    	.kernel_step(kernel_step),
    	
    	.maxpooling_en(maxpooling_en),
    	.image_return_axi(image_return_axi),
    	
    	.infor_update(infor_update)
    	
    
        );    
    
    
load_image load_image_m1(
		.clk(clk),
		.axi_clk(axi_clk),
		.rst_n(rst_n),
		
		.load_image_begin(load_image_begin),
		.load_image_finish(load_image_finish),
		.maxpooling_finish(maxpooling_finish),
		
		.infor_update(infor_update),
		.filter_num(filter_num),
		.kernel_num(kernel_num),
		.kernel_size(kernel_size),
		.image_size(image_size),
		.image_next_read_en(image_next_read_en),
		.image_return_axi(image_return_axi),
		.image_addr_inputRAM_increase(image_addr_inputRAM_increase),
		.image_one_return_finish(image_one_return_finish),
		
		.image_rd_ready(image_rd_ready),
		.buffer_image_rd(buffer_image_rd),
		.buffer_image_rd_addr(buffer_image_rd_addr),
		.buffer_image_rd_q(buffer_image_rd_q),
		.buffer_image_rd_valid(buffer_image_rd_valid),
		
		.image_need(image_need),
		.image_rd_q(image_rd_q),
		.image_valid(image_valid)	
	
	
		);    
    
 
 
 
load_kernel load_kernel_m1(
		.clk(clk),
		.rst_n(rst_n),
		
		.load_kernel_begin(load_kernel_begin),
		.load_kernel_finish(load_kernel_finish),
		
		.kernel_size(kernel_size),
		
		.buffer_kernel_rd(buffer_kernel_rd),
		.buffer_kernel_rd_q(buffer_kernel_rd_q),
		.buffer_kernel_empty(buffer_kernel_empty),
		

		.kernel_q(kernel_q),
		.bias1_q(bias1_q),
		.bias2_q(bias2_q),
		.div_q(div_q),
		.kernel_valid(kernel_valid)
		
		
		    );
 
 
 
 
 
 
 
 
    
endmodule
