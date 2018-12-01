`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/26 22:08:54
// Design Name: 
// Module Name: multi_rd_addr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: two data multiply
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module multi_rd_addr(
	input clk,
	input rst_n,
	input en,
	
	input	[`IMAGE_SIZE-1:0]	size,
	input [`IMAGE_SIZE-1:0]	multi1,
	input [`IMAGE_SIZE-1:0]	multi2,
	output [`IMAGE_RAM_ADDR_WIDTH2+`PARALLEL_WIDTH-1:0]	result
	
    );
    
reg	[`IMAGE_RAM_ADDR_WIDTH2+`PARALLEL_WIDTH-1:0]	result_temp; 
 
    		
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			result_temp	<=	0;
		else if(en)
			result_temp	<=	multi2*size+multi1;
end    		
    		
    		
assign	result	=	result_temp[`IMAGE_RAM_ADDR_WIDTH2+`PARALLEL_WIDTH-1:0];   
    
    
endmodule
