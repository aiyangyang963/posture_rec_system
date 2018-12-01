`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/26 14:41:46
// Design Name: 
// Module Name: ram_to_cal_virtual_path
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


module ram_to_cal_virtual_path(
	input	clk,
	
	input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	data,
	input	[`PARALLEL_NUM-1:0]	choose,
	output	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	q



    );
    
    
    
reg	[`IMAGE_ELE_BITWIDTH-1:0]	q_temp[`PARALLEL_NUM-1:0];    

always @(posedge clk)
begin
		case(choose)
		`PARALLEL_NUM'h02:
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH];
		`PARALLEL_NUM'h04:
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2];
		`PARALLEL_NUM'h08:
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*3];
		`PARALLEL_NUM'h10:
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*5-1:`IMAGE_ELE_BITWIDTH*4];
		`PARALLEL_NUM'h20:
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*6-1:`IMAGE_ELE_BITWIDTH*5];
		`PARALLEL_NUM'h40:
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*7-1:`IMAGE_ELE_BITWIDTH*6];
		`PARALLEL_NUM'h80:
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*8-1:`IMAGE_ELE_BITWIDTH*7];
			

		
		`PARALLEL_NUM'h05:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2];		
		end
		`PARALLEL_NUM'h0A:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*3];		
		end	
		
		`PARALLEL_NUM'h09:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*3];		
		end	
		`PARALLEL_NUM'h12:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*5-1:`IMAGE_ELE_BITWIDTH*4];		
		end	
		`PARALLEL_NUM'h24:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*6-1:`IMAGE_ELE_BITWIDTH*5];		
		end	
		
		`PARALLEL_NUM'h11:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*5-1:`IMAGE_ELE_BITWIDTH*4];		
		end	
		`PARALLEL_NUM'h22:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*6-1:`IMAGE_ELE_BITWIDTH*5];		
		end			
		`PARALLEL_NUM'h44:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*7-1:`IMAGE_ELE_BITWIDTH*6];		
		end	
		`PARALLEL_NUM'h88:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*3];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*8-1:`IMAGE_ELE_BITWIDTH*7];		
		end
		


		`PARALLEL_NUM'h15:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2];
			q_temp[2]	<=	data[`IMAGE_ELE_BITWIDTH*5-1:`IMAGE_ELE_BITWIDTH*4];
		end	
		`PARALLEL_NUM'h2A:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*3];
			q_temp[2]	<=	data[`IMAGE_ELE_BITWIDTH*6-1:`IMAGE_ELE_BITWIDTH*5];
		end		



		`PARALLEL_NUM'h55:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2];
			q_temp[2]	<=	data[`IMAGE_ELE_BITWIDTH*5-1:`IMAGE_ELE_BITWIDTH*4];
			q_temp[3]	<=	data[`IMAGE_ELE_BITWIDTH*7-1:`IMAGE_ELE_BITWIDTH*6];
		end	
		`PARALLEL_NUM'hAA:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*3];
			q_temp[2]	<=	data[`IMAGE_ELE_BITWIDTH*6-1:`IMAGE_ELE_BITWIDTH*5];
			q_temp[3]	<=	data[`IMAGE_ELE_BITWIDTH*8-1:`IMAGE_ELE_BITWIDTH*7];
		end	
		
		
		default:begin
			q_temp[0]	<=	data[`IMAGE_ELE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH];
			q_temp[2]	<=	data[`IMAGE_ELE_BITWIDTH*3-1:`IMAGE_ELE_BITWIDTH*2];	
			q_temp[3]	<=	data[`IMAGE_ELE_BITWIDTH*4-1:`IMAGE_ELE_BITWIDTH*3];
			q_temp[4]	<=	data[`IMAGE_ELE_BITWIDTH*5-1:`IMAGE_ELE_BITWIDTH*4];	
			q_temp[5]	<=	data[`IMAGE_ELE_BITWIDTH*6-1:`IMAGE_ELE_BITWIDTH*5];
			q_temp[6]	<=	data[`IMAGE_ELE_BITWIDTH*7-1:`IMAGE_ELE_BITWIDTH*6];
			q_temp[7]	<=	data[`IMAGE_ELE_BITWIDTH*8-1:`IMAGE_ELE_BITWIDTH*7];			
		end
																						
		endcase
end


assign	q	=	{q_temp[7], q_temp[6], 
				 q_temp[5], q_temp[4],
				 q_temp[3], q_temp[2],
				 q_temp[1], q_temp[0]};    



    
    
    
    
    
endmodule
