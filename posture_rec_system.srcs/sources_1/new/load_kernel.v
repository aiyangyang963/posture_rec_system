`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An pingbo
// 
// Create Date: 2017/08/29 15:39:01
// Design Name: 
// Module Name: load_kernel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: load kernel and be ready for convolution
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module load_kernel(
	clk,
	rst_n,
	
	load_kernel_begin,
	load_kernel_finish,
	
	kernel_size,
	
	buffer_kernel_rd,
	buffer_kernel_rd_q,
	buffer_kernel_empty,
	

	kernel_q,
	bias1_q,
	bias2_q,
	div_q,
	kernel_valid


    );
    
////////////////////////inputs and outputs//////////////////////////////////////////
input	clk;
input	rst_n;

input	load_kernel_begin;//begin signal for loading kernel
output	reg load_kernel_finish;//finishing load kernel

input	[`KERNEL_SIZE-1:0]	kernel_size;//kernel size

output	 buffer_kernel_rd;//read request for reading kernel buffer
input	[`KERNEL_BITWIDTH*`PARALLEL_NUM-1:0]	buffer_kernel_rd_q;//output kernel
input	buffer_kernel_empty;


output	reg	[`KERNEL_ELE_BITWIDTH*`PARALLEL_NUM*`MAX_KERNEL_SIZE-1:0]	kernel_q;//kernel output
output	reg	[`BIAS_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	bias1_q;
output	reg	[`BIAS_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	bias2_q;
output	reg	[`DIV_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	div_q;
(*DONT_TOUCH="TRUE"*)output	reg	kernel_valid;//valid signal

////////////////////////////////////////////////////////////////////////////////////    
    



/////////////////////////record for counting elements of kernel///////////////////////
reg	[`KERNEL_SIZE-1:0]	kernel_rd_num_record;//how many for reading kernels and bias and div

always @(kernel_size)
begin
		case(kernel_size)
		`KERNEL_SIZE'd1:	kernel_rd_num_record	=	`KERNEL_SIZE'd2;//+bias1+bias2+div
		`KERNEL_SIZE'd3:	kernel_rd_num_record	=	`KERNEL_SIZE'd6;//+bias1+bias2+div
		default:
			kernel_rd_num_record	=	`KERNEL_SIZE'd6;
		endcase
end



/////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////get the load_kernel_begin signal///////////////////
reg load_kernel_begin_r;
wire load_kernel_begin_pos;
always @(posedge clk)
begin
	load_kernel_begin_r <= load_kernel_begin;
end
assign load_kernel_begin_pos = load_kernel_begin && !load_kernel_begin_r;
/////////////////////////////////////////////////////////////////////////////////////


////////////////////////count for read kernel elements////////////////////////////////
reg [2:0] rd_kernel_state;
parameter rd_kernel_idle = 3'h0,
		   rd_kernel_read = 3'h1,
		   rd_kernel_end = 3'h2;
reg	[`KERNEL_SIZE-1:0]	kernel_cnt;//count the kernel elemnets

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		rd_kernel_state <= rd_kernel_idle;
		kernel_cnt	<=	`KERNEL_SIZE'h0;
	end
	else
		case(rd_kernel_state)
		rd_kernel_idle:begin
			kernel_cnt	<=	`KERNEL_SIZE'h0;
			if(load_kernel_begin_pos)
				rd_kernel_state <= rd_kernel_read;
		end
		rd_kernel_read:
			if(!buffer_kernel_empty && kernel_cnt == kernel_rd_num_record - 1'b1)begin
				rd_kernel_state <= rd_kernel_end;
				kernel_cnt	<=	`KERNEL_SIZE'h0;
			end
			else if(!buffer_kernel_empty)begin
				kernel_cnt <= kernel_cnt + 1'b1;
			end
		rd_kernel_end:begin
			rd_kernel_state <= rd_kernel_idle;	
		end
		default:
			rd_kernel_state <= rd_kernel_idle;		
		endcase
end








///////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////output kernel data/////////////////////////////////////
reg		buffer_kernel_rd_r, buffer_kernel_rd_r1;
wire	buffer_kernel_rd_neg;
reg	[`KERNEL_BITWIDTH-1:0]	kernel_bias_div_temp[`PARALLEL_NUM-1:0][`MAX_KERNEL_BIAS_DIV_LEN-1:0];
wire load_kernel_finish_temp;
reg load_kernel_finish_r, load_kernel_finish_r1;



assign buffer_kernel_rd = (rd_kernel_state == rd_kernel_read && !buffer_kernel_empty) ? 1'b1 : 1'b0;
assign	load_kernel_finish_temp	=	(rd_kernel_state == rd_kernel_end) ? 1'b1 : 1'b0;
always @(posedge clk)
begin
	load_kernel_finish_r <= load_kernel_finish_temp;
	load_kernel_finish_r1 <= load_kernel_finish_r;
	load_kernel_finish <= load_kernel_finish_r1;
end

always @(posedge clk)
begin
		buffer_kernel_rd_r	<=	buffer_kernel_rd;
		buffer_kernel_rd_r1	<=	buffer_kernel_rd_r;
end





genvar i;
for(i=0;i<`PARALLEL_NUM;i=i+1)begin : kernel_q_loop
	always @(posedge clk)
	begin
	 if(buffer_kernel_rd_r)begin
			kernel_bias_div_temp[i][0]	<=	buffer_kernel_rd_q[`KERNEL_BITWIDTH*(i+1)-1:`KERNEL_BITWIDTH*i];
			kernel_bias_div_temp[i][1]	<=	kernel_bias_div_temp[i][0];
			kernel_bias_div_temp[i][2]	<=	kernel_bias_div_temp[i][1];
			kernel_bias_div_temp[i][3]	<=	kernel_bias_div_temp[i][2];
			kernel_bias_div_temp[i][4]	<=	kernel_bias_div_temp[i][3];
			kernel_bias_div_temp[i][5]	<=	kernel_bias_div_temp[i][4];
			
		end//if
	end//always
end//for




genvar k;
for(k=0;k<`PARALLEL_NUM;k=k+1)begin: kernel_bias_div_loop
	always @(posedge clk)
	begin
			case(kernel_size)
			`KERNEL_SIZE'd1:
				if(load_kernel_finish_r1)begin
					kernel_q[`KERNEL_ELE_BITWIDTH*(k+1)*`MAX_KERNEL_SIZE-1:`KERNEL_ELE_BITWIDTH*k*`MAX_KERNEL_SIZE]
							<=	kernel_bias_div_temp[k][1][`KERNEL_ELE_BITWIDTH-1:0];
					bias1_q[`BIAS_ELE_BITWIDTH*(k+1)-1:`BIAS_ELE_BITWIDTH*k]	<=	kernel_bias_div_temp[k][1][`KERNEL_ELE_BITWIDTH*2-1:`KERNEL_ELE_BITWIDTH];
					bias2_q[`BIAS_ELE_BITWIDTH*(k+1)-1:`BIAS_ELE_BITWIDTH*k]	<=	kernel_bias_div_temp[k][0][`KERNEL_ELE_BITWIDTH-1:0];
					div_q[`DIV_ELE_BITWIDTH*(k+1)-1:`DIV_ELE_BITWIDTH*k]	<=	kernel_bias_div_temp[k][0][`KERNEL_ELE_BITWIDTH*2-1:`KERNEL_ELE_BITWIDTH];
			end
			`KERNEL_SIZE'd3: 
				if(load_kernel_finish_r1)begin
					kernel_q[`KERNEL_ELE_BITWIDTH*(k+1)*`MAX_KERNEL_SIZE-1:`KERNEL_ELE_BITWIDTH*k*`MAX_KERNEL_SIZE]
							<=	{kernel_bias_div_temp[k][1][`KERNEL_ELE_BITWIDTH-1:0], kernel_bias_div_temp[k][2][`KERNEL_BITWIDTH-1:0],
								kernel_bias_div_temp[k][3][`KERNEL_BITWIDTH-1:0], kernel_bias_div_temp[k][4][`KERNEL_BITWIDTH-1:0], 
								kernel_bias_div_temp[k][5][`KERNEL_BITWIDTH-1:0]};
					bias1_q[`BIAS_ELE_BITWIDTH*(k+1)-1:`BIAS_ELE_BITWIDTH*k]	<=	kernel_bias_div_temp[k][1][`KERNEL_ELE_BITWIDTH*2-1:`KERNEL_ELE_BITWIDTH];
					bias2_q[`BIAS_ELE_BITWIDTH*(k+1)-1:`BIAS_ELE_BITWIDTH*k]	<=	kernel_bias_div_temp[k][0][`KERNEL_ELE_BITWIDTH-1:0];
					div_q[`DIV_ELE_BITWIDTH*(k+1)-1:`DIV_ELE_BITWIDTH*k]	<=	kernel_bias_div_temp[k][0][`KERNEL_ELE_BITWIDTH*2-1:`KERNEL_ELE_BITWIDTH];				
			end
		endcase
	end

end



always @(posedge clk)
begin
		kernel_valid	<=	load_kernel_finish_r1;
end
///////////////////////////////////////////////////////////////////////////////////////    
   

 

 
 
 
 
    
    
endmodule













