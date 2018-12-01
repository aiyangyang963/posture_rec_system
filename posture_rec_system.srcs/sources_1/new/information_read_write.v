`timescale 1ns / 1ns
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/22 16:21:02
// Design Name: 
// Module Name: information_read_write
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: conrol operations of dealt image data, kernels, head information.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module information_read_write(
	clk,
	deal_clk,
	rst_n,
	
	rd_req,
	rd_addr,
	rd_len,
	rd_finish,
	wr_req,
	wr_addr,
	wr_len,
	wr_finish,
	
	image_begin,	
	maxpooling_finish,
	one_layer_finish,
	algorithm_finish,

	
	head_rd_need,
	kernel_rd_need,
	image_rd_need,
	image_wr_need,
	information_operation,
	head_wr_req,
	head_data,
	image_wr_size,
	image_wr_num,
	kernel_wr_size,
	kernel_wr_num,
	filter_wr_num,
	image_wr_finish,
	image_rd_finish,
	
	image_toaxi_size,
	image_toaxi_num



    );
  
    
////////////////////////////////////inputs and outputs/////////////////////////////////////////////////
input clk;
input deal_clk;
input rst_n;

output  rd_req;//read request from axi
output [`AXI_ADDR_WIDTH-1:0]	rd_addr;//the read address
output [7:0]	rd_len;//the length of one read burst
input rd_finish;//finishing reading data
output  wr_req;//write request to axi
output [`AXI_ADDR_WIDTH-1:0]	wr_addr;//write address
output [7:0]	wr_len;//write burst length
input wr_finish;//finishing writing data

input image_begin;//the image is ready from ps end, and can begin to read or write to axi
input one_layer_finish;//one layer of machine learning finish
input maxpooling_finish;
input algorithm_finish;

input head_rd_need;//need to read head control data from axi
input kernel_rd_need;
input image_rd_need;
input image_wr_need;//need to write dealt image to axi
output reg[3:0]	information_operation;//indicate which operation is going on: head, kernel, image read, image write from low bit to high bit
input [`HEAD_WIDTH-1:0]	head_data;//write to a RAM for iterating and telling the read and write kernel or image information
input head_wr_req;//request for head_data write
output [`KERNEL_NUM-1:0]	kernel_wr_num;//number of the kernel of every filter read from axi and write to ram.
output [`FILTER_NUM-1:0]	filter_wr_num;//number of filter
output [`KERNEL_SIZE-1:0]	kernel_wr_size;//size of one kernel
output [`IMAGE_NUM-1:0]		image_wr_num;//image number read from axi and write to ram
output [`IMAGE_SIZE-1:0]	image_wr_size;//image size read from axi and write to ram
output	reg	image_wr_finish;//finishing writing all data to axi
(*DONT_TOUCH="TRUE"*)output	reg	image_rd_finish;//finishing reading all data from axi

input [`IMAGE_NUM-1:0]	image_toaxi_num;//image number returned to axi
input [`IMAGE_SIZE-1:0]	image_toaxi_size;//size returned to axi


////////////////////////////////////////////////////////////////////////////////////////////////////////    
 
 
//////////////////////////////////////cross clcok////////////////////////////////////////////////////////
reg one_layer_finish_r;
reg kernel_rd_need_r;
reg head_rd_need_r;
reg image_begin_temp, image_begin_temp1, image_begin_temp2;
wire image_begin_pos;
reg image_begin_flag;
reg [`IMAGE_SIZE-1:0]	image_toaxi_size_r, image_toaxi_size_r1;
reg [`IMAGE_NUM-1:0]	image_toaxi_num_r, image_toaxi_num_r1;
reg algorithm_finish_req = 1'b0;
reg algorithm_finish_req_r, algorithm_finish_req_r1;
reg algorithm_finish_ack = 1'b0;
reg algorithm_finish_ack_r, algorithm_finish_ack_r1;
reg maxpooling_finish_req = 1'b0;
reg maxpooling_finish_req_r, maxpooling_finish_req_r1, maxpooling_finish_req_r2, maxpooling_finish_req_r3;
reg maxpooling_finish_ack = 1'b0;
reg maxpooling_finish_ack_r, maxpooling_finish_ack_r1;



always @(posedge clk)
begin
		image_begin_temp <= image_begin;
		image_begin_temp1 <= image_begin_temp;
		image_begin_temp2 <= image_begin_temp1;
end
assign image_begin_pos	=	image_begin_temp1 && !image_begin_temp2;



always @(posedge deal_clk)
begin
	if(algorithm_finish)
		algorithm_finish_req <= 1'b1;
	else if(algorithm_finish_ack_r1)
		algorithm_finish_req <= 1'b0;
end
always @(posedge clk)
begin
	algorithm_finish_req_r <= algorithm_finish_req;
	algorithm_finish_req_r1 <= algorithm_finish_req_r;
end
always @(posedge clk)
begin
	if(algorithm_finish_req_r1)
		algorithm_finish_ack <= 1'b1;
	else
		algorithm_finish_ack <= 1'b0;
end
always @(posedge deal_clk)
begin
	algorithm_finish_ack_r <= algorithm_finish_ack;
	algorithm_finish_ack_r1 <= algorithm_finish_ack_r;
end
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		image_begin_flag <= 1'b0;
	else if(image_begin_temp1)
		image_begin_flag <= 1'b1;
	else if(algorithm_finish_req_r1)
		image_begin_flag <= 1'b0;
end

always @(posedge deal_clk)
begin
	if(maxpooling_finish || image_begin_pos)
		maxpooling_finish_req <= 1'b1;
	else if(maxpooling_finish_ack_r1 || algorithm_finish_req_r1)
		maxpooling_finish_req <= 1'b0;
end
always @(posedge clk)
begin
	maxpooling_finish_req_r <= maxpooling_finish_req;
	maxpooling_finish_req_r1 <= maxpooling_finish_req_r;
	maxpooling_finish_req_r2 <= maxpooling_finish_req_r1;
	maxpooling_finish_req_r3 <= maxpooling_finish_req_r2;
end
always @(posedge deal_clk)
begin
	maxpooling_finish_ack_r <= maxpooling_finish_ack;
	maxpooling_finish_ack_r1 <= maxpooling_finish_ack_r;
end

always @(posedge clk)
begin
		one_layer_finish_r <= one_layer_finish;		
end

always @(posedge clk)
begin
		kernel_rd_need_r <= kernel_rd_need;
end

always @(posedge clk)
begin
		head_rd_need_r <= head_rd_need;
end


always @(posedge clk)
begin
		image_toaxi_size_r <= image_toaxi_size;
		image_toaxi_size_r1 <= image_toaxi_size_r;
end


always @(posedge clk)
begin
		image_toaxi_num_r <= (image_toaxi_num == `IMAGE_NUM'h0) ? `IMAGE_NUM'h1 : image_toaxi_num;
		image_toaxi_num_r1 <= image_toaxi_num_r;
end
///////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
    
/////////////////////////////////////////write and read state control///////////////////////////////////
(*DONT_TOUCH="TRUE"*)reg [11:0]	inf_write_read_control;
parameter  inf_write_read_idle	=	12'h000,
			inf_write_read_ready	=	12'h001,
			inf_write_read_head_rd	=	12'h002,
			inf_write_read_iterate_head_wait	=	12'h004,
			inf_write_read_iterate_head	=	12'h008,
			inf_write_read_iterate_judge_wait	=	12'h010,
			inf_write_read_iterate_judge	=  12'h020,
			inf_write_read_image_rd	=	12'h040,
			inf_write_read_kernel_rd	=	12'h080,
			inf_write_read_kernel_judge	=	12'h100,
			inf_write_read_image_wr	=	12'h200,
			inf_write_read_end	=	12'h400,
			inf_write_read_wait	=	12'h800;

wire 		image_rd_en;//in iterating head, need to read image
wire 		all_rd_finish;//finishing read all data
wire 		all_wr_finish;//finishing writing all data
wire		new_wr_finish;
wire		new_rd_finish;
wire 		image_next_load;//in the next step, need to load image from axi
wire		image_stop_load;
wire		kernel_no_rd;
reg	[7:0]	wait_cnt;
reg [1:0]   iterate_head_wait_cnt;
reg [3:0]	iterate_judge_wait_cnt;

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)begin
			inf_write_read_control	<=	inf_write_read_idle;
			wait_cnt <= 8'h0;
			iterate_head_wait_cnt <= 2'b00;
			iterate_judge_wait_cnt <= 4'h0;
		end
		else 
			case(inf_write_read_control)
			inf_write_read_idle:
				if(image_begin_flag)
					inf_write_read_control	<=	inf_write_read_ready;
			inf_write_read_ready:
				if(image_wr_need)//priority 1
					inf_write_read_control	<=	inf_write_read_image_wr;
				else if(head_rd_need_r && maxpooling_finish_req_r3)begin
					inf_write_read_control	<=	inf_write_read_head_rd;					
				end
//				else if(image_rd_need || (kernel_rd_need_r && !image_next_load && !image_stop_load))//priority 3
//					inf_write_read_control	<=	inf_write_read_iterate_head;
			inf_write_read_image_wr:
				if(all_wr_finish)//finishing writing image to axi 
					inf_write_read_control	<=	inf_write_read_end;
			inf_write_read_head_rd:
				if(new_rd_finish)//in this state, reading head is in operation
					inf_write_read_control	<=	inf_write_read_iterate_head_wait;
			inf_write_read_iterate_head_wait:
				if(iterate_head_wait_cnt == 2'b11)begin
					inf_write_read_control	<=	inf_write_read_iterate_head;
					iterate_head_wait_cnt <= 2'b00;
				end	
				else begin
					iterate_head_wait_cnt <= iterate_head_wait_cnt + 1'b1;
				end	
			inf_write_read_iterate_head:				
				inf_write_read_control	<=	inf_write_read_iterate_judge_wait;
			inf_write_read_iterate_judge_wait:
				if(iterate_judge_wait_cnt == 4'hF)begin
					inf_write_read_control	<=	inf_write_read_iterate_judge;
					iterate_judge_wait_cnt <= 4'h0;
				end
				else begin
					iterate_judge_wait_cnt <= iterate_judge_wait_cnt + 1'b1;
				end
			inf_write_read_iterate_judge:
				if(image_rd_en && image_rd_need)//need read image and head have read image flag
					inf_write_read_control	<=	inf_write_read_image_rd;
				else if(kernel_no_rd)
					inf_write_read_control	<=	inf_write_read_end;
				else
					inf_write_read_control	<=	inf_write_read_kernel_rd;
			inf_write_read_image_rd:
				if(all_rd_finish)//finishing reading image 
					inf_write_read_control	<=	inf_write_read_kernel_rd;
			inf_write_read_kernel_rd:
				if(all_rd_finish)
					inf_write_read_control	<=	inf_write_read_kernel_judge;
			inf_write_read_kernel_judge:
//				if(!kernel_rd_need_r || image_next_load || image_stop_load)
				inf_write_read_control	<=	inf_write_read_end;
//				else
//					inf_write_read_control	<=	inf_write_read_iterate_head;
			inf_write_read_end:
				inf_write_read_control	<=	inf_write_read_wait;
			inf_write_read_wait:
				if(wait_cnt == 8'hF)begin
					inf_write_read_control	<=	inf_write_read_idle;
					wait_cnt <= 8'h0;
				end
				else
					wait_cnt <= wait_cnt + 1'b1;
			default:
				inf_write_read_control	<=	inf_write_read_idle;
			endcase
end
///////////////////////////////////////////////////////////////////////////////////////////////////////    
  
  
  
//////////////////////////////////////operation state///////////////////////////////////////////////////
wire	[3:0]	information_operation_temp;

assign information_operation_temp[0]	=	(inf_write_read_control == inf_write_read_image_wr) ? 1'b1 : 1'b0;
assign information_operation_temp[1]	=	(inf_write_read_control == inf_write_read_head_rd) ? 1'b1 : 1'b0;
assign information_operation_temp[2]	=	(inf_write_read_control == inf_write_read_image_rd) ? 1'b1 : 1'b0;
assign information_operation_temp[3]	=	(inf_write_read_control == inf_write_read_kernel_rd) ? 1'b1 : 1'b0;


always @(posedge clk)
begin
		information_operation	<=	information_operation_temp;
end

always @(posedge clk)
begin
	if(inf_write_read_control == inf_write_read_ready && head_rd_need_r && maxpooling_finish_req_r3)
		maxpooling_finish_ack <= 1'b1;
	else
		maxpooling_finish_ack <= 1'b0;
end
/////////////////////////////////////////////////////////////////////////////////////////////////////  
 
 
 
 
 
    
//////////////////////////////////ieterate head_ram and generate read bytes number///////////////////////    
wire [2:0]	mux_en;
wire [28:0]	mux_q;
wire [15:0]	multi_byte;//the 32bits number, 32bits is the unit of data for image and kernel
wire [15:0] multi_byte_double;//number of 64 bits 
wire iterate_en;
reg [7:0]	kernel_wr_size_4bytes;//how many 4 bytes in a kernel with size kernel_wr_size	



assign mux_en[0]	=	(inf_write_read_control == inf_write_read_image_wr) ? 1'b1 : 1'b0;
assign mux_en[1]	=	(inf_write_read_control == inf_write_read_image_rd) ? 1'b1 : 1'b0;
assign mux_en[2]	=	(inf_write_read_control == inf_write_read_kernel_rd) ? 1'b1 : 1'b0;
 
 
assign iterate_en	=	(inf_write_read_control == inf_write_read_iterate_head) ? 1'b1 : 1'b0;

 
always @(kernel_wr_size)
begin
		case(kernel_wr_size)
		`KERNEL_SIZE'h1: kernel_wr_size_4bytes	=	8'd4;
		`KERNEL_SIZE'h3: kernel_wr_size_4bytes	=	8'd12;
		default: kernel_wr_size_4bytes	=	8'd12;
		endcase
end 
 
 
//3 to 1 choice    
mux_3to1 mux_3to1_m1(
	.en(mux_en),
	.d1({image_toaxi_num_r1, image_toaxi_size_r1, image_toaxi_size_r1}),
	.d2({image_wr_num, image_wr_size, image_wr_size}),
	.d3({filter_wr_num, {`KERNEL_NUM_RED'h0,kernel_wr_num}, kernel_wr_size_4bytes}),
	.q(mux_q)
);


//iterate head_ram and generate the number information    
iterate_head iterate_head_m1(
	.clk(clk),
	.rst_n(rst_n),
	
	.iterate_en(iterate_en),
	.finish_readHead(algorithm_finish_req_r1),
	.head_data(head_data),
	.head_wr_req(head_wr_req),
	.image_num(image_wr_num),//number of images need to read from AXI
	.image_en(image_rd_en),//whether to read from axi
	.image_next_load(image_next_load),//in the next step, need to read image
	.image_stop_load(image_stop_load),
	.kernel_no_rd(kernel_no_rd),
	.image_size(image_wr_size),//image size of one image
	.kernel_num(kernel_wr_num),//kernel number in one filter
	.kernel_size(kernel_wr_size),//kernel size
	.filter_num(filter_wr_num)//filter number
	
    );   
  
    
//calculating all bytes need to write or read from axi    
multiplier_3x multiplier_3x_m1(
	.clk(clk),
	.operand_a(mux_q[28:16]),//number
	.operand_b(mux_q[15:8]),//size
	.operand_c(mux_q[7:0]),//size
	.operand_result(multi_byte)
);    

assign	multi_byte_double = multi_byte[15:1]; 
//////////////////////////////////////////////////////////////////////////////////////////////////////    



//////////////////////////////////////registers for writing and reading state////////////////////////
reg rd_finish_state;//whether finishing reading data from axi
reg wr_finish_state;//whether finishing writing data to axi


always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			rd_finish_state	<=	1'b1;
		else if(new_rd_finish)
			rd_finish_state	<=	1'b1;
		else if(rd_req)
			rd_finish_state	<=	1'b0;//when request to reading data, set to 0
end

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			wr_finish_state	<=	1'b1;
		else if(new_wr_finish)
			wr_finish_state	<=	1'b1;
		else if(wr_req)
			wr_finish_state	<=	1'b0;//when request to reading data, set to 0
end

//////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////write and read request control//////////////////////////////////
reg rd_req_temp;//read request temperary
reg rd_req_temp1, rd_req_temp2, rd_req_temp3;

reg wr_req_temp;//write request temparory
reg wr_req_temp1, wr_req_temp2, wr_req_temp3;

always @(posedge clk)
begin
		if(((inf_write_read_control == inf_write_read_head_rd ||
			inf_write_read_control == inf_write_read_image_rd ||
			inf_write_read_control == inf_write_read_kernel_rd) && rd_finish_state))			
			rd_req_temp	<=	1'b1;
		else
			rd_req_temp	<=	1'b0;
end

always @(posedge clk)
begin
		rd_req_temp1	<=	rd_req_temp;
end


 
always @(posedge clk)
begin
		if(inf_write_read_control == inf_write_read_image_wr && wr_finish_state)
			wr_req_temp	<=	1'b1;
		else
			wr_req_temp	<=	1'b0;
end

always @(posedge clk)
begin
		wr_req_temp1	<=	wr_req_temp;
end


always @(posedge clk)
begin
		rd_req_temp2	<=	rd_req_temp && !rd_req_temp1;
		rd_req_temp3	<=	rd_req_temp2;
		wr_req_temp2	<=	wr_req_temp && !wr_req_temp1;
		wr_req_temp3	<=	wr_req_temp2;
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////



    
/////////////////////////////////////////clculate the burst length///////////////////////////////////
reg A_valid;
reg A_valid_r;
reg sub_en;//enable subtraction
wire [`SUB_B_WIDTH-1:0]	sub_result;


always @(posedge clk)
begin
		A_valid	<=	|(information_operation_temp & (~information_operation));
		A_valid_r <= A_valid;
end



always @(posedge clk)
begin
	 sub_en	<=	(rd_req_temp && !rd_req_temp1) || (wr_req_temp && !wr_req_temp1);
end


sub_com sub_com_m1(
	.clk(clk),
	.A_valid(A_valid_r),
	.en(sub_en),
	.A(multi_byte_double),//practical 2bytes number plus 2bytes number used to be aligned for one data of width AXI_BYTE_NUM
	.result1(sub_result)//how many AXI_BYTE_NUM of data

);

//////////////////////////////////////////////////////////////////////////////////////////////////////    


////////////////////////////////////////////image address cross//////////////////////////////////////////////
reg	[`AXI_ADDR_WIDTH-1:0]	image_base_rd_addr;//the base address for image read
reg	[`AXI_ADDR_WIDTH-1:0]	image_base_wr_addr;//the base address for image write
reg image_begin_r;

parameter HEAD_BASE_ADDR_SHIFTRIGHT3 = `HEAD_BASE_ADDR >> 3;
parameter IMAGE_BASE_ADDR1_SHIFTRIGHT3 = `IMAGE_BASE_ADDR1 >> 3;
parameter KERNEL_BASE_ADDR_SHIFTRIGHT3 = `KERNEL_BASE_ADDR >> 3;
parameter IMAGE_BASE_ADDR2_SHIFTRIGHT3 = `IMAGE_BASE_ADDR2 >> 3;





always @(posedge clk)
begin
		if(image_begin_pos)
			image_base_rd_addr	<=	IMAGE_BASE_ADDR1_SHIFTRIGHT3;
		else if(one_layer_finish_r)
			image_base_rd_addr	<=	image_base_rd_addr ^ IMAGE_BASE_ADDR1_SHIFTRIGHT3 ^ IMAGE_BASE_ADDR2_SHIFTRIGHT3;
end

always @(posedge clk)
begin
		if(image_begin_pos)
			image_base_wr_addr	<=	IMAGE_BASE_ADDR2_SHIFTRIGHT3;
		else if(one_layer_finish_r)
			image_base_wr_addr	<=	image_base_wr_addr ^ IMAGE_BASE_ADDR1_SHIFTRIGHT3 ^ IMAGE_BASE_ADDR2_SHIFTRIGHT3;
end



//////////////////////////////////////////////////////////////////////////////////////////////////////////////    
  
/////////////////////////////////////write and read address///////////////////////////////////////////////////
(*DONT_TOUCH="TRUE"*)reg [`AXI_ADDR_WIDTH-1:0] head_addr;
reg [`AXI_ADDR_WIDTH-1:0]	image_rd_addr;
reg [`AXI_ADDR_WIDTH-1:0]	kernel_addr;

wire	[`AXI_ADDR_WIDTH-1:0] 	rd_addr_temp;
reg [`AXI_ADDR_WIDTH-1:0] rd_addr_temp1;
wire [2:0]	rd_addr_strobe;//choose which read address is used
reg	image_wr_need_r;
wire image_rd_addr_rewind;//the read address rewind to start address
reg one_layer_finish_r1;


always @(posedge clk)
begin
	one_layer_finish_r1 <= one_layer_finish_r;
end
always @(posedge clk)
begin
		image_wr_need_r	<=	image_wr_need;
end

assign	image_rd_addr_rewind	=	image_wr_need && !image_wr_need_r;

always @(posedge clk)
begin
		if(image_begin_pos)//begin every CNN leraning test
			head_addr	<=	HEAD_BASE_ADDR_SHIFTRIGHT3;
		else if(inf_write_read_control == inf_write_read_head_rd && new_rd_finish)//1 burst
			head_addr	<=	head_addr + 1'b1;			
end



always @(posedge clk)
begin
		if(image_begin_pos)
			image_rd_addr	<=	IMAGE_BASE_ADDR1_SHIFTRIGHT3;
		else if(image_rd_addr_rewind || one_layer_finish_r1)
			image_rd_addr	<=	image_base_rd_addr;
		else if(inf_write_read_control == inf_write_read_image_rd && new_rd_finish)
			image_rd_addr	<=	image_rd_addr + sub_result;

end


always @(posedge clk)
begin
		if(image_begin_pos)
			kernel_addr	<=	KERNEL_BASE_ADDR_SHIFTRIGHT3;
		else if(inf_write_read_control == inf_write_read_kernel_rd && new_rd_finish)
			kernel_addr	<=	kernel_addr + sub_result;
end


assign rd_addr_strobe[0]	=	(inf_write_read_control == inf_write_read_head_rd) ? 1'b1 : 1'b0;
assign rd_addr_strobe[1]	=	(inf_write_read_control == inf_write_read_image_rd) ? 1'b1 : 1'b0;
assign rd_addr_strobe[2]	=	(inf_write_read_control == inf_write_read_kernel_rd) ? 1'b1 : 1'b0;


//image, kernel, head read address
addr_mux addr_mux_m1(
	.strobe(rd_addr_strobe),
	.a1(head_addr),
	.a2(image_rd_addr),
	.a3(kernel_addr),
	.q(rd_addr_temp)

);

always @(posedge clk)
begin
		rd_addr_temp1	<=	{rd_addr_temp,3'b000};
end

/////////////////////////////////////////////////////////////////////////////////////////////////////  


//////////////////////////////////write address//////////////////////////////////////////////////////  
reg image_begin_pos_r;
reg [`AXI_ADDR_WIDTH-1:0] image_wr_addr_temp, wr_addr_temp1;

always @(posedge clk)
begin
	one_layer_finish_r1 <= one_layer_finish_r;
end
always @(posedge clk)
begin
	image_begin_pos_r <= image_begin_pos;
end  
    
always @(posedge clk)
begin
		if(image_begin_pos_r || one_layer_finish_r1)
			image_wr_addr_temp	<=	image_base_wr_addr;
		else if(inf_write_read_control == inf_write_read_image_wr && new_wr_finish)
			image_wr_addr_temp	<=	image_wr_addr_temp + sub_result;
end

always @(posedge clk)
begin
		wr_addr_temp1	<=	{image_wr_addr_temp, 3'b000};
end
	

///////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////write and read length/////////////////////////////////////////////////////////
wire [7:0] rd_len_temp;
wire [7:0] wr_len_temp;



assign rd_len_temp	=	(inf_write_read_control == inf_write_read_head_rd)	? `MAX_BURST_HEAD_LENGTH - 1 : sub_result - 1'b1;
assign wr_len_temp	=	sub_result - 1'b1;


///////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////4KB boundary//////////////////////////////////////////////

AXI_4KBboundary AXI_4KBboundary_read(
	.clk(clk),
	.rst_n(rst_n),
	.addr_req(rd_req_temp3),
	.addr(rd_addr_temp1),
	.burst_len(rd_len_temp),
	.finish(rd_finish),
	.addr_valid(rd_req),
	.addr_out(rd_addr),
	.burst_len_out(rd_len),
	.new_finish(new_rd_finish)

    );


AXI_4KBboundary AXI_4KBboundary_write(
	.clk(clk),
	.rst_n(rst_n),
	.addr_req(wr_req_temp3),
	.addr(wr_addr_temp1),
	.burst_len(wr_len_temp),
	.finish(wr_finish),
	.addr_valid(wr_req),
	.addr_out(wr_addr),
	.burst_len_out(wr_len),
	.new_finish(new_wr_finish)

    );
/////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////write and read finish/////////////////////////////////////////
(*DONT_TOUCH="TRUE"*)reg [7:0]	wr_finish_cnt;
(*DONT_TOUCH="TRUE"*)reg [7:0]	rd_finish_cnt;
reg [7:0]	finish_cnt_threshold;
wire [7:0] finish_cnt_threshold_temp;
wr_rd_finish_cnt_threshhold wr_rd_finish_cnt_threshhold_m(
 .len(multi_byte_double),//2-32 in 64 bits
 .choose(information_operation_temp),
 .threshhold(finish_cnt_threshold_temp)

);

always @(posedge clk)
begin
	finish_cnt_threshold	<=	finish_cnt_threshold_temp;
end


always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			wr_finish_cnt	<=	8'h0;
		else if(wr_finish_cnt == finish_cnt_threshold && new_wr_finish)
			wr_finish_cnt	<=	8'h0;
		else if(new_wr_finish)
			wr_finish_cnt	<=	wr_finish_cnt + 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			rd_finish_cnt	<=	8'h0;
		else if(rd_finish_cnt == finish_cnt_threshold && new_rd_finish)
			rd_finish_cnt	<=	8'h0;
		else if(new_rd_finish && (information_operation_temp[2] || information_operation_temp[3]))
			rd_finish_cnt	<=	rd_finish_cnt + 1'b1;
end






assign all_rd_finish	=	(rd_finish_cnt == finish_cnt_threshold && new_rd_finish) ? 1'b1 : 1'b0;
assign all_wr_finish	=	(wr_finish_cnt == finish_cnt_threshold && new_wr_finish) ? 1'b1 : 1'b0;
//////////////////////////////////////////////////////////////////////////////////////////////////////////




//////////////////////////////////////////image read or write finish//////////////////////////////////
always @(posedge clk)
begin
	image_wr_finish	<=	information_operation_temp[0] && all_wr_finish;
end

always @(posedge clk)
begin
	image_rd_finish	<=	information_operation_temp[2] && all_rd_finish;
end
///////////////////////////////////////////////////////////////////////////////////////////////////////

















    
endmodule
