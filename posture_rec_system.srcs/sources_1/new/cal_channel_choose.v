`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/25 19:33:04
// Design Name: 
// Module Name: cal_channel_choose
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


module cal_channel_choose(
	input clk,
	input	infor_update,
	input	[`FILTER_NUM-1:0]	filter_num,//the filter number
	input	[`KERNEL_NUM-1:0]	kernel_num,//number of kernel in one filter 
	output	reg[`PARALLEL_NUM-1:0] channel_choose

    );
reg [7:0] channel_num;    
always @(posedge clk)
begin	
	channel_num <= filter_num * kernel_num;
end     
    
always @(posedge clk)
    begin
    	case(channel_num)
    	8'h1:
    		channel_choose <= 8'h1;
    	8'h2:
    		channel_choose <= 8'h3;
    	8'h3:
    		channel_choose <= 8'h7;
    	8'h4:
    		channel_choose <= 8'hF;
    	8'h5:
    		channel_choose <= 8'h1F;
    	8'h6:
    		channel_choose <= 8'h3F;
    	8'h7:
    		channel_choose <= 8'h7F;
    	8'h8:
    		channel_choose <= 8'hFF;
    	default:
    		channel_choose <= 8'h0;
    	endcase
    	 
    end     
    
    
endmodule
