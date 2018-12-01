`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/07 18:54:55
// Design Name: 
// Module Name: axi_read_write_master_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench for module axi_read_write_master
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_read_write_master_tb(
    clk,
	rst_n,
	
    rd_req,
    rd_addr,
    rd_len,
    rd_finish,
    
    wr_req,
    wr_addr,
    wr_len,
    wr_finish,
    
    buffer_wr_req,
    buffer_wr_data,
    buffer_rd_req,
    buffer_rd_pre,
    buffer_rd_empty,
    buffer_rd_data



    );
    
input									clk;
input									rst_n;    
    
output 	logic			               rd_req;//request for reading AXI4 data
output 	logic[`AXI_ADDR_WIDTH-1:0]	   rd_addr;//read address
output 	logic[7:0]		               rd_len;//read length
input 					               rd_finish;//finishing reading from AXI4

output 	logic			               wr_req;//write request
output 	logic[`AXI_ADDR_WIDTH-1:0]	   wr_addr;//write address
output 	logic[7:0]		               wr_len;//write length
input 					               wr_finish;//finishing writing data    
    

input 	 						   buffer_wr_req;//write request to buffer
input 	 [`AXI_DATA_WIDTH-1:0]     buffer_wr_data;//write data to buffer
input 	 			               buffer_rd_req;//request for reading buffer data
input 							   buffer_rd_pre;//pre_reading data from buffer
output 	logic					   buffer_rd_empty;//the pre-reading FIFO is empty
output 	reg[`AXI_DATA_WIDTH-1:0]	   buffer_rd_data;//read data

    
    
initial begin
	rd_req	=	1'b0;
	rd_addr	=	`AXI_ADDR_WIDTH'h0;
	rd_len	=	8'h0;
	wr_req	=	1'b0;
	wr_addr	=	`AXI_ADDR_WIDTH'h0;
	wr_len	=	8'h0;
	buffer_rd_empty	=	1'b0;
	@(posedge rst_n);
	
	forever begin
		repeat(20)
			@(posedge clk);
		rd_req	=	1'b1;
		rd_addr	=	`AXI_ADDR_WIDTH'd0;
		rd_len	=	8'd128;
		@(posedge clk);
		rd_req	=	1'b0;
		@(posedge rd_finish);
		
		
		repeat(6) @(posedge clk);
	
		wr_req	=	1'b1;
		wr_addr	=	`AXI_ADDR_WIDTH'h0;
		wr_len	=	8'd128;
		@(posedge clk);
		wr_req	=	1'b0;
	end
end



always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			buffer_rd_data	<=	`AXI_DATA_WIDTH'h0;
		else if(buffer_rd_req)
			buffer_rd_data	<=	buffer_rd_data + 1'b1;
end






    
    
    
endmodule
