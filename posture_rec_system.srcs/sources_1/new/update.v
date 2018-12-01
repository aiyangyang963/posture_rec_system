`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/01 11:35:10
// Design Name: 
// Module Name: update
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: read from dealt image ram and give to for summation and recieve data from maxpooling and write to ram
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module update(
	clk,
	rst_n,
	
	infor_update,
	image_size,
	maxpooling_en,
	last_image_sum_en,
	
	image_wr,
	image_data,
	maxpooling_finish,
	
	last_image,
	last_image_rd,
	
	deal_PostImage_rd,
	deal_PostImage_rd_addr,
	deal_PostImage_rd_q,
	deal_PostImage_rd_valid,
	
	deal_PostImage_wr,
	deal_PostImage_wr_addr,
	deal_PostImage_wr_data,
	deal_PostImage_wr_last



    );
    
    
/////////////////////////////////inputs and outputs//////////////////////////////////
input	clk;
input	rst_n;

input	infor_update;
input	[`IMAGE_SIZE-1:0]	image_size;
input	maxpooling_en;
input	last_image_sum_en;

input	[`POSTIMAGE_CHANNEL-1:0]	image_wr;
input	[`POSTIMAGE_CHANNEL*`POSTIMAGE_BITWIDTH-1:0]	image_data;
input	maxpooling_finish;


input	[`POSTIMAGE_CHANNEL-1:0] last_image_rd;
output	[`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	last_image;


output	deal_PostImage_rd;//the postdeal part need to read image
output	[`IMAGE_SIZE*2-1:0]	deal_PostImage_rd_addr;//{row, column}
input	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_q;
input	[`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_valid;
output	deal_PostImage_wr;//write image data to ram
output	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_wr_data;
output	deal_PostImage_wr_last;//the last write data
output	[`IMAGE_SIZE*2-1:0]	deal_PostImage_wr_addr;//{row, column}

///////////////////////////////////////////////////////////////////////////////////    
 
 
    
///////////////////////////////read and write threshold///////////////////////////
reg	[`IMAGE_SIZE-1:0]	odd_wrimage_size, even_wrimage_size;

always @(posedge clk)
begin
		if(maxpooling_en)
			even_wrimage_size	<=	{image_size[`IMAGE_SIZE-1:2], 1'b0};
		else
			even_wrimage_size	<=	{image_size[`IMAGE_SIZE-1:1], 1'b0};
end
always @(posedge clk)
begin
	if(maxpooling_en)
		odd_wrimage_size <= image_size[`IMAGE_SIZE-1:1];
	else
		odd_wrimage_size <= image_size[`IMAGE_SIZE-1:0];		
end
//////////////////////////////////////////////////////////////////////////////////////


    
//////////////////////////////write/////////////////////////////////////////////////
assign	deal_PostImage_wr	=	|image_wr;
assign	deal_PostImage_wr_data	=	image_data;



/***************write address*****************/
wire	[`IMAGE_SIZE-1:0]	wr_row_cnt;
wire	[`IMAGE_SIZE-1:0]	wr_col_cnt;
reg maxpooling_finish_r;


always @(posedge clk)
begin
	maxpooling_finish_r <= maxpooling_finish;
end
row_col_ptr_gen_for_2unite row_col_ptr_gen_for_2unite_wr(
	.clk(clk),
	.rst_n(rst_n),
	.odd_size(odd_wrimage_size),
	.even_size(even_wrimage_size),
	.en(deal_PostImage_wr),
	.col(wr_col_cnt),
	.row(wr_row_cnt),
	.reach_end(deal_PostImage_wr_last)
);




assign	deal_PostImage_wr_addr	=	{wr_row_cnt, wr_col_cnt};
/////////////////////////////////////////////////////////////////////////////////////    



////////////////////////////fifo for data read from ram///////////////////////////////////////////
wire [`POSTIMAGE_CHANNEL-1:0]	fifo_full;
wire [`POSTIMAGE_CHANNEL-1:0] prog_full;
wire [`POSTIMAGE_CHANNEL-1:0]	fifo_empty;
wire [`POSTIMAGE_CHANNEL-1:0]  fifo_wr;
reg fifo_clc;

genvar i;
for(i=0;i<`POSTIMAGE_CHANNEL;i=i+1)begin: update_fifo_loop

	user_update_fifo user_update_fifo_m(
	  .rst(!rst_n || fifo_clc),    // input wire srst
	  .wr_clk(clk),				// input wire wr_clk
	  .rd_clk(clk),				// input wire rd_clk
	  .din(deal_PostImage_rd_q[`POSTIMAGE_BITWIDTH*(i+1)-1:`POSTIMAGE_BITWIDTH*i]),      // input wire [63 : 0] din
	  .wr_en(fifo_wr[i]),  // input wire wr_en
	  .rd_en(last_image_rd[i]),  // input wire rd_en
	  .dout(last_image[(i + 1)*`IMAGE_ELE_BITWIDTH-1:i*`IMAGE_ELE_BITWIDTH]),    // output wire [31 : 0] dout
	  .prog_full(prog_full[i]),
	  .full(fifo_full[i]),    // output wire full
	  .empty(fifo_empty[i])  // output wire empty
	);

	assign fifo_wr[i] = deal_PostImage_rd_valid[i] && !fifo_full[i];
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		fifo_clc <= 1'b0;
	else if(maxpooling_finish_r)
		fifo_clc <= 1'b1;
	else if(infor_update)
		fifo_clc <= 1'b0;
end

//////////////////////////////////////////////////////////////////////////////////////////////////





////////////////////////////////read data from ram///////////////////////////////////////////////
reg fifo_rd_period;

wire [`IMAGE_SIZE-1:0] rd_row_cnt;
wire [`IMAGE_SIZE-1:0] rd_col_cnt;
reg	[`IMAGE_SIZE-1:0]	odd_rdimage_size, even_rdimage_size;

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			fifo_rd_period <= 1'b0;
		else if(infor_update && last_image_sum_en)
			fifo_rd_period <= 1'b1;
		else if(maxpooling_finish)
			fifo_rd_period <= 1'b0;
end


assign	deal_PostImage_rd = fifo_rd_period && !prog_full[0];

always @(posedge clk)
begin
	even_rdimage_size	<=	{image_size[`IMAGE_SIZE-1:1], 1'b0};
end
always @(posedge clk)
begin
	odd_rdimage_size <= image_size[`IMAGE_SIZE-1:0];
end

row_col_ptr_gen_for_2unite row_col_ptr_gen_for_2unite_rd(
	.clk(clk),
	.rst_n(rst_n && !maxpooling_finish_r),
	.odd_size(odd_rdimage_size),
	.even_size(even_rdimage_size),
	.en(deal_PostImage_rd),
	.col(rd_col_cnt),
	.row(rd_row_cnt),
	.reach_end()
);




assign	deal_PostImage_rd_addr = {rd_row_cnt, rd_col_cnt};
////////////////////////////////////////////////////////////////////////////////////////////////


    
endmodule
