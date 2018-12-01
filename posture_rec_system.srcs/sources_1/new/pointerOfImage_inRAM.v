`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/24 17:55:00
// Design Name: 
// Module Name: pointerOfImage_inRAM
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


module pointerOfImage_inRAM(
	input clk,
	input rst_n,
	input [7:0] endOfPointer,//how many feature maps in one ram
	input [7:0] virtual_pointer,//the pointer of one feature map, for example, there are 4 feature maps in one ram, the pointer can be 0,1,2,3
	output [7:0] real_pointer
    );
    
    
reg [7:0] endOfPointer_add;
reg [7:0] virtualPointer_equal_endPointer;
reg [7:0] real_pointer_temp;
reg [7:0] virtual_pointer_r;
reg realPointer_mask;
wire realPointer_mask_temp;

always @(posedge clk)
begin
	virtualPointer_equal_endPointer <= endOfPointer_add + endOfPointer;
end
always @(posedge clk)
begin
	if(virtual_pointer == 8'h0)
		endOfPointer_add <= 8'h0;
	else if(realPointer_mask_temp)
		endOfPointer_add <= endOfPointer_add + endOfPointer;		
end  
always @(posedge clk)
begin
	virtual_pointer_r <= virtual_pointer;
end 

assign realPointer_mask_temp =  virtual_pointer == virtualPointer_equal_endPointer && virtual_pointer_r == virtualPointer_equal_endPointer - 1'b1;
always @(posedge clk)
begin 
	realPointer_mask <= realPointer_mask_temp;  
end
always @(posedge clk)
begin
	if(virtual_pointer == 8'h0)
		real_pointer_temp <= 8'h0;
	else
		real_pointer_temp <= virtual_pointer - endOfPointer_add;		
end    
    
assign real_pointer = realPointer_mask ? 8'h0 : real_pointer_temp;     
    
endmodule
