`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/13 15:29:49
// Design Name: 
// Module Name: buffer_control_tb
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


module buffer_control_tb(

	input clk,
	input rst_n,
	
	

	output reg load_head_rd,//read head from fifo
	input [`HEAD_WIDTH-1:0]	load_head_rd_q,//output head data to who is reading
	input load_head_empty,//the fifo is empty
	

	output logic load_kernel_rd,//read request
	input [`KERNEL_BITWIDTH*`PARALLEL_NUM-1:0]	load_kernel_rd_q,
	input load_kernel_empty,



	output	logic image_rd_update,//need to update the image ram
	input	image_rd_ready,//the image have been download to ram
	

	output logic load_image_rd,
	output [`IMAGE_SIZE*2:0]	load_image_rd_addr,//{row[7:0],column[7:0]}
	input [`IMAGE_BITWIDTH*`PARALLEL_NUM-1:0]	load_image_rd_q,//all the 24 ram data
	input [`PARALLEL_NUM-1:0]	load_image_valid,//which channel is valid
	
	
	output	logic [`FILTER_NUM-1:0]	filter_num,//equal the ram channels
	output	logic [`IMAGE_SIZE-1:0]	image_size,//image size
	output	logic	[`IMAGE_NUM-1:0]	image_num,
	output	logic infor_update,//head information have been updated
	output	logic image_return_axi,//return image to axi
	output	logic	maxpooling_en,
	
	
	output	deal_PostImage_clk,
	output	logic deal_PostImage_rd,//the postdeal part need to read image
	output	[`IMAGE_SIZE*2-1:0]	deal_PostImage_rd_addr,//{row, column}
	input	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_q,
	input	[`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_valid_channel,
	output	logic deal_PostImage_wr,//write image data to ram
	output	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_wr_data,
	output	logic deal_PostImage_wr_last,//the last write data
	output	[`IMAGE_SIZE*2-1:0]	deal_PostImage_wr_addr,//{row, column}
	output	logic	maxpooling_finish
	
    );
    
    
 
 
 
    
event image_update;    
event image_update_ok;    
    
    
//head control testbench    
initial
begin
    
    
    		load_head_rd	=	1'b0;
    		@(posedge rst_n);
    		@(negedge load_head_empty);
    		repeat(300) @(posedge clk);
    		
    		forever begin
    		
    			while(load_head_empty)begin
    				load_head_rd	=	1'b0;
    				@(posedge clk);
    			end
	
				load_head_rd	=	1'b1;
				@(posedge clk);
				load_head_rd	=	1'b0;
				
				->image_update;
				@image_update_ok;
				
				
    		end//forever
    	
end
    
    
 
    
    
//kernel control testbench


initial
begin

	load_kernel_rd	=	1'b0;
	@(posedge rst_n);
	
	@(posedge clk);
	forever begin
		@(negedge load_kernel_empty);
		@(negedge clk);		
		for(int i=0;i<10;i++)begin
			if(!load_kernel_empty)begin
				load_kernel_rd	=	1'b1;
				@(negedge clk);					 	
			end//if
			else begin
				load_kernel_rd	=	1'b0;
				@(negedge load_kernel_empty);
				@(negedge clk);
			end//else	
		end//for
		
			load_kernel_rd	=	1'b0;
			repeat(300) @(posedge clk);
	
	end//forever



end
    
    
 
    
    




//image read control
logic [`IMAGE_SIZE-1:0] load_image_rd_row_addr;
logic [`IMAGE_SIZE-1:0]	load_image_rd_col_addr;


initial
begin
		image_rd_update=1'b0;
		load_image_rd=1'b0;	
		load_image_rd_col_addr=0;
		load_image_rd_row_addr=0;
		@(posedge rst_n);
		
		forever begin
			@image_update;
			
			image_rd_update=1'b1;
			@(posedge clk);
			image_rd_update=1'b0;
			
			@(posedge image_rd_ready);
			repeat(5) @(posedge clk);
			
			for(int i=0;i<224;i++)begin
				for(int j=0;j<224;j=j+2)begin
					load_image_rd=1'b1;					
					@(posedge clk);
					load_image_rd_col_addr	=	load_image_rd_col_addr + 2;
				end//for
				load_image_rd_row_addr++;
				load_image_rd_col_addr=0;
			end//for
			
			load_image_rd_col_addr=0;
			load_image_rd_row_addr=0;
			load_image_rd=1'b0;	
			@(posedge clk);
			->image_update_ok;
			
		end//forever

end//initial


assign	load_image_rd_addr={1'b0,load_image_rd_row_addr, load_image_rd_col_addr};


//read from image ram and write to axi
reg [`IMAGE_BITWIDTH*`PARALLEL_NUM-1:0]	load_image_rd_q_r, load_image_rd_q_r1,
										load_image_rd_q_r2, load_image_rd_q_r3,
										load_image_rd_q_r4;
logic load_image_valid_or;
reg load_image_valid_or_r, load_image_valid_or_r1, load_image_valid_or_r2,
	load_image_valid_or_r3, load_image_valid_or_r4;
	
logic [`IMAGE_SIZE-1:0]	deal_PostImage_row_rd_addr, deal_PostImage_col_rd_addr;
wire	[`POSTIMAGE_BITWIDTH-1:0]	deal_PostImage_wr_data_temp[`POSTIMAGE_CHANNEL];

assign	load_image_valid_or	=	|load_image_valid;

initial
begin
		deal_PostImage_row_rd_addr	=	`IMAGE_SIZE'h0;
		deal_PostImage_col_rd_addr	=	`IMAGE_SIZE'h0;
		deal_PostImage_rd	=	1'b0;
		
		@(posedge rst_n);
		@(posedge load_image_valid_or);
		 begin
			for(int i=0;i<image_size;i++)begin
				for(int j=0;j<image_size;j=j+2)begin
					if(load_image_valid_or)begin
						deal_PostImage_rd	=	1'b1;						
						@(posedge clk);
						deal_PostImage_col_rd_addr	=	deal_PostImage_col_rd_addr + 2;
					end//if
					else begin
						deal_PostImage_rd	=	1'b0;
						@(posedge load_image_valid_or);
					end
				end//for
				
				deal_PostImage_row_rd_addr++;
				deal_PostImage_col_rd_addr	=0;
			end	//for
			deal_PostImage_row_rd_addr	=	`IMAGE_SIZE'h0;
			deal_PostImage_col_rd_addr	=	`IMAGE_SIZE'h0;			
		end//forever
end



assign	deal_PostImage_rd_addr	=	{deal_PostImage_row_rd_addr, deal_PostImage_col_rd_addr};


always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)begin
			filter_num	<=	`FILTER_NUM'h0;
			image_size	<=	`IMAGE_SIZE'd0;
			image_num	<=	`IMAGE_NUM'h0;
			infor_update	<=	1'b0;
			maxpooling_en	<=	1'b0;
			image_return_axi	<=	1'b0;
		end
		else if(load_head_rd)begin
			filter_num	<=	`FILTER_NUM'h1;
			image_size	<=	`IMAGE_SIZE'd224;
			image_num	<=	`IMAGE_NUM'h1;
			infor_update	<=	1'b1;
			maxpooling_en	<=	1'b0;
			image_return_axi	<=	1'b1;
		end
		else 
			infor_update	<=	1'b0;
end


always @(posedge clk)
begin
		load_image_rd_q_r	<=	load_image_rd_q;
		load_image_rd_q_r1	<=	load_image_rd_q_r;
		load_image_rd_q_r2	<=	load_image_rd_q_r1;
		load_image_rd_q_r3	<=	load_image_rd_q_r2;
		load_image_rd_q_r4	<=	load_image_rd_q_r3;



		load_image_valid_or_r	<=	load_image_valid_or;
		load_image_valid_or_r1	<=	load_image_valid_or_r;
		load_image_valid_or_r2	<=	load_image_valid_or_r1;
		load_image_valid_or_r3	<=	load_image_valid_or_r2;
		load_image_valid_or_r4	<=	load_image_valid_or_r3;

end



logic [`IMAGE_SIZE-1:0]	deal_PostImage_row_wr_addr, deal_PostImage_col_wr_addr;

initial
begin
		deal_PostImage_row_wr_addr	=	`IMAGE_SIZE'h0;
		deal_PostImage_col_wr_addr	=	`IMAGE_SIZE'h0;
		deal_PostImage_wr	=	1'b0;
		deal_PostImage_wr_last	=	1'b0;
		maxpooling_finish	=	1'b0;
		
		@(posedge load_image_valid_or_r4);
		 begin
		
			for(int i=0;i<image_size;i++)begin
				for(int j=0;j<image_size;j=j+2)begin
				
					if(load_image_valid_or_r4)begin
						deal_PostImage_wr	=	1'b1;
						
						if(i==image_size-1 && j==image_size-2)
							deal_PostImage_wr_last	=	1'b1;
							
						@(posedge clk);
						deal_PostImage_col_wr_addr=deal_PostImage_col_wr_addr+2;
					end
					else begin
						deal_PostImage_wr	=	1'b0;
						@(posedge clk);
					end//else
					

				
				end//for
					deal_PostImage_row_wr_addr++;
					deal_PostImage_col_wr_addr=0;
			end//for
			
			deal_PostImage_row_wr_addr	=	`IMAGE_SIZE'h0;
			deal_PostImage_col_wr_addr	=	`IMAGE_SIZE'h0;
			deal_PostImage_wr	=	1'b0;
			deal_PostImage_wr_last	=	1'b0;
			@(posedge clk);
			
			repeat(5) @(posedge clk);
			maxpooling_finish	=	1'b1;
			@(posedge clk);
			maxpooling_finish	=	1'b0;
		end//forever

end//initial


genvar k;
for(k=0;k<`POSTIMAGE_CHANNEL;k=k+1)begin
		assign	deal_PostImage_wr_data_temp[k]	=	deal_PostImage_wr ? 
													deal_PostImage_rd_q[`POSTIMAGE_BITWIDTH*(k+1)-1:`POSTIMAGE_BITWIDTH*k] + 
													load_image_rd_q_r4[`POSTIMAGE_BITWIDTH*(k+1)-1:`POSTIMAGE_BITWIDTH*k] : 0;
end


assign	deal_PostImage_clk	=	clk;
assign	deal_PostImage_wr_data	=	{deal_PostImage_wr_data_temp[7], deal_PostImage_wr_data_temp[6],
									deal_PostImage_wr_data_temp[5], deal_PostImage_wr_data_temp[4],
									deal_PostImage_wr_data_temp[3], deal_PostImage_wr_data_temp[2],
									deal_PostImage_wr_data_temp[1], deal_PostImage_wr_data_temp[0]};
									
assign	deal_PostImage_wr_addr	=	{deal_PostImage_row_wr_addr, deal_PostImage_col_wr_addr};








    
    
    
endmodule


