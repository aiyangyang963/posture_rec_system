//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/24 15:11:46
// Design Name: 
// Module Name: fifo_custom
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
`define CUSTOM_FIFO_DEPTH 256
`define CUSTOM_FIFO_WIDTH 32
`define CUSTOM_FIFO_DEPTH_BITWIDTH 8

module fifo_custom(

	input clk,
	input rst_n,
	input [`CUSTOM_FIFO_WIDTH - 1:0] data,
	input wr,
	input rd,
	output reg[`CUSTOM_FIFO_WIDTH - 1:0] q,
	output empty,
	output full


    );
    

reg [`CUSTOM_FIFO_WIDTH - 1:0] ram[`CUSTOM_FIFO_DEPTH-1:0];
reg [`CUSTOM_FIFO_DEPTH_BITWIDTH:0] rd_ptr = 0;
reg [`CUSTOM_FIFO_DEPTH_BITWIDTH:0] wr_ptr = 0;
wire [`CUSTOM_FIFO_DEPTH_BITWIDTH - 1:0] rd_ptr_gray;
wire [`CUSTOM_FIFO_DEPTH_BITWIDTH - 1:0] wr_ptr_gray;

always @(posedge clk)
begin
	if(wr)
		ram[wr_ptr[`CUSTOM_FIFO_DEPTH_BITWIDTH - 1:0]] <= data;
end
always @(posedge clk)
begin
	if(rd)
		q <= ram[rd_ptr[`CUSTOM_FIFO_DEPTH_BITWIDTH - 1:0]];
end


always @(posedge clk)
begin
	if(wr)
		wr_ptr <= wr_ptr + 1'b1;
end
always @(posedge clk)
begin
	if(rd)
		rd_ptr <= rd_ptr + 1'b1;
end
assign wr_ptr_gray[`CUSTOM_FIFO_DEPTH_BITWIDTH - 1] = wr_ptr[`CUSTOM_FIFO_DEPTH_BITWIDTH - 1];
assign rd_ptr_gray[`CUSTOM_FIFO_DEPTH_BITWIDTH - 1] = rd_ptr[`CUSTOM_FIFO_DEPTH_BITWIDTH - 1];
genvar i;
for(i=0;i<`CUSTOM_FIFO_DEPTH_BITWIDTH - 1;i=i+1)begin: binary_to_gray
	assign wr_ptr_gray[i] = wr_ptr[i] ^ wr_ptr[i+1];
	assign rd_ptr_gray[i] = rd_ptr[i] ^ rd_ptr[i+1];
end  
 
assign empty = (wr_ptr[`CUSTOM_FIFO_DEPTH_BITWIDTH] == rd_ptr[`CUSTOM_FIFO_DEPTH_BITWIDTH] && wr_ptr_gray == rd_ptr_gray);
assign full = (wr_ptr[`CUSTOM_FIFO_DEPTH_BITWIDTH] != rd_ptr[`CUSTOM_FIFO_DEPTH_BITWIDTH] && wr_ptr_gray == rd_ptr_gray); 
 
 
 
    
    
endmodule
