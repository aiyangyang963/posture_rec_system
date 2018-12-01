`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/24 10:22:45
// Design Name: 
// Module Name: sub_com
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: if B can be subtracted by A, then B, else A
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sub_com(
	input clk,
	input A_valid,//A is valid
	input en,
	input [`SUB_A_WIDTH-1:0]	A,//16bit
	output reg[`SUB_B_WIDTH-1:0]	result1//8bit
    );
    
    

wire [`SUB_A_WIDTH-1:0]	sub_result;
wire [`SUB_A_WIDTH-1:0]	sub_A;
wire	ce;


wire   greater;


assign sub_A	=	A_valid ? A : sub_result;


assign	greater	=	(sub_A > `MAX_BURST_LENGTH) ? 1'b1 : 1'b0;

								
assign ce	=	greater ? en : 1'b0;




always @(posedge clk)
begin
		if(en)begin
			result1	<=	greater ? `MAX_BURST_LENGTH : sub_A;
		end
		
end


wire [15:0] max_burst_len;
assign max_burst_len = `MAX_BURST_LENGTH;

    
sub_unit sub_unit_m1 (
      .A(sub_A),      // input wire [15 : 0] A
      .B(max_burst_len),      // input wire [15 : 0] B
      .CLK(clk),  // input wire CLK
      .CE(ce),    // input wire CE
      .S(sub_result)      // output wire [15 : 0] S
    );    
    
    





    
endmodule
