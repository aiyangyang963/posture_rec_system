`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/25 15:26:13
// Design Name: 
// Module Name: user_update_fifo
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
`define DEPTH 16
`define DEPTH_WIDTH 4

module user_update_fifo(
    input wr_clk,
    input rd_clk,
    input rst,
    input [`IMAGE_ELE_BITWIDTH*2-1:0] din,
    input wr_en,
    input rd_en,
    output reg [`IMAGE_ELE_BITWIDTH-1:0] dout,
    output full,
    output reg prog_full,
    output empty


    );
    
 
reg [`IMAGE_ELE_BITWIDTH*2-1:0] ram[`DEPTH-1:0];
 
 //write data in the fifo
 (*DONT_TOUCH="TRUE"*)reg [`DEPTH_WIDTH:0] wr_cnt;
 always @(posedge wr_clk)
 begin
    if(rst)
        wr_cnt <= `DEPTH_WIDTH'h0;
    else if(wr_en)
        wr_cnt <= wr_cnt + 1'b1;
 end
 always @(posedge wr_clk)
 begin
    if(wr_en)
        ram[wr_cnt[`DEPTH_WIDTH-1:0]] <= din;
 end
 
 
 //read data from the fifo
 (*DONT_TOUCH="TRUE"*)reg [`DEPTH_WIDTH+1:0] rd_cnt;
 always @(posedge rd_clk)
 begin
    if(rst)
        rd_cnt <= 0;
    else if(rd_en)
        rd_cnt <= rd_cnt + 1'b1;
 end
 always @(posedge rd_clk)
 begin
    if(rd_en)
        dout <= (rd_cnt[0] == 1'b0) ? ram[rd_cnt[`DEPTH_WIDTH:1]][`IMAGE_ELE_BITWIDTH-1:0]
                                      : ram[rd_cnt[`DEPTH_WIDTH:1]][`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH];
 end
 
 
 //counter transformed to gray number
 wire [`DEPTH_WIDTH:0] wrCnt_to_gray;
 wire [`DEPTH_WIDTH+1:0] rdCnt_to_gray;
 
 assign rdCnt_to_gray[`DEPTH_WIDTH+1] = rd_cnt[`DEPTH_WIDTH+1];
 genvar j;
 for(j=`DEPTH_WIDTH;j>=0;j=j-1)begin: rdCnt_to_gray_loop
    assign rdCnt_to_gray[j] = rd_cnt[j+1] ^ rd_cnt[j];
 end
  
 assign wrCnt_to_gray[`DEPTH_WIDTH] = wr_cnt[`DEPTH_WIDTH];
 genvar i;
 for(i=`DEPTH_WIDTH-1;i>=0;i=i-1)begin: wrCnt_to_gray_loop
    assign wrCnt_to_gray[i] = wr_cnt[i+1] ^ wr_cnt[i];
 end
 
 
 //generate the full flag 
 reg [`DEPTH_WIDTH+1:0] rdCnt_to_gray_r;
 reg [`DEPTH_WIDTH+1:0] rdCnt_to_gray_r1;
 wire [`DEPTH_WIDTH+1:0] rdCntGray_to_nature;
  
always @(posedge wr_clk)
 begin
    rdCnt_to_gray_r <= rdCnt_to_gray;
    rdCnt_to_gray_r1 <= rdCnt_to_gray_r;
 end
 
assign rdCntGray_to_nature[`DEPTH_WIDTH+1] = rdCnt_to_gray_r1[`DEPTH_WIDTH+1];
genvar k;
for(k=`DEPTH_WIDTH;k>=0;k=k-1)begin: rdCntGray_to_nature_loop 
	assign rdCntGray_to_nature[k] = rdCntGray_to_nature[k+1] ^ rdCnt_to_gray_r1[k];
end
 
assign full = ((wr_cnt[`DEPTH_WIDTH] != rdCntGray_to_nature[`DEPTH_WIDTH+1]) &&
				(wr_cnt[`DEPTH_WIDTH-1:0] == rdCntGray_to_nature[`DEPTH_WIDTH:1])) ? 1'b1 : 1'b0;
 
 
wire [`DEPTH_WIDTH:0] wr_cnt_for_progFull;
assign wr_cnt_for_progFull = wr_cnt[`DEPTH_WIDTH-1:0] + 4'd6;
always @(posedge wr_clk)
begin
		if((wr_cnt_for_progFull >= rdCntGray_to_nature[`DEPTH_WIDTH:1] && wr_cnt[`DEPTH_WIDTH] != rdCntGray_to_nature[`DEPTH_WIDTH+1]) ||
			(wr_cnt_for_progFull[`DEPTH_WIDTH-1:0] >= rdCntGray_to_nature[`DEPTH_WIDTH:1] && wr_cnt[`DEPTH_WIDTH] == rdCntGray_to_nature[`DEPTH_WIDTH+1] && wr_cnt_for_progFull[`DEPTH_WIDTH] == 1'b1))
				prog_full <= 1'b1;
		else
				prog_full <= 1'b0;
end 
 
 
//generate the empty flag 
reg [`DEPTH_WIDTH:0] wrCnt_to_gray_r; 
reg [`DEPTH_WIDTH:0] wrCnt_to_gray_r1;
wire [`DEPTH_WIDTH:0] wrCntGray_to_nature;

 always @(posedge rd_clk)
 begin
    wrCnt_to_gray_r <= wrCnt_to_gray;
    wrCnt_to_gray_r1 <= wrCnt_to_gray_r;
 end
    
assign wrCntGray_to_nature[`DEPTH_WIDTH] = wrCnt_to_gray_r1[`DEPTH_WIDTH];
genvar p;
for(p=`DEPTH_WIDTH-1;p>=0;p=p-1)begin: wrCntGray_to_nature_loop
	assign wrCntGray_to_nature[p] = wrCntGray_to_nature[p+1] ^ wrCnt_to_gray_r1[p];
end    

assign empty = (wrCntGray_to_nature == rd_cnt[`DEPTH_WIDTH+1:1]) ? 1'b1 : 1'b0;    
    
endmodule
