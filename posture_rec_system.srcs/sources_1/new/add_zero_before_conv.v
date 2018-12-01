`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/24 14:56:45
// Design Name: 
// Module Name: add_zero_after_conv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module add_zero_before_conv(
	clk,
	rst_n,
	infor_update,
	channel_choose,
	image_size,
	in_data,
	in_data_en,
	out_q,
	out_q_valid

    );
    
input clk;
input rst_n;
input infor_update;
input channel_choose;
input [`IMAGE_SIZE-1:0] image_size;
input [`IMAGE_ELE_BITWIDTH-1:0] in_data;
input in_data_en;
output reg[`IMAGE_ELE_BITWIDTH-1:0] out_q;
output reg out_q_valid;

wire fifo_rd;
wire fifo_wr;
reg fifo_wr_r;
reg [`IMAGE_ELE_BITWIDTH-1:0] fifo_data;
wire [`IMAGE_ELE_BITWIDTH-1:0] fifo_q;
wire fifo_empty;

add_zero_fifo add_zero_fifo_m (
  .wr_clk(clk),  // input wire wr_clk
  .rd_clk(clk),  // input wire rd_clk
  .din(fifo_data),      // input wire [31 : 0] din
  .wr_en(fifo_wr_r),  // input wire wr_en
  .rd_en(fifo_rd),  // input wire rd_en
  .dout(fifo_q),    // output wire [31 : 0] dout
  .full(),    // output wire full
  .empty(fifo_empty)  // output wire empty
);
reg [6:0] control;
parameter control_idle = 7'h00,
		   control_writeFirst = 7'h01,
		   control_writeOne = 7'h02,
		   control_waitData = 7'h04,
		   control_wr = 7'h08,
		   control_writeLast = 7'h10,
		   control_waitRead = 7'h20,
		   control_end = 7'h40;
wire wr_finish;
wire writeFirst_finish;
wire writeLast_finish;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		control <= control_idle;
	else
		case(control)
		control_idle:
			if(infor_update && channel_choose)
				control <= control_writeFirst;
		control_writeFirst:
			if(writeFirst_finish)
				control <= control_writeOne;
		control_writeOne:
			control <= control_waitData;
		control_waitData:
			if(in_data_en)
				control <= control_wr;
		control_wr:
			if(wr_finish)
				control <= control_writeLast;
		control_writeLast:
			if(writeLast_finish)
				control <= control_waitRead;
		control_waitRead:
			if(fifo_empty)
				control <= control_end;
		control_end:
			control <= control_idle;
		default:
			control <= control_idle;
		endcase
end
    
    
reg [`IMAGE_SIZE-1:0] row_ptr = 0;
reg [`IMAGE_SIZE-1:0] col_ptr = 0;
always @(posedge clk)
begin
	if(col_ptr == image_size + 1 && fifo_wr)
		col_ptr <= `IMAGE_SIZE'h0;
	else if(fifo_wr)
		col_ptr <= col_ptr + 1'b1;
end
always @(posedge clk)
begin
	if(col_ptr == image_size + 1 && row_ptr == image_size + 1 && fifo_wr)
		row_ptr <= `IMAGE_SIZE'h0;
	else if(col_ptr == image_size - 1 && fifo_wr)
		row_ptr <= row_ptr + 1'b1;
end 
 
 
assign fifo_wr = (control == control_writeFirst || 
				control == control_writeOne ||
				in_data_en || 
				col_ptr == image_size + 1 || 
				((col_ptr == 0 || col_ptr == image_size + 1) && control == control_wr) ||
				control == control_writeLast) ? 1'b1 : 1'b0;
always @(posedge clk)
begin
	fifo_wr_r <= fifo_wr;
end
always @(posedge clk)
begin
	if(in_data_en)
		fifo_data <= in_data;
	else
		fifo_data <= `IMAGE_ELE_BITWIDTH'h0;
end 
 
assign writeFirst_finish = (control == control_writeFirst && col_ptr == image_size + 1);
assign writeLast_finish = (control == control_writeLast && col_ptr == image_size + 1);
assign wr_finish = (control == control_wr && col_ptr == image_size + 1 && row_ptr == image_size); 

reg out_q_valid_temp;
assign fifo_rd = (control == control_wr || control == control_writeLast || control == control_waitRead) && !fifo_empty;
always @(posedge clk)
begin
	out_q_valid_temp <= fifo_rd;
	out_q_valid <= out_q_valid_temp;
end 
always @(posedge clk)
begin
	out_q <= fifo_q;
end 
 
 
 
 
 

 
 
 
 
    
endmodule
