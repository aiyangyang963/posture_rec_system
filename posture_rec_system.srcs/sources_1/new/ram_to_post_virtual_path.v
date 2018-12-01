`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/18 16:24:11
// Design Name: 
// Module Name: ram_to_post_virtual_path
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: channel transformation from ram data to postImage module data
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ram_to_post_virtual_path(
	input	clk,
	
	input	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	data,
	input	[`POSTIMAGE_CHANNEL-1:0]	choose,
	output	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	q



    );
    
    
    
reg	[`POSTIMAGE_BITWIDTH-1:0]	q_temp[`POSTIMAGE_CHANNEL-1:0];    

always @(posedge clk)
begin
		case(choose)
		`POSTIMAGE_CHANNEL'h02:
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*2-1:`POSTIMAGE_BITWIDTH];
		`POSTIMAGE_CHANNEL'h04:
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*3-1:`POSTIMAGE_BITWIDTH*2];
		`POSTIMAGE_CHANNEL'h08:
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*4-1:`POSTIMAGE_BITWIDTH*3];
		`POSTIMAGE_CHANNEL'h10:
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*5-1:`POSTIMAGE_BITWIDTH*4];
		`POSTIMAGE_CHANNEL'h20:
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*6-1:`POSTIMAGE_BITWIDTH*5];
		`POSTIMAGE_CHANNEL'h40:
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*7-1:`POSTIMAGE_BITWIDTH*6];
		`POSTIMAGE_CHANNEL'h80:
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*8-1:`POSTIMAGE_BITWIDTH*7];
			

		
		`POSTIMAGE_CHANNEL'h05:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*3-1:`POSTIMAGE_BITWIDTH*2];		
		end
		`POSTIMAGE_CHANNEL'h0A:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*2-1:`POSTIMAGE_BITWIDTH];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*4-1:`POSTIMAGE_BITWIDTH*3];		
		end	
		
		`POSTIMAGE_CHANNEL'h09:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*4-1:`POSTIMAGE_BITWIDTH*3];		
		end	
		`POSTIMAGE_CHANNEL'h12:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*2-1:`POSTIMAGE_BITWIDTH];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*5-1:`POSTIMAGE_BITWIDTH*4];		
		end	
		`POSTIMAGE_CHANNEL'h24:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*3-1:`POSTIMAGE_BITWIDTH*2];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*6-1:`POSTIMAGE_BITWIDTH*5];		
		end	
		
		`POSTIMAGE_CHANNEL'h11:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*5-1:`POSTIMAGE_BITWIDTH*4];		
		end	
		`POSTIMAGE_CHANNEL'h22:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*2-1:`POSTIMAGE_BITWIDTH];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*6-1:`POSTIMAGE_BITWIDTH*5];		
		end			
		`POSTIMAGE_CHANNEL'h44:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*3-1:`POSTIMAGE_BITWIDTH*2];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*7-1:`POSTIMAGE_BITWIDTH*6];		
		end	
		`POSTIMAGE_CHANNEL'h88:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*4-1:`POSTIMAGE_BITWIDTH*3];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*8-1:`POSTIMAGE_BITWIDTH*7];		
		end
		


		`POSTIMAGE_CHANNEL'h15:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*3-1:`POSTIMAGE_BITWIDTH*2];
			q_temp[2]	<=	data[`POSTIMAGE_BITWIDTH*5-1:`POSTIMAGE_BITWIDTH*4];
		end	
		`POSTIMAGE_CHANNEL'h2A:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*2-1:`POSTIMAGE_BITWIDTH];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*4-1:`POSTIMAGE_BITWIDTH*3];
			q_temp[2]	<=	data[`POSTIMAGE_BITWIDTH*6-1:`POSTIMAGE_BITWIDTH*5];
		end		



		`POSTIMAGE_CHANNEL'h55:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*3-1:`POSTIMAGE_BITWIDTH*2];
			q_temp[2]	<=	data[`POSTIMAGE_BITWIDTH*5-1:`POSTIMAGE_BITWIDTH*4];
			q_temp[3]	<=	data[`POSTIMAGE_BITWIDTH*7-1:`POSTIMAGE_BITWIDTH*6];
		end	
		`POSTIMAGE_CHANNEL'hAA:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH*2-1:`POSTIMAGE_BITWIDTH];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*4-1:`POSTIMAGE_BITWIDTH*3];
			q_temp[2]	<=	data[`POSTIMAGE_BITWIDTH*6-1:`POSTIMAGE_BITWIDTH*5];
			q_temp[3]	<=	data[`POSTIMAGE_BITWIDTH*8-1:`POSTIMAGE_BITWIDTH*7];
		end	
		
		
		default:begin
			q_temp[0]	<=	data[`POSTIMAGE_BITWIDTH-1:0];
			q_temp[1]	<=	data[`POSTIMAGE_BITWIDTH*2-1:`POSTIMAGE_BITWIDTH];
			q_temp[2]	<=	data[`POSTIMAGE_BITWIDTH*3-1:`POSTIMAGE_BITWIDTH*2];	
			q_temp[3]	<=	data[`POSTIMAGE_BITWIDTH*4-1:`POSTIMAGE_BITWIDTH*3];
			q_temp[4]	<=	data[`POSTIMAGE_BITWIDTH*5-1:`POSTIMAGE_BITWIDTH*4];	
			q_temp[5]	<=	data[`POSTIMAGE_BITWIDTH*6-1:`POSTIMAGE_BITWIDTH*5];
			q_temp[6]	<=	data[`POSTIMAGE_BITWIDTH*7-1:`POSTIMAGE_BITWIDTH*6];
			q_temp[7]	<=	data[`POSTIMAGE_BITWIDTH*8-1:`POSTIMAGE_BITWIDTH*7];			
		end
																						
		endcase
end


assign	q	=	{q_temp[7], q_temp[6], 
				 q_temp[5], q_temp[4],
				 q_temp[3], q_temp[2],
				 q_temp[1], q_temp[0]};    



    
    
    
    
    
endmodule
