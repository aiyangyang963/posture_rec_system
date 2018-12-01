`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone
// Engineer: An Pingbo
// 
// Create Date: 2017/08/22 15:57:13
// Design Name: 
// Module Name: err_detect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: based on the error pulse number and threshold, generate error warning
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module err_detect(
	input 		clk,
	input 		rst_n,
	
	input [7:0] err_threshold,
	input 		err_pulse,
	output reg	err_out		
    );
    
reg 	[7:0]	err_cnt; 
 
    
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			err_cnt		<=	8'h0;
		else if(err_pulse)
			err_cnt		<=	err_cnt	+ 1'b1;
end    
    
    
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			err_out		<=  1'b0;
		else if(err_cnt == err_threshold)
			err_out		<=  1'b1;
end    
    
    
    
    
    
    
    
    
    
    
    
endmodule
