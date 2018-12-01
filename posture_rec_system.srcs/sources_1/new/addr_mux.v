`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/24 16:22:58
// Design Name: 
// Module Name: addr_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: choose the address
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module addr_mux(
	input [2:0]	strobe,
	input [`AXI_ADDR_WIDTH-1:0]	a1,
	input [`AXI_ADDR_WIDTH-1:0]	a2,
	input [`AXI_ADDR_WIDTH-1:0]	a3,
	output reg[`AXI_ADDR_WIDTH-1:0]	q
    );
    
    
always @(strobe or a1 or a2 or a3)  
begin
		case(strobe)
		3'b001:
			q	=	a1;
		3'b010:
			q	=	a2;
		3'b100:
			q	=	a3;
		default:
			q	=	`AXI_ADDR_WIDTH'h0;
		endcase
end  
    
    
    
    
    
    
    
endmodule
