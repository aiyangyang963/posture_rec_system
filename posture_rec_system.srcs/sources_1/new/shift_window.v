`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An pingbo
// 
// Create Date: 2017/08/29 17:28:49
// Design Name: 
// Module Name: shift_window
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: shift window
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module shift_window(

	clk,
	rst_n,
	
	infor_update,
	channel_choose,
	
	image_size,
	kernel_size,
	kernel_step,
	

	
	kernel_data,
	kernel_valid,
	
	image_ready,
	image_need,
	image_data,
	image_valid,
	

	image_q,
	kernel_q,
	conv_en,
	conv_ready


    );
    
    
//////////////////////////////////inputs and outputs//////////////////////////////////
input	clk;
input	rst_n;

input infor_update;
input channel_choose;
input	[`IMAGE_SIZE-1:0]	image_size;
input	[`KERNEL_SIZE-1:0]	kernel_size;
input	[`KERNEL_STEP-1:0]	kernel_step;


input	[`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0]	kernel_data;
input	kernel_valid;

input	image_ready;
output	image_need;
input	[`IMAGE_ELE_BITWIDTH-1:0]	image_data;
input	image_valid;

output	reg	[`IMAGE_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0]	image_q;

output	reg	[`KERNEL_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0]	kernel_q;
output	reg	conv_en;//enbale convolution
input	conv_ready;

//////////////////////////////////////////////////////////////////////////////////////    
    
   
 
 
//////////////////////////////image fifo//////////////////////////////////////////////
wire image_fifo_rd;
wire [31:0]image_fifo_q;
wire image_fifo_prog_full;
wire image_fifo_empty;



fifo_shift_window fifo_shift_window_m(
  .wr_clk(clk),        // input wire wr_clk
  .rd_clk(clk),        // input wire rd_clk
  .din(image_data),              // input wire [31 : 0] din
  .wr_en(image_valid),          // input wire wr_en
  .rd_en(image_fifo_rd),          // input wire rd_en
  .dout(image_fifo_q),            // output wire [31 : 0] dout
  .full(),            // output wire full
  .empty(image_fifo_empty),          // output wire empty
  .prog_full(image_fifo_prog_full)  // output wire prog_full
);

assign	image_need = !image_fifo_prog_full;



/////////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
 
 
    
////////////////////////image register pointer///////////////////////////////////////
wire	[`WINDOW_COL_BITWIDTH-1:0]	shift_col_ptr;//pointer for shift window 
wire	[`WINDOW_COL_BITWIDTH-1:0]	write_col_ptr;//write data pointer
wire	[`WINDOW_ROW_BITWIDTH-1:0]	write_row_ptr;


wire	shift;//shift window




shift_control shift_control_m1(
	.clk(clk),
	.rst_n(rst_n),
	
	.image_size(image_size),
	.kernel_size(kernel_size),
	.kernel_step(kernel_step),
	

	.image_empty(image_fifo_empty),
	.image_rd(image_fifo_rd),
	.shift_col_ptr(shift_col_ptr),
	.write_col_ptr(write_col_ptr),
	.write_row_ptr(write_row_ptr),
	
	.conv_ready(conv_ready),
	.shift(shift)
);
/////////////////////////////////////////////////////////////////////////////////// 


////////////////////////////////////form a bunch of data for convalution////////////////
wire [`MAX_KERNEL_SIZE*`IMAGE_ELE_BITWIDTH-1:0]window_data_out;



data_from_window data_from_window_m1(
	.clk(clk),
	.rst_n(rst_n),
	
	.kernel_size(kernel_size),
	
	.write_col_ptr(write_col_ptr),
	.write_row_ptr(write_row_ptr),
	.shift_col_ptr(shift_col_ptr),
	
	.window_data(image_fifo_q),
	.window_data_out(window_data_out)
	
	
	
);



///////////////////////////////////////////////////////////////////////////////////////////




   
    
    
    
    
/////////////////////////////////////output valid signal////////////////////////////
reg	shift_r;//shift window

always @(posedge clk)
begin
		shift_r	<= shift;
end





always @(posedge clk)
begin
		if(shift_r)begin
			image_q	<=	window_data_out;
			conv_en	<=	1'b1;
		end
		else
			conv_en	<=	1'b0;
			
end

//////////////////////////////////////////////////////////////////////////////////////    
    
    
///////////////////////////////kernel get/////////////////////////////////////////////
always @(posedge clk)
begin
	kernel_q	<=	kernel_data;
end

///////////////////////////////////////////////////////////////////////////////////////   
    
    
    
    
    
    
    
endmodule



