`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/12 14:44:02
// Design Name: 
// Module Name: axi_clk_gen
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


module axi_clk_gen(

	output reg axi_clk


    );
    
    

initial begin
	axi_clk = 1'b0;
	
	forever #5 axi_clk = ~axi_clk;
end    
    



    
endmodule
