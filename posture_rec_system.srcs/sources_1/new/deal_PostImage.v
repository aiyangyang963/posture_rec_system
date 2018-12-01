`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/30 18:07:17
// Design Name: 
// Module Name: deal_PostImage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: sum overall channel image data and update the dealt image data
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module deal_PostImage(


	clk,
	rst_n,
	
	infor_update,
	filter_num,
	kernel_num,
	last_image_sum_en,
	
	image_data,
	image_valid,
	
	activation_choose,
	norm_en,
	bias1_data,
	bias2_data,
	mul_data,
	kernel_valid,
	
	maxpooling_flag,
	image_size,
	maxpooling_finish,
	
	deal_PostImage_rd,
	deal_PostImage_rd_addr,
	deal_PostImage_rd_q,
	deal_PostImage_rd_valid,
	deal_PostImage_wr,
	deal_PostImage_wr_addr,
	deal_PostImage_wr_data,
	deal_PostImage_wr_last



    );
    
    



input	clk;
input	rst_n;

input	infor_update;
input	[`FILTER_NUM-1:0]	filter_num;
input	[`KERNEL_NUM-1:0]	kernel_num;//kernel number in one filter
input	last_image_sum_en;//whether sum the image data with the buffered data
input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	image_data;//the input image data from PARALLEL_NUM dealing channels
input	[`PARALLEL_NUM-1:0]	image_valid;//valid signal

input	activation_choose;
input	norm_en;
input	[`BIAS_ELE_BITWIDTH*`PARALLEL_NUM-1:0] bias1_data;
input	[`BIAS_ELE_BITWIDTH*`PARALLEL_NUM-1:0] bias2_data;
input	[`DIV_ELE_BITWIDTH*`PARALLEL_NUM-1:0] mul_data;
input	kernel_valid;

input	maxpooling_flag;//flag of perform maxpooling
input	[`IMAGE_SIZE-1:0]	image_size;
output	maxpooling_finish;//indicate that maxpooling is end for one images



output	deal_PostImage_rd;//the postdeal part need to read image
output	[`IMAGE_SIZE*2-1:0]	deal_PostImage_rd_addr;//{row, column}
input	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_q;
input	[`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_valid;
output	deal_PostImage_wr;//write image data to ram
output	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_wr_data;
output	deal_PostImage_wr_last;//the last write data
output	[`IMAGE_SIZE*2-1:0]	deal_PostImage_wr_addr;//{row, column}







wire	[`POSTIMAGE_CHANNEL-1:0] last_image_rd;//read the image data from buffer store the dealt image data
wire	[`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	last_image;//image data read from the buffer srore dealt image
wire	[`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	sum_q;//output to be operated for maxpooling
wire	[`POSTIMAGE_CHANNEL-1:0]	sum_q_valid;

wire	[`POSTIMAGE_CHANNEL*`POSTIMAGE_BITWIDTH-1:0]	update_image_data;
wire	[`POSTIMAGE_CHANNEL-1:0]	update_image_valid;
wire	[`POSTIMAGE_CHANNEL-1:0]	maxpooling_finish_array;






   
    
summation summation_m1(
    
    	.clk(clk),
    	.rst_n(rst_n),
    	
    	.filter_num(filter_num),
    	.kernel_num(kernel_num),
    	.last_image_sum_en(last_image_sum_en),
    	
    	.image_data(image_data),
    	.image_valid(image_valid),
    	
    	.last_image_rd(last_image_rd),
    	.last_image(last_image),
    	
    	.sum_q(sum_q),
    	.sum_q_valid(sum_q_valid)
    
    
        );    
    
wire [`IMAGE_ELE_BITWIDTH-1:0] norm_q[`PARALLEL_NUM-1:0];
wire [`PARALLEL_NUM-1:0] norm_q_valid;
wire [`IMAGE_ELE_BITWIDTH-1:0] activation_q[`PARALLEL_NUM-1:0];
wire [`PARALLEL_NUM-1:0] activation_q_valid;
wire [`IMAGE_ELE_BITWIDTH-1:0] to_maxpooling_data[`PARALLEL_NUM-1:0];
wire [`PARALLEL_NUM-1:0] to_maxpooling_data_valid;
reg norm_en_r, norm_en_r1, norm_en_r2, norm_en_r3, norm_en_r4;

always @(posedge clk)
begin
	norm_en_r <= norm_en;
	norm_en_r1 <= norm_en_r;
	norm_en_r2 <= norm_en_r1;
	norm_en_r3 <= norm_en_r2;
	norm_en_r4 <= norm_en_r3;
end
genvar	h;
for(h=0;h<`POSTIMAGE_CHANNEL;h=h+1)begin : norm_and_activation
batch_norm batch_norm_m(
	.clk(clk),
	.norm_en(sum_q_valid[h]),
	.data(sum_q[`IMAGE_ELE_BITWIDTH*(h+1)-1:`IMAGE_ELE_BITWIDTH*h]),
	.bias(bias1_data[`BIAS_ELE_BITWIDTH*(h+1)-1:`BIAS_ELE_BITWIDTH*h]),
	.mean(bias2_data[`BIAS_ELE_BITWIDTH*(h+1)-1:`BIAS_ELE_BITWIDTH*h]),
	.mul(mul_data[`DIV_ELE_BITWIDTH*(h+1)-1:`DIV_ELE_BITWIDTH*h]),
	.q(norm_q[h]),
	.q_valid(norm_q_valid[h])
    );
    
activation activation_m(
	.clk(clk),
	.activation_en(norm_q_valid[h]),
	.data(norm_q[h]),
	.activation_choose(activation_choose),
	.q(activation_q[h]),
	.q_valid(activation_q_valid[h])
        );    



    
assign to_maxpooling_data[h] = norm_en_r4 ? activation_q[h] : sum_q[`IMAGE_ELE_BITWIDTH*(h+1)-1:`IMAGE_ELE_BITWIDTH*h];
assign to_maxpooling_data_valid[h] = norm_en_r4 ? activation_q_valid[h] : sum_q_valid[h];     
    
end


    
genvar	k;
for(k=0;k<`POSTIMAGE_CHANNEL;k=k+1)begin : max_pooling_loop

	max_pooling max_pooling_m(
	.clk(clk),
	.rst_n(rst_n),
	
	.maxpooling_flag(maxpooling_flag),
	.image_size(image_size),
	
	.image_data(to_maxpooling_data[k]),
	.image_valid(to_maxpooling_data_valid[k]),
	
	.image_q_valid(update_image_valid[k]),
	.image_q(update_image_data[`POSTIMAGE_BITWIDTH*(k+1)-1:`POSTIMAGE_BITWIDTH*k]),
	
	.maxpooling_finish(maxpooling_finish_array[k])

	);  
	
end  
    
assign	maxpooling_finish	=	maxpooling_finish_array[0]; 
    
    
 
 
 

update update_m1(
	.clk(clk),
	.rst_n(rst_n),
	
	.infor_update(infor_update),
	.image_size(image_size),
	.maxpooling_en(maxpooling_flag),
	.last_image_sum_en(last_image_sum_en),
	
	.image_wr(update_image_valid),
	.image_data(update_image_data),
	.maxpooling_finish(maxpooling_finish),
	
	.last_image(last_image),
	.last_image_rd(last_image_rd),
	
	.deal_PostImage_rd(deal_PostImage_rd),
	.deal_PostImage_rd_addr(deal_PostImage_rd_addr),
	.deal_PostImage_rd_q(deal_PostImage_rd_q),
	.deal_PostImage_rd_valid(deal_PostImage_rd_valid),
	.deal_PostImage_wr(deal_PostImage_wr),
	.deal_PostImage_wr_addr(deal_PostImage_wr_addr),
	.deal_PostImage_wr_data(deal_PostImage_wr_data),
	.deal_PostImage_wr_last(deal_PostImage_wr_last)



    );
     
 

 
 
 
 
/* 
wire  tb_maxpooling_flag;
wire [`IMAGE_SIZE-1:0] tb_image_size;
wire [`IMAGE_ELE_BITWIDTH-1:0] tb_image_data;
wire tb_image_valid;
wire [`POSTIMAGE_BITWIDTH-1:0] tb_image_q;
wire tb_image_q_valid;
wire tb_maxpooling_finish;



maxpooling_tb maxpooling_tb_m1(

	.clk(clk),
	.rst_n(rst_n),
	
	.maxpooling_flag(tb_maxpooling_flag),
	.image_size(tb_image_size),
	.image_data(tb_image_data),
	.image_valid(tb_image_valid),
	.image_q(tb_image_q),
	.image_q_valid(tb_image_q_valid),
	.maxpooling_finish(tb_maxpooling_finish)

);  


max_pooling max_pooling_m(
	.clk(clk),
	.rst_n(rst_n),
	
	.maxpooling_flag(tb_maxpooling_flag),
	.image_size(tb_image_size),
	
	.image_data(tb_image_data),
	.image_valid(tb_image_valid),
	
	.image_q_valid(tb_image_q_valid),
	.image_q(tb_image_q),
	
	.maxpooling_finish(tb_maxpooling_finish)

); 
*/

 
    
endmodule
