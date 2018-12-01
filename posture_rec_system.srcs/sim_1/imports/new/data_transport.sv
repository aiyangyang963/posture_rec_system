`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/26 22:13:22
// Design Name: 
// Module Name: data_transport
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: recieving data and transporting to other modules. it is an interface
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


interface data_transport(	
	input logic clk,	
	input logic[`KERNEL_BITWIDTH*`PARALLEL_NUM-1:0] data1_in, 
	input logic[`KERNEL_ELE_BITWIDTH*`PARALLEL_NUM*`MAX_KERNEL_SIZE-1:0] data2_in, 
	input logic valid1_in,
	input logic valid2_in);

logic[`KERNEL_BITWIDTH*`PARALLEL_NUM-1:0] data1;
logic[`KERNEL_ELE_BITWIDTH*`PARALLEL_NUM*`MAX_KERNEL_SIZE-1:0] data2;
logic valid1;
logic valid2;

assign	data1	=	data1_in;
assign	data2	=	data2_in;
assign	valid1	=	valid1_in;
assign	valid2	=	valid2_in;

modport master(
	input clk,
	output data1, 
	output data2, 
	output valid1, 
	output valid2);


	
	
endinterface



