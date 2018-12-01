`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/29 09:50:49
// Design Name: 
// Module Name: shift_control
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


module shift_control(
	input	clk,
	input	rst_n,
	
	input	[`IMAGE_SIZE-1:0]	image_size,
	input	[`KERNEL_SIZE-1:0]	kernel_size,
	input	[`KERNEL_STEP-1:0]	kernel_step,
	

	input	image_empty,
	output	image_rd,
	
	output	reg[`WINDOW_COL_BITWIDTH-1:0]	shift_col_ptr,
	output	reg	[`WINDOW_COL_BITWIDTH-1:0]	write_col_ptr,
	output	reg	[`WINDOW_ROW_BITWIDTH-1:0]	write_row_ptr,
	input	conv_ready,
	output	reg shift


    );
    


////////////////////////////////////kernel size counting////////////////////////////////
reg	[`KERNEL_SIZE-1:0]	kernel_element_num;


always @(posedge clk)
begin
		case(kernel_size)
		`KERNEL_SIZE'd1:
			kernel_element_num <= `KERNEL_SIZE'd0;//1-1
		`KERNEL_SIZE'd3:
			kernel_element_num <= `KERNEL_SIZE'd8;//9-1
		default:
			kernel_element_num <= `KERNEL_SIZE'd0;
		endcase
end



////////////////////////////////////////////////////////////////////////////////////////








    
///////////////////////////////////control state/////////////////////////////////////
reg	[3:0]	control_state;
parameter	control_idle	= 4'h0,
			control_start_write = 4'h1,
			control_write = 4'h2,
			control_shift = 4'h4,
			control_col_end = 4'h8;
			
(*DONT_TOUCH="TRUE"*)reg	[`KERNEL_SIZE-1:0] write_data_cnt;
			
wire	image_row_move_end;//move the end of image row




			
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			control_state <= control_idle;
		else
			case(control_state)
			control_idle:
				if(!image_empty)
					control_state <= control_start_write;
			control_start_write:
				if(write_data_cnt == kernel_element_num && image_rd)
					control_state <= control_shift;
			control_shift:
				if(conv_ready)begin
					if(image_row_move_end)
						control_state <= control_col_end;
					else
						control_state <= control_write;
				end
			control_write:
				if(write_data_cnt == kernel_size - 1'b1 && image_rd)
					control_state <= control_shift;
			control_col_end:
				control_state <= control_start_write;
			default:
				control_state <= control_idle;
			
			endcase
end			
			


////////////////////////////////////////////////////////////////////////////////////




/////////////////////////////////////shift signal/////////////////////////////////////////
reg [`IMAGE_SIZE-1:0]	image_row_move_cnt;
wire shift_temp;

assign	shift_temp	=	(control_state == control_shift && conv_ready) ? 1'b1 : 1'b0;
assign	image_rd = ((control_state == control_start_write || control_state == control_write) 
					&& !image_empty) ? 1'b1 : 1'b0;
					


always @(posedge clk)
begin
		shift	<=	shift_temp;

end
					
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			image_row_move_cnt	<=	`IMAGE_SIZE'h0;
		else if(control_state == control_col_end)
			image_row_move_cnt	<=	`IMAGE_SIZE'h0;
		else if(shift_temp)
			image_row_move_cnt	<=	image_row_move_cnt + 1'b1;
end


assign	image_row_move_end	=	(image_row_move_cnt == image_size - 2'd1) ? 1'b1 : 1'b0;					
/////////////////////////////////////////////////////////////////////////////////////////


    
////////////////////////image register pointer///////////////////////////////////////
reg[`WINDOW_COL_BITWIDTH-1:0]	shift_col_ptr_temp;
reg	[`WINDOW_COL_BITWIDTH-1:0]	write_col_ptr_temp;
reg	[`WINDOW_ROW_BITWIDTH-1:0]	write_row_ptr_temp;





always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			write_data_cnt	<=	`KERNEL_SIZE'h0;
		else if(image_rd)
			write_data_cnt	<=	write_data_cnt + 1'b1;
		else if(control_state == control_shift)
			write_data_cnt	<=	`KERNEL_SIZE'h0;
end



always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			shift_col_ptr_temp	<=	`WINDOW_COL_BITWIDTH'h0;
		else if(control_state == control_col_end)	
			shift_col_ptr_temp	<=	`WINDOW_COL_BITWIDTH'h0;
		else if(shift_temp)
			shift_col_ptr_temp	<=	shift_col_ptr_temp + 1'b1;
end



always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			write_row_ptr_temp	<=	`WINDOW_ROW_BITWIDTH'h0;
		else if(write_row_ptr_temp == kernel_size - 1'b1 && image_rd)
			write_row_ptr_temp	<=	`WINDOW_ROW_BITWIDTH'h0;
		else if(image_rd)
			write_row_ptr_temp	<=	write_row_ptr_temp + 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			write_col_ptr_temp	<=	`WINDOW_COL_BITWIDTH'h0;
		else if(control_state == control_col_end)
			write_col_ptr_temp	<=	`WINDOW_COL_BITWIDTH'h0;
		else if(image_rd && write_row_ptr_temp == kernel_size - 1'b1)
			write_col_ptr_temp	<=	write_col_ptr_temp + 1'b1;
end








always @(posedge clk)
begin
	shift_col_ptr <= shift_col_ptr_temp;
	write_col_ptr <= write_col_ptr_temp;
	write_row_ptr <= write_row_ptr_temp;
end

//////////////////////////////////////////////////////////////////////////////////////////////    
   
    
    
    
    
    
    
    
    
    
    
endmodule
