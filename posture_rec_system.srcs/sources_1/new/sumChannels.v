`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/15 15:00:37
// Design Name: 
// Module Name: sumChannels
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


module sumChannels(
	input	clk,
	input	rst_n,

    input	[`KERNEL_NUM-1:0]	kernel_num,
	input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	data,//the input image data from PARALLEL_NUM dealing channels
	input	valid,//valid signal    
	 
	output	reg[`IMAGE_ELE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	result,
	output	reg r_valid
    );
    
    
    
wire [`IMAGE_ELE_BITWIDTH*4-1:0] res1;
wire res1_valid;
wire [`IMAGE_ELE_BITWIDTH*2-1:0] res2;
wire res2_valid;
wire [`IMAGE_ELE_BITWIDTH-1:0] res3;
wire res3_valid;
    
    
    
    
addTree addTree_m(
	.clk(clk),
	.data(data),
	.valid(valid),
	.q1(res1),
	.q1_valid(res1_valid),
	.q2(res2),
	.q2_valid(res2_valid),
	.q3(res3),
	.q3_valid(res3_valid)

);    
    
always @(posedge clk)
begin
	case(kernel_num)
	`KERNEL_NUM'h1:begin
		result <= data;
		r_valid <= valid;		
	end
	`KERNEL_NUM'h2:begin
		result <= {{4{`IMAGE_ELE_BITWIDTH'h0}},res1};
		r_valid <= res1_valid;
	end
	`KERNEL_NUM'h4:begin
		result <= {{6{`IMAGE_ELE_BITWIDTH'h0}},res2};
		r_valid <= res2_valid;		
	end
	`KERNEL_NUM'h8:begin
		result <= {{7{`IMAGE_ELE_BITWIDTH'h0}},res3};
		r_valid <= res3_valid;			
	end
	default:begin
		result <= data;
		r_valid <= valid;		
	end
	endcase
end    
    
    
    
    
    
    
    
    
endmodule
