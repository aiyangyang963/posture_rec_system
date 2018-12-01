`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/30 09:36:09
// Design Name: 
// Module Name: data_from_window
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


module data_from_window(

	input clk,
	input rst_n,
	
	input [`KERNEL_SIZE-1:0]	kernel_size,
	
	input [`WINDOW_COL_BITWIDTH-1:0]	write_col_ptr,//write data pointer
	input [`WINDOW_ROW_BITWIDTH-1:0]	write_row_ptr,
	input [`WINDOW_COL_BITWIDTH-1:0]	shift_col_ptr,
	
	input [`IMAGE_ELE_BITWIDTH-1:0] window_data,
	output reg[`MAX_KERNEL_SIZE*`IMAGE_ELE_BITWIDTH-1:0] window_data_out


    );
    
    




    
    
/////////////////////image register group////////////////////////////////////////////
reg	[`IMAGE_ELE_BITWIDTH-1:0]	window_image[`WINDOW_ROW-1:0][`WINDOW_COL-1:0];


always @(posedge clk)
begin
	window_image[write_row_ptr][write_col_ptr] <= window_data;
end

/////////////////////////////////////////////////////////////////////////////////// 


 

	
///////////////////////image out///////////////////////////////////////////////////////
parameter DATA_TRUNC_WIDTH = (`MAX_KERNEL_SIZE-1)*`IMAGE_ELE_BITWIDTH;



always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			window_data_out <= `IMAGE_ELE_BITWIDTH'h0;
		else
		case(shift_col_ptr)
		`WINDOW_COL_BITWIDTH'd0:
			if(kernel_size == `KERNEL_SIZE'd1)
				window_data_out <= {{DATA_TRUNC_WIDTH{1'b0}}, window_image[0][0]};
			else if(kernel_size == `KERNEL_SIZE'd3)
				window_data_out <= {window_image[2][2],window_image[1][2], window_image[0][2], 
									 window_image[2][1],window_image[1][1],window_image[0][1], 				
									 window_image[2][0],window_image[1][0], window_image[0][0]};
		`WINDOW_COL_BITWIDTH'd1:
			if(kernel_size == `KERNEL_SIZE'd1)
				window_data_out <= {{DATA_TRUNC_WIDTH{1'b0}}, window_image[0][1]};
			else if(kernel_size == `KERNEL_SIZE'd3)
				window_data_out <= {window_image[2][3],window_image[1][3], window_image[0][3], 
									 window_image[2][2],window_image[1][2],window_image[0][2], 				
									 window_image[2][1],window_image[1][1], window_image[0][1]};	
		`WINDOW_COL_BITWIDTH'd2:
			if(kernel_size == `KERNEL_SIZE'd1)
				window_data_out <= {{DATA_TRUNC_WIDTH{1'b0}}, window_image[0][2]};
			else if(kernel_size == `KERNEL_SIZE'd3)
				window_data_out <= {window_image[2][4],window_image[1][4], window_image[0][4], 
									 window_image[2][3],window_image[1][3],window_image[0][3], 				
									 window_image[2][2],window_image[1][2], window_image[0][2]};	
		`WINDOW_COL_BITWIDTH'd3:
			if(kernel_size == `KERNEL_SIZE'd1)
				window_data_out <= {{DATA_TRUNC_WIDTH{1'b0}}, window_image[0][3]};
			else if(kernel_size == `KERNEL_SIZE'd3)
				window_data_out <= {window_image[2][5],window_image[1][5], window_image[0][5], 
									 window_image[2][4],window_image[1][4],window_image[0][4], 				
									 window_image[2][3],window_image[1][3], window_image[0][3]};									 
									 
		`WINDOW_COL_BITWIDTH'd4:
			if(kernel_size == `KERNEL_SIZE'd1)
				window_data_out <= {{DATA_TRUNC_WIDTH{1'b0}}, window_image[0][4]};
			else if(kernel_size == `KERNEL_SIZE'd3)
				window_data_out <= {window_image[2][6],window_image[1][6], window_image[0][6], 
									 window_image[2][5],window_image[1][5],window_image[0][5], 				
									 window_image[2][4],window_image[1][4], window_image[0][4]};								 
		`WINDOW_COL_BITWIDTH'd5:
			if(kernel_size == `KERNEL_SIZE'd1)
				window_data_out <= {{DATA_TRUNC_WIDTH{1'b0}}, window_image[0][5]};
			else if(kernel_size == `KERNEL_SIZE'd3)
				window_data_out <= {window_image[2][7],window_image[1][7], window_image[0][7], 
									 window_image[2][6],window_image[1][6],window_image[0][6], 				
									 window_image[2][5],window_image[1][5], window_image[0][5]};									 
		`WINDOW_COL_BITWIDTH'd6:
			if(kernel_size == `KERNEL_SIZE'd1)
				window_data_out <= {{DATA_TRUNC_WIDTH{1'b0}}, window_image[0][6]};
			else if(kernel_size == `KERNEL_SIZE'd3)
				window_data_out <= {window_image[2][0],window_image[1][0], window_image[0][0], 
									 window_image[2][7],window_image[1][7],window_image[0][7], 				
									 window_image[2][6],window_image[1][6], window_image[0][6]};	
	
		`WINDOW_COL_BITWIDTH'd7:
			if(kernel_size == `KERNEL_SIZE'd1)
				window_data_out <= {{DATA_TRUNC_WIDTH{1'b0}}, window_image[0][7]};
			else if(kernel_size == `KERNEL_SIZE'd3)
				window_data_out <= {window_image[2][1],window_image[1][1], window_image[0][1], 
									 window_image[2][0],window_image[1][0],window_image[0][0], 				
									 window_image[2][7],window_image[1][7], window_image[0][7]};	
									 
		endcase
end






//////////////////////////////////////////////////////////////////////////////////////    
    
    
    
    
    
    
    
    
    
    
endmodule
