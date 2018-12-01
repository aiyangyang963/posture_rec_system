`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/20 11:59:34
// Design Name: 
// Module Name: wr_rd_finish_cnt_threshhold
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


module wr_rd_finish_cnt_threshhold(

input [15:0] len,
input [3:0] choose,
output reg[7:0] threshhold





    );
    
    
always @(*)
begin
	case(choose)
	4'h1: threshhold <= (len[7:0] != 8'h0) ? len[15:8] : len[15:8] - 1;//256 burst for writing image
	4'h2: threshhold <= (len[7:0] != 8'h0) ? len[15:6] : len[15:6] - 1;//64 burst for head
	4'h4: threshhold <= (len[7:0] != 8'h0) ? len[15:8] : len[15:8] - 1;//256 burst for reading image
	4'h8: threshhold <= (len[7:0] != 8'h0) ? len[15:8] : len[15:8] - 1;//256 burst for kernel
	default: threshhold <= (len[7:0] != 8'h0) ? len[15:8] : len[15:8] - 1;
	endcase
end    
    
    
    
    
endmodule
