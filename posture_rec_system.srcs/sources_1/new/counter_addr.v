`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/26 18:41:04
// Design Name: 
// Module Name: counter_addr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: counter for image with row, column and number
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module counter_addr(
	clk,
	rst_n,
	
	en,
	cnti_threshold,//image_wr_num
	cntk_threshold,//image_wr_size2_div
	
	cntk_threshold_reach,//reach the cnk_threshold
	recordImageNum_inRAM,
	result


    );


input clk;
input rst_n;

input en;
input [12:0]	cnti_threshold;//image_wr_num
input [`IMAGE_SIZE+`IMAGE_SIZE-1:0]	cntk_threshold;//image_wr_size2_div

output	cntk_threshold_reach;//reach the cnk_threshold
output  reg [7:0] recordImageNum_inRAM=0;
output reg[`RESULT_BITWIDTH-1:0]	result=0;


(*DONT_TOUCH="TRUE"*)reg [12:0]	cnt_i=13'h0;
(*DONT_TOUCH="TRUE"*)reg [`CNT_WIDTH-1:0]	cnt_k=13'h0;
reg [`IMAGE_RAM_ADDR_WIDTH-1:0]	result_low_bit_ptr=`IMAGE_RAM_ADDR_WIDTH'h0;
(*DONT_TOUCH="TRUE"*)reg [7:0] recordImageNum_inRAM_cnt=8'h0;
(*DONT_TOUCH="TRUE"*)reg recordImageNum_inRAM_get = 1'b0;

always @(posedge clk)
begin
		if(cnt_k == cntk_threshold - 1'b1 && en)//image size counting
			cnt_k	<=	`CNT_WIDTH'h0;
		else if(en)
			cnt_k	<=	cnt_k + 1'b1;
end


always @(posedge clk)
begin
		if(cnt_i == cnti_threshold - 1'b1 && cnt_k == cntk_threshold - 1'b1 && en)//image number counting
			cnt_i	<=	13'h0;
		else if(cnt_k == cntk_threshold - 1'b1 && en)
			cnt_i	<=	cnt_i + 1'b1;
end



always @(posedge clk)
begin
		if(cnt_i == cnti_threshold - 1'b1 && cnt_k == cntk_threshold - 1'b1 && en)
			result[`IMAGE_RAM_ADDR_WIDTH-1:0]	<=	`IMAGE_RAM_ADDR_WIDTH'h0;
		else if(cnt_k == cntk_threshold - 1'b1 && en)
			result[`IMAGE_RAM_ADDR_WIDTH-1:0]	<=	result_low_bit_ptr;				
		else if(en)
			result[`IMAGE_RAM_ADDR_WIDTH-1:0]	<=	result[`IMAGE_RAM_ADDR_WIDTH-1:0] + 1'b1;
end


always @(posedge clk)
begin
		if((cnt_i == cnti_threshold - 1'b1 || cnt_i[2:0] == 3'h7) && cnt_k == cntk_threshold - 1'b1 && en)
			result[`RESULT_BITWIDTH-1:`IMAGE_RAM_ADDR_WIDTH]	<=	0;
		else if((cnt_k == cntk_threshold - 1'b1 || cnt_k[`IMAGE_RAM_ADDR_WIDTH-1:0] == `IMAGE_RAM_ADDR_WIDTH'hFFF) && en)
			result[`RESULT_BITWIDTH-1:`IMAGE_RAM_ADDR_WIDTH]	<=	result[`RESULT_BITWIDTH-1:`IMAGE_RAM_ADDR_WIDTH] + 1'b1;
end


always @(posedge clk)
begin
		if(cnt_i == cnti_threshold - 1'b1 && cnt_k == cntk_threshold - 1'b1 && en)
			result_low_bit_ptr	<=	`IMAGE_RAM_ADDR_WIDTH'h0;
		else if(cnt_k == cntk_threshold - 2'b10 && result[`RESULT_BITWIDTH-1:`IMAGE_RAM_ADDR_WIDTH] == 'h7 && en)
			result_low_bit_ptr	<=	result[`IMAGE_RAM_ADDR_WIDTH-1:0] + 2'b10;
end

always @(posedge clk)
begin
	if(cntk_threshold_reach)
		recordImageNum_inRAM_cnt <= 8'h0;
	else if((cnt_k == cntk_threshold - 1'b1 || cnt_k[`IMAGE_RAM_ADDR_WIDTH-1:0] == `IMAGE_RAM_ADDR_WIDTH'hFFF) 
			&& result[`RESULT_BITWIDTH-1:`IMAGE_RAM_ADDR_WIDTH] == 0 && en)
		recordImageNum_inRAM_cnt <= recordImageNum_inRAM_cnt + 1'b1;
end
always @(posedge clk)
begin
	if((cnt_k == cntk_threshold - 1'b1 || cnt_k[`IMAGE_RAM_ADDR_WIDTH-1:0] == `IMAGE_RAM_ADDR_WIDTH'hFFF) 
			&& result[`RESULT_BITWIDTH-1:`IMAGE_RAM_ADDR_WIDTH] == 0 && en)
		recordImageNum_inRAM_get <= 1'b1;
	else
		recordImageNum_inRAM_get <= 1'b0;
end

always @(posedge clk)
begin
	if(recordImageNum_inRAM_get)
		recordImageNum_inRAM <= recordImageNum_inRAM_cnt;
end

assign	cntk_threshold_reach	=	(cnt_i == cnti_threshold - 1'b1 && cnt_k == cntk_threshold - 1'b1 && en) ? 1'b1 : 1'b0;


    
    
    
    
endmodule



