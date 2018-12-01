`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/24 16:55:33
// Design Name: 
// Module Name: stayInstep
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


module stayInstep(

	input clk,
	input rst_n,
	input [`PARALLEL_NUM-1:0]	channel_choose,//the filter number
	input [`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0] din,
	input [`PARALLEL_NUM-1:0]din_valid,
	output [`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0] dout,
	output reg [`PARALLEL_NUM-1:0] dout_valid


    );
    

wire [`PARALLEL_NUM-1:0] rd_en;
wire [`PARALLEL_NUM-1:0] full;
wire [`PARALLEL_NUM-1:0] empty; 
wire [`PARALLEL_NUM-1:0] empty_n;
wire rd_en_temp;




genvar i;
for(i=0;i<8;i=i+1)begin: fifo_gen

stayInstep_fifo stayInstep_fifo_m (
  .wr_clk(clk),  // input wire wr_clk
  .rd_clk(clk),  // input wire rd_clk
  .din(din[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i]),      // input wire [31 : 0] din
  .wr_en(din_valid[i]),  // input wire wr_en
  .rd_en(rd_en[i]),  // input wire rd_en
  .dout(dout[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i]),    // output wire [31 : 0] dout
  .full(full[i]),    // output wire full
  .empty(empty[i])  // output wire empty
);

assign empty_n[i] = !empty[i];
assign rd_en[i] = rd_en_temp && channel_choose[i]; 


end   
 
 
    
assign  rd_en_temp = (channel_choose == empty_n && channel_choose != 8'h0) ? 1'b1 : 1'b0;   
always @(posedge clk)
begin
	dout_valid <= rd_en;
end
    
    
    
endmodule
