`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: 
// 
// Create Date: 2017/09/28 11:18:47
// Design Name: 
// Module Name: mul_results_adder
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



module mul_results_adder(
	
	Clk,
	rst_n,
	
	kernel_size,
	a,
	add_en,
	b,
	b_valid

);


input Clk;
input rst_n;

input [`KERNEL_SIZE-1:0] kernel_size;
input[`IMAGE_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0] a;
input[`MAX_KERNEL_SIZE-1:0] add_en;
output [`IMAGE_ELE_BITWIDTH-1:0] b;
output  b_valid;


	



wire [`IMAGE_ELE_BITWIDTH*8-1:0] addend;
wire [7:0] addend_valid;
wire [4*`IMAGE_ELE_BITWIDTH-1:0] sum;
wire [3:0] sum_valid;





generate
genvar i;
for(i=0;i<=3;i=i+1)
	begin: float_add_ip_loop1
		float_add_IP_use_DSP_multilatency float_add_IP_m1(
				.aclk(Clk),
				.s_axis_a_tvalid(addend_valid[(2*i)]),
				.s_axis_a_tdata(addend[(2*i+1)*`IMAGE_ELE_BITWIDTH-1:(2*i*`IMAGE_ELE_BITWIDTH)]),
				.s_axis_b_tvalid(addend_valid[2*i+1]),
				.s_axis_b_tdata(addend[(2*i+2)*`IMAGE_ELE_BITWIDTH-1:(2*i+1)*`IMAGE_ELE_BITWIDTH]),							
				.m_axis_result_tvalid(sum_valid[i]),
				.m_axis_result_tdata(sum[(i+1)*`IMAGE_ELE_BITWIDTH-1:i*`IMAGE_ELE_BITWIDTH])
		);
	end
endgenerate



sumorder_control sumorder_control_m1(
	.clk(Clk),
	.rst_n(rst_n),
	
	.kernel_size(kernel_size),
	.initial_addend(a),
	.intial_addend_valid(add_en),
	.lastround_sumresult(sum),
	.lastround_sumresult_valid(sum_valid),
	.nextround_addend(addend),
	.nextround_addend_valid(addend_valid),
	.finalround_sum(b),
	.finalround_sum_valid(b_valid)

);
	

endmodule





module sumorder_control(
	input clk,
	input rst_n,
	
	input [`KERNEL_SIZE-1:0] kernel_size,
	
	input [`IMAGE_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:0] initial_addend,
	input [`MAX_KERNEL_SIZE-1:0] intial_addend_valid,
	
	input [4*`IMAGE_ELE_BITWIDTH-1:0] lastround_sumresult,
	input [3:0] lastround_sumresult_valid,
	
	output reg[8*`IMAGE_ELE_BITWIDTH-1:0] nextround_addend,
	output reg[7:0] nextround_addend_valid,
	
	output reg[`IMAGE_ELE_BITWIDTH-1:0] finalround_sum,
	output reg finalround_sum_valid


);



reg [3:0] addround_control;
parameter	addround_idle = 4'h0,
			addround_round1 = 4'h1,
			addround_round2 = 4'h2,
			addround_round3 = 4'h4,
			addround_round4 = 4'h8;
			
			
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			addround_control <= addround_idle;
		else
			case(addround_control)
			addround_idle:
				if(intial_addend_valid[0] && kernel_size == `KERNEL_SIZE'd3)
					addround_control <= addround_round1;
			addround_round1:
				if(lastround_sumresult_valid[0])
					addround_control <= addround_round2;
			addround_round2:
				if(lastround_sumresult_valid[0])
					addround_control <= addround_round3;
			addround_round3:
				if(lastround_sumresult_valid[0])
					addround_control <= addround_round4;
			addround_round4:
				if(lastround_sumresult_valid[0])
					addround_control <= addround_idle;
			default:
				addround_control <= addround_idle;						
			endcase
end					




reg [`IMAGE_ELE_BITWIDTH-1:0] lonedata_in_initialaddend;

always @(posedge clk)
begin
		if(intial_addend_valid[0] && kernel_size == `KERNEL_SIZE'd3)
			lonedata_in_initialaddend <= initial_addend[`IMAGE_ELE_BITWIDTH*`MAX_KERNEL_SIZE-1:`IMAGE_ELE_BITWIDTH*(`MAX_KERNEL_SIZE-1)];
end




always @(posedge clk)
begin
		case(addround_control)
		addround_idle:
			nextround_addend <= initial_addend[`IMAGE_ELE_BITWIDTH*8-1:0];
		addround_round1:
			nextround_addend <= {{4{`IMAGE_ELE_BITWIDTH'h0}},lastround_sumresult};
		addround_round2:
			nextround_addend <= {{4{`IMAGE_ELE_BITWIDTH'h0}},lastround_sumresult};
		addround_round3:
			nextround_addend <= {{6{`IMAGE_ELE_BITWIDTH'h0}},lonedata_in_initialaddend,lastround_sumresult[`IMAGE_ELE_BITWIDTH-1:0]};
		endcase
end




always @(posedge clk)
begin
		case(addround_control)
		addround_idle:begin
			if(intial_addend_valid[0] && kernel_size == `KERNEL_SIZE'd3)begin
				nextround_addend_valid = 8'hFF;
			end
			else begin
				nextround_addend_valid = 8'h0;
			end
		end
		addround_round1:begin
			if(lastround_sumresult_valid[0])
				nextround_addend_valid = {4'h0,4'hF};	
			else
				nextround_addend_valid = 8'h0;			
		end
		addround_round2:begin
			if(lastround_sumresult_valid[0])
				nextround_addend_valid = {6'h0,2'b11};
			else
				nextround_addend_valid = 8'h0;	
		end	
		addround_round3:begin
			if(lastround_sumresult_valid[0])
				nextround_addend_valid = {6'h0,2'b11};
			else
				nextround_addend_valid = 8'h0;
		end	
		default:begin
			nextround_addend_valid = 8'h0;		
		end
		endcase
end





reg[`IMAGE_ELE_BITWIDTH-1:0] finalround_sum_temp;
reg finalround_sum_valid_temp;

always @(posedge clk)
begin
		if(intial_addend_valid[0] && kernel_size == `KERNEL_SIZE'd1)begin
			finalround_sum_temp <= initial_addend[`IMAGE_ELE_BITWIDTH-1:0];
			finalround_sum_valid_temp <= 1'b1;
		end
		else if(kernel_size == `KERNEL_SIZE'd3 && addround_control == addround_round4 && lastround_sumresult_valid[0])begin
			finalround_sum_temp <= lastround_sumresult[`IMAGE_ELE_BITWIDTH-1:0];
			finalround_sum_valid_temp <= 1'b1;		
		end
		else
			finalround_sum_valid_temp <= 1'b0;
			
end


always @(posedge clk)
begin
		finalround_sum <= finalround_sum_temp;
		finalround_sum_valid <= finalround_sum_valid_temp;
end




//sumorder_control_ila sumorder_control_ila_m (
//	.clk(clk), // input wire clk


//	.probe0(finalround_sum_temp), // input wire [31:0]  probe0  
//	.probe1(lastround_sumresult[31:0]), // input wire [31:0]  probe1 
//	.probe2(initial_addend[31:0]) // input wire [31:0]  probe2
//);










endmodule
