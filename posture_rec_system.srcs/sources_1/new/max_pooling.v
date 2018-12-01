`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/01 09:27:10
// Design Name: 
// Module Name: max_pooling
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: maxpooling
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module max_pooling(
	clk,
	rst_n,
	
	maxpooling_flag,
	image_size,
	
	image_data,
	image_valid,
	
	image_q_valid,
	image_q,
	
	maxpooling_finish
	
	




    );
    
    
/////////////////////////////////inputs and outputs///////////////////////////////////
input	clk;
input	rst_n;

input	maxpooling_flag;//flag of perform maxpooling
input	[`IMAGE_SIZE-1:0]	image_size;

input	[`IMAGE_ELE_BITWIDTH-1:0]	image_data;//from summation
input	image_valid;

output	[`POSTIMAGE_BITWIDTH-1:0]	image_q;//output to update, include 2 data
output	reg	image_q_valid;

output	 maxpooling_finish;//indicate that maxpooling is end for one images


/////////////////////////////////////////////////////////////////////////////////////    





    
    
//////////////////////////////////buffer two rows data/////////////////////////////
reg		wr_1;
reg		wr_2;
reg [`IMAGE_ELE_BITWIDTH-1:0] image_data_fifo1, image_data_fifo2;
wire	fifo_empty1;
wire	fifo_empty2;
wire	rd_en1;
wire	rd_en2;
wire	[`IMAGE_ELE_BITWIDTH*2-1:0]	rd_out1;
wire	[`IMAGE_ELE_BITWIDTH*2-1:0]	rd_out2;
reg		wr_row_end;

user_maxpooling_fifo user_maxpooling_fifo_max1(
  
  .clk(clk),                // input wire wr_clk
  .rst(!rst_n),                      // input wire rst
  .wr_en(wr_1),                  // input wire wr_en
  .din(image_data_fifo1),                      // input wire [31 : 0] din
  .compledata_en(wr_row_end && wr_1),
  .rd_en(rd_en1),                  // input wire rd_en
  .dout(rd_out1),                    // output wire [63 : 0] dout
  .full(),                    // output wire full
  .empty(fifo_empty1)                  // output wire empty
);


user_maxpooling_fifo user_maxpooling_fifo_max2(

  .clk(clk),                // input wire wr_clk
  .rst(!rst_n),                      // input wire rst
  .wr_en(wr_2),                  // input wire wr_en  
  .din(image_data_fifo2),                      // input wire [31 : 0] din
  .compledata_en(wr_row_end && wr_2),
  .rd_en(rd_en2),                  // input wire rd_en
  .dout(rd_out2),                    // output wire [63 : 0] dout
  .full(),                    // output wire full
  .empty(fifo_empty2)                 // output wire empty
);
///////////////////////////////////////////////////////////////////////////////////    
  

 
  
    
/////////////////////////////////write fifo1 and fifo2 state//////////////////////
reg	[1:0]	wr_fifo_state;
parameter	wr_fifo1	=	2'b00,
			wr_fifo2	=	2'b01,
			wr_fifo12	=	2'b11;


(*DONT_TOUCH="TRUE"*)reg		[`IMAGE_SIZE-1:0]	image_wr_cnt;//counter for write image to fifo
reg		[`IMAGE_SIZE-1:0]	image_wr_row_cnt;
wire	image_wr_noMax_end;
			
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)begin
			wr_fifo_state	<=	wr_fifo1;
		end
		else
			case(wr_fifo_state)
			wr_fifo1:begin
				if(image_wr_cnt == image_size - 1'b1 && image_valid)
					wr_fifo_state	<=	wr_fifo2;
			end	
			wr_fifo2:begin
				if(image_wr_row_cnt == image_size - 2'b10 && image_wr_cnt == image_size - 1'b1 && image_valid)
					wr_fifo_state	<=	wr_fifo12;
				else if(image_wr_cnt == image_size - 1'b1 && image_valid)
					wr_fifo_state	<=	wr_fifo1;				
			end	
			wr_fifo12:begin
				if(image_wr_row_cnt == image_size - 1'b1 && image_wr_cnt == image_size - 1'b1 && image_valid)
					wr_fifo_state	<=	wr_fifo1;
			end	
			endcase
end



always @(posedge clk)
begin
	if(image_wr_cnt == image_size - 1'b1 && image_size[0] && image_valid)
	  	wr_row_end <= 1'b1;
	else
		wr_row_end <= 1'b0;
end

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			image_wr_cnt <= 8'h0;
		else if(image_wr_cnt == image_size - 1'b1 && image_valid)
			image_wr_cnt <= 8'h0;
		else if(image_valid)
			image_wr_cnt <= image_wr_cnt + 1'b1;
end
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		image_wr_row_cnt <= `IMAGE_SIZE'h0;
	else if(image_wr_row_cnt == image_size - 1'b1 && image_wr_cnt == image_size - 1'b1 && image_valid)
		image_wr_row_cnt <= `IMAGE_SIZE'h0;
	else if(image_wr_cnt == image_size - 1'b1 && image_valid)
		image_wr_row_cnt <= image_wr_row_cnt + 1'b1;
end

assign image_wr_noMax_end = !maxpooling_flag && image_size[0] && image_wr_row_cnt == image_size - 1'b1 && image_wr_cnt == image_size - 1'b1 && image_valid;


always @(posedge clk)
begin
		image_data_fifo1 <= image_data;	
end	
always @(posedge clk)
begin
	if(wr_fifo_state == wr_fifo2)
		image_data_fifo2 <= image_data;	
	else if(wr_fifo_state == wr_fifo12)
		image_data_fifo2 <= `FLT_MAX;
end
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			wr_1 <= 1'b0;
		else if(maxpooling_flag && image_valid && (wr_fifo_state == wr_fifo1 || wr_fifo_state == wr_fifo12))
			wr_1 <= 1'b1;
		else
			wr_1 <= 1'b0;
end
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			wr_2 <= 1'b0;
		else if(maxpooling_flag && image_valid && (wr_fifo_state == wr_fifo2 || wr_fifo_state == wr_fifo12))
			wr_2 <= 1'b1;
		else
			wr_2 <= 1'b0;
end
/////////////////////////////////////////////////////////////////////////////////////////////////////    


///////////////////////////////count the number of reading image data/////////////////
wire    max_rd_en;



assign	max_rd_en = !fifo_empty1 && !fifo_empty2 && maxpooling_flag;
assign	rd_en1 = max_rd_en;
assign	rd_en2 = max_rd_en;
///////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////compare///////////////////////////////////////////////
reg	[`IMAGE_ELE_BITWIDTH*2-1:0]	rd_out1_r;
reg	[`IMAGE_ELE_BITWIDTH*2-1:0]	rd_out2_r;
reg		compare_rd_en;

wire	compare_valid1;
wire	compare_valid2;
wire	[7:0]	compare_result1;
wire	[7:0]	compare_result2;
wire	[7:0]	compare_result3;

wire	[`IMAGE_ELE_BITWIDTH-1:0]	compare_data1;
wire	[`IMAGE_ELE_BITWIDTH-1:0]	compare_data2;
reg		[`IMAGE_ELE_BITWIDTH-1:0]	compare_data1_r;
reg		[`IMAGE_ELE_BITWIDTH-1:0]	compare_data2_r;


wire	compare_valid;
wire	[`IMAGE_ELE_BITWIDTH-1:0]	compare_final_data;



always @(posedge clk)
begin
	rd_out1_r <= rd_out1;
	rd_out2_r <= rd_out2;
end





always @(posedge clk)
begin
		compare_rd_en	<=	max_rd_en;
end


floating_point_compare floating_point_compare_1(
  .aclk(clk),                                  // input wire aclk
  .s_axis_a_tvalid(compare_rd_en),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(rd_out1[`IMAGE_ELE_BITWIDTH-1:0]),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(compare_rd_en),            // input wire s_axis_b_tvalid
  .s_axis_b_tdata(rd_out1[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH]),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(compare_valid1),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(compare_result1)    // output wire [7 : 0] m_axis_result_tdata
);


floating_point_compare floating_point_compare_2(
  .aclk(clk),                                  // input wire aclk
  .s_axis_a_tvalid(compare_rd_en),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(rd_out2[`IMAGE_ELE_BITWIDTH-1:0]),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(compare_rd_en),            // input wire s_axis_b_tvalid
  .s_axis_b_tdata(rd_out2[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH]),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(compare_valid2),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(compare_result2)    // output wire [7 : 0] m_axis_result_tdata
);



assign	compare_data1	=	(compare_result1 == 1'b1) ? 
							rd_out1_r[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH] :
							rd_out1_r[`IMAGE_ELE_BITWIDTH-1:0];

assign	compare_data2	=	(compare_result2 == 1'b1) ? 
							rd_out2_r[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH] :
							rd_out2_r[`IMAGE_ELE_BITWIDTH-1:0];


always @(posedge clk)
begin
		compare_data1_r <=	compare_data1;
		compare_data2_r <=	compare_data2;
end




floating_point_compare floating_point_compare_3(
  .aclk(clk),                                  // input wire aclk
  .s_axis_a_tvalid(compare_valid1),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(compare_data1),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(compare_valid2),            // input wire s_axis_b_tvalid
  .s_axis_b_tdata(compare_data2),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(compare_valid),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(compare_result3)    // output wire [7 : 0] m_axis_result_tdata
);


assign	compare_final_data	=	(compare_result3 == 1'b1 && compare_valid) ? 
								compare_data2_r :
								compare_data1_r;

/////////////////////////////////////////////////////////////////////////////////////    


////////////////////////////////combine two compared data///////////////////////////
(*DONT_TOUCH="TRUE"*)reg [15:0] maxpool_image_pixelNum =0;
reg [`IMAGE_SIZE-1:0] image_size_after_maxpooling =0;
reg [15:0] maxpool_image_pixelNum_r;
(*DONT_TOUCH="TRUE"*)reg [15:0] compare_final_data_cnt = 0;
wire combine2data_fifo_rd_en;
wire combine2data_fifo_wr;
reg combine2data_lastData_wr;
reg combine2data_fifo_rd_en_r;
wire combine2data_fifo_empty;
wire [`POSTIMAGE_BITWIDTH-1:0]	combine_compare_data;
wire [`POSTIMAGE_BITWIDTH-1:0]	combine2data_fifo_dout;

always @(posedge clk)
begin
	if(maxpooling_flag)
		image_size_after_maxpooling <= image_size[`IMAGE_SIZE-1:1];
	else
		image_size_after_maxpooling <= image_size;
end
always @(posedge clk)
begin
	if(maxpooling_flag)
		maxpool_image_pixelNum <= image_size_after_maxpooling * image_size_after_maxpooling;
end
always @(posedge clk)
begin
	maxpool_image_pixelNum_r <= maxpool_image_pixelNum;
end

always @(posedge clk)
begin
	if(compare_final_data_cnt == maxpool_image_pixelNum_r - 1'b1 && compare_valid && maxpooling_flag)
		compare_final_data_cnt <= 0;
	else if(compare_valid && maxpooling_flag)
		compare_final_data_cnt <= compare_final_data_cnt + 1'b1;
end
always @(posedge clk)
begin
	if(compare_final_data_cnt == maxpool_image_pixelNum_r - 1'b1 && compare_valid && image_size_after_maxpooling[0] && maxpooling_flag)
		combine2data_lastData_wr <= 1'b1;
	else
		combine2data_lastData_wr <= 1'b0;
end

assign combine2data_fifo_wr =  (combine2data_lastData_wr || compare_valid) && maxpooling_flag;
assign combine2data_fifo_rd_en = !combine2data_fifo_empty;
always @(posedge clk)
begin
	combine2data_fifo_rd_en_r <= combine2data_fifo_rd_en;
end

assign combine_compare_data = {combine2data_fifo_dout[31:0],combine2data_fifo_dout[63:32]};

combine2data_fifo combine2data_fifo_m (
  .clk(clk),      // input wire clk
  .din(compare_final_data),      // input wire [31 : 0] din
  .wr_en(combine2data_fifo_wr),  // input wire wr_en
  .rd_en(combine2data_fifo_rd_en),  // input wire rd_en
  .dout(combine2data_fifo_dout),    // output wire [63 : 0] dout
  .full(),    // output wire full
  .empty(combine2data_fifo_empty)  // output wire empty
);

//////////////////////////////////////////////////////////////////////////////////////


/////////////////////////rdivide the image_size by 2//////////////////////////////////// 
reg		[`IMAGE_SIZE-1:0]	image_size_in_couple;


always @(posedge clk)
begin
		if(image_size[0])
			image_size_in_couple	<= image_size[`IMAGE_SIZE-1:1];
		else
			image_size_in_couple	<= image_size[`IMAGE_SIZE-1:1] - 1'b1;
end 

 
/////////////////////////////////////////////////////////////////////////////////////////// 
 





////////////////////////////////no maxpooling, read data from fifo////////////////////
wire no_max_rd_en;
wire noMaxfifo_empty;
wire [`IMAGE_ELE_BITWIDTH*2-1:0] noMax_rd_out;
wire noMaxFIFO_wr;

user_maxpooling_fifo user_maxpooling_fifo_nomax1(

  .clk(clk),                // input wire wr_clk
  .rst(!rst_n),                      // input wire rst
  .wr_en(noMaxFIFO_wr),                  // input wire wr_en  
  .din(image_data),                      // input wire [31 : 0] din
  .compledata_en(image_wr_noMax_end),
  .rd_en(no_max_rd_en),                  // input wire rd_en
  .dout(noMax_rd_out),                    // output wire [63 : 0] dout
  .full(),                    // output wire full
  .empty(noMaxfifo_empty)                 // output wire empty
);


assign  noMaxFIFO_wr = !maxpooling_flag && image_valid;
assign 	no_max_rd_en = !maxpooling_flag && !noMaxfifo_empty;



maxpooling_finish_gen maxpooling_finish_gen_m1(
	.clk(clk),
	.rst_n(rst_n),	
	.maxpooling_flag(maxpooling_flag),	
	.image_size(image_size),
	.image_size_in_couple(image_size_in_couple),	
	.max_rd_en(max_rd_en),
	.no_max_rd_en(no_max_rd_en),		
	.maxpooling_finish(maxpooling_finish)


);




///////////////////////////////////////////////////////////////////////////////////////



   
/////////////////////////////whether maxpooling//////////////////////////////////////
reg compare_valid_r;

always @(posedge clk)
begin
		compare_valid_r <= compare_valid;
end



assign	image_q	=	maxpooling_flag ? combine_compare_data : noMax_rd_out;
					
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			image_q_valid	<=	1'b0;
		else 
			case(maxpooling_flag)
			1'b1:
				image_q_valid	<=	combine2data_fifo_rd_en_r;
			1'b0:
				image_q_valid	<=	no_max_rd_en;
			
			endcase
end
////////////////////////////////////////////////////////////////////////////////////    
    
    







    
    
endmodule






module maxpooling_finish_gen(
	input clk,
	input rst_n,	
	input maxpooling_flag,
	input [`IMAGE_SIZE-1:0] image_size,
	input [`IMAGE_SIZE-1:0] image_size_in_couple,	
	input max_rd_en,
	input no_max_rd_en,		
	output reg maxpooling_finish
	
	

);


(*DONT_TOUCH="TRUE"*)reg		[`IMAGE_SIZE-1:0]	image_rd_cnt;
(*DONT_TOUCH="TRUE"*)reg		[`IMAGE_SIZE-1:0]	rd_allimage_cnt;//count the image data for read
wire    allimage_rd_finish1;
wire	allimage_rd_finish2;
(*DONT_TOUCH="TRUE"*)reg		[`IMAGE_SIZE*2-1:0] image_noMax_cnt;
reg		[`IMAGE_SIZE*2-1:0] x2pixel_image_length;
reg		[`IMAGE_SIZE*2-1:0] x2pixel_image_length_r;
reg		maxpooling_finish_temp, maxpooling_finish_temp1, maxpooling_finish_temp2, maxpooling_finish_temp3;


always @(posedge clk)
begin
	if(image_size[0])begin
		x2pixel_image_length <= image_size*image_size;
		x2pixel_image_length_r <= x2pixel_image_length[`IMAGE_SIZE*2-1:1];
	end
	else begin
		x2pixel_image_length <= image_size*image_size;
		x2pixel_image_length_r <= x2pixel_image_length[`IMAGE_SIZE*2-1:1] - 1'b1;
	end
end
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		image_noMax_cnt <= {(`IMAGE_SIZE*2){1'b0}};
	else if(image_noMax_cnt == x2pixel_image_length_r && no_max_rd_en)
		image_noMax_cnt <= {(`IMAGE_SIZE*2){1'b0}};
	else if(no_max_rd_en)
		image_noMax_cnt <= image_noMax_cnt + 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			image_rd_cnt <= `IMAGE_SIZE'h0;
		else if(image_rd_cnt == image_size_in_couple && max_rd_en)
			image_rd_cnt <= `IMAGE_SIZE'h0;
		else if(max_rd_en)
			image_rd_cnt <= image_rd_cnt + 1'b1;
end



always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			rd_allimage_cnt	<=	`IMAGE_SIZE'h0;
		else if(allimage_rd_finish1)
			rd_allimage_cnt	<=	`IMAGE_SIZE'h0;
		else if(image_rd_cnt == image_size_in_couple && max_rd_en)
			rd_allimage_cnt	<=	rd_allimage_cnt + 1'b1;
end

assign	allimage_rd_finish1 = (rd_allimage_cnt == image_size_in_couple && image_rd_cnt == image_size_in_couple && max_rd_en);
assign	allimage_rd_finish2 = (image_noMax_cnt == x2pixel_image_length_r && no_max_rd_en);


always @(posedge clk)
begin 
	if(allimage_rd_finish1 || allimage_rd_finish2)
		maxpooling_finish_temp	<=	1'b1;
	else
		maxpooling_finish_temp	<=	1'b0;
end


always @(posedge clk)
begin
		maxpooling_finish_temp1 <= maxpooling_finish_temp;
		maxpooling_finish_temp2 <= maxpooling_finish_temp1;
		maxpooling_finish_temp3 <= maxpooling_finish_temp2;
		
end


always @(posedge clk)
begin
		if(maxpooling_flag)
			maxpooling_finish <= maxpooling_finish_temp3;
		else
			maxpooling_finish <= maxpooling_finish_temp;
end





endmodule








