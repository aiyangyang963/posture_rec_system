`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/13 09:35:34
// Design Name: 
// Module Name: virtual_start_deal
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


module virtual_start_deal(
	input	clk,
	input	rst_n,
	
	output	logic image_begin_inter,
	input		 image_finish_inter
    );
    
    
    
initial
begin
		image_begin_inter	=	1'b0;

		
		
		@(posedge rst_n);
		repeat(10) @(posedge clk);
		
		forever begin
			image_begin_inter=1'b1;
			@(posedge clk);
			image_begin_inter=1'b0;
			
			@(posedge image_finish_inter);
			repeat(20) @(posedge clk);
		end
		
		
end    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
