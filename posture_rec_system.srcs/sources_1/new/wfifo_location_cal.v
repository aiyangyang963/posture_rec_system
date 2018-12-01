`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An pingbo
// 
// Create Date: 2017/08/25 21:58:03
// Design Name: 
// Module Name: wfifo_location_cal
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


module wfifo_location_cal(
	input clk,
	input rst_n,
	
	input en,
	input [`FILTER_NUM-1:0]	cnti_threshold,//filter number
	input [`KERNEL_NUM-1:0]	cntj_threshold,//kenel number
	input [`KERNEL_SIZE-1:0]	cntk_threshold,//kenrel size in 8bytes
	output [`PARALLEL_NUM-1:0]	location1,//used for represent the valid data need to write to kernel fifo
	output [`PARALLEL_NUM-1:0]	location2// used for represent the zero data written to fifo

    );
 

(*DONT_TOUCH="TRUE"*)reg [`PARALLEL_WIDTH-1:0]	cnt_ij;//counter j
(*DONT_TOUCH="TRUE"*)reg [`KERNEL_SIZE-1:0]	cnt_k;//counter k
reg [`PARALLEL_WIDTH-1:0]	location_cnt;
wire cnt_end;//the data reach the end 

reg	[`PARALLEL_WIDTH - 1:0]	cntij_threshold;//cnti_threshold*cntj_threshold  
  
 
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			cntij_threshold	<=	`PARALLEL_WIDTH'h0;
		else
			cntij_threshold	<=	cnti_threshold * cntj_threshold;
end 
 
   
    
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			cnt_ij	<=	`PARALLEL_WIDTH'h0;
		else if(cnt_k == cntk_threshold - 1'b1 && en)
			if(cnt_ij == cntij_threshold - 1'b1)
				cnt_ij	<=	`PARALLEL_WIDTH'h0;
			else
				cnt_ij	<=	cnt_ij + 1'b1;
end     



always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			cnt_k	<=	`KERNEL_SIZE'h0;
		else if(cnt_k == cntk_threshold - 1'b1 && en)
			cnt_k	<=	`KERNEL_SIZE'h0;
		else if(en)
			cnt_k	<=	cnt_k + 1'b1;
end


always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			location_cnt	<=	`PARALLEL_WIDTH'h0;
		else if(cnt_k == cntk_threshold - 1'b1 && cnt_ij == cntij_threshold - 1'b1 && en)
			location_cnt	<=	`PARALLEL_WIDTH'h0;
		else if(cnt_k == cntk_threshold - 1'b1 && en)
			location_cnt	<=	location_cnt + 1'b1;
end

assign cnt_end	=	(cnt_k == cntk_threshold - 1'b1 && 
					cnt_ij == cntij_threshold - 1'b1 && en) ? 1'b1 : 1'b0;



wire [`PARALLEL_WIDTH-1:0] k[`PARALLEL_NUM-1:0];
assign k[0]	=	`PARALLEL_WIDTH'd0;
assign k[1]	=	`PARALLEL_WIDTH'd1;
assign k[2]	=	`PARALLEL_WIDTH'd2;
assign k[3]	=	`PARALLEL_WIDTH'd3;
assign k[4]	=	`PARALLEL_WIDTH'd4;
assign k[5]	=	`PARALLEL_WIDTH'd5;
assign k[6]	=	`PARALLEL_WIDTH'd6;
assign k[7]	=	`PARALLEL_WIDTH'd7;

wire [`PARALLEL_WIDTH-1:0] q[`PARALLEL_NUM-1:0];
assign q[0]	=	`PARALLEL_WIDTH'd1;
assign q[1]	=	`PARALLEL_WIDTH'd2;
assign q[2]	=	`PARALLEL_WIDTH'd3;
assign q[3]	=	`PARALLEL_WIDTH'd4;
assign q[4]	=	`PARALLEL_WIDTH'd5;
assign q[5]	=	`PARALLEL_WIDTH'd6;
assign q[6]	=	`PARALLEL_WIDTH'd7;
assign q[7]	=	`PARALLEL_WIDTH'd8;



genvar i;
for(i=0;i<`PARALLEL_NUM;i=i+1)begin : wfifo_mux_loop

	wfifo_mux wfifo_mux_m(
		.cnt(location_cnt),
		.comp(k[i]),
		.en(en),
		.result(location1[i])
	);
	
	wfifo_invalid_mux wfifo_invalid_mux_m(
		.cnt_thresh(cntij_threshold),
		.cnt(cnt_ij),
		.comp(q[i]),
		.en(en),
		.result(location2[i])
	);	
end




    
endmodule










module wfifo_mux(	
	input [`PARALLEL_WIDTH-1:0]	cnt,
	input [`PARALLEL_WIDTH-1:0]	comp,
	input en,
	output reg result

);

always @(cnt or comp or en)
begin
		if(en && cnt == comp)//kernel is written to fifo in a sequence, and if the kernels is less than fifos,
			result	=	1'b1;			//the remainning unwritten fifo should be written
		else 
			result	=	1'b0;
end





endmodule


module wfifo_invalid_mux(
	input [`PARALLEL_WIDTH-1:0] cnt_thresh,
	input [`PARALLEL_WIDTH-1:0]	cnt,
	input [`PARALLEL_WIDTH-1:0]	comp,
	input en,
	output reg result

);

always @(cnt or comp or en or cnt_thresh)
begin
		if(en && cnt_thresh < comp && cnt == cnt_thresh - 1'b1)//kernel is written to fifo in a sequence, and if the kernels is less than fifos,
			result	=	1'b1;			//the remainning unwritten fifo should be written
		else 
			result	=	1'b0;
end


endmodule


