`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An pingbo
// 
// Create Date: 2017/08/27 18:20:04
// Design Name: 
// Module Name: axi_read_image_cnt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: counter and generate the address for axi read from ram
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define		WIDTH	`POSTIMAGE_CHANNEL_BITWIDTH+`POSTIMAGE_RAMDEPTH_WIDTH

module axi_read_image_cnt(
	input	clk,
	input	rst_n,
	input	en,
	input	clc,//clear the all bit of result
	input	clc_low,//clear the low bit of result,and high bit plus 1
	(*DONT_TOUCH="TRUE"*)output	reg[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	result_high,//high bits of result, indicating the ram number
	output	reg[`POSTIMAGE_RAMDEPTH_WIDTH-1:0]	result_low//the address of ram
	


    );
    
    
always @(posedge clk or negedge rst_n)    
begin
		if(!rst_n)
			result_low	<=	`POSTIMAGE_RAMDEPTH_WIDTH'h0;		
		else if(clc_low || clc)
			result_low	<=	`POSTIMAGE_RAMDEPTH_WIDTH'h0;
		else if(en)
			result_low	<=	result_low + 1'b1;
			
end
    
    
always @(posedge clk or negedge rst_n)    
begin
		if(!rst_n)
			result_high	<=	`POSTIMAGE_CHANNEL_BITWIDTH'h0;
		else if(clc)
			result_high	<=	`POSTIMAGE_CHANNEL_BITWIDTH'h0;
		else if((clc_low || result_low == `POSTIMAGE_RAMDEPTH_WIDTH'hFFF) && en)
			result_high	<=	result_high + 1'b1;
		

end    
    
    
    
    
endmodule
