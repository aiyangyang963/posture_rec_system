`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/01 10:52:23
// Design Name: 
// Module Name: bandWidth_count
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


module bandWidth_count(

	clk,	
	rst_n,
	numerator_en,
	denominator_en,
	send_en,
	send_clk,
	message


    );
    
input clk;
input rst_n;
input numerator_en;
input denominator_en;
input send_en;
input send_clk;
output reg [31:0] message;

parameter MS_UNITE = 24'h186A0;//1 ms with frequency 100MHz    
reg [23:0] demTimeUnite_cnt;    
reg [15:0] dem_cnt; 
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		demTimeUnite_cnt <= 24'h0;
	else if(demTimeUnite_cnt == MS_UNITE && denominator_en)
		demTimeUnite_cnt <= 24'h0;
	else if(denominator_en)
		demTimeUnite_cnt <= demTimeUnite_cnt + 1'b1;
end 
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dem_cnt <= 16'h0;
	else if(send_en)
		dem_cnt <= dem_cnt;
	else if(demTimeUnite_cnt == MS_UNITE && denominator_en)
		dem_cnt <= dem_cnt + 1'b1;
end 
 

reg [23:0] numTimeUnite_cnt;
reg [15:0] num_cnt;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		numTimeUnite_cnt <= 24'h0;
	else if(numTimeUnite_cnt == MS_UNITE && numerator_en)
		numTimeUnite_cnt <= 24'h0;
	else if(numerator_en)
		numTimeUnite_cnt <= numTimeUnite_cnt + 1'b1;
end
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		num_cnt <= 16'h0;
	else if(send_en)
		num_cnt <= num_cnt;
	else if(numTimeUnite_cnt == MS_UNITE && numerator_en)
		num_cnt <= num_cnt + 1'b1;
end

reg [31:0] message_temp;
reg [31:0] message_temp1;
reg send_en_extend;
reg send_en_at_send_clk, send_en_at_send_clk_r;
reg [3:0] send_en_cnt;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		send_en_cnt <= 4'h0;
	else if(send_en_cnt == 4'hF)
		send_en_cnt <= 4'h0;
	else if(send_en_cnt != 4'h0 || send_en)
		send_en_cnt <= send_en_cnt + 1'b1;

end
always @(posedge clk)
begin
	if(send_en_cnt != 4'h0)
		send_en_extend <= 1'b1;
	else 
		send_en_extend <= 1'b0;
end
always @(posedge send_clk)
begin
	send_en_at_send_clk <= send_en_extend;
	send_en_at_send_clk_r <= send_en_at_send_clk;
end
always @(posedge send_clk or negedge rst_n)   
begin
	if(!rst_n)
		message_temp <= 32'h0;
	else if(send_en_at_send_clk_r)
		message_temp <= {num_cnt, dem_cnt};
end 
always @(posedge send_clk)
begin
	message_temp1 <= message_temp;
	message <= message_temp1;
end


    
endmodule
