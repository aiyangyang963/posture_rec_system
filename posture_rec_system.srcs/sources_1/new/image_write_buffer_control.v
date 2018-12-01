`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/27 10:22:37
// Design Name: 
// Module Name: image_write_buffer_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: control the read and write of ram wchich holds the dealt image
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module image_write_buffer_control(
	clk,
	debug_clk,
	rst_n,
	
	image_wr_need,
	
	filter_num,
	image_size,
	infor_update,
	image_return_axi,
	maxpooling_en,

	
	image_rd_req,
	image_rd_pre,
	image_rd_finish,
	image_rd_empty,
	image_rd_data,
	
	deal_PostImage_clk,
	deal_PostImage_rd,
	deal_PostImage_rd_addr,
	deal_PostImage_rd_q,
	deal_PostImage_rd_valid_channel,
	deal_PostImage_wr,
	deal_PostImage_wr_data,
	deal_PostImage_wr_last,
	deal_PostImage_wr_addr,
	maxpooling_finish

    );
    
/////////////////////////////////inputs and outputs/////////////////////////////////////////
input	clk;
input	debug_clk;
input	rst_n;

output	reg	image_wr_need;//maxpooling is done and can write to axi

input	[`FILTER_NUM-1:0]	filter_num;//equal the ram channels
input	[`IMAGE_SIZE-1:0]	image_size;//image size
input	infor_update;//head information have been updated
input	image_return_axi;//whether operate maxpooling
input	maxpooling_en;//enbale maxpooling at this operation



input	image_rd_req;//request to read from image ram
input	image_rd_pre;//preread image to FIFO and be ready for axi reading image
(*DONT_TOUCH="TRUE"*)input	image_rd_finish;
output	image_rd_empty;
output	[`IMAGE_BITWIDTH-1:0]	image_rd_data;//from fifo which is read from ram with 16 bit width

input	deal_PostImage_clk;
input	deal_PostImage_rd;//the postdeal part need to read image
input	[`IMAGE_SIZE*2-1:0]	deal_PostImage_rd_addr;//{row, column}
output	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_q;
output	reg	[`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_valid_channel;
input	deal_PostImage_wr;//write image data to ram
input	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_wr_data;
input	deal_PostImage_wr_last;//the last write data
input	[`IMAGE_SIZE*2-1:0]	deal_PostImage_wr_addr;//{row, column}
input	maxpooling_finish;

//////////////////////////////////////////////////////////////////////////////////////////    




///////////////////////////////image_rd_finish cross clock domain//////////////////////////
reg	image_rd_finish_r1, image_rd_finish_r2;


always @(posedge deal_PostImage_clk)
begin
		image_rd_finish_r1	<=	image_rd_finish;
		image_rd_finish_r2	<=	image_rd_finish_r1;
end


///////////////////////////////////////////////////////////////////////////////////////////


    
//////////////////////////////////image ram instantiate//////////////////////////////////
wire	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	ram_rd_q;
wire	[`POSTIMAGE_CHANNEL-1:0]	ram_ena;
wire	[`POSTIMAGE_RAMDEPTH_WIDTH-1:0]	ram_wr_addr;
wire	[`POSTIMAGE_RAMDEPTH_WIDTH-1:0]	ram_rd_addr;
wire	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	ram_wr_data;



genvar	i;
for(i=0;i<`POSTIMAGE_CHANNEL;i=i+1)begin : post_image_ram_loop
	
	post_image_ram post_image_ram_m1 (
	  .clka(deal_PostImage_clk),    // input wire clka
	  .wea(ram_ena[i]),      // input wire [0 : 0] wea
	  .addra(ram_wr_addr),  // input wire [11 : 0] addra
	  .dina(ram_wr_data[`POSTIMAGE_BITWIDTH*(i+1)-1:`POSTIMAGE_BITWIDTH*i]),    // input wire [63 : 0] dina
	  .clkb(deal_PostImage_clk),    // input wire clkb
	  .addrb(ram_rd_addr),  // input wire [11 : 0] addrb
	  .doutb(ram_rd_q[`POSTIMAGE_BITWIDTH*(i+1)-1:`POSTIMAGE_BITWIDTH*i])  // output wire [63 : 0] doutb
	);

end


/////////////////////////////////////////////////////////////////////////////////////////   
    
    
 

 
 
 
 
/////////////////////////////////////axi preread fifo///////////////////////////////////////
wire	image_prerd_toaxi_fifo_full;
wire	[`POSTIMAGE_BITWIDTH-1:0]	ramtofifo_data;
reg		fifo_wr;
wire	image_prerd_toaxi_fifo_prog_full;
reg		image_prerd_toaxi_fifo_rst = 1'b0;
reg		[2:0] image_prerd_toaxi_fifo_rst_cnt = 3'h0;

always @(posedge clk)
begin
	if(image_rd_finish)
		image_prerd_toaxi_fifo_rst_cnt <= image_prerd_toaxi_fifo_rst_cnt + 1'b1;
	else if(image_prerd_toaxi_fifo_rst_cnt != 3'h0)
		image_prerd_toaxi_fifo_rst_cnt <= image_prerd_toaxi_fifo_rst_cnt + 1'b1;
end
always @(posedge clk)
begin
	if(image_prerd_toaxi_fifo_rst_cnt != 3'h0)
		image_prerd_toaxi_fifo_rst <= 1'b1;
	else
		image_prerd_toaxi_fifo_rst <= 1'b0;
end
image_prerd_toaxi_fifo image_prerd_toaxi_fifo_m (
  .rst(image_prerd_toaxi_fifo_rst),  
  .wr_clk(deal_PostImage_clk),        // input wire wr_clk
  .rd_clk(clk),        // input wire rd_clk
  .din(ramtofifo_data),              // input wire [63 : 0] din
  .wr_en(fifo_wr),          // input wire wr_en
  .rd_en(image_rd_req),          // input wire rd_en
  .dout(image_rd_data),            // output wire [63 : 0] dout
  .full(image_prerd_toaxi_fifo_full),            // output wire full
  .empty(image_rd_empty),          // output wire empty
  .prog_full(image_prerd_toaxi_fifo_prog_full)  // output wire prog_full
);
///////////////////////////////////////////////////////////////////////////////////////// 
 
    
//////////////////////////////////define a register for reading data///////////////////////    
reg	image_fifo_pre_read;//register for preread request
reg	image_fifo_pre_read_reg1, image_fifo_pre_read_reg2;//2 register for cross clock from clk to deal_PostImage_clk

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			image_fifo_pre_read	<=	1'b0;
		else if(image_rd_finish)//when the last image data have been read from ram, clear
			image_fifo_pre_read	<=	1'b0;
		else if(image_rd_pre)//set to 1 to begin to read from ram
			image_fifo_pre_read	<=	1'b1;
end  
   
   
always @(posedge deal_PostImage_clk)
begin
		image_fifo_pre_read_reg1	<=	image_fifo_pre_read;
		image_fifo_pre_read_reg2	<=	image_fifo_pre_read_reg1;
end
    
////////////////////////////////////////////////////////////////////////////////////////////    
 
 
 
///////////////////////////////////////counter for each RAM//////////////////////////////
//define counter for each ram to indicate the data number stored in ram
(*DONT_TOUCH="TRUE"*)reg	[`POSTIMAGE_RAMDEPTH_WIDTH:0]	ramdata_cnt[`POSTIMAGE_CHANNEL-1:0];



genvar t;
for(t=0;t<`POSTIMAGE_CHANNEL;t=t+1)begin : ramdata_cnt_loop
	always @(posedge deal_PostImage_clk or negedge rst_n)
	begin
		if(!rst_n)
			ramdata_cnt[t]	<=	'h0;
		else if(image_rd_finish_r2)
			ramdata_cnt[t]	<=	'h0;
		else if(ram_ena[t] && image_return_axi)
			ramdata_cnt[t]	<=	ramdata_cnt[t] + 1'b1;
		
	end
end





///////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
 
 
    
/////////////////////////////////axi read from ram address/////////////////////////////////
wire	[`IMAGE_RAM_ADDR_WIDTH-1:0]	axi_rd_ram_addr;//axi read from ram 
wire	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	ram_channel_no;//ram number from 0 to 15
wire	clc;
wire	clc_low;
wire	[`POSTIMAGE_CHANNEL-1:0]	clc_array;
wire [`POSTIMAGE_CHANNEL_BITWIDTH-1:0] k[`POSTIMAGE_CHANNEL-1:0];



//define 16 number indicate the 16 channels
assign k[0]	=	`POSTIMAGE_CHANNEL_BITWIDTH'd0;
assign k[1]	=	`POSTIMAGE_CHANNEL_BITWIDTH'd1;
assign k[2]	=	`POSTIMAGE_CHANNEL_BITWIDTH'd2;
assign k[3]	=	`POSTIMAGE_CHANNEL_BITWIDTH'd3;
assign k[4]	=	`POSTIMAGE_CHANNEL_BITWIDTH'd4;
assign k[5]	=	`POSTIMAGE_CHANNEL_BITWIDTH'd5;
assign k[6]	=	`POSTIMAGE_CHANNEL_BITWIDTH'd6;
assign k[7]	=	`POSTIMAGE_CHANNEL_BITWIDTH'd7;





axi_read_image_cnt axi_read_image_cnt_m1(
	.clk(deal_PostImage_clk),
	.rst_n(rst_n),
	.en(image_fifo_pre_read_reg2 && !image_prerd_toaxi_fifo_prog_full),
	.clc(clc),
	.clc_low(clc_low),
	.result_high(ram_channel_no),
	.result_low(axi_rd_ram_addr)
	

);



genvar	j;
for(j=0;j<`POSTIMAGE_CHANNEL;j=j+1)begin : clc_array_loop
	assign	clc_array[j]	=	(ram_channel_no == k[j] &&
								 axi_rd_ram_addr == ramdata_cnt[j] - 1'b1
								 && (image_fifo_pre_read_reg2 && !image_prerd_toaxi_fifo_prog_full)) ? 1'b1 : 1'b0;
end	

assign	clc_low	=	|clc_array;//reach any channel capacity which is record by its counter, then clear the address counter
assign	clc	=	image_rd_finish_r2;




/////////////////////////////////////////////////////////////////////////////////////////// 



///////////////////////////axi read ram request choose/////////////////////////////////////////////
wire	[`POSTIMAGE_CHANNEL-1:0]	axi_ram_rd;


genvar l;
for(l=0;l<`POSTIMAGE_CHANNEL;l=l+1)begin : axi_ram_rd_loop
	assign	axi_ram_rd[l]	=	(ram_channel_no == k[l]) ? image_fifo_pre_read_reg2 && !image_prerd_toaxi_fifo_prog_full : 1'b0;
end


/////////////////////////////////////////////////////////////////////////////////////////////////////
 
 
 
/////////////////////////axi read from ram data choose//////////////////////////////////////////////
wire	fifo_wr_temp;
reg	fifo_wr_temp1, fifo_wr_temp2;
reg	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	ram_channel_no_r, ram_channel_no_r1;


always @(posedge deal_PostImage_clk)
begin
		ram_channel_no_r	<=	ram_channel_no;
		ram_channel_no_r1	<=	ram_channel_no_r;
end

mux_ramtofifo_data mux_ramtofifo_data_m1(
	.clk(deal_PostImage_clk),
	.number(ram_channel_no_r1),
	.data(ram_rd_q),
	.q(ramtofifo_data)

);


assign	fifo_wr_temp	=	|axi_ram_rd;
always @(posedge deal_PostImage_clk)
begin
		fifo_wr_temp1	<=	fifo_wr_temp;
		fifo_wr_temp2	<=	fifo_wr_temp1;
		fifo_wr		<=	fifo_wr_temp2;
end

/////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
/////////////////////////////////generate the need to write to axi/////////////////////////////////
reg	image_wr_need_temp, image_wr_need_temp1, image_wr_need_temp2;


always @(posedge deal_PostImage_clk or negedge rst_n)
begin
		if(!rst_n)
			image_wr_need_temp	<=	1'b0;
		else if(maxpooling_finish && image_return_axi)
			image_wr_need_temp	<=	1'b1;
		else if(image_rd_finish_r2)
			image_wr_need_temp	<=	1'b0;
end

//cross clock domain
always @(posedge clk)
begin
		image_wr_need_temp1	<=	image_wr_need_temp;
		image_wr_need_temp2	<=	image_wr_need_temp1;
		image_wr_need	<=	image_wr_need_temp2;
end
/////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 

 
 
///////////////////////////////////write and read image size//////////////////////////////////////////////
reg	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	oneImage_occupy_ram_wr_num;//number of rams one image occupies
reg	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	oneImage_occupy_ram_rd_num;//number of rams one image occupies
wire	[`IMAGE_SIZE*2-1:0]	image_size_multi;
reg	infor_update_r, infor_update_r1, infor_update_r2;






always @(posedge deal_PostImage_clk)
begin
		infor_update_r	<=	infor_update;
		infor_update_r1	<=	infor_update_r;
		infor_update_r2	<=	infor_update_r1;
end


assign	image_size_multi	=	image_size*image_size;


always @(posedge deal_PostImage_clk)
begin
		if(infor_update)
			if(maxpooling_en)
				oneImage_occupy_ram_wr_num	<=	image_size_multi[`IMAGE_SIZE*2-1:`POSTIMAGE_RAMDEPTH_WIDTH+3];
			else
				oneImage_occupy_ram_wr_num	<=	image_size_multi[`IMAGE_SIZE*2-1:`POSTIMAGE_RAMDEPTH_WIDTH+1];
end


always @(posedge deal_PostImage_clk)
begin
		if(infor_update_r)
			oneImage_occupy_ram_rd_num	<=	oneImage_occupy_ram_wr_num;
end



/////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 

///////////////////////////////////////read and write address decode from post_image part/////////////
wire	[`POSTIMAGE_RAMDEPTH_WIDTH-1:0]	PostImage_rd_addr;//the decoded address from post_image part
wire	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	PostImage_rd_location_in_filter;//if one image is greater than
																				//one ram, they should be stored in
																				//next ram. this signal indicate which
																				//ram of channel.




image_ram_multi_addr image_ram_multi_addr_m1(
	.size(image_size),
	.multi1(deal_PostImage_rd_addr[`IMAGE_SIZE-1:0]),
	.multi2(deal_PostImage_rd_addr[`IMAGE_SIZE*2-1:`IMAGE_SIZE]),
	.result({PostImage_rd_location_in_filter, PostImage_rd_addr})
);


///////////////////////////////////////////////////////////////////////////////////////////////////////// 


 
 
///////////////////////////////////////image ram channel choose/////////////////////////////////////////
wire	[`POSTIMAGE_CHANNEL-1:0]	channel_choose_rd_start;//the start channel flag for read and write
reg	[`POSTIMAGE_CHANNEL-1:0]	channel_choose_rd_valid;
reg	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	PostImage_rd_location_in_filter_r;
reg	PostImage_rd_location_in_filter_change, PostImage_rd_location_in_filter_change_r;
wire	PostImage_rd_location_in_filter_change_edge;
reg		PostImage_rd_location_in_filter_change_edge_mask;

reg	deal_PostImage_wr_last_r, deal_PostImage_wr_last_r1, deal_PostImage_wr_last_r2;






postImage_channel_choose postImage_channel_choose_RD(
	.clk(deal_PostImage_clk),
	.num1(oneImage_occupy_ram_rd_num),
	.num2(filter_num[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]),
	.channel(channel_choose_rd_start)
);




always @(posedge deal_PostImage_clk)
begin
		deal_PostImage_wr_last_r	<=	deal_PostImage_wr_last;
		deal_PostImage_wr_last_r1	<=	deal_PostImage_wr_last_r;
		deal_PostImage_wr_last_r2	<=	deal_PostImage_wr_last_r1;
end



always @(posedge deal_PostImage_clk)
begin	
		PostImage_rd_location_in_filter_r	<=	PostImage_rd_location_in_filter;
end





always @(posedge deal_PostImage_clk or negedge rst_n)
begin
		if(!rst_n)
			PostImage_rd_location_in_filter_change	<=	1'b0;
		else if(deal_PostImage_wr_last_r2)
			PostImage_rd_location_in_filter_change	<=	1'b0;
		else if(PostImage_rd_location_in_filter_r != PostImage_rd_location_in_filter)
			PostImage_rd_location_in_filter_change	<=	~PostImage_rd_location_in_filter_change;
end


always @(posedge deal_PostImage_clk)
begin
		PostImage_rd_location_in_filter_change_r	<=	PostImage_rd_location_in_filter_change;
end


assign	PostImage_rd_location_in_filter_change_edge	=	(PostImage_rd_location_in_filter_change && !PostImage_rd_location_in_filter_change_r)
															|| (!PostImage_rd_location_in_filter_change && PostImage_rd_location_in_filter_change_r);




always @(posedge deal_PostImage_clk)
begin
		if((PostImage_rd_location_in_filter == 'h0 && PostImage_rd_location_in_filter_r != 'h0) || deal_PostImage_wr_last_r2)
			PostImage_rd_location_in_filter_change_edge_mask	<=	1'b1;
		else
			PostImage_rd_location_in_filter_change_edge_mask	<=	1'b0;
			
end



always @(posedge deal_PostImage_clk)
begin
		if(infor_update_r1)
			channel_choose_rd_valid	<=	channel_choose_rd_start;
		else if(PostImage_rd_location_in_filter_change_edge && !PostImage_rd_location_in_filter_change_edge_mask)
			channel_choose_rd_valid	<=	channel_choose_rd_valid << 1;
end

/////////////////////////////////////////////////////////////////////////////////////////////////////

 


//////////////////////////////////////read data from ram to cal_image/////////////////////////////////
reg	deal_PostImage_rd_r, deal_PostImage_rd_r1, deal_PostImage_rd_r2, deal_PostImage_rd_r3;



always @(posedge deal_PostImage_clk)
begin
		deal_PostImage_rd_r	<=	deal_PostImage_rd;
		deal_PostImage_rd_r1	<=	deal_PostImage_rd_r;
		deal_PostImage_rd_r2	<=	deal_PostImage_rd_r1;
		deal_PostImage_rd_r3	<=	deal_PostImage_rd_r2;
end



 
 
always @(posedge deal_PostImage_clk) 
begin
		case(filter_num[`POSTIMAGE_CHANNEL_BITWIDTH-1:0])
		`POSTIMAGE_CHANNEL_BITWIDTH'd1:begin
			deal_PostImage_rd_valid_channel[0]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[1]	<=	1'b0;
			deal_PostImage_rd_valid_channel[2]	<=	1'b0;
			deal_PostImage_rd_valid_channel[3]	<=	1'b0;
			deal_PostImage_rd_valid_channel[4]	<=	1'b0;
			deal_PostImage_rd_valid_channel[5]	<=	1'b0;
			deal_PostImage_rd_valid_channel[6]	<=	1'b0;
			deal_PostImage_rd_valid_channel[7]	<=	1'b0;
		end
		`POSTIMAGE_CHANNEL_BITWIDTH'd2:begin
			deal_PostImage_rd_valid_channel[0]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[1]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[2]	<=	1'b0;
			deal_PostImage_rd_valid_channel[3]	<=	1'b0;
			deal_PostImage_rd_valid_channel[4]	<=	1'b0;
			deal_PostImage_rd_valid_channel[5]	<=	1'b0;
			deal_PostImage_rd_valid_channel[6]	<=	1'b0;
			deal_PostImage_rd_valid_channel[7]	<=	1'b0;
		end
		`POSTIMAGE_CHANNEL_BITWIDTH'd3:begin
			deal_PostImage_rd_valid_channel[0]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[1]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[2]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[3]	<=	1'b0;
			deal_PostImage_rd_valid_channel[4]	<=	1'b0;
			deal_PostImage_rd_valid_channel[5]	<=	1'b0;
			deal_PostImage_rd_valid_channel[6]	<=	1'b0;
			deal_PostImage_rd_valid_channel[7]	<=	1'b0;
		end	
		`POSTIMAGE_CHANNEL_BITWIDTH'd4:begin
			deal_PostImage_rd_valid_channel[0]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[1]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[2]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[3]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[4]	<=	1'b0;
			deal_PostImage_rd_valid_channel[5]	<=	1'b0;
			deal_PostImage_rd_valid_channel[6]	<=	1'b0;
			deal_PostImage_rd_valid_channel[7]	<=	1'b0;
		end	
		`POSTIMAGE_CHANNEL_BITWIDTH'd5:begin
			deal_PostImage_rd_valid_channel[0]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[1]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[2]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[3]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[4]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[5]	<=	1'b0;
			deal_PostImage_rd_valid_channel[6]	<=	1'b0;
			deal_PostImage_rd_valid_channel[7]	<=	1'b0;
		end	
		`POSTIMAGE_CHANNEL_BITWIDTH'd6:begin
			deal_PostImage_rd_valid_channel[0]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[1]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[2]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[3]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[4]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[5]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[6]	<=	1'b0;
			deal_PostImage_rd_valid_channel[7]	<=	1'b0;
		end	
		`POSTIMAGE_CHANNEL_BITWIDTH'd7:begin
			deal_PostImage_rd_valid_channel[0]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[1]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[2]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[3]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[4]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[5]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[6]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[7]	<=	1'b0;
		end	
		`POSTIMAGE_CHANNEL_BITWIDTH'd8:begin
			deal_PostImage_rd_valid_channel[0]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[1]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[2]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[3]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[4]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[5]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[6]	<=	deal_PostImage_rd_r3;
			deal_PostImage_rd_valid_channel[7]	<=	deal_PostImage_rd_r3;
		end	
		endcase

end

 
 
//////////////////////////////////////////////////////////////////////////////////////////////////////
 
 
////////////////////////////////////read data from ram to dealPost///////////////////////////////////
reg	[`POSTIMAGE_CHANNEL-1:0]	channel_choose_rd_valid_r, channel_choose_rd_valid_r1;
wire	[`POSTIMAGE_CHANNEL-1:0]	post_ram_rd_req;


always @(posedge deal_PostImage_clk)
begin
		channel_choose_rd_valid_r	<=	channel_choose_rd_valid;
		channel_choose_rd_valid_r1	<=	channel_choose_rd_valid_r;
end



ram_to_post_virtual_path ram_to_post_virtual_path_m1(
	.clk(deal_PostImage_clk),
	.data(ram_rd_q),
	.choose(channel_choose_rd_valid_r1),
	.q(deal_PostImage_rd_q)

);



assign		post_ram_rd_req	=	channel_choose_rd_valid & {`POSTIMAGE_CHANNEL{deal_PostImage_rd_r1}};


////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
 
 
 
 
 
/////////////////////////////////////write to ram from postImage//////////////////////////////////////
wire	[`POSTIMAGE_RAMDEPTH_WIDTH-1:0]	PostImage_wr_addr;//the decoded address from post_image part
wire	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	PostImage_wr_location_in_filter;//if one image is greater than
																				//one ram, they should be stored in
																				//next ram. this signal indicate which
																				//ram of channel.

wire	[`POSTIMAGE_CHANNEL-1:0]	channel_choose_wr_start;//the start channel flag for read and write
reg	[`POSTIMAGE_CHANNEL-1:0]	channel_choose_wr_valid;
reg	[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]	PostImage_wr_location_in_filter_r;
reg		PostImage_wr_location_in_filter_change_edge_mask;
reg	PostImage_wr_location_in_filter_change, PostImage_wr_location_in_filter_change_r;
wire	PostImage_wr_location_in_filter_change_edge;

reg	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_wr_data_r, deal_PostImage_wr_data_r1;

reg [`IMAGE_SIZE-1:0] or_maxpooling_image_size;

always @(posedge clk)
begin
	if(maxpooling_en)
		or_maxpooling_image_size <= image_size[`IMAGE_SIZE-1:1];
	else
		or_maxpooling_image_size <= image_size;
end


image_ram_multi_addr image_ram_multi_addr_m2(
	.size(or_maxpooling_image_size),
	.multi1(deal_PostImage_wr_addr[`IMAGE_SIZE-1:0]),
	.multi2(deal_PostImage_wr_addr[`IMAGE_SIZE*2-1:`IMAGE_SIZE]),
	.result({PostImage_wr_location_in_filter, PostImage_wr_addr})
);



postImage_channel_choose postImage_channel_choose_WR(
	.clk(deal_PostImage_clk),
	.num1(oneImage_occupy_ram_wr_num),
	.num2(filter_num[`POSTIMAGE_CHANNEL_BITWIDTH-1:0]),
	.channel(channel_choose_wr_start)
);








always @(posedge deal_PostImage_clk)
begin	
		PostImage_wr_location_in_filter_r	<=	PostImage_wr_location_in_filter;
end





always @(posedge deal_PostImage_clk or negedge rst_n)
begin
		if(!rst_n)
			PostImage_wr_location_in_filter_change	<=	1'b0;
		else if(deal_PostImage_wr_last_r2)
			PostImage_wr_location_in_filter_change	<=	1'b0;
		else if(PostImage_wr_location_in_filter_r != PostImage_wr_location_in_filter)
			PostImage_wr_location_in_filter_change	<=	~PostImage_wr_location_in_filter_change;
end


always @(posedge deal_PostImage_clk)
begin
		PostImage_wr_location_in_filter_change_r	<=	PostImage_wr_location_in_filter_change;
end


assign	PostImage_wr_location_in_filter_change_edge	=	(PostImage_wr_location_in_filter_change && !PostImage_wr_location_in_filter_change_r)
															|| (!PostImage_wr_location_in_filter_change && PostImage_wr_location_in_filter_change_r);




always @(posedge deal_PostImage_clk)
begin
		if((PostImage_wr_location_in_filter == 'h0 && PostImage_wr_location_in_filter_r != 'h0) || deal_PostImage_wr_last_r2)
			PostImage_wr_location_in_filter_change_edge_mask	<=	1'b1;
		else
			PostImage_wr_location_in_filter_change_edge_mask	<=	1'b0;
			
end



always @(posedge deal_PostImage_clk)
begin
		deal_PostImage_wr_data_r	<=	deal_PostImage_wr_data;
		deal_PostImage_wr_data_r1	<=	deal_PostImage_wr_data_r;
end





always @(posedge deal_PostImage_clk)
begin
		if(infor_update_r2)
			channel_choose_wr_valid	<=	channel_choose_wr_start;
		else if(PostImage_wr_location_in_filter_change_edge && !PostImage_wr_location_in_filter_change_edge_mask)
			channel_choose_wr_valid	<=	channel_choose_wr_valid << 1;
end



post_to_ram_virtual_path post_to_ram_virtual_path_m1(
	.clk(deal_PostImage_clk),
	.data(deal_PostImage_wr_data_r1),
	.choose(channel_choose_wr_valid),
	.q(ram_wr_data)
	

);
///////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
 
////////////////////////////////write request to ram, post_image////////////////////////////// 
reg	deal_PostImage_wr_r, deal_PostImage_wr_r1;
reg	[`POSTIMAGE_CHANNEL-1:0]	post_ram_wr_req;


always @(posedge deal_PostImage_clk)
begin
		deal_PostImage_wr_r	<=	deal_PostImage_wr;
		deal_PostImage_wr_r1	<=	deal_PostImage_wr_r;
end

always @(posedge deal_PostImage_clk)
begin
		post_ram_wr_req	<=	channel_choose_wr_valid & {`POSTIMAGE_CHANNEL{deal_PostImage_wr_r1}};
end
		

	



///////////////////////////////////////////////////////////////////////////////////////////////////////  
 
 
 
 
////////////////////////////////////////////read request from axi and post-image choose/////////////////
reg		[`POSTIMAGE_RAMDEPTH_WIDTH-1:0]	PostImage_rd_addr_r, PostImage_rd_addr_r1;
reg		[`POSTIMAGE_RAMDEPTH_WIDTH-1:0]	PostImage_wr_addr_r, PostImage_wr_addr_r1, PostImage_wr_addr_r2;

always @(posedge deal_PostImage_clk)
begin
		PostImage_rd_addr_r	<=	PostImage_rd_addr;
		PostImage_rd_addr_r1	<=	PostImage_rd_addr_r;
end


always @(posedge deal_PostImage_clk)
begin
		PostImage_wr_addr_r	<=	PostImage_wr_addr;
		PostImage_wr_addr_r1	<=	PostImage_wr_addr_r;
		PostImage_wr_addr_r2	<=	PostImage_wr_addr_r1;
end




assign	ram_rd_addr	=	(|axi_ram_rd) ? axi_rd_ram_addr :
						(|post_ram_rd_req) ? PostImage_rd_addr_r1 : `POSTIMAGE_CHANNEL_BITWIDTH'h0;


assign	ram_ena	=	post_ram_wr_req;
assign	ram_wr_addr	=	PostImage_wr_addr_r2;
////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 
 
 
 

 
 
    
    
endmodule




