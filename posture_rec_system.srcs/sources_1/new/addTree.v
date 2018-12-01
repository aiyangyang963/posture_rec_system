`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/15 15:01:34
// Design Name: 
// Module Name: addTree
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


module addTree(
	input	clk,
	input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	data,//the input image data from PARALLEL_NUM dealing channels
	input	valid,//valid signal
	output	reg [`IMAGE_ELE_BITWIDTH*4-1:0] q1,
	output	reg q1_valid,
	output	reg [`IMAGE_ELE_BITWIDTH*2-1:0] q2,
	output	reg q2_valid,
	output	reg [`IMAGE_ELE_BITWIDTH-1:0] q3,
	output	reg q3_valid
    );
 
reg [`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	data_r;
reg valid_r;
wire [`IMAGE_ELE_BITWIDTH-1:0] add_4res [3:0];
wire [3:0] add_4res_valid;
reg [`IMAGE_ELE_BITWIDTH-1:0] add_4res_r [3:0];
reg [3:0] add_4res_valid_r;


always @(posedge clk)
begin
	data_r <= data;
	valid_r <= valid;
end
 
    
    
genvar i;
for(i=0;i<4;i=i+1)begin: add_loop1
	
	float_add_IP_use_DSP_multilatency float_add_IP_mA(
      .aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(valid_r),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(data_r[`IMAGE_ELE_BITWIDTH*(2*i+1)-1:`IMAGE_ELE_BITWIDTH*i*2]),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(valid_r),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(data_r[`IMAGE_ELE_BITWIDTH*(2*i+2)-1:`IMAGE_ELE_BITWIDTH*(2*i+1)]),              // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(add_4res_valid[i]),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(add_4res[i])    // output wire [31 : 0] m_axis_result_tdata
    ); 

	always @(posedge clk)
	begin
		add_4res_r[i] <= add_4res[i];
		add_4res_valid_r[i] <= add_4res_valid[i];
	end	

end    
    

wire [`IMAGE_ELE_BITWIDTH-1:0] add_2res [1:0];
wire [1:0] add_2res_valid;
reg [`IMAGE_ELE_BITWIDTH-1:0] add_2res_r [1:0];
reg [1:0] add_2res_valid_r;   
 
genvar j;
for(j=0;j<2;j=j+1)begin: add_loop2

	float_add_IP_use_DSP_multilatency float_add_IP_mB(
      .aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(add_4res_valid_r[j]),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(add_4res_r[2*j]),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(add_4res_valid_r[j]),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(add_4res_r[2*j+1]),              // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(add_2res_valid[j]),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(add_2res[j])    // output wire [31 : 0] m_axis_result_tdata
    ); 
    
   always @(posedge clk)
   begin
		add_2res_r[j] <= add_2res[j];
		add_2res_valid_r[j] <= add_2res_valid[j];
   end 
    
end    

wire [`IMAGE_ELE_BITWIDTH-1:0] add_1res;
wire add_1res_valid;
reg [`IMAGE_ELE_BITWIDTH-1:0] add_1res_r;
reg add_1res_valid_r;     
float_add_IP_use_DSP_multilatency float_add_IP_mC(
  .aclk(clk),                                  // input wire aclk
  .s_axis_a_tvalid(add_2res_valid_r[0]),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(add_2res_r[0]),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(add_2res_valid_r[1]),            // input wire s_axis_b_tvalid
  .s_axis_b_tdata(add_2res_r[1]),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(add_1res_valid),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(add_1res)    // output wire [31 : 0] m_axis_result_tdata
); 
 
always @(posedge clk)
begin
	add_1res_r <= add_1res;
	add_1res_valid_r <= add_1res_valid;
end 
 

always @(posedge clk)
begin
	q1 <= {add_4res_r[3], add_4res_r[2], add_4res_r[1], add_4res_r[0]};
	q1_valid <= add_4res_valid_r[0];
end
always @(posedge clk)
begin
	q2 <= {add_2res_r[1], add_2res_r[0]};
	q2_valid <= add_2res_valid_r[0];
end    
always @(posedge clk)
begin
	q3 <= add_1res_r;
	q3_valid <= add_1res_valid_r;
end    
endmodule
