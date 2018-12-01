`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An pingbo
// 
// Create Date: 2017/08/23 22:33:20
// Design Name: 
// Module Name: multiplier_3x
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 3 operands multiply
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define A_WIDTH		13
`define B_WIDTH		8
`define C_WIDTH		8
`define RESULT_WIDTH	16

module multiplier_3x(
	input clk,
	
	input [`A_WIDTH-1:0]	operand_a,
	input [`B_WIDTH-1:0]	operand_b,
	input [`C_WIDTH-1:0]	operand_c,
	output reg[`RESULT_WIDTH-1:0]	operand_result

    );
 
reg [`B_WIDTH + `C_WIDTH - 1:0] operand_bc;



always @(posedge clk)
begin
	if(operand_b[0])
		operand_bc <= operand_b * operand_c + 1'b1;
	else
		operand_bc <= operand_b * operand_c;		
end




    
always @(posedge clk)
begin
	operand_result	<=	operand_a*operand_bc;
end    
  

    
    
    
    
endmodule
