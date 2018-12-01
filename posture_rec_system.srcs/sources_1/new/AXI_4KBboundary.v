`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/09 10:33:52
// Design Name: 
// Module Name: AXI_4KBboundary
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


module AXI_4KBboundary(
	clk,
	rst_n,
	addr_req,
	addr,
	burst_len,
	finish,
	addr_valid,
	addr_out,
	burst_len_out,
	new_finish

    );
    
input clk;
input rst_n;
input addr_req;
input [`AXI_ADDR_WIDTH-1:0] addr;
input [7:0] burst_len;
input finish;
output reg addr_valid;
output reg [`AXI_ADDR_WIDTH-1:0] addr_out;
output reg [7:0] burst_len_out;
output  new_finish;



reg [7:0] addrSplit_control = 0;
parameter addrSplit_idle = 8'h00,
		   addrSplit_judge = 8'h01,
		   addrSplit_yes1 = 8'h02,
		   addrSplit_yes1_wait = 8'h04,
		   addrSplit_yes2 = 8'h08,
		   addrSplit_yes2_wait = 8'h10,
		   addrSplit_no = 8'h20,
		   addrSplit_no_wait = 8'h40,
		   addrSplit_end = 8'h80;
reg [12:0] endAddr = 0;

		   
always @(posedge clk)
begin
	if(!rst_n)
		addrSplit_control <= addrSplit_idle;
	else
		case(addrSplit_control)
		addrSplit_idle:
			if(addr_req)
				addrSplit_control <= addrSplit_judge;
		addrSplit_judge:
			if(endAddr[12])
				addrSplit_control <= addrSplit_yes1;
			else
				addrSplit_control <= addrSplit_no;
		addrSplit_yes1:
			addrSplit_control <= addrSplit_yes1_wait;
		addrSplit_yes1_wait:
			if(finish)
				addrSplit_control <= addrSplit_yes2;
		addrSplit_yes2:
			addrSplit_control <= addrSplit_yes2_wait;
		addrSplit_yes2_wait:
			if(finish)
				addrSplit_control <= addrSplit_end;
		addrSplit_no:
			addrSplit_control <= addrSplit_no_wait;
		addrSplit_no_wait:
			if(finish)
				addrSplit_control <= addrSplit_end;
		addrSplit_end:
			addrSplit_control <= addrSplit_idle;
		default:
			addrSplit_control <= addrSplit_idle;
		endcase
end


always @(posedge clk)
begin
	if(addr_req)
		endAddr <= addr[11:0] + {burst_len, 3'h0};
	else
		endAddr <= 13'h0;
end



reg [7:0] burst_len_temp = 0;
wire [10:0] burst_len_temp1;
reg [`AXI_ADDR_WIDTH-1:0] addr_temp =0;

always @(posedge clk)
begin
	if(addr_req)begin
		burst_len_temp <= burst_len;
		addr_temp <= addr;
	end
end    
 
assign burst_len_temp1 = 12'hFF8 - addr_temp[11:0];    
always @(posedge clk)
begin
	if(addrSplit_control == addrSplit_yes1)begin
		addr_out <= addr_temp;
		burst_len_out <= burst_len_temp1[10:3];
	end
	else if(addrSplit_control == addrSplit_yes2)begin
		addr_out <= {addr_temp[`AXI_ADDR_WIDTH-1:12] + 1'b1, 12'h000};
		burst_len_out <= burst_len_temp - burst_len_out - 1;		
	end
	else if(addrSplit_control == addrSplit_no)begin
		addr_out <= addr_temp;
		burst_len_out <= burst_len_temp;
	end
	else if(addrSplit_control == addrSplit_idle)begin
		addr_out <= `AXI_ADDR_WIDTH'h0;
		burst_len_out <= 8'h0;
	end		
end    
    
always @(posedge clk)
begin
	if(addrSplit_control == addrSplit_yes1 || addrSplit_control == addrSplit_yes2 || addrSplit_control == addrSplit_no)
		addr_valid <= 1'b1;
	else
		addr_valid <= 1'b0;
end    
    
 

 
assign  new_finish = (addrSplit_control == addrSplit_yes2_wait || addrSplit_control == addrSplit_no_wait) && finish;
 
    
endmodule
