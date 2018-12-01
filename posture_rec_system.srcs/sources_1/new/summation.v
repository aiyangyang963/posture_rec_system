`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/31 09:15:33
// Design Name: 
// Module Name: summation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: sum the convolution result based on the filter number
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module summation(

	clk,
	rst_n,
	
	filter_num,
	kernel_num,
	last_image_sum_en,
	
	image_data,
	image_valid,
	
	last_image_rd,
	last_image,
	
	sum_q,
	sum_q_valid


    );
    
    
///////////////////////////////inputs and outputs definition////////////////////////////
input	clk;
input	rst_n;

input	[`FILTER_NUM-1:0]	filter_num;
input	[`KERNEL_NUM-1:0]	kernel_num;//kernel number in one filter
input	last_image_sum_en;//whether sum the image data with the buffered data


input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	image_data;//the input image data from PARALLEL_NUM dealing channels
input	[`PARALLEL_NUM-1:0]	image_valid;//valid signal

output	reg [`POSTIMAGE_CHANNEL-1:0] last_image_rd;//read the image data from buffer store the dealt image data
input	[`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	last_image;//image data read from the buffer srore dealt image

output	reg[`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	sum_q;//output to be operated for maxpooling
output	reg	[`POSTIMAGE_CHANNEL-1:0]	sum_q_valid;


/////////////////////////////////////////////////////////////////////////////////////////    
    






///////////////////////////////////////sum//////////////////////////////////////////////
wire	[`IMAGE_ELE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	result_temp;
wire	r_valid;









 
sumChannels sumChannels_m1(
	
	.clk(clk),
	.rst_n(rst_n),

    .kernel_num(kernel_num),
	.data(image_data),//the input image data from PARALLEL_NUM dealing channels
	.valid(image_valid[0]),//valid signal    
	 
	.result(result_temp),
	.r_valid(r_valid)



    ); 
 



		 	
////////////////////////////////////////////////////////////////////////////////////////

   
    


/////////////////////////////////read the ram image data///////////////////////////////
wire [`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0] last_image_temp;
wire	[`POSTIMAGE_CHANNEL-1:0]sum_image_valid;
wire    [`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	sum_q_temp;
reg    [`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	sum_q_temp1, sum_q_temp2;

reg 	[`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	result_temp_r;
reg		r_valid_r;
reg 	[`POSTIMAGE_CHANNEL*`IMAGE_ELE_BITWIDTH-1:0]	result_temp_r1, result_temp_r2;
reg		r_valid_r1, r_valid_r2;

reg [`POSTIMAGE_CHANNEL-1:0]sum_image_valid_temp, sum_image_valid_temp1;
reg [`POSTIMAGE_CHANNEL-1:0] last_image_rd_r;



always @(posedge clk)
begin
		r_valid_r <= r_valid;		
end

always @(posedge clk)
begin
		result_temp_r <= result_temp;		
end


always @(posedge clk)
begin
		r_valid_r1 <= r_valid_r;		
end

always @(posedge clk)
begin
		r_valid_r2 <= r_valid_r1;		
end

always @(posedge clk)
begin
		result_temp_r1 <= result_temp_r;		
end

always @(posedge clk)
begin
		result_temp_r2 <= result_temp_r1;		
end

always @(*)
begin
	case(filter_num)
	`FILTER_NUM'd0:
		last_image_rd <= 0;
	`FILTER_NUM'd1:
		last_image_rd <= (r_valid_r1 && last_image_sum_en) ? 8'h1: 8'h0;
	`FILTER_NUM'd2:
		last_image_rd <= (r_valid_r1 && last_image_sum_en) ? 8'h3: 8'h0;
	`FILTER_NUM'd4:
		last_image_rd <= (r_valid_r1 && last_image_sum_en) ? 8'hF: 8'h0;
	`FILTER_NUM'd8:
		last_image_rd <= (r_valid_r1 && last_image_sum_en) ? 8'hFF: 8'h0;
	default:
		last_image_rd <= (r_valid_r1 && last_image_sum_en) ? 8'h0: 8'h0;
	endcase
end
always @(posedge clk)
begin
	last_image_rd_r <= last_image_rd;
end
genvar i;
for(i=0;i<8;i=i+1)begin: assign_last_image
	assign last_image_temp[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i] = (last_image_sum_en && last_image_rd_r[i]) ? 
																				last_image[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i] : 0;
end

genvar k;
for(k=0;k<8;k=k+1)begin: update_ram_summation_loop

	float_add_IP_use_DSP_multilatency float_add_IP_update_ram(
			  .aclk(clk),                                  // input wire aclk
			  .s_axis_a_tvalid(r_valid_r2),            // input wire s_axis_a_tvalid
			  .s_axis_a_tdata(result_temp_r2[`IMAGE_ELE_BITWIDTH*(k+1)-1:`IMAGE_ELE_BITWIDTH*k]),              // input wire [31 : 0] s_axis_a_tdata
			  .s_axis_b_tvalid(r_valid_r2),            // input wire s_axis_b_tvalid
			  .s_axis_b_tdata(last_image_temp[`IMAGE_ELE_BITWIDTH*(k+1)-1:`IMAGE_ELE_BITWIDTH*k]),              // input wire [31 : 0] s_axis_b_tdata
			  .m_axis_result_tvalid(sum_image_valid[k]),  // output wire m_axis_result_tvalid
			  .m_axis_result_tdata(sum_q_temp[`IMAGE_ELE_BITWIDTH*(k+1)-1:`IMAGE_ELE_BITWIDTH*k])    // output wire [31 : 0] m_axis_result_tdata
			);
		
end



always @(posedge clk)
begin
		sum_q_temp1 <= sum_q_temp;
end


always @(posedge clk)
begin
		sum_q_temp2 <= sum_q_temp1;
		sum_q <= sum_q_temp2;
end


always @(posedge clk)
begin
		sum_image_valid_temp <= sum_image_valid;
end

always @(posedge clk)
begin
		sum_image_valid_temp1 <= sum_image_valid_temp;
end



//////////////////////////////////////////////////////////////////////////////////////////




//////////////////////////////valid signal///////////////////////////////////////////////
always @(posedge clk)
begin
	if(sum_image_valid_temp1[0])
		case(filter_num)
		`FILTER_NUM'd0:
			sum_q_valid	=	`POSTIMAGE_CHANNEL'h0;
		`FILTER_NUM'd1:
			sum_q_valid	=	`POSTIMAGE_CHANNEL'h1;
		`FILTER_NUM'd2:
			sum_q_valid	=	{6'h0, 2'b11};
//		`FILTER_NUM'd3:
//			sum_q_valid	=	{5'h0, 3'b111};		
		`FILTER_NUM'd4:
			sum_q_valid	=	{4'h0, 4'b1111};	
//		`FILTER_NUM'd5:
//			sum_q_valid	=	{3'h0, 5'h1F};
//		`FILTER_NUM'd6:
//			sum_q_valid	=	{2'h0, 6'h3F};
//		`FILTER_NUM'd7:
//			sum_q_valid	=	{1'b0, 7'h7F};
		`FILTER_NUM'd8:
			sum_q_valid	=	{8'hFF};
		default:
			sum_q_valid	=	`POSTIMAGE_CHANNEL'h0;
		endcase
	else
		sum_q_valid	=	`POSTIMAGE_CHANNEL'h0;
end

//////////////////////////////////////////////////////////////////////////////////////////




//summation_ila summation_ila_m (
//	.clk(clk), // input wire clk


//	.probe0(sum_q[31:0]), // input wire [31:0]  probe0  
//	.probe1(image_data[31:0]), // input wire [31:0]  probe1
//	.probe2(last_image[31:0]), // input wire [31:0]  probe2 
//	.probe3(image_data[159:128]) // input wire [31:0]  probe3
//);

    
    
    
endmodule
