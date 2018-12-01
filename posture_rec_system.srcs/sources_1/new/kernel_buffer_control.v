`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/25 15:01:58
// Design Name: 
// Module Name: kernel_buffer_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: conrol the write and read from kernel fifos
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module kernel_buffer_control(
	clk,
	rst_n,
	
	kernel_wr_req,
	kernel_wr_data,
	
	kernel_rd_need,
	kernel_wr_size,
	kernel_wr_num,
	filter_wr_num,
	

	
	load_kernel_clk,
	load_kernel_rd,
	load_kernel_rd_q,
	load_kernel_empty



    );
    
////////////////////////////////////////inputs and outputs/////////////////////////////////////////
input clk;
input rst_n;

input kernel_wr_req;
input [`AXI_DATA_WIDTH-1:0]	kernel_wr_data;

output 	 kernel_rd_need;//need to read kernel from axi
input [`KERNEL_SIZE-1:0]	kernel_wr_size;//size of the kernel
input [`KERNEL_NUM-1:0]	kernel_wr_num;//number of kernels in one filter
input [`FILTER_NUM-1:0]	filter_wr_num;//number of the filters



input load_kernel_clk;
input load_kernel_rd;//read request
output [`KERNEL_BITWIDTH*`PARALLEL_NUM-1:0]	load_kernel_rd_q;
output load_kernel_empty;




///////////////////////////////////////////////////////////////////////////////////////////////////    
    
//////////////////////////////////////generate kernel fifos///////////////////////////////////////
wire [`PARALLEL_NUM-1:0]	fifo_wr;
wire [`PARALLEL_NUM-1:0]	prog_full;
wire [`PARALLEL_NUM-1:0]	prog_empty;
wire [`PARALLEL_NUM-1:0]	fifo_empty;
wire [`AXI_DATA_WIDTH-1:0]	fifo_wr_data	[`PARALLEL_NUM-1:0];


genvar	i;
generate
	for(i=0;i<`PARALLEL_NUM;i=i+1)begin	:	kernel_fifo_loop
	

		kernel_fifo kernel_fifo1_m (
			.rst(1'b0),                // input wire rst
	 		.wr_clk(clk),          // input wire wr_clk
	 		.rd_clk(load_kernel_clk),          // input wire rd_clk
	 		.din(fifo_wr_data[i]),                // input wire [63 : 0] din
	 		.wr_en(fifo_wr[i]),            // input wire wr_en
	 		.rd_en(load_kernel_rd),            // input wire rd_en
	   	 	.dout(load_kernel_rd_q[`KERNEL_BITWIDTH*(i+1)-1:`KERNEL_BITWIDTH*i]), // output wire [63 : 0] dout
	  		.full(),              // output wire full
	  		.empty(fifo_empty[i]),            // output wire empty
	  		.prog_full(prog_full[i]),    // output wire prog_full,greater than 13
	  		.prog_empty(prog_empty[i])  // output wire prog_empty
	);
	
	
	end
	
endgenerate




////////////////////////////////////////////////////////////////////////////////////////////////////    
 
 
 
/////////////////////////////////////kernel size to 8bytes///////////////////////////////////////// 
reg	[`KERNEL_SIZE-1:0]	kernel_wr_size_8bytes;//based on the size of kernel, generate how many data with width 64bit


always @(kernel_wr_size)
begin
		case(kernel_wr_size)
		`KERNEL_SIZE'h1: kernel_wr_size_8bytes	=	`KERNEL_SIZE'd2;
		`KERNEL_SIZE'h3: kernel_wr_size_8bytes	=	`KERNEL_SIZE'd6;
		default: kernel_wr_size_8bytes	=	`KERNEL_SIZE'd6;
		endcase
end 
 
 
/////////////////////////////////////////////////////////////////////////////////////////////////////




    
////////////////////////////////choose fifo for data write/////////////////////////////////////////
wire [`PARALLEL_NUM-1:0]		wfifo_valid_location;//location of write to fifo 0-7
wire [`PARALLEL_NUM-1:0]		wfifo_invalid_location;//invalid write data will be zero




assign fifo_wr	=	wfifo_valid_location | wfifo_invalid_location;



genvar	l;
for(l=0;l<`PARALLEL_NUM;l=l+1)begin : wr_data_loop
	assign fifo_wr_data[l]	=	wfifo_valid_location[l] ? kernel_wr_data : `AXI_DATA_WIDTH'h0;
end



//based on the filter, kernel number and size
//to identify which fifo should be chosen for writing
wfifo_location_cal wfifo_location_cal_m1(
	.clk(clk),
	.rst_n(rst_n),
	
	.en(kernel_wr_req),//enable counting
	.cnti_threshold(filter_wr_num),//counter i threshold
	.cntj_threshold(kernel_wr_num),
	.cntk_threshold(kernel_wr_size_8bytes),
	.location1(wfifo_valid_location),
	.location2(wfifo_invalid_location)

);


///////////////////////////////////////////////////////////////////////////////////////////////////    
    
    
    
//////////////////////////////////////////////generate write request///////////////////////////////


assign	kernel_rd_need	=	&prog_empty;
///////////////////////////////////////////////////////////////////////////////////////////////////    
    
    
///////////////////////////////read fifo empty/////////////////////////////////////////////////////

assign load_kernel_empty	=	|fifo_empty;//all the fifo is read at the same time


////////////////////////////////////////////////////////////////////////////////////////////////////    
    








    
    
endmodule
