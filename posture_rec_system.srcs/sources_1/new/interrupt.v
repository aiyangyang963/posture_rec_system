`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/02 21:15:12
// Design Name: 
// Module Name: interrupt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: generate the interrupt to ps part, and the image and kernel read begin signal
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module interrupt(
	clk,
	axi_clk,
	rst_n,
	
	image_return_axi,
	
	maxpooling_finish,
	
	slow_clk,
	image_begin_inter,
	image_finish_inter,
	
	
	load_head_begin,
	
	load_image_begin,
	load_image_finish,
	one_layer_finish,
	one_layer_finish_int,
	activation_choose,
	
	image_one_return_finish,
	algorithm_finish,
	
	load_kernel_begin,
	load_kernel_finish
	
    );
    
    
///////////////////////////////inputs and outputs////////////////////////////////
input	clk;
input 	axi_clk;
input	rst_n;

input	image_return_axi;

input	maxpooling_finish;

input	slow_clk;
input	image_begin_inter;//the image have been sampled and stored in ddr
output	reg image_finish_inter;//all the images are dealt and give an interrupt to ps
output	one_layer_finish;//one layer is finished
output reg one_layer_finish_int;
output	activation_choose;

input	image_one_return_finish;//image in the ram have been returned once
output	reg algorithm_finish;//the algorithm dealing is end

output	load_head_begin;

output	load_image_begin;
input	load_image_finish;

output	load_kernel_begin;
input	load_kernel_finish;

//////////////////////////////////////////////////////////////////////////////////    
 


/////////////////////////////////image_begin_inter clock cross/////////////////////
wire image_begin_inter_in_clk_domain;
reg	image_begin_inter_r, image_begin_inter_r1, image_begin_inter_r2, image_begin_inter_r3;


always @(posedge slow_clk)
begin
	image_begin_inter_r <= image_begin_inter;
end


always @(posedge clk)
begin
		image_begin_inter_r1 <= image_begin_inter_r;
		image_begin_inter_r2 <= image_begin_inter_r1;
end

always @(posedge clk)
begin
		image_begin_inter_r3 <= image_begin_inter_r2;
end


assign	image_begin_inter_in_clk_domain = image_begin_inter_r2 && !image_begin_inter_r3;
/////////////////////////////////////////////////////////////////////////////////// 
  
////////////////////////////////////image_one_return_finish////////////////////////////
reg image_one_return_finish_flag=1'b0;
reg image_one_return_finish_flag_r=1'b0;
reg image_one_return_finish_flag_r1=1'b0;
reg image_one_return_finish_ready=1'b0;
reg image_one_return_finish_ready_r=1'b0;
reg image_one_return_finish_ready_r1=1'b0;
reg image_one_return_finish_ready_temp;
reg image_one_return_finish_ready_temp1;
wire image_one_return_finish_ready_pos;

always @(posedge axi_clk)
begin
	if(image_one_return_finish)
		image_one_return_finish_flag <= 1'b1;
	else if(image_one_return_finish_ready_r1)
		image_one_return_finish_flag <= 1'b0;
end
always @(posedge clk)
begin
	if(image_one_return_finish_flag_r1)
		image_one_return_finish_ready <= 1'b1;
	else if(!image_one_return_finish_flag_r1)
		image_one_return_finish_ready <= 1'b0;
end
always @(posedge axi_clk)
begin
	image_one_return_finish_ready_r <= image_one_return_finish_ready;
	image_one_return_finish_ready_r1 <= image_one_return_finish_ready_r;
end
always @(posedge clk)
begin
	image_one_return_finish_flag_r <= image_one_return_finish_flag;
	image_one_return_finish_flag_r1 <= image_one_return_finish_flag_r;
end

always @(posedge clk)
begin
	image_one_return_finish_ready_temp <= image_one_return_finish_ready;
	image_one_return_finish_ready_temp1 <= image_one_return_finish_ready_temp;
end
assign image_one_return_finish_ready_pos = image_one_return_finish_ready_temp && !image_one_return_finish_ready_temp1;
///////////////////////////////////////////////////////////////////////////////////////  
  
  
    
/////////////////////////////control state////////////////////////////////////////
reg	[8:0]	process_control_state;
parameter	process_control_idle	=	9'h00,
			process_control_start	=	9'h01,
			process_control_load_head	=	9'h02,
			process_control_load_head_waitAddZero = 9'h04,
			process_control_load_kernel	=	9'h08,
			process_control_load_image	=	9'h10,
			process_control_deal_image	=	9'h20,
			process_control_send_image	=	9'h40,
			process_control_end	=	9'h80,
			process_control_inter	=	9'h100;
			


wire	axi_inter_out_finish;//finish sending interrupt to ps
reg 	[7:0] load_head_delay_cnt=0;
wire	algorithm_finish_temp;

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			process_control_state	<=	process_control_idle;
		else
			case(process_control_state)
			process_control_idle:
				if(image_begin_inter_in_clk_domain)
					process_control_state	<=	process_control_start;
			process_control_start:
				process_control_state	<=	process_control_load_head;
			process_control_load_head:
				process_control_state	<=	process_control_load_head_waitAddZero;
			process_control_load_head_waitAddZero:
				if(load_head_delay_cnt == 8'hFF)
					process_control_state	<=	process_control_load_kernel;
			process_control_load_kernel:
				if(load_kernel_finish)
					process_control_state	<=	process_control_load_image;
			process_control_load_image:
				if(load_image_finish)
					process_control_state	<=	process_control_deal_image;	
			process_control_deal_image:
				if(maxpooling_finish && image_return_axi)	
					process_control_state	<=	process_control_send_image;
				else if(maxpooling_finish && !image_return_axi)
					process_control_state	<=	process_control_start;
			process_control_send_image:
				if(image_one_return_finish_ready_pos)	
					process_control_state	<=	process_control_end;
			process_control_end:
				if(algorithm_finish_temp)
					process_control_state	<=	process_control_inter;
				else 
					process_control_state	<=	process_control_start;
			process_control_inter:
				if(axi_inter_out_finish)
					process_control_state	<=	process_control_idle;
			default:
				process_control_state	<=	process_control_idle;
			endcase
end

always @(posedge clk)
begin
	if(load_head_delay_cnt == 8'hFF)
		load_head_delay_cnt <= 8'h0;
	else if(process_control_state == process_control_load_head_waitAddZero)
		load_head_delay_cnt <= load_head_delay_cnt + 1'b1;
end
////////////////////////////////////////////////////////////////////////////////    
    
/////////////////////////////////load control signals////////////////////////////
wire	load_image_begin_long_pulse;
reg		load_image_begin_long_pulse_r;

wire	load_kernel_begin_long_pulse;
reg		load_kernel_begin_long_pulse_r;

assign	load_head_begin	=	(process_control_state == process_control_load_head) ? 1'b1 : 1'b0;


assign	load_image_begin_long_pulse	=	(process_control_state == process_control_load_image) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
		load_image_begin_long_pulse_r	<=	load_image_begin_long_pulse;
end

assign	load_image_begin	=	load_image_begin_long_pulse && !load_image_begin_long_pulse_r;


assign	load_kernel_begin_long_pulse	=	(process_control_state == process_control_load_kernel) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
		load_kernel_begin_long_pulse_r	<=	load_kernel_begin_long_pulse;
end

assign	load_kernel_begin	=	load_kernel_begin_long_pulse && load_kernel_begin_long_pulse_r;



//////////////////////////////////////////////////////////////////////////////////    
    
////////////////////////////////////interrupt control//////////////////////////
reg	[`INTER_DELAY_BITWIDTH-1:0]	inter_cnt = 0;
wire image_finish_inter_in_clk_domain;



always @(posedge clk)
begin
		if(inter_cnt == `INTER_DELAY)
			inter_cnt	<=	`INTER_DELAY_BITWIDTH'h0;
		else if(process_control_state == process_control_inter)
			inter_cnt	<=	inter_cnt + 1'b1;
end


assign	axi_inter_out_finish	=	(inter_cnt == `INTER_DELAY) ? 1'b1 : 1'b0;

assign	image_finish_inter_in_clk_domain	=	(process_control_state == process_control_inter) ? 1'b1 : 1'b0;
//////////////////////////////////////////////////////////////////////////////////////////////




/////////////////////////////////////////image_finish_inter///////////////////////////////////
reg image_finish_inter_in_slow_clk_domain_r, image_finish_inter_in_slow_clk_domain;




always @(posedge slow_clk)
begin
		image_finish_inter_in_slow_clk_domain <= image_finish_inter_in_clk_domain;
		image_finish_inter_in_slow_clk_domain_r <= image_finish_inter_in_slow_clk_domain;
end

always @(posedge slow_clk)
begin
		image_finish_inter <= image_finish_inter_in_slow_clk_domain_r;
end

////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////one_layer_finish_int///////////////////////////////////
reg [3:0] oneLayerFinish_cnt;
reg one_layer_finish_int_temp;
reg one_layer_finish_int_temp1;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		oneLayerFinish_cnt <= 4'h0;
	else if(oneLayerFinish_cnt == 4'd5)
		oneLayerFinish_cnt <= 4'h0;
	else if(one_layer_finish || oneLayerFinish_cnt != 4'd0)
		oneLayerFinish_cnt <= oneLayerFinish_cnt + 1'b1;
end

always @(posedge clk)
begin
	if(oneLayerFinish_cnt != 4'd0)
		one_layer_finish_int_temp <= 1'b1;
	else
		one_layer_finish_int_temp <= 1'b0;
end

always @(posedge slow_clk)
begin
	one_layer_finish_int_temp1 <= one_layer_finish_int_temp;
	one_layer_finish_int <= one_layer_finish_int_temp1;
end
///////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////layer count/////////////////////////////////////////////////





inter_finish_counter inter_finish_counter_m1(

	.clk(clk),
	.rst_n(rst_n),
	
	.image_one_return_finish(image_one_return_finish_ready_pos),
	.image_begin_inter_in_clk_domain(image_begin_inter_in_clk_domain),
	.one_layer_finish(one_layer_finish),
	.activation_choose(activation_choose),
	.algorithm_finish(algorithm_finish_temp)

);

always @(posedge clk)
begin
	algorithm_finish <= algorithm_finish_temp;
end
///////////////////////////////////////////////////////////////////////////////////////////////




//interrupt_ila1 interrupt_ila1_m (
//	.clk(clk), // input wire clk


//	.probe0(process_control_state), // input wire [8:0] probe0
//	.probe1(algorithm_finish), // input wire [0:0]  probe1 
//	.probe2(one_layer_finish_int), // input wire [0:0]  probe2
//	.probe3(image_finish_inter), // input wire [0:0]  probe3
//	.probe4(axi_inter_out_finish) // input wire [0:0]  probe3
//);



    
endmodule







module inter_finish_counter(
	input	clk,
	input	rst_n,
	
	input	image_one_return_finish,
	input	image_begin_inter_in_clk_domain,
	
	output	reg	one_layer_finish,
	output	reg activation_choose,
	output		 algorithm_finish
);



reg	[9:0]	conv_cnt;

reg	[3:0]	conv_layer_change_state;
parameter	conv_layer_change_idle	=	4'b0000,
			conv_layer_change_start	=	4'b0001,
			conv_layer_change_layer1	=	4'b0011,
			conv_layer_change_layer2	=	4'b0010,
			conv_layer_change_layer3	=	4'b0110,
			conv_layer_change_layer4	=	4'b0111,
			conv_layer_change_layer5	=	4'b0101,
			conv_layer_change_layer6	=	4'b0100,
			conv_layer_change_layer7	=	4'b1100,
			conv_layer_change_end	=	4'b1101;
			


always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)begin
			conv_layer_change_state	<=	conv_layer_change_idle;
			conv_cnt <= 10'h0;
			one_layer_finish <= 1'b0;
		end
		else
			case(conv_layer_change_state)
			conv_layer_change_idle:begin
				one_layer_finish <= 1'b0;
				conv_cnt <= 10'h0;
				if(image_begin_inter_in_clk_domain)
					conv_layer_change_state	<=	conv_layer_change_start;
			end
			conv_layer_change_start:
				conv_layer_change_state	<=	conv_layer_change_layer1;
			conv_layer_change_layer1:begin
				if(image_one_return_finish)
					conv_cnt <= conv_cnt + 1'b1;
				else if(conv_cnt == `LAYER1_RETURN_NUM)begin
					conv_layer_change_state	<=	conv_layer_change_layer2;
					conv_cnt <= 10'h0;
					one_layer_finish <= 1'b1;
				end
				else
					one_layer_finish <= 1'b0;
			end
			
			conv_layer_change_layer2:begin
				if(image_one_return_finish)
					conv_cnt <= conv_cnt + 1'b1;
				else if(conv_cnt == `LAYER2_RETURN_NUM)begin
					conv_cnt <= 10'h0;
					conv_layer_change_state	<=	conv_layer_change_layer3;
					one_layer_finish <= 1'b1;
				end	
				else
					one_layer_finish <= 1'b0;
			end
			
			conv_layer_change_layer3:begin
				if(image_one_return_finish)
					conv_cnt <= conv_cnt + 1'b1;
				else if(conv_cnt == `LAYER3_RETURN_NUM)begin
					conv_cnt <= 10'h0;
					conv_layer_change_state	<=	conv_layer_change_layer4;
					one_layer_finish <= 1'b1;	
				end	
				else
					one_layer_finish <= 1'b0;
			end
					
			conv_layer_change_layer4:begin
				if(image_one_return_finish)
					conv_cnt <= conv_cnt + 1'b1;				
				else if(conv_cnt == `LAYER4_RETURN_NUM)begin
					conv_cnt <= 10'h0;
					conv_layer_change_state	<=	conv_layer_change_layer5;
					one_layer_finish <= 1'b1;	
				end
				else
					one_layer_finish <= 1'b0;
			end
					
			conv_layer_change_layer5:begin
				if(image_one_return_finish)
					conv_cnt <= conv_cnt + 1'b1;				
				else if(conv_cnt == `LAYER5_RETURN_NUM)begin
					conv_cnt <= 10'h0;
					conv_layer_change_state	<=	conv_layer_change_layer6;
					one_layer_finish <= 1'b1;
				end
				else
					one_layer_finish <= 1'b0;
			end
			
			
			conv_layer_change_layer6:begin
				if(image_one_return_finish)
					conv_cnt <= conv_cnt + 1'b1;			
				else if(conv_cnt == `LAYER6_RETURN_NUM)begin
					conv_cnt <= 10'h0;
					conv_layer_change_state	<=	conv_layer_change_layer7;
					one_layer_finish <= 1'b1;
				end
				else
					one_layer_finish <= 1'b0;
			end		
				
			conv_layer_change_layer7:begin
				if(image_one_return_finish)
					conv_cnt <= conv_cnt + 1'b1;						
				else if(conv_cnt == `LAYER7_RETURN_NUM)begin
					conv_cnt <= 10'h0;
					conv_layer_change_state	<=	conv_layer_change_end;
					one_layer_finish <= 1'b1;
				end
				else
					one_layer_finish <= 1'b0;
			end
							
			conv_layer_change_end:
				conv_layer_change_state	<=	conv_layer_change_idle;
			default:
				conv_layer_change_state	<=	conv_layer_change_idle;
			endcase
end



always @(posedge clk)
begin
	if(conv_layer_change_state == conv_layer_change_layer7)
		activation_choose <= 1'b1;
	else
		activation_choose <= 1'b0;
end

assign	algorithm_finish	=	(conv_layer_change_state == conv_layer_change_layer7 && 
								conv_cnt == `LAYER7_RETURN_NUM) ? 1'b1 : 1'b0;












//interrupr_ila interrupr_ila_m (
//	.clk(clk), // input wire clk


//	.probe0(conv_layer_change_state), // input wire [3:0]  probe0  
//	.probe1(conv_cnt), // input wire [9:0]  probe1 
//	.probe2(image_one_return_finish), // input wire [0:0]  probe2 
//	.probe3(one_layer_finish) // input wire [0:0]  probe3
//);







endmodule






