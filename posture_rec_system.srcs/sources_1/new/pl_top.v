`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/01 23:09:18
// Design Name: 
// Module Name: top
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


module pl_top(
		global_clk,
		rst_n,
		soft_rst_n,
		axi_clk,
		
		awid,
		awaddr,
		awlen,
		awsize,
		awburst,
		awlock,
		awcache,
		awprot,
		awqos,
		awregion,
		awvalid,
		awready,
		
		wdata,
		wstrb,
		wlast,
		wvalid,
		wready,
		
		bid,
		bresp,
		bvalid,
		bready,
		
		arid,
		araddr,
		arlen,
		arsize,
		arburst,
		arlock,
		arcache,
		arprot,
		arqos,
		arregion,
		arvalid,
		arready,
		
		rid,
		rdata,
		rresp,
		rlast,
		rvalid,
		rready,

		err_out,
		locked_out,
		
		image_begin_inter,
		image_finish_inter,
		pl_message,
		one_layer_finish,
		one_layer_finish_int




    );
    
input							   global_clk;    
input							   rst_n;//global reset
output  						   soft_rst_n;
input							   axi_clk;

output  [5:0]       			   awid;//ID for write-address
output  [`AXI_ADDR_WIDTH-1:0]      awaddr;//write address
output  [7:0]       			   awlen;//length of one burst write
output  [2:0]                      awsize;//burst size£º1£¬2£¬4£¬8£¬16£¬32£¬64£¬128
output  [1:0]                      awburst;//burst type
output                             awlock;//atomic access signaling
output  [3:0]                      awcache;//cache type
output  [2:0]                      awprot;//protection type
output  [3:0]                      awqos;//quality of service
output  [3:0]                      awregion;//region identifier
output                             awvalid;//the valid signal
input                              awready;//the write address is ready

output  [`AXI_DATA_WIDTH-1:0]      wdata;//write data
output  [`AXI_VALID_BYTE-1:0]  	   wstrb;//indicate which byte lanes hold valid data. one strobe bit for each 8 bits
output                             wlast;//the last transfer in one burst write
output                             wvalid;//indicate that the data and strobe is valid
input                              wready;//indicate that the slave have recieved the data


input   [5:0]                      bid;//responce ID tag
input   [1:0]                      bresp;//write responce
input                              bvalid;//the response data is valid
output                             bready;//ready to recieve the write response

output  [5:0]                      arid;//identification tag for the read address group of signals
output  [`AXI_ADDR_WIDTH-1:0]      araddr;//read address
output  [7:0]                      arlen;//burst length
output  [2:0]                      arsize;//burst size
output  [1:0]                      arburst;//burst type
output                             arlock;//lock type
output  [3:0]                      arcache;//how transactions acess the memory system
output  [2:0]                      arprot;//protect type
output  [3:0]                      arqos;//quality of service
output  [3:0]                      arregion;//permits a single physical interface on a slave to be used 
output                             arvalid;//the read address is valid
input                              arready;//the read address is acceptied

input   [5:0]                      rid;//read ID tag
input   [`AXI_DATA_WIDTH-1:0]      rdata;//read data
input   [1:0]                      rresp;//read response
input                              rlast;//the last read data
input                              rvalid;//indicate that the read data is valid
output                             rready;//the read data is accepted

output 							   err_out;//the AXI communication error    
output							   locked_out;//pll locked


input	image_begin_inter;//the image have been sampled and stored in ddr
output	image_finish_inter;//all the images are dealt and give an interrupt to ps
output [31:0] pl_message;   
output one_layer_finish_int;    


//axi_interface_control with buffer_control
wire 	 						   buffer_wr_req;//write request to buffer
wire 	[`AXI_DATA_WIDTH-1:0]  	   buffer_wr_data;//write data to buffer
wire	image_rd_req;//request to read from image ram
wire	image_rd_pre;//preread image to FIFO and be ready for axi reading image
wire	image_rd_empty;
wire	[`IMAGE_BITWIDTH-1:0]	image_rd_data;//from fifo which is read from ram with 16 bit width

	
//axi_interface_control
wire head_rd_need;//need to read head control data from axi
wire kernel_rd_need;
wire image_rd_need;
wire image_wr_need;//need to write dealt image to axi
wire [3:0]	information_operation;//indicate which operation is going on: head, kernel, image read, image write from low bit to high bit
wire [`HEAD_WIDTH-1:0]	head_data;//write to a RAM for iterating and telling the read and write kernel or image information
wire head_wr_req;//request for head_data write
wire [`KERNEL_NUM-1:0]	kernel_wr_num;//number of the kernel of every filter read from axi and write to ram.
wire [`FILTER_NUM-1:0]	filter_wr_num;//number of filter
wire [`KERNEL_SIZE-1:0]	kernel_wr_size;//size of one kernel
wire [`IMAGE_NUM-1:0]		image_wr_num;//image number read from axi and write to ram
wire [`IMAGE_SIZE-1:0]	image_wr_size;//image size read from axi and write to ram
wire		image_toaxi_wr_finish;//finishing writing all data to axi
wire	image_fromaxi_rd_finish;//finish reading all data from axi and write to ram
wire	algorithm_finish;
wire	activation_choose;

//buffer_control
wire	deal_PostImage_clk;
wire	deal_PostImage_rd;//the postdeal part need to read image
wire	[`IMAGE_SIZE*2-1:0]	deal_PostImage_rd_addr;//{row, column}
wire	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_q;
wire	[`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_rd_valid_channel;
wire	deal_PostImage_wr;//write image data to ram
wire	[`POSTIMAGE_BITWIDTH*`POSTIMAGE_CHANNEL-1:0]	deal_PostImage_wr_data;
wire	deal_PostImage_wr_last;//the last write data
wire	[`IMAGE_SIZE*2-1:0]	deal_PostImage_wr_addr;//{row, column}
wire	maxpooling_finish;

//load_data
wire	[`IMAGE_NUM-1:0]	operate_image_num;//image number operated at this round
wire	[`IMAGE_SIZE-1:0]	operate_image_size;//image size
wire	[`IMAGE_SIZE-1:0]   image_size_after_maxpooling;
wire	operate_image_sum_en;//indicate whether perform summation of all the convolution channels
wire	operate_image_update;//indicate whether update the image ram
wire	operate_image_next_read_en;//next round, need to read image
wire	[`FILTER_NUM-1:0]	operate_filter_num;//the filter number
wire	[`KERNEL_NUM-1:0]	operate_kernel_num;//number of kernel in one filter 
wire	[`KERNEL_SIZE-1:0]	operate_kernel_size;//the kernel size
wire	[`KERNEL_STEP-1:0]	operate_kernel_step;//convolution step
wire	operate_maxpooling_en;//enable maxpooling
wire	operate_image_return_axi;//return image to axi
wire		operate_infor_update;//the head information have been updated 

//load_head
wire	load_head_begin;
wire load_head_rd;//read signal
wire [`HEAD_WIDTH-1:0]	load_head_rd_q;//
wire load_head_empty;//the fifo is empty
//load_image
wire	load_image_begin;//begin to load an image
output	one_layer_finish;//finishing one layer computation
wire	load_image_finish;//finishing loading an image
wire	image_ram_rd_ready;//the ram is ready for reading image data
wire	 	load_image_rd;//read the ram 
wire	 	[`IMAGE_SIZE*2+7:0]	load_image_rd_addr;//{num,row,column] of the image 
wire	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	load_image_rd_q;//all the channel image data
wire	[`PARALLEL_NUM-1:0]	load_image_rd_valid;//indicate valid channel data
wire	cal_image_need;//cal_image part need read image request
wire	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	cal_image_rd_q;//output image data
wire	 	[`PARALLEL_NUM-1:0]	cal_image_valid;//the valid image data      
//load_kernel
wire	load_kernel_begin;//begin signal for loading kernel
wire	load_kernel_finish;//finishing load kerne
wire		load_kernel_rd;//read request for reading kernel buffer
wire	[`KERNEL_BITWIDTH*`PARALLEL_NUM-1:0]	load_kernel_rd_q;//output kernel
wire	load_kernel_empty;
wire		[`KERNEL_ELE_BITWIDTH*`PARALLEL_NUM*`MAX_KERNEL_SIZE-1:0]	cal_kernel_q;//kernel output
wire	 	[`BIAS_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	cal_bias1_q;
wire	 	[`BIAS_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	cal_bias2_q;
wire	 	[`DIV_ELE_BITWIDTH*`PARALLEL_NUM-1:0]		cal_div_q;
wire	cal_kernel_valid;//valid signal  
wire	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	image_rect_q;
wire	[`PARALLEL_NUM-1:0]	image_rect_valid;


wire	deal_clk;
wire	slow_clk;
wire	debug_clk;
wire 	[7:0] soft_rstArray_n;

reset reset_m1(
	.clk(axi_clk),
	.rst_n(rst_n),
	.soft_rstArray_n(soft_rstArray_n)

);


PLL PLL_m1
   (
    // Clock out ports
    .clk_out1(slow_clk),     // output clk_out1
    .clk_out2(deal_clk),     // output clk_out2
//    .clk_out3(debug_clk),     // output clk_out3
    // Status and control signals
    .resetn(rst_n), // input reset
    .locked(locked_out),       // output locked
   // Clock in ports
    .clk_in1(axi_clk));      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template ---------

  
  
    
axi_interface_control axi_interface_control_m1(
		.clk(axi_clk),
		.deal_clk(deal_clk),
		.debug_clk(debug_clk),
		.rst_n(soft_rstArray_n[0]),
		
		.awid(awid),
		.awaddr(awaddr),
		.awlen(awlen),
		.awsize(awsize),
		.awburst(awburst),
		.awlock(awlock),
		.awcache(awcache),
		.awprot(awprot),
		.awqos(awqos),
		.awregion(awregion),
		.awvalid(awvalid),
		.awready(awready),
		
		.wdata(wdata),
		.wstrb(wstrb),
		.wlast(wlast),
		.wvalid(wvalid),
		.wready(wready),
		
		.bid(bid),
		.bresp(bresp),
		.bvalid(bvalid),
		.bready(bready),
		
		.arid(arid),
		.araddr(araddr),
		.arlen(arlen),
		.arsize(arsize),
		.arburst(arburst),
		.arlock(arlock),
		.arcache(arcache),
		.arprot(arprot),
		.arqos(arqos),
		.arregion(arregion),
		.arvalid(arvalid),
		.arready(arready),
		
		.rid(rid),
		.rdata(rdata),
		.rresp(rresp),
		.rlast(rlast),
		.rvalid(rvalid),
		.rready(rready),
		
		.buffer_wr_req(buffer_wr_req),
		.buffer_wr_data(buffer_wr_data),		
		.buffer_rd_req(image_rd_req),
		.buffer_rd_pre(image_rd_pre),
		.buffer_rd_empty(image_rd_empty),
		.buffer_rd_data(image_rd_data),  
			  
		.err_out(err_out),
		
		.image_begin(image_begin_inter),
		.maxpooling_finish(maxpooling_finish),
		.one_layer_finish(one_layer_finish),
		.algorithm_finish(algorithm_finish),
		
		.head_rd_need(head_rd_need),
		.kernel_rd_need(kernel_rd_need),
		.image_rd_need(image_rd_need),
		.image_wr_need(image_wr_need),
		.information_operation(information_operation),
		
		.head_wr_req(head_wr_req),
		.head_data(head_data),
		
		.image_wr_size(image_wr_size),
		.image_wr_num(image_wr_num),
		.kernel_wr_size(kernel_wr_size),
		.kernel_wr_num(kernel_wr_num),
		.filter_wr_num(filter_wr_num),
		.image_wr_finish(image_toaxi_wr_finish),
		.image_rd_finish(image_fromaxi_rd_finish),
		.image_toaxi_size(image_size_after_maxpooling),
		.image_toaxi_num(operate_image_num)        
            
        );    
    








buffer_control buffer_control_m1(
		.clk(axi_clk),
		.debug_clk(debug_clk),
		.rst_n(soft_rstArray_n[1]),
		
		.information_operation(information_operation),
		.buffer_wr_req(buffer_wr_req),
		.buffer_wr_data(buffer_wr_data),
		
		
		.head_wr_req(head_wr_req),
		.head_data(head_data),
		
		.head_rd_need(head_rd_need),
		.load_head_clk(deal_clk),
		.load_head_rd(load_head_rd),
		.load_head_rd_q(load_head_rd_q),
		.load_head_empty(load_head_empty),
		
		.kernel_rd_need(kernel_rd_need),
		.kernel_wr_size(kernel_wr_size),
		.kernel_wr_num(kernel_wr_num),
		.filter_wr_num(filter_wr_num),
		
	
		.load_kernel_clk(deal_clk),
		.load_kernel_rd(load_kernel_rd),
		.load_kernel_rd_q(load_kernel_rd_q),
		.load_kernel_empty(load_kernel_empty),
		
		
		.image_rd_need(image_rd_need),
		.image_wr_finish(image_fromaxi_rd_finish),
		.image_wr_num(image_wr_num),
		.image_wr_size(image_wr_size),
		
		
		.image_rd_update(operate_image_update),
		.image_rd_ready(image_ram_rd_ready),
		
		.load_image_clk(deal_clk),
		.load_image_rd(load_image_rd),
		.load_image_rd_addr(load_image_rd_addr),
		.load_image_rd_q(load_image_rd_q),
		.load_image_valid(load_image_rd_valid),
		
		.image_wr_need(image_wr_need),
			
		.filter_num(operate_filter_num),
		.kernel_num(operate_kernel_num),
		.image_size(operate_image_size),
		.infor_update(operate_infor_update),
		.image_return_axi(operate_image_return_axi),
		.maxpooling_en(operate_maxpooling_en),

		
		
		.image_rd_req(image_rd_req),
		.image_rd_pre(image_rd_pre),
		.image_rd_finish(image_toaxi_wr_finish),
		.image_rd_empty(image_rd_empty),
		.image_rd_data(image_rd_data),
		
		.deal_PostImage_clk(deal_clk),
		.deal_PostImage_rd(deal_PostImage_rd),
		.deal_PostImage_rd_addr(deal_PostImage_rd_addr),
		.deal_PostImage_rd_q(deal_PostImage_rd_q),
		.deal_PostImage_rd_valid_channel(deal_PostImage_rd_valid_channel),
		.deal_PostImage_wr(deal_PostImage_wr),
		.deal_PostImage_wr_data(deal_PostImage_wr_data),
		.deal_PostImage_wr_last(deal_PostImage_wr_last),
		.deal_PostImage_wr_addr(deal_PostImage_wr_addr),
		.maxpooling_finish(maxpooling_finish),
        .algorithm_finish(algorithm_finish)	
         );    
    
   
 load_data load_data_m1(
		.clk(deal_clk),
		.axi_clk(axi_clk),
		.rst_n(soft_rstArray_n[2]),
		
		.load_head_begin(load_head_begin),
		.load_head_rd(load_head_rd),
		.load_head_rd_q(load_head_rd_q),
		.load_head_empty(load_head_empty),
		.image_num(operate_image_num),
		.image_size(operate_image_size),
		.image_size_after_maxpooling(image_size_after_maxpooling),
		.image_sum_en(operate_image_sum_en),
		.image_update(operate_image_update),
		.image_next_read_en(operate_image_next_read_en),
		.filter_num(operate_filter_num),
		.kernel_num(operate_kernel_num),
		.kernel_size(operate_kernel_size),
		.kernel_step(operate_kernel_step),
		.maxpooling_en(operate_maxpooling_en),
		.image_return_axi(operate_image_return_axi),
		.infor_update(operate_infor_update),
		.image_one_return_finish(image_toaxi_wr_finish),
	
		.load_image_begin(load_image_begin),
		.load_image_finish(load_image_finish),
		.maxpooling_finish(maxpooling_finish),
		.image_rd_ready(image_ram_rd_ready),
		.buffer_image_rd(load_image_rd),
		.buffer_image_rd_addr(load_image_rd_addr),
		.buffer_image_rd_q(load_image_rd_q),
		.buffer_image_rd_valid(load_image_rd_valid),
		
		.image_need(cal_image_need),
		.image_rd_q(cal_image_rd_q),
		.image_valid(cal_image_valid),
	
		.load_kernel_begin(load_kernel_begin),
		.load_kernel_finish(load_kernel_finish),
		
		
		.buffer_kernel_rd(load_kernel_rd),
		.buffer_kernel_rd_q(load_kernel_rd_q),
		.buffer_kernel_empty(load_kernel_empty),
		
	
		.kernel_q(cal_kernel_q),
		.bias1_q(cal_bias1_q),
		.bias2_q(cal_bias2_q),
		.div_q(cal_div_q),
		.kernel_valid(cal_kernel_valid)
            
        );   
    
  
  

cal_image cal_image_m1(
        
		.clk(deal_clk),
		.rst_n(soft_rstArray_n[3]),
		
		.infor_update(operate_infor_update),
		.filter_num(operate_filter_num),
		.kernel_num(operate_kernel_num),
		.image_size(operate_image_size),
		.kernel_size(operate_kernel_size),
		.kernel_step(operate_kernel_step),
	
		
		.kernel_data(cal_kernel_q),
		.kernel_valid(cal_kernel_valid),
		
		.image_ready(image_ram_rd_ready),
		.image_need(cal_image_need),
		.image_data(cal_image_rd_q),
		.image_valid(cal_image_valid),
		
		.image_rect_q(image_rect_q),
		.image_rect_valid(image_rect_valid)
        	
        	
        	
		);  
  
  
  

  
deal_PostImage deal_PostImage_m1(

		.clk(deal_clk),
		.rst_n(soft_rstArray_n[4]),
		
		.infor_update(operate_infor_update),
		.filter_num(operate_filter_num),
		.kernel_num(operate_kernel_num),
		.last_image_sum_en(operate_image_sum_en),
		
		.image_data(image_rect_q),
		.image_valid(image_rect_valid),
		
		.activation_choose(activation_choose),
		.norm_en(operate_image_return_axi),
		.bias1_data(cal_bias1_q),
		.bias2_data(cal_bias2_q),
		.mul_data(cal_div_q),
		.kernel_valid(cal_kernel_valid),	
			
		.maxpooling_flag(operate_maxpooling_en),
		.image_size(operate_image_size),
		.maxpooling_finish(maxpooling_finish),
		
		.deal_PostImage_rd(deal_PostImage_rd),
		.deal_PostImage_rd_addr(deal_PostImage_rd_addr),
		.deal_PostImage_rd_q(deal_PostImage_rd_q),
		.deal_PostImage_rd_valid(deal_PostImage_rd_valid_channel),
		.deal_PostImage_wr(deal_PostImage_wr),
		.deal_PostImage_wr_addr(deal_PostImage_wr_addr),
		.deal_PostImage_wr_data(deal_PostImage_wr_data),
		.deal_PostImage_wr_last(deal_PostImage_wr_last)
		
		
		
		 );  
  
 


interrupt interrupt_m1(
		.clk(deal_clk),
		.axi_clk(axi_clk),
		.rst_n(soft_rstArray_n[5]),
		.image_return_axi(operate_image_return_axi),
		.maxpooling_finish(maxpooling_finish),
		
		.slow_clk(slow_clk),
		.image_begin_inter(image_begin_inter),
		.image_finish_inter(image_finish_inter),
		
		
		.load_head_begin(load_head_begin),
		
		.load_image_begin(load_image_begin),
		.load_image_finish(load_image_finish),
		.one_layer_finish(one_layer_finish),
		.one_layer_finish_int(one_layer_finish_int),
		.activation_choose(activation_choose),
		
		.image_one_return_finish(image_toaxi_wr_finish),
		.algorithm_finish(algorithm_finish),
		
		.load_kernel_begin(load_kernel_begin),
		.load_kernel_finish(load_kernel_finish)
		 	
		 );  
  
  
 
//reg denominator_en;
//always @(posedge deal_clk)
//begin
//	if(image_begin_inter)
//		denominator_en <= 1'b1;
//	else if(image_finish_inter)
//		denominator_en <= 1'b0;
//end
//bandWidth_count bandWidth_count_m(

//	.clk(deal_clk),	
//	.rst_n(soft_rstArray_n[6]),
//	.numerator_en((wvalid && wready) || (rvalid && rready)),
//	.denominator_en(denominator_en),
//	.send_en(algorithm_finish),
//	.send_clk(slow_clk),
//	.message(pl_message)


//    );







    
endmodule

