`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/10/10 17:16:22
// Design Name: 
// Module Name: user_maxpooling_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: used defined fifo
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define		MAXPOOLING_FIFO_DEPTH	128
`define		MAXPOOLING_FIFO_DEPTH_BITWIDTH	7

module user_maxpooling_fifo(

	clk,
	rst,
	
	wr_en,
	din,
	compledata_en,
	
	rd_en,
	dout,
	 
	full,
	empty




    );
    
    
input	clk;
input	rst;

input	wr_en;
input	[`IMAGE_ELE_BITWIDTH-1:0]    din;
input	compledata_en;
input	rd_en;
output	reg[`POSTIMAGE_BITWIDTH-1:0]	dout;

output	full;
output	empty;



reg	[`POSTIMAGE_BITWIDTH-1:0] ram_reg[`MAXPOOLING_FIFO_DEPTH-1:0];
    
    
(*DONT_TOUCH="TRUE"*)reg [`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1:0] wr_cnt =0;
(*DONT_TOUCH="TRUE"*)reg [`MAXPOOLING_FIFO_DEPTH_BITWIDTH:0] rd_cnt =0;    

always @(posedge clk)
begin
	if(compledata_en)
		wr_cnt <= wr_cnt + 2'b10;
	else if(wr_en)
		wr_cnt <= wr_cnt + 1'b1;
end


always @(posedge clk)
begin
	if(compledata_en)
		ram_reg[wr_cnt[`MAXPOOLING_FIFO_DEPTH_BITWIDTH:1]] <= {`FLT_MAX, din};
	else if(wr_en)
		if(!wr_cnt[0])
			ram_reg[wr_cnt[`MAXPOOLING_FIFO_DEPTH_BITWIDTH:1]][`IMAGE_ELE_BITWIDTH-1:0] <= din;
		else 
			ram_reg[wr_cnt[`MAXPOOLING_FIFO_DEPTH_BITWIDTH:1]][`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH] <= din;
end


always @(posedge clk) 
begin
		if(rd_en)
			rd_cnt <= rd_cnt + 1'b1;
end
always @(posedge clk)
begin
		if(rd_en)
			dout <= ram_reg[rd_cnt[`MAXPOOLING_FIFO_DEPTH_BITWIDTH-1:0]];
end


 //counter transformed to gray number
 wire [`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1:0] wrCnt_to_gray;
 wire [`MAXPOOLING_FIFO_DEPTH_BITWIDTH:0] rdCnt_to_gray;
 
 assign rdCnt_to_gray[`MAXPOOLING_FIFO_DEPTH_BITWIDTH] = rd_cnt[`MAXPOOLING_FIFO_DEPTH_BITWIDTH];
 genvar j;
 for(j=`MAXPOOLING_FIFO_DEPTH_BITWIDTH-1;j>=0;j=j-1)begin: rdCnt_to_gray_loop
    assign rdCnt_to_gray[j] = rd_cnt[j+1] ^ rd_cnt[j];
 end
  
 assign wrCnt_to_gray[`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1] = wr_cnt[`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1];
 genvar i;
 for(i=`MAXPOOLING_FIFO_DEPTH_BITWIDTH;i>=0;i=i-1)begin: wrCnt_to_gray_loop
    assign wrCnt_to_gray[i] = wr_cnt[i+1] ^ wr_cnt[i];
 end 


 //generate the full flag 
 reg [`MAXPOOLING_FIFO_DEPTH_BITWIDTH:0] rdCnt_to_gray_r;
 reg [`MAXPOOLING_FIFO_DEPTH_BITWIDTH:0] rdCnt_to_gray_r1;
 wire [`MAXPOOLING_FIFO_DEPTH_BITWIDTH:0] rdCntGray_to_nature;
  
always @(posedge clk)
 begin
    rdCnt_to_gray_r <= rdCnt_to_gray;
    rdCnt_to_gray_r1 <= rdCnt_to_gray_r;
 end
 
assign rdCntGray_to_nature[`MAXPOOLING_FIFO_DEPTH_BITWIDTH] = rdCnt_to_gray_r1[`MAXPOOLING_FIFO_DEPTH_BITWIDTH];
genvar k;
for(k=`MAXPOOLING_FIFO_DEPTH_BITWIDTH-1;k>=0;k=k-1)begin: rdCntGray_to_nature_loop 
	assign rdCntGray_to_nature[k] = rdCntGray_to_nature[k+1] ^ rdCnt_to_gray_r1[k];
end




assign full = ((wr_cnt[`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1] != rdCntGray_to_nature[`MAXPOOLING_FIFO_DEPTH_BITWIDTH]) &&
				(wr_cnt[`MAXPOOLING_FIFO_DEPTH_BITWIDTH:1] == rdCntGray_to_nature[`MAXPOOLING_FIFO_DEPTH_BITWIDTH-1:0])) ? 1'b1 : 1'b0;



//generate the empty flag 
reg [`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1:0] wrCnt_to_gray_r; 
reg [`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1:0] wrCnt_to_gray_r1;
wire [`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1:0] wrCntGray_to_nature;

 always @(posedge clk)
 begin
    wrCnt_to_gray_r <= wrCnt_to_gray;
    wrCnt_to_gray_r1 <= wrCnt_to_gray_r;
 end
    
assign wrCntGray_to_nature[`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1] = wrCnt_to_gray_r1[`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1];
genvar p;
for(p=`MAXPOOLING_FIFO_DEPTH_BITWIDTH;p>=0;p=p-1)begin: wrCntGray_to_nature_loop
	assign wrCntGray_to_nature[p] = wrCntGray_to_nature[p+1] ^ wrCnt_to_gray_r1[p];
end    

assign empty = (wrCntGray_to_nature[`MAXPOOLING_FIFO_DEPTH_BITWIDTH+1:1] == rd_cnt) ? 1'b1 : 1'b0;    


 





    
endmodule
