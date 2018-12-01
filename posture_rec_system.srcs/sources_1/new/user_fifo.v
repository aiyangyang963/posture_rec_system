`timescale 1ns / 1ps
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
`define		FIFO_DEPTH	64
`define		FIFO_DEPTH_BITWIDTH	6
`define		FIFO_DATA_BITWIDTH  32


module user_fifo(

	clk,
	rst_n,
	
	wr_en,
	din,
	
	rd_en,
	dout,
	 
	full,
	empty,
	prog_full




    );
    
    
input	clk;
input	rst_n;

input	wr_en;
input	[`FIFO_DATA_BITWIDTH-1:0]    din;

input	rd_en;
output	reg[`FIFO_DATA_BITWIDTH-1:0]	dout;

output	full;
output	empty;
output	reg prog_full;


(* ram_style = "block"*) reg	[`FIFO_DATA_BITWIDTH-1:0] ram_reg[`FIFO_DEPTH-1:0];
    
    
reg [`FIFO_DEPTH_BITWIDTH:0] wr_cnt;
reg [`FIFO_DEPTH_BITWIDTH:0] rd_cnt;    
    


    
always @(posedge clk or negedge rst_n) 
begin
		if(!rst_n)
			wr_cnt <= `FIFO_DEPTH_BITWIDTH'h0;
		else if(wr_en)
			wr_cnt <= wr_cnt + 1'b1;
end   
    

always @(posedge clk or negedge rst_n) 
begin
		if(!rst_n)
			rd_cnt <= `FIFO_DEPTH_BITWIDTH'h0;
		else if(rd_en)
			rd_cnt <= rd_cnt + 1'b1;
end 


 
 
 


always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			ram_reg[wr_cnt[`FIFO_DEPTH_BITWIDTH-1:0]]	<= `FIFO_DATA_BITWIDTH'h0;
		else if(wr_en)
			ram_reg[wr_cnt[`FIFO_DEPTH_BITWIDTH-1:0]]	<= din;
end

always @(posedge clk)
begin
		if(rd_en)
			dout <= ram_reg[rd_cnt[`FIFO_DEPTH_BITWIDTH-1:0]];
end


 


assign	full = (rd_cnt[`FIFO_DEPTH_BITWIDTH] != wr_cnt[`FIFO_DEPTH_BITWIDTH] &&
				rd_cnt[`FIFO_DEPTH_BITWIDTH-1:0] == wr_cnt[`FIFO_DEPTH_BITWIDTH-1:0]) ? 1'b1 : 1'b0;
assign 	empty = (rd_cnt == wr_cnt) ? 1'b1 : 1'b0;


wire [`FIFO_DEPTH_BITWIDTH:0] wr_cnt_for_progFull;
assign wr_cnt_for_progFull = wr_cnt[`FIFO_DEPTH_BITWIDTH-1:0] + 4'd10;
always @(posedge clk)
begin
		if((wr_cnt_for_progFull >= rd_cnt[`FIFO_DEPTH_BITWIDTH-1:0] && wr_cnt[`FIFO_DEPTH_BITWIDTH] != rd_cnt[`FIFO_DEPTH_BITWIDTH]) ||
			(wr_cnt_for_progFull[`FIFO_DEPTH_BITWIDTH-1:0] >= rd_cnt[`FIFO_DEPTH_BITWIDTH-1:0] && wr_cnt[`FIFO_DEPTH_BITWIDTH] == rd_cnt[`FIFO_DEPTH_BITWIDTH] && wr_cnt_for_progFull[`FIFO_DEPTH_BITWIDTH] == 1'b1))
				prog_full <= 1'b1;
		else
				prog_full <= 1'b0;
end



    
endmodule
