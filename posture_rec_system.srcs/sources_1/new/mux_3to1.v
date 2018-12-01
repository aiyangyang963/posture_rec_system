`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/24 09:30:36
// Design Name: 
// Module Name: mux_3to1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: choose one data from 3 channels
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define EN_WIDTH	3
`define D_WIDTH		29



module mux_3to1(
input [`EN_WIDTH-1:0]	en,//gate signal
input [`D_WIDTH-1:0]	d1,
input [`D_WIDTH-1:0]	d2,
input [`D_WIDTH-1:0]	d3,
output reg[`D_WIDTH-1:0]	q


    );
    
    
always @(en or d1 or d2 or d3)  
begin
		case(en)
		3'b001:
			q	=	d1;
		3'b010:
			q	=	d2;
		3'b100:
			q	=	d3;
		default:
			q	=	`D_WIDTH'h0;
		endcase
end  
    
    
    
    
    
    
    
    
endmodule
