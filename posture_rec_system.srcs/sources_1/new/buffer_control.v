`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/25 10:17:17
// Design Name: 
// Module Name: buffer_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: head, image read from axi, kernel and image write to axi storage and control
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module buffer_control(
	clk,
	debug_clk,
	rst_n,
	
	information_operation,
	buffer_wr_req,
	buffer_wr_data,
	
	
	head_wr_req,
	head_data,
	
	head_rd_need,
	load_head_clk,
	load_head_rd,
	load_head_rd_q,
	load_head_empty,
	
	kernel_rd_need,
	kernel_wr_size,
	kernel_wr_num,
	filter_wr_num,
	

	load_kernel_clk,
	load_kernel_rd,
	load_kernel_rd_q,
	load_kernel_empty,
	
	image_rd_need,
	image_wr_finish,
	image_wr_num,
	image_wr_size,
	
	image_rd_update,
	image_rd_ready,
	
	load_image_clk,
	load_image_rd,
	load_image_rd_addr,
	load_image_rd_q,
	load_image_valid,
	
	image_wr_need,
		
	filter_num,
	kernel_num,
	image_size,
	infor_update,
	image_return_axi,
	maxpooling_en,

	
	image_rd_req,
	image_rd_pre,
	image_rd_finish,
	image_rd_empty,
	image_rd_data,
	
	deal_PostImage_clk,
	deal_PostImage_rd,
	deal_PostImage_rd_addr,
	deal_PostImage_rd_q,
	deal_PostImage_rd_valid_channel,
	deal_PostImage_wr,
	deal_PostImage_wr_data,
	deal_PostImage_wr_last,
	deal_PostImage_wr_addr,
	maxpooling_finish,
	algorithm_finish
	
	
	
	

    );
    
input clk;
input debug_clk;
input rst_n;
   
input [3:0]	information_operation;//record the state of operating
input buffer_wr_req;//write data to buffer request   
input [`AXI_DATA_WIDTH-1:0]	buffer_wr_data; 


output	head_wr_req;
output	[`AXI_DATA_WIDTH-1:0]	head_data;

output head_rd_need;//need to read head information
input  load_head_clk;//clock for reading head from fifo
input load_head_rd;//read signal
output [`HEAD_WIDTH-1:0]	load_head_rd_q;//
output load_head_empty;//the fifo is empty




output   kernel_rd_need;//need to read kernel from axi
input [`KERNEL_SIZE-1:0]	kernel_wr_size;//size of the kernel
input [`KERNEL_NUM-1:0]	kernel_wr_num;//number of kernels in one filter
input [`FILTER_NUM-1:0]	filter_wr_num;//number of the filters



input load_kernel_clk;
input load_kernel_rd;//read request
output [`KERNEL_BITWIDTH*`PARALLEL_NUM-1:0]	load_kernel_rd_q;
output load_kernel_empty;

input	image_wr_finish;//finish reading all image 
output image_rd_need;//need to read image from axi
input [`IMAGE_NUM-1:0]	image_wr_num;//in writing image operation, the bumber of images
input [`IMAGE_SIZE-1:0]	image_wr_size;//the size of image sizeXsize
input	maxpooling_en;//enbale maxpooling at this operation



input	image_rd_update;
output	image_rd_ready;

input load_image_clk;
input load_image_rd;
input [`IMAGE_SIZE*2+7:0]	load_image_rd_addr;//{num,row[7:0],column[7:0]}
output [`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	load_image_rd_q;//all the 24 ram data
output [`PARALLEL_NUM-1:0]	load_image_valid;//which channel is valid

output	 	image_wr_need;//maxpooling is done and can write to axi

input	[`FILTER_NUM-1:0]	filter_num;//equal the ram channels
input   [`KERNEL_NUM-1:0]	kernel_num;//the kernel number
input	[`IMAGE_SIZE-1:0]	image_size;//image size
input	infor_update;//head information have been updated
input	image_return_axi;//whether return image to axi


input	image_rd_req;//request to read from image ram
input	image_rd_pre;//preread image to FIFO and be ready for axi reading image
input	image_rd_finish;
output	image_rd_empty;
output	[`IMAGE_BITWIDTH-1:0]	image_rd_data;//from fifo which is read from ram with 16 bit width

input	deal_PostImage_clk;
input	deal_PostImage_rd;//the postdeal part need to read image
input	[`IMAGE_SIZE*2-1:0]	deal_PostImage_rd_addr;//{row, column}
output	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_q;
output	[`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_valid_channel;
input	deal_PostImage_wr;//write image data to ram
input	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_wr_data;
input	deal_PostImage_wr_last;//the last write data
input	[`IMAGE_SIZE*2-1:0]	deal_PostImage_wr_addr;//{row, column}
input	maxpooling_finish;
input	algorithm_finish;



    

wire   image_wr_req;
wire 	kernel_wr_req;
    
 
 
assign	head_data	=	 head_wr_req ? buffer_wr_data : `AXI_DATA_WIDTH'h0;
    
    
mux_head_image_kernel mux_head_image_kernel_m1(
	.information_operation(information_operation),
	.buffer_wr_req(buffer_wr_req),
	.head_wr_req(head_wr_req),
	.image_wr_req(image_wr_req),
	.kernel_wr_req(kernel_wr_req)


);    
    
head_bufer_control head_bufer_control_m1(
	.clk(clk),
	.rst_n(rst_n),
	
	.algorithm_finish(algorithm_finish),
	.head_rd_need(head_rd_need),
	.head_wr_req(head_wr_req),
	.head_wr_data(buffer_wr_data),
	
	.load_head_clk(load_head_clk),
	.load_head_rd(load_head_rd),
	.load_head_rd_q(load_head_rd_q),
	.load_head_empty(load_head_empty)



    );    
    
 

 
    
   
kernel_buffer_control kernel_buffer_control_m1(
    	.clk(clk),
    	.rst_n(rst_n),
    	
    	.kernel_wr_req(kernel_wr_req),
    	.kernel_wr_data(buffer_wr_data),
    	
    	.kernel_rd_need(kernel_rd_need),
    	.kernel_wr_size(kernel_wr_size),
    	.kernel_wr_num(kernel_wr_num),
    	.filter_wr_num(filter_wr_num),
    	
    	
    	.load_kernel_clk(load_kernel_clk),
    	.load_kernel_rd(load_kernel_rd),
    	.load_kernel_rd_q(load_kernel_rd_q),
    	.load_kernel_empty(load_kernel_empty)
    
    
    
        );   
        
         
  
image_read_buffer_control image_read_buffer_control_m1(
        	.clk(clk),
        	.load_head_clk(load_head_clk),
        	.rst_n(rst_n),
        	
        	.image_rd_need(image_rd_need),
        	.image_wr_finish(image_wr_finish),//choose the image data last
        	.image_wr_num(image_wr_num),
        	.image_wr_size(image_wr_size),
        	
        	.image_wr_req(image_wr_req),
        	.image_wr_data(buffer_wr_data),
        	
        	.infor_update(infor_update),
        	.image_rd_update(image_rd_update),
        	.image_rd_ready(image_rd_ready),
        	.algorithm_finish(algorithm_finish),
        	
        	.kernel_rd_num(kernel_num),
        	.image_rd_size(image_size),
        	.load_image_clk(load_image_clk),
        	.load_image_rd(load_image_rd),
        	.load_image_rd_addr(load_image_rd_addr),
        	.load_image_rd_q(load_image_rd_q),
        	.load_image_valid(load_image_valid)
        			
            );    
    


image_write_buffer_control image_write_buffer_control_m1(
	.clk(clk),
	.debug_clk(debug_clk),
	.rst_n(rst_n),
	
	.image_wr_need(image_wr_need),
	
	.filter_num(filter_num),
	.image_size(image_size),
	.infor_update(infor_update),
	.image_return_axi(image_return_axi),
	.maxpooling_en(maxpooling_en),

	
	.image_rd_req(image_rd_req),
	.image_rd_pre(image_rd_pre),
	.image_rd_finish(image_rd_finish),
	.image_rd_empty(image_rd_empty),
	.image_rd_data(image_rd_data),
	
	.deal_PostImage_clk(deal_PostImage_clk),
	.deal_PostImage_rd(deal_PostImage_rd),
	.deal_PostImage_rd_addr(deal_PostImage_rd_addr),
	.deal_PostImage_rd_q(deal_PostImage_rd_q),
	.deal_PostImage_rd_valid_channel(deal_PostImage_rd_valid_channel),
	.deal_PostImage_wr(deal_PostImage_wr),
	.deal_PostImage_wr_data(deal_PostImage_wr_data),
	.deal_PostImage_wr_last(deal_PostImage_wr_last),
	.deal_PostImage_wr_addr(deal_PostImage_wr_addr),
	.maxpooling_finish(maxpooling_finish)

    );












    
    
endmodule
