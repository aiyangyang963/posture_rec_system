`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/10 19:42:42
// Design Name: 
// Module Name: information_read_write_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench for information_read_write
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module information_read_write_tb(
	clk,
	rst_n,
	
	tb_image_begin,

	
	head_rd_need,
	kernel_rd_need,
	image_rd_need,
	image_wr_need,
	information_operation,
	
	head_wr_req,
	head_data,
	buffer_wr_req,
	buffer_wr_data,
	
	
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
input rst_n;


output	logic tb_image_begin;


output logic head_rd_need;//need to read head control data from axi
output logic kernel_rd_need;
output logic image_rd_need;
output logic image_wr_need;//need to write dealt image to axi

input [3:0]	information_operation;//indicate which operation is going on: head, kernel, image read, image write from low bit to high bit
output [`HEAD_WIDTH-1:0]	head_data;//write to a RAM for iterating and telling the read and write kernel or image information
output head_wr_req;//request for head_data write
input	buffer_wr_req;
input	[`AXI_DATA_WIDTH-1:0]	buffer_wr_data;

input [`KERNEL_NUM-1:0]	kernel_wr_num;//number of the kernel of every filter read from axi and write to ram.
input [`FILTER_NUM-1:0]	filter_wr_num;//number of filter
input [`KERNEL_SIZE-1:0]	kernel_wr_size;//size of one kernel
input [`IMAGE_NUM-1:0]		image_wr_num;//image number read from axi and write to ram
input [`IMAGE_SIZE-1:0]	image_wr_size;//image size read from axi and write to ram
input		image_wr_finish;//finishing writing all data to axi
input		image_rd_finish;//finishing reading all data from axi

output [`IMAGE_NUM-1:0]	image_toaxi_num;//image number returned to axi
output [`IMAGE_SIZE-1:0]	image_toaxi_size;//size returned to axi


////////////////////////////////////////////////////////////////////////////////////////////////////////      
initial begin
	tb_image_begin=1'b0;
	@(posedge rst_n);
	repeat(3) @(posedge clk);
	tb_image_begin=1'b1;
end    
   
    
initial begin

	head_rd_need=1'b0;
	@(posedge rst_n);
	repeat(8) @(posedge clk);
	
	begin: head_gen
		head_rd_need=1'b1;
		
		@(posedge information_operation[1]);//wait the head read state
		#1;
		for(int i=0;i<`MAX_BURST_LENGTH;i++)begin
			if(buffer_wr_req)
				@(negedge clk);
			else
				@(posedge buffer_wr_req);
			
		end
		@(posedge clk);
		head_rd_need=1'b0;
		
	end//begin:head_gen
	
	
end //initial   
    
 
assign	head_data=information_operation[1] ? buffer_wr_data :  `AXI_DATA_WIDTH'h0;
assign	head_wr_req=information_operation[1] && buffer_wr_req;
 
 
 
int kernel_cnt;    
always @(negedge clk or negedge rst_n)   
begin:kernel_cnt_gen
		if(!rst_n)
			kernel_cnt=0;
		else if(information_operation[3] && buffer_wr_req)
			kernel_cnt++;
		if(kernel_cnt==255)
			disable kernel_cnt_gen;
end
    
 
  
initial begin
	kernel_rd_need	=	1'b0;
	@(posedge rst_n);
	repeat(8) @(posedge clk);
	
	#0;
	
	forever fork
		begin:kernel_gen
			if(kernel_cnt==255)begin
				kernel_rd_need	=	1'b0;
				disable kernel_gen;
			end
			else begin
				kernel_rd_need	=	1'b1;
				@(posedge clk);
				
			end//else
			
		end//kernel_gen
		@(posedge clk);
	join//forever
	
end//initial
  
  
  
  
  
initial begin

	image_rd_need=1'b0;
	@(posedge rst_n);
	repeat(8) @(posedge clk);
	
	
	image_rd_need=1'b1;
	@(posedge information_operation[2]);
	
	@(posedge image_rd_finish);
	image_rd_need=1'b0;
	
end  
  
  
  
  
  
  
  
  
    
endmodule
