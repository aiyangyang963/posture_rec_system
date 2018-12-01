`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/16 20:42:10
// Design Name: 
// Module Name: sum_8channel
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


module sum_8channel(
	input	clk,
	input	rst_n,

    input	[`KERNEL_NUM-1:0]	kernel_num,
	input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	data,//the input image data from PARALLEL_NUM dealing channels
	input	valid,//valid signal    
	 
	output	reg[`IMAGE_ELE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	result,
	output	reg r_valid
    );
    
    
reg [`IMAGE_ELE_BITWIDTH-1:0] addend[3:0];
reg  addend_en;
wire [`IMAGE_ELE_BITWIDTH-1:0] add_result[1:0];    
wire add_result_valid;    
    
float_add_IP_use_DSP_multilatency float_add_IP_m1(
	   .aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(addend_en),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(addend[0]),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(addend_en),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(addend[1]),              // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(add_result_valid),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(add_result[0])    // output wire [31 : 0] m_axis_result_tdata
    );    
        
        
float_add_IP_use_DSP_multilatency float_add_IP_m2(
       .aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(addend_en),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(addend[2]),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(addend_en),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(addend[3]),              // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(add_result[1])    // output wire [31 : 0] m_axis_result_tdata
    );     
    
 
 
    
reg [3:0]	sum_control;
parameter	sum_idle = 4'h0,
			sum_round1 = 4'h1,
			sum_round2 = 4'h2,
			sum_round3 = 4'h4,
			sum_round4 = 4'h8;
			
			    
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			sum_control <= sum_idle;
		else
			case(sum_control)
			sum_idle:
				if(kernel_num != `KERNEL_NUM'h1 && valid)
					sum_control <= sum_round1;
			sum_round1:
				if(add_result_valid)
					sum_control <= sum_round2;
			sum_round2:
				if(add_result_valid)
					sum_control <= sum_round3;
			sum_round3:
				if(kernel_num == `KERNEL_NUM'd8 && add_result_valid)
					sum_control <= sum_round4;
				else if(kernel_num == `KERNEL_NUM'd4 && add_result_valid)
						sum_control <= sum_idle;
			sum_round4:
				if(add_result_valid)			
					sum_control <= sum_idle;
			endcase
end    
    




reg [`IMAGE_ELE_BITWIDTH-1:0] add_result_buf[1:0];
always @(posedge clk)
begin
		case(sum_control)
		sum_round1, sum_round3:
			if(add_result_valid)begin
				add_result_buf[0] <= add_result[0];
				add_result_buf[1] <= add_result[1];				
			end
		endcase

end


always @(posedge clk)
begin
		case(sum_control)
		sum_idle:
			if(kernel_num != `KERNEL_NUM'h1 && valid)begin
				{addend[1],addend[0]} <= data[`IMAGE_ELE_BITWIDTH*2-1:0];
				{addend[3],addend[2]} <= data[`IMAGE_ELE_BITWIDTH*6-1:`IMAGE_ELE_BITWIDTH*4];
			end
		sum_round1:
			begin
				{addend[1],addend[0]} <= data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*2];
				{addend[3],addend[2]} <= data[`IMAGE_ELE_BITWIDTH*8-1:`IMAGE_ELE_BITWIDTH*6];
			end
		sum_round2:
			 begin
				{addend[1],addend[0]} <= {add_result_buf[1],add_result_buf[0]};
				{addend[3],addend[2]} <= {add_result[1],add_result[0]};				
			end
		sum_round3:
			if(kernel_num == `KERNEL_NUM'h8)
				{addend[1],addend[0]} <= {add_result[1],add_result[0]};				
		endcase
end


always @(posedge clk)
begin
		case(sum_control)
		sum_idle:
			if(kernel_num != `KERNEL_NUM'h1 && valid)
				addend_en <= 1'b1;
			else
				addend_en <= 1'b0;
		sum_round1:
			if(add_result_valid)
				addend_en <= 1'b1;
			else
				addend_en <= 1'b0;
		sum_round2:
			if(add_result_valid)
				addend_en <= 1'b1;
			else
				addend_en <= 1'b0;

		sum_round3:
			if(add_result_valid && kernel_num == `KERNEL_NUM'h8)
				addend_en <= 1'b1;
			else
				addend_en <= 1'b0;
		default:
			addend_en <= 1'b0;
		endcase
end


always @(posedge clk)
begin
		if(kernel_num == `KERNEL_NUM'h1)begin
			result <= data;
			r_valid <= valid;
		end
		else if(kernel_num == `KERNEL_NUM'h4 && sum_control == sum_round3)begin
			result[`IMAGE_ELE_BITWIDTH-1:0] <= add_result[0];
			result[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH] <= add_result[1];			
			result[`IMAGE_ELE_BITWIDTH*`POSTIMAGE_CHANNEL-1:`IMAGE_ELE_BITWIDTH*2] <= 0;
			r_valid <= add_result_valid;		
		end
		else if(kernel_num == `KERNEL_NUM'h8 && sum_control == sum_round4)begin
			result[`IMAGE_ELE_BITWIDTH-1:0] <= add_result[0];
			result[`IMAGE_ELE_BITWIDTH*`POSTIMAGE_CHANNEL-1:`IMAGE_ELE_BITWIDTH] <= 0;
			r_valid <= add_result_valid;
		end
		else
			r_valid <= 1'b0;
end



    
    
endmodule
