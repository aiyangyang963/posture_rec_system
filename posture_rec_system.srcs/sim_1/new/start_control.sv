`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/05 11:31:55
// Design Name: 
// Module Name: start_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: interrupt
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module start_control(
	input	clk,
	input	rst_n,
	
	output	logic	image_begin_inter,
	input	reg	image_finish_inter,
	output	logic	en
    );
    
initial begin

	image_begin_inter	=	1'b0;
	en	=	1'b0;

	@(posedge rst_n);	

	forever begin
		en	=	1'b1;
		repeat(10) @(posedge clk);
		image_begin_inter	=	1'b1;
		
		repeat(10) @(posedge clk);
		
		image_begin_inter	=	1'b0;
		@(posedge image_finish_inter);
		en	=	1'b0;
		@(negedge image_finish_inter);
		@(posedge clk);
	end

end    
    



    
    
endmodule
