`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/10/02 12:38:39
// Design Name: 
// Module Name: maxpooling_tb
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
class image_generate;
	logic[31:0] image_data_queue[$];
	int queue_size;
	logic[31:0] into_queue_data;
	
	function new(int queue_size_in);
	
		queue_size = queue_size_in;
	
	endfunction: new


	function void gen();//generate the image data
		shortreal a=0;
	
		for(int i=0;i<queue_size;i++)begin
			into_queue_data = real_to_int(a+0.3);
			image_data_queue.push_back(into_queue_data);
			
			into_queue_data = real_to_int(a+0.5);
			image_data_queue.push_back(into_queue_data);
			
			into_queue_data = real_to_int(a+0.7);
			image_data_queue.push_back(into_queue_data);
			
			into_queue_data = real_to_int(a+1);
			image_data_queue.push_back(into_queue_data);
			a++;
		end
		
		
	endfunction
	
	
	function logic[31:0] real_to_int(shortreal data);
	
		bit signbit;
		logic[7:0] exp;
		logic[22:0] tail;
		logic[31:0] result;
		
		shortreal unsigned_data;
		byte signed exp_real;
		
		
		if(data>=0)
			signbit = 0;
		else
		    signbit = 1;
		    
		if(data>=0)  
			unsigned_data = data;
		else
			unsigned_data = -data;  
		    
		exp_real = 0;
		if(unsigned_data>1)begin
			while(unsigned_data>=2)begin
				unsigned_data = unsigned_data/2;
				exp_real++;
			end//while
		end
		else begin
			while(unsigned_data<1)begin
				unsigned_data = unsigned_data*2;
				exp_real--;
			end//while
		end
		
		exp = exp_real + 127;
		unsigned_data = unsigned_data - 1;
		
		tail = 23'h0;
		for(int i=0;i<23;i++)begin
			unsigned_data = unsigned_data*2;

			if(unsigned_data>=1)begin
				tail[22-i] = 1;
				unsigned_data--;
			end
			else
				tail[22-i] = 0;
			
		end
	
		result = {signbit,exp,tail};
		
		//$display("data is: %f %d %d %h\n",data, exp_real, tail, result);
		
		
		return result;
		
	endfunction

endclass



module maxpooling_tb(
	input clk,
	input rst_n,
	
	output logic maxpooling_flag,
	output logic[`IMAGE_SIZE-1:0] image_size,
	
	output logic[`IMAGE_ELE_BITWIDTH-1:0] image_data,
	output logic image_valid,
	
	input [`POSTIMAGE_BITWIDTH-1:0] image_q,
	input image_q_valid,
	
	input maxpooling_finish


);




maxpooling_tb_pro maxpooling_tb_pro_m1(

	.clk(clk),
	.rst_n(rst_n),
	
	.maxpooling_flag(maxpooling_flag),
	.image_size(image_size),
	.image_data(image_data),	
	.image_valid(image_valid),
	
	.image_q(image_q),
	.image_q_valid(image_q_valid),
	.maxpooling_finish(maxpooling_finish)
);




endmodule




//program
program maxpooling_tb_pro(
	input clk,
	input rst_n,
	
	output logic maxpooling_flag,
	output logic[`IMAGE_SIZE-1:0] image_size,
	
	output logic[`IMAGE_ELE_BITWIDTH-1:0] image_data,
	output logic image_valid,
	
	input [`POSTIMAGE_BITWIDTH-1:0] image_q,
	input image_q_valid,
	
	input maxpooling_finish
    );
    
    

    
    





image_generate image_generate_ins;
int N;

initial begin

	image_size = `IMAGE_SIZE'd0;
	maxpooling_flag = 1'b0;
	
	image_data = `IMAGE_ELE_BITWIDTH'h0;
	image_valid = 1'b0;
	
	@(posedge rst_n);
	
	repeat(10) @(posedge clk);
	image_size = `IMAGE_SIZE'd224;
	maxpooling_flag = 1'b0;
	
	begin: send_data
		N = image_size*image_size/4;
		image_generate_ins = new(N);
		image_generate_ins.gen();
		
		for(int i=0;i<image_generate_ins.image_data_queue.size();i++)begin
			@(posedge clk);
			image_data = image_generate_ins.image_data_queue[i];			
			image_valid = 1'b1;
			
		end//for
		@(posedge clk);
		image_data = `IMAGE_ELE_BITWIDTH'h0;
		image_valid = 1'b0;
	
	end//send_data
	
	
end//initial



int h;
initial begin
	h=0;
	forever begin: recieve_data
		@(posedge clk);
		if(image_q_valid)begin
			h++;
			assert(image_q[`IMAGE_ELE_BITWIDTH-1:0] == h)			
			else
				$error("result of mapooling is wrong, the data is: %d,%d",image_q[`IMAGE_ELE_BITWIDTH-1:0],image_q[`IMAGE_ELE_BITWIDTH*2-1:`IMAGE_ELE_BITWIDTH]);
		end//if
		h++;	
	
	end//forever

end//initial
    
    
    
    
endprogram


















