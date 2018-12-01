`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pinbgo
// 
// Create Date: 2017/09/04 13:46:20
// Design Name: 
// Module Name: clk_rst
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: global clocks and reset
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_rst(
	output	reg	axi_clk,
	output	reg	rst_n,
	output	reg	clk_rst_n
    );
    
    
initial	begin
	axi_clk	=	1'b0;
	rst_n	=	1'b0;
	clk_rst_n	=	1'b0;
	#100	clk_rst_n	=	1'b1;
	#1000	rst_n	=	1'b1;
end
    
    
always #10	axi_clk	=	~axi_clk;   

    
endmodule
