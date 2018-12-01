`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An pingbo
// 
// Create Date: 2017/08/29 17:27:35
// Design Name: 
// Module Name: cal_image
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: shift window and perform convolution
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cal_image(

	clk,
	rst_n,
	
	infor_update,
	filter_num,
	kernel_num,
	image_size,
	kernel_size,
	kernel_step,

	
	kernel_data,
	kernel_valid,
	
	image_ready,
	image_need,
	image_data,
	image_valid,
	
	image_rect_q,
	image_rect_valid
	
	
	
    );
    
    
input	clk;
input	rst_n;

input	infor_update;
input	[`FILTER_NUM-1:0]	filter_num;//the filter number
input	[`KERNEL_NUM-1:0]	kernel_num;//number of kernel in one filter 
input	[`IMAGE_SIZE-1:0]	image_size;
input	[`KERNEL_SIZE-1:0]	kernel_size;
input	[`KERNEL_STEP-1:0]	kernel_step;
input	[`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE*`PARALLEL_NUM-1:0]	kernel_data;
input	kernel_valid;

input	image_ready;
output	image_need;
input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	image_data;
input	[`PARALLEL_NUM-1:0]image_valid;

output	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	image_rect_q;
output	[`PARALLEL_NUM-1:0]	image_rect_valid;

wire	[`IMAGE_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0]	image[`PARALLEL_NUM-1:0];
wire	[`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0]	kernel[`PARALLEL_NUM-1:0];
wire	conv_en[`PARALLEL_NUM-1:0];//enbale convolution    
wire	conv_ready[`PARALLEL_NUM-1:0];   

wire [`PARALLEL_NUM-1:0] image_need_temp; 
reg [`IMAGE_SIZE-1:0]	image_size_r, image_size_r1;
reg [`KERNEL_SIZE-1:0]	kernel_size_r, kernel_size_r1;
reg [`KERNEL_STEP-1:0]	kernel_step_r, kernel_step_r1;  
reg infor_update_r, infor_update_r1;
reg [`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	image_data_r; 
reg [`PARALLEL_NUM-1:0]image_valid_r;
reg [`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE*`PARALLEL_NUM-1:0]	kernel_data_r;
reg kernel_valid_r;
wire [`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0] stayInstep_data;
wire [`PARALLEL_NUM-1:0] stayInstep_valid;
wire [`PARALLEL_NUM-1:0] channel_choose;


always @(posedge clk)
begin
	infor_update_r <= infor_update;
	image_size_r <= image_size;
	kernel_step_r <= kernel_step;
	kernel_size_r <= kernel_size;
	infor_update_r1 <= infor_update_r;
	image_size_r1 <= image_size_r;
	kernel_step_r1 <= kernel_step_r;
	kernel_size_r1 <= kernel_size_r;
end  
  
always @(posedge clk)
begin
	image_data_r <= image_data;
	image_valid_r <= image_valid;
	kernel_data_r <= kernel_data;
	kernel_valid_r <= kernel_valid;
end  
cal_channel_choose cal_channel_choose_m(
	.clk(clk),
	.infor_update(infor_update),
	.filter_num(filter_num),
	.kernel_num(kernel_num),
	.channel_choose(channel_choose)

); 



    
genvar	i;
for(i=0;i<`PARALLEL_NUM;i=i+1)begin : shift_window_loop



shift_window shift_window_m(    
	.clk(clk),
	.rst_n(rst_n),	
	.infor_update(infor_update_r1),
	.channel_choose(channel_choose[i]),
	.image_size(image_size_r1),
	.kernel_size(kernel_size_r1),
	.kernel_step(kernel_step_r1),		
	.kernel_data(kernel_data_r[`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE*(i+1)-1:`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE*i]),
	.kernel_valid(kernel_valid_r),	
	.image_ready(image_ready),
	.image_need(image_need_temp[i]),
	.image_data(image_data_r[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i]),
	.image_valid(image_valid_r[i]),	
	.image_q(image[i]),
	.kernel_q(kernel[i]),
	.conv_en(conv_en[i]),
	.conv_ready(conv_ready[i])
        
);    
     
 
 
conv conv_m(        	
	.clk(clk),
	.rst_n(rst_n),	
	.infor_update(infor_update_r1),
	.channel_choose(channel_choose[i]),
	.kernel_size(kernel_size_r1),
	.image_size(image_size_r1),
	.image_data(image[i]),
	.kernel_data(kernel[i]),
	.conv_en(conv_en[i]),
	.conv_ready(conv_ready[i]),	
	.image_q(stayInstep_data[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i]),
	.image_q_valid(stayInstep_valid[i])
    );
            
                                                     
end//for    
    
assign image_need=&image_need_temp;  


stayInstep stayInstep_m(
	.clk(clk),
	.channel_choose(channel_choose),
	.din(stayInstep_data),
	.din_valid(stayInstep_valid),
	.dout(image_rect_q),
	.dout_valid(image_rect_valid)

);

//reg [7:0] image_rect_q_error;
//genvar t;
//for(t=0;t<8;t=t+1)begin: error_gen

//	always @(posedge clk)
//	begin
//		if(image_rect_valid[t])
//			if(image_rect_q[`IMAGE_ELE_BITWIDTH*(t+1)-1:`IMAGE_ELE_BITWIDTH*t] == image_rect_q[31:0])
//				image_rect_q_error[t] <= 1'b0;
//			else
//				image_rect_q_error[t] <= 1'b1;
//	end

//end

// conv_ila conv_ila_m (
//	.clk(clk), // input wire clk


//	.probe0(image[1][31:0]), // input wire [31:0]  probe0  
//	.probe1(stayInstep_valid), // input wire [7:0]  probe1
//	.probe2(image[3][31:0]), // input wire [31:0]  probe2 
//	.probe3(image[4][31:0]), // input wire [31:0]  probe3 
//	.probe4(image[5][31:0]), // input wire [31:0]  probe4 
//	.probe5(stayInstep_data[159:128]), // input wire [31:0]  probe5
//	.probe6({conv_en[7], conv_en[6], conv_en[5], conv_en[4], conv_en[3], conv_en[2], conv_en[1], conv_en[0]}), // input wire [7:0]  probe6
//	.probe7(image_rect_q_error) // input wire [7:0]  probe7
//); 
  
 
  
  
  
    
    
    
endmodule
