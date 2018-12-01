`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingo
// 
// Create Date: 2017/08/23 10:38:04
// Design Name: 
// Module Name: iterate_head
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: iterate head infromation and get the image, kernel size 
//	and number information for reading from AXI.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define		RAM_DEPTH_BITWIDTH	6

module iterate_head(
	input clk,
	input rst_n,
	
	input iterate_en,
	input finish_readHead,
	input [`HEAD_WIDTH-1:0]	head_data,
	input head_wr_req,
	output [`IMAGE_NUM-1:0]	image_num,//number of images need to read from AXI
	output image_en,//whether to read from axi
	output image_next_load,
	output image_stop_load,//in next step, need to read image or the head have been empty
	output kernel_no_rd,
	output [`IMAGE_SIZE-1:0]	image_size,//image size of one image
	output [`KERNEL_NUM-1:0]	kernel_num,//kernel number in one filter
	output [`KERNEL_SIZE-1:0]	kernel_size,//kernel size
	output [`FILTER_NUM-1:0]	filter_num//filter number
	
    );
    
    
reg [`RAM_DEPTH_BITWIDTH:0]	head_rd_cnt = 0;//head_ram can hold 64 head information(each haed 6 bytes)    
reg [`RAM_DEPTH_BITWIDTH:0]	head_wr_cnt = 0;//count the write head number
wire [`HEAD_WIDTH-1:0]	head_q;//head_ram output data
wire empty;


 
 
 
always @(posedge clk)
begin
		if(finish_readHead)
			head_wr_cnt	<=	0;
		else if(head_wr_req)
			head_wr_cnt	<=	head_wr_cnt + 1'b1;
end  
    
 


always @(posedge clk)
begin
		if(finish_readHead)
			head_rd_cnt	<=	0;
		else if(iterate_en)
			head_rd_cnt	<=	head_rd_cnt + 1'b1;
end

assign empty = (head_wr_cnt == head_rd_cnt) ? 1'b1 : 1'b0;

wire [63:0] head_q_bigEndian;
assign	head_q_bigEndian[7:0] = head_q[15:8];
assign	head_q_bigEndian[15:8] = head_q[7:0];
assign	head_q_bigEndian[23:16] = head_q[31:24];
assign	head_q_bigEndian[31:24] = head_q[23:16];
assign	head_q_bigEndian[39:32] = head_q[47:40];
assign	head_q_bigEndian[47:40] = head_q[39:32];
assign	head_q_bigEndian[55:48] = head_q[63:56];
assign	head_q_bigEndian[63:56] = head_q[55:48];
 
assign image_en	=	head_q_bigEndian[15];//bit 15 indicate whether to load image from ddr
assign image_next_load	=	head_q_bigEndian[37];

assign image_num	=	head_q_bigEndian[12:0];
assign image_size	=	head_q_bigEndian[31:24]; 
assign kernel_num	=	head_q_bigEndian[36:32];
assign filter_num	=	head_q_bigEndian[23:16];
assign kernel_size	=	head_q_bigEndian[47:44];//except last layer, every layer is 3x3
 
assign image_stop_load =  empty;
assign kernel_no_rd = (filter_num == 0) ? 1'b1 : 1'b0;
  
head_for_interate_dram head_for_interate_dram_m1(
          .a(head_wr_cnt[`RAM_DEPTH_BITWIDTH-1:0]),                // input wire [5 : 0] a
          .d(head_data),                // input wire [63 : 0] d
          .dpra(head_rd_cnt[`RAM_DEPTH_BITWIDTH-1:0]),          // input wire [5 : 0] dpra
          .clk(clk),            // input wire clk
          .we(head_wr_req),              // input wire we
          .qdpo_ce(iterate_en),    // input wire qdpo_ce
          .qdpo_clk(clk),  // input wire qdpo_clk
          .qdpo(head_q)          // output wire [63 : 0] qdpo
        );
        
        
         
endmodule
