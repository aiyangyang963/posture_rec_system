`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/25 10:21:09
// Design Name: 
// Module Name: head_bufer_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: store head data in fifo and control the write and read to fifo
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module head_bufer_control(
	clk,
	rst_n,
	
	algorithm_finish,
	head_rd_need,
	head_wr_req,
	head_wr_data,
	
	load_head_clk,
	load_head_rd,
	load_head_rd_q,
	load_head_empty



    );
    
    
/////////////////////////////////////inputs and outputs///////////////////////////////////////////////////////
input clk;
input rst_n;

input algorithm_finish;
output head_rd_need;//need to read head information from axi
input head_wr_req;//request to write to head fifo
input [`AXI_DATA_WIDTH-1:0]	head_wr_data;//data from axi

input load_head_clk;//clock for reading from head fifo
input load_head_rd;//read head from fifo
output [`HEAD_WIDTH-1:0]	load_head_rd_q;//output head data to who is reading
output load_head_empty;//the fifo is empty


/////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    
 
////////////////////////////////////////algorithm_fininsh///////////////////////////////////////////////////
reg algorithm_finish_req = 1'b0;
reg algorithm_finish_req_r, algorithm_finish_req_r1;
reg algorithm_finish_ack = 1'b0;
reg algorithm_finish_ack_r, algorithm_finish_ack_r1;




always @(posedge load_head_clk)
begin
	if(algorithm_finish)
		algorithm_finish_req <= 1'b1;
	else if(algorithm_finish_ack_r1)
		algorithm_finish_req <= 1'b0;
end
always @(posedge clk)
begin
	algorithm_finish_req_r <= algorithm_finish_req;
	algorithm_finish_req_r1 <= algorithm_finish_req_r;
end
always @(posedge clk)
begin
	if(algorithm_finish_req_r1)
		algorithm_finish_ack <= 1'b1;
	else
		algorithm_finish_ack <= 1'b0;
end
always @(posedge load_head_clk)
begin
	algorithm_finish_ack_r <= algorithm_finish_ack;
	algorithm_finish_ack_r1 <= algorithm_finish_ack_r;
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
 
    
////////////////////////////head fifo instantiation////////////////////////////////////////////////////////////



head_fifo head_fifo_m1(
  .rst(algorithm_finish_req_r1),        // input wire rst
  .wr_clk(clk),          // input wire wr_clk
  .rd_clk(load_head_clk),          // input wire rd_clk
  .din(head_wr_data),                // input wire [63 : 0] din
  .wr_en(head_wr_req),            // input wire wr_en
  .rd_en(load_head_rd),            // input wire rd_en
  .dout(load_head_rd_q),              // output wire [63 : 0] dout
  .full(),              // output wire full
  .empty(load_head_empty)            // output wire empty
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    
    
////////////////////////////////////////control signals////////////////////////////////////////////////////////

assign head_rd_need	=	load_head_empty;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
 
 
 
 
 
 
 
 
 
    
endmodule
