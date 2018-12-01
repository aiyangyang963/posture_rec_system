`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/16 16:53:33
// Design Name: 
// Module Name: image_shift_rc_noaddzero_cnt
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



//counting row and column of one image
module image_shift_rc_noaddzero_cnt(
	input	clk,
	input	rst_n,
	input	en,
	input	increase,
	input	clc_num,
	input	[`IMAGE_SIZE-1:0]	cnt_threshold,//image_size
	input	[`KERNEL_SIZE-1:0]	size,
	output	finish,
	output reg buffer_image_rd,
	output  add_zero_en,
	output reg [`IMAGE_SIZE*2+7:0]	result


);


(*DONT_TOUCH="TRUE"*)reg	[7:0]	num = 0;//number of the image
(*DONT_TOUCH="TRUE"*)reg	[`IMAGE_SIZE-1:0]	row_cnt = 0;//row counter
(*DONT_TOUCH="TRUE"*)reg	[`IMAGE_SIZE-1:0]	col_cnt = 0;//column counter

always @(posedge clk)
begin
	if(en && col_cnt == cnt_threshold - 1'b1)
		col_cnt <= 0;
	else if(en)
		col_cnt <= col_cnt + 1'b1;
end
always @(posedge clk)
begin
	if(finish)
		row_cnt <= 0;
	else if(en && col_cnt == cnt_threshold - 1'b1)
		row_cnt <= row_cnt + 1'b1;
end
assign	finish	=	(row_cnt == cnt_threshold - 1'b1 && col_cnt == cnt_threshold - 1'b1 && en) ? 1'b1 : 1'b0;


reg [4:0] numIncrease_state;
parameter numIncrease_idle = 5'h0,
		   numIncrease_judge = 5'h01,
		   numIncrease_clc = 5'h02,
		   numIncrease_inc = 5'h04,
		   numIncrease_hold = 5'h08,
		   numIncrease_end = 5'h10;
		   
always @(posedge clk)
begin
	if(!rst_n)begin
		numIncrease_state <= numIncrease_idle;	
		num <= 8'h0;	
	end
	else
		case(numIncrease_state)
		numIncrease_idle:
			if(clc_num)
				numIncrease_state <= numIncrease_clc;
			else if(finish)
				numIncrease_state <= numIncrease_judge;
		numIncrease_judge:
			if(increase)
				numIncrease_state <= numIncrease_inc;
			else if(en && !increase)
				numIncrease_state <= numIncrease_hold;
		numIncrease_clc:begin
			numIncrease_state <= numIncrease_end;
			num <= 8'h0;
		end	
		numIncrease_inc:begin
			numIncrease_state <= numIncrease_end;
			num <= num + 1'b1;
		end
		numIncrease_hold:begin
			numIncrease_state <= numIncrease_end;
			num <= num;
		end
		numIncrease_end:
			numIncrease_state <= numIncrease_idle;
		default:
			numIncrease_state <= numIncrease_idle;
		endcase	
end		   



always @(posedge clk)
begin
	buffer_image_rd <= en;
end


	

always @(posedge clk)
begin
	result	<=	{num, row_cnt, col_cnt};
end

assign add_zero_en = 1'b0;


endmodule

