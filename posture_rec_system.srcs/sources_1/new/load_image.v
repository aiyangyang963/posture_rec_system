`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/29 10:47:02
// Design Name: 
// Module Name: load_image
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: load image data from ram and be ready for the convolution algorithm
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module load_image(
	clk,
	axi_clk,
	rst_n,
	
	load_image_begin,
	load_image_finish,
	maxpooling_finish,
	image_return_axi,
	image_one_return_finish,
	
	infor_update,
	kernel_num,
	filter_num,
	kernel_size,
	image_size,
	image_next_read_en,
	image_addr_inputRAM_increase,
	
	image_rd_ready,
	buffer_image_rd,
	buffer_image_rd_addr,
	buffer_image_rd_q,
	buffer_image_rd_valid,
	
	image_need,
	image_rd_q,
	image_valid	


    );
    
/////////////////////////////inputs and outputs///////////////////////////////////////////
input	clk;
input	axi_clk;
input	rst_n;

input	load_image_begin;//begin to load an image
output	load_image_finish;//finishing loading an image
input	maxpooling_finish;
input	image_one_return_finish;

input	infor_update;
input	[`FILTER_NUM-1:0]	filter_num;
input	[`KERNEL_NUM-1:0]	kernel_num;//number of kernel in one filter
input	[`IMAGE_SIZE-1:0]	image_size;
input	[`KERNEL_SIZE-1:0]	kernel_size;//the kernel size
input	image_next_read_en;
input	image_return_axi;
input	image_addr_inputRAM_increase;

input	image_rd_ready;//the ram is ready for reading image data
output	 	buffer_image_rd;//read the ram 
output	 	[`IMAGE_SIZE*2+7:0]	buffer_image_rd_addr;//{num,row,column] of the image 
input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	buffer_image_rd_q;//all the channel image data
input	[`PARALLEL_NUM-1:0]	buffer_image_rd_valid;//indicate valid channel data
input	image_need;//cal_image part need read image request
output	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	image_rd_q;//output image data
output	[`PARALLEL_NUM-1:0]	image_valid;//the valid image data


/////////////////////////////////////////////////////////////////////////////////////////    
    
 
////////////////////////////////////image_one_return_finish////////////////////////////
reg image_one_return_finish_flag=1'b0;
reg image_one_return_finish_flag_r=1'b0;
reg image_one_return_finish_flag_r1=1'b0;
reg image_one_return_finish_ready=1'b0;
reg image_one_return_finish_ready_r=1'b0;
reg image_one_return_finish_ready_r1=1'b0;
reg image_one_return_finish_ready_temp;
reg image_one_return_finish_ready_temp1;
wire image_one_return_finish_ready_pos;

always @(posedge axi_clk)
begin
	if(image_one_return_finish)
		image_one_return_finish_flag <= 1'b1;
	else if(image_one_return_finish_ready_r1)
		image_one_return_finish_flag <= 1'b0;
end
always @(posedge clk)
begin
	if(image_one_return_finish_flag_r1)
		image_one_return_finish_ready <= 1'b1;
	else if(!image_one_return_finish_flag_r1)
		image_one_return_finish_ready <= 1'b0;
end
always @(posedge axi_clk)
begin
	image_one_return_finish_ready_r <= image_one_return_finish_ready;
	image_one_return_finish_ready_r1 <= image_one_return_finish_ready_r;
end
always @(posedge clk)
begin
	image_one_return_finish_flag_r <= image_one_return_finish_flag;
	image_one_return_finish_flag_r1 <= image_one_return_finish_flag_r;
end

always @(posedge clk)
begin
	image_one_return_finish_ready_temp <= image_one_return_finish_ready;
	image_one_return_finish_ready_temp1 <= image_one_return_finish_ready_temp;
end
assign image_one_return_finish_ready_pos = image_one_return_finish_ready_temp && !image_one_return_finish_ready_temp1;
/////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
 
 
 
    
//////////////////////////////////loading image state register///////////////////////////
reg	image_loading_reg;//is loading image data

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			image_loading_reg	<=	1'b0;
		else if(load_image_begin)
			image_loading_reg	<=	1'b1;
		else if(load_image_finish)
			image_loading_reg	<=	1'b0;
end


////////////////////////////////////////////////////////////////////////////////////////    
 
 
 
 
////////////////////////cross clock////////////////////////////////////////////////////
reg image_rd_ready_in_clk_domain;
reg image_rd_ready_in_clk_domain_r;


always @(posedge clk)
begin
		image_rd_ready_in_clk_domain <= image_rd_ready;
		image_rd_ready_in_clk_domain_r <= image_rd_ready_in_clk_domain;
end

/////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
    
//////////////////////////////////row and column counter registers/////////////////////
wire   conv_data_addzero_en;
wire   conv_data_nozero_en;
wire	add_zero_en1, add_zero_en2, add_zero_en;
wire   buffer_image_rd1, buffer_image_rd2;
wire	load_image_finish1, load_image_finish2;
wire 	[`IMAGE_SIZE*2+7:0] buffer_image_rd_addr1, buffer_image_rd_addr2;


assign	conv_data_addzero_en	=	image_need && image_loading_reg && image_rd_ready_in_clk_domain_r && (kernel_size == 3);
assign	conv_data_nozero_en	=	image_need && image_loading_reg && image_rd_ready_in_clk_domain_r && (kernel_size == 1);

assign buffer_image_rd = (kernel_size == 1) ? buffer_image_rd2 : buffer_image_rd1;
assign buffer_image_rd_addr = (kernel_size == 1) ? buffer_image_rd_addr2 : buffer_image_rd_addr1;

assign add_zero_en = (kernel_size == 1) ? add_zero_en2 : add_zero_en1;
assign load_image_finish = (kernel_size == 1) ? load_image_finish2 : load_image_finish1;

image_shift_rc_cnt image_shift_rc_cnt_m1(
	.clk(clk),
	.rst_n(rst_n),
	.en(conv_data_addzero_en),//enable counting
	.increase(image_addr_inputRAM_increase),
	.clc_num(image_one_return_finish_ready_pos),
	.cnt_threshold(image_size),//row and column counter threshold
	.size(kernel_size),//how many row counts before column counter count
	.finish(load_image_finish1),
	.buffer_image_rd(buffer_image_rd1),
	.add_zero_en(add_zero_en1),
	.result(buffer_image_rd_addr1)


);


image_shift_rc_noaddzero_cnt image_shift_rc_noaddzero_cnt_m1(
	.clk(clk),
	.rst_n(rst_n),
	.en(conv_data_nozero_en),//enable counting
	.increase(image_addr_inputRAM_increase),
	.clc_num(image_one_return_finish_ready_pos),
	.cnt_threshold(image_size),//row and column counter threshold
	.size(kernel_size),//how many row counts before column counter count
	.finish(load_image_finish2),
	.buffer_image_rd(buffer_image_rd2),
	.add_zero_en(add_zero_en2),
	.result(buffer_image_rd_addr2)


);
////////////////////////////////////////////////////////////////////////////////////////    
    
    
/////////////////////////////////////read request and data output///////////////////////
reg add_zero_en_r, add_zero_en_r1, add_zero_en_r2,
	add_zero_en_r3;
reg [`PARALLEL_NUM-1:0] add_zero_en_r4, add_zero_en_r5;
reg [`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0] bufferImage_zeroImage;
reg [`PARALLEL_NUM-1:0]	buffer_image_rd_valid_r;

always @(posedge clk)
begin
	add_zero_en_r <= add_zero_en;
	add_zero_en_r1 <= add_zero_en_r;
	add_zero_en_r2 <= add_zero_en_r1;
	add_zero_en_r3 <= add_zero_en_r2;
end
always @(posedge clk)
begin
	case(kernel_num)
	`PARALLEL_WIDTH'd1:begin
		add_zero_en_r4 <= {7'h0, add_zero_en_r3};
	end
	`PARALLEL_WIDTH'd2:begin
		add_zero_en_r4 <= {6'h0, {2{add_zero_en_r3}}};
	end
	`PARALLEL_WIDTH'd3:begin
		add_zero_en_r4 <= {5'h0, {3{add_zero_en_r3}}};
	end
	`PARALLEL_WIDTH'd4:begin
		add_zero_en_r4 <= {4'h0, {4{add_zero_en_r3}}};
	end
	`PARALLEL_WIDTH'd5:begin
		add_zero_en_r4 <= {3'h0, {5{add_zero_en_r3}}};
	end
	`PARALLEL_WIDTH'd6:begin
		add_zero_en_r4 <= {2'h0, {6{add_zero_en_r3}}};
	end
	`PARALLEL_WIDTH'd7:begin
		add_zero_en_r4 <= {1'h0, {7{add_zero_en_r3}}};
	end
	`PARALLEL_WIDTH'd8:begin
		add_zero_en_r4 <= {8{add_zero_en_r3}};
	end
	endcase
end
always @(posedge clk)
begin
	add_zero_en_r5 <= add_zero_en_r4;
end
always @(posedge clk)
begin
	buffer_image_rd_valid_r <= buffer_image_rd_valid;
end


genvar i;
for(i=0;i<`PARALLEL_NUM;i=i+1)begin: image_choose
	always @(posedge clk)begin
		if(buffer_image_rd_valid[i])
			bufferImage_zeroImage[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i] <= buffer_image_rd_q[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i];
		else if(add_zero_en_r4[i])
			bufferImage_zeroImage[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i] <= 0;
	end
end





CalImageChannel_replication CalImageChannel_replication_m1(
	.clk(clk),
	.rst_n(rst_n),
	.data(bufferImage_zeroImage),
	.choose(filter_num),
	.valid(buffer_image_rd_valid_r | add_zero_en_r5),
	.q(image_rd_q),
	.valid_out(image_valid)

);

///////////////////////////////////////////////////////////////////////////////////////    
    

//load_image_ila load_image_ila_m (
//	.clk(clk), // input wire clk


//	.probe0(image_addr_inputRAM_increase), // input wire [0:0]  probe0  
//	.probe1(maxpooling_finish), // input wire [0:0]  probe1 
//	.probe2(image_return_axi), // input wire [0:0]  probe2 
//	.probe3(buffer_image_rd_addr[23:16]), // input wire [7:0]  probe3 
//	.probe4(buffer_image_rd_q[159:128]) // input wire [31:0]  probe4
//);
    
    
    
endmodule








//counting row and column of one image
module image_shift_rc_cnt(
	input	clk,
	input	rst_n,
	input	en,
	input	increase,
	input	clc_num,
	input	[`IMAGE_SIZE-1:0]	cnt_threshold,//image_size
	input	[`KERNEL_SIZE-1:0]	size,
	output	finish,
	output reg buffer_image_rd,
	output reg add_zero_en,
	output reg [`IMAGE_SIZE*2+7:0]	result


);


(*DONT_TOUCH="TRUE"*)reg	[7:0]	num = 0;//number of the image
(*DONT_TOUCH="TRUE"*)reg	[`IMAGE_SIZE-1:0]	row_cnt = 0;//row counter
(*DONT_TOUCH="TRUE"*)reg	[`IMAGE_SIZE-1:0]	col_cnt = 0;//column counter
(*DONT_TOUCH="TRUE"*)reg	[`KERNEL_SIZE-1:0]	kernel_cnt = 0;//counter for kernel
wire	[`IMAGE_SIZE-1:0]	row_real_loc;//the column location	


always @(posedge clk)
begin
		if(kernel_cnt == size - 1'b1 && en)
			kernel_cnt	<=	`KERNEL_SIZE'h0;
		else if(en)
			kernel_cnt	<=	kernel_cnt + 1'b1;
end





always @(posedge clk)
begin
		if(kernel_cnt == size - 1'b1 && col_cnt == cnt_threshold + 1'b1 && en)
			col_cnt	<=	`IMAGE_SIZE'h0;
		else if(kernel_cnt == size - 1'b1 && en)
			col_cnt	<=	col_cnt + 1'b1;
end


always @(posedge clk)
begin
		if(finish)
			row_cnt	<=	`IMAGE_SIZE'h0;
		else if(en && col_cnt == cnt_threshold + 1'b1 && kernel_cnt == size - 1'b1)
			row_cnt	<=	row_cnt + 1'b1;
end





assign	row_real_loc	=	row_cnt + kernel_cnt;
assign	finish	=	(row_real_loc == cnt_threshold + 1'b1 && col_cnt == cnt_threshold + 1'b1 && en) ? 1'b1 : 1'b0;


reg [4:0] numIncrease_state;
parameter numIncrease_idle = 5'h0,
		   numIncrease_judge = 5'h01,
		   numIncrease_clc = 5'h02,
		   numIncrease_inc = 5'h04,
		   numIncrease_hold = 5'h08,
		   numIncrease_end = 5'h10;
		   
always @(posedge clk)
begin
	if(!rst_n)begin
		numIncrease_state <= numIncrease_idle;	
		num <= 8'h0;	
	end
	else
		case(numIncrease_state)
		numIncrease_idle:
			if(clc_num)
				numIncrease_state <= numIncrease_clc;
			else if(finish)
				numIncrease_state <= numIncrease_judge;
		numIncrease_judge:
			if(increase)
				numIncrease_state <= numIncrease_inc;
			else if(en && !increase)
				numIncrease_state <= numIncrease_hold;
		numIncrease_clc:begin
			numIncrease_state <= numIncrease_end;
			num <= 8'h0;
		end	
		numIncrease_inc:begin
			numIncrease_state <= numIncrease_end;
			num <= num + 1'b1;
		end
		numIncrease_hold:begin
			numIncrease_state <= numIncrease_end;
			num <= num;
		end
		numIncrease_end:
			numIncrease_state <= numIncrease_idle;
		default:
			numIncrease_state <= numIncrease_idle;
		endcase	
end		   



always @(posedge clk)
begin
	if(!rst_n)
		buffer_image_rd <= 1'b0;
	else if(row_real_loc != 0 && col_cnt != 0 && row_real_loc != cnt_threshold + 1'b1 && col_cnt != cnt_threshold + 1'b1)
		buffer_image_rd <= en;
	else
		buffer_image_rd <= 1'b0;
end
always @(posedge clk)
begin
	if(!rst_n)
		add_zero_en <= 1'b0;
	else if(row_real_loc == 0 || col_cnt == 0 || row_real_loc == cnt_threshold + 1'b1 || col_cnt == cnt_threshold + 1'b1)
		add_zero_en <= en;
	else
		add_zero_en <= 1'b0;
end

	

always @(posedge clk)
begin
	result	<=	{num, row_real_loc - 1'b1, col_cnt - 1'b1};
end




endmodule




