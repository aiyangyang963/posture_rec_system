`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Poingbo
// 
// Create Date: 2017/08/25 10:02:46
// Design Name: 
// Module Name: mux_head_image_kernel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: choose which Ram in head, kernel and image data access to RAM
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_head_image_kernel(

	input [3:0]	information_operation,//record the state of operating
	input buffer_wr_req,//write data to buffer request
	output head_wr_req,//write to head fifo
	output image_wr_req,//write to image ram
	output kernel_wr_req//write to kernel ram


    );
    
    
    assign head_wr_req	=	information_operation[1] ? buffer_wr_req : 1'b0;
    assign image_wr_req	=	information_operation[2] ? buffer_wr_req : 1'b0;
    assign kernel_wr_req	=	information_operation[3] ? buffer_wr_req : 1'b0;
    
    
    
    
endmodule
