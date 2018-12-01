`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/29 09:35:10
// Design Name: 
// Module Name: load_head
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: when finishing one round calculation, start loading head information for next round
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module load_head(
	clk,
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
	image_addr_inputRAM_increase,
	
	filter_num,
	kernel_num,
	kernel_size,
	kernel_step,
	
	maxpooling_en,
	image_return_axi,
	
	infor_update
	

    );
    
    
//////////////////////////////inputs and outputs///////////////////////////////////////////////////
input	clk;//data deal clock
input	rst_n;//global reset

input	load_head_begin;//request to load head information from fifo

output	 	load_head_rd;//read request to head fifo
input	[`HEAD_WIDTH-1:0]	load_head_rd_q;//output head data from fifo
input	load_head_empty;//empty tag of the fifo hold head data

output	reg[`IMAGE_NUM-1:0]	image_num;//image number operated at this round
output	reg[`IMAGE_SIZE-1:0]	image_size;//image size
output	reg[`IMAGE_SIZE-1:0]	image_size_after_maxpooling;
output	reg image_sum_en;//indicate whether perform summation of all the convolution channels
output	reg image_update;//indicate whether update the image ram
output	reg image_next_read_en;//next round, need to read image
output	reg image_addr_inputRAM_increase;//whether increasing the address in the input ram for image

output	reg[`FILTER_NUM-1:0]	filter_num;//the filter number
output	reg[`KERNEL_NUM-1:0]	kernel_num;//number of kernel in one filter 
output	reg[`KERNEL_SIZE-1:0]	kernel_size;//the kernel size
output	reg[`KERNEL_STEP-1:0]	kernel_step;//convolution step

output	reg maxpooling_en;//enable maxpooling
output	reg image_return_axi;

output	reg	infor_update;//the head information have been updated
///////////////////////////////////////////////////////////////////////////////////////////////////    
reg	load_head_rd_reg;//register for the read need of head
reg infor_update_temp;



always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			load_head_rd_reg	<=	1'b0;
		else if(load_head_begin)
			load_head_rd_reg	<=	1'b1;
		else if(load_head_rd)
			load_head_rd_reg	<=	1'b0;
end    
    
    

assign		load_head_rd	=	load_head_rd_reg && !load_head_empty;
  
    
always @(posedge clk)
begin
		infor_update_temp	<=	load_head_rd;
		infor_update 	<=	infor_update_temp;		
end    
    
wire [`HEAD_WIDTH-1:0] load_head_rd_q_bigEndian;
assign	load_head_rd_q_bigEndian[7:0] = load_head_rd_q[15:8];
assign	load_head_rd_q_bigEndian[15:8] = load_head_rd_q[7:0];
assign	load_head_rd_q_bigEndian[23:16] = load_head_rd_q[31:24];
assign	load_head_rd_q_bigEndian[31:24] = load_head_rd_q[23:16];
assign	load_head_rd_q_bigEndian[39:32] = load_head_rd_q[47:40];
assign	load_head_rd_q_bigEndian[47:40] = load_head_rd_q[39:32];
assign	load_head_rd_q_bigEndian[55:48] = load_head_rd_q[63:56];
assign	load_head_rd_q_bigEndian[63:56] = load_head_rd_q[55:48];
always @(posedge clk)
begin
	image_num	<=	  (load_head_rd_q_bigEndian[13]) ? `IMAGE_NUM'h1 :
					  (load_head_rd_q_bigEndian[12:0] == 0)? image_num : load_head_rd_q_bigEndian[12:0];
	image_return_axi	<=	load_head_rd_q_bigEndian[13];
	image_addr_inputRAM_increase	<=	load_head_rd_q_bigEndian[14];
	image_update	<=	load_head_rd_q_bigEndian[15];
	filter_num	<=	load_head_rd_q_bigEndian[23:16];
	image_size	<=	(load_head_rd_q_bigEndian[31:24] == 0) ? image_size : load_head_rd_q_bigEndian[31:24];
	image_size_after_maxpooling	<=	maxpooling_en ? load_head_rd_q_bigEndian[31:25] : load_head_rd_q_bigEndian[31:24];
	kernel_num	<=	load_head_rd_q_bigEndian[36:32];
	image_next_read_en	<=	load_head_rd_q_bigEndian[37];
	maxpooling_en	<=	load_head_rd_q_bigEndian[38];
	image_sum_en	<=	load_head_rd_q_bigEndian[39];
	kernel_size	<=	load_head_rd_q_bigEndian[47:44];
	kernel_step	<=	load_head_rd_q_bigEndian[43:40];
end  
	

	



  
  
  
  
    
    
    
endmodule
