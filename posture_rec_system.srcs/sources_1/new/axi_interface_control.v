`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/24 23:24:59
// Design Name: 
// Module Name: axi_interface_control
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


module axi_interface_control(
		clk,
		deal_clk,
		debug_clk,
        rst_n,
        
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
        
    	buffer_wr_req,
        buffer_wr_data,
        buffer_rd_req,
        buffer_rd_pre,
        buffer_rd_empty,
        buffer_rd_data,  
              
        err_out,
        
        image_begin,
        maxpooling_finish,
        one_layer_finish,
        algorithm_finish,

        
		head_rd_need,
        kernel_rd_need,
        image_rd_need,
        image_wr_need,
        information_operation,
        head_wr_req,
        head_data,
        image_wr_size,
        image_wr_num,
        kernel_wr_size,
        kernel_wr_num,
        filter_wr_num,
        image_wr_finish,
        image_rd_finish,
        
        image_toaxi_size,
        image_toaxi_num        
        
    );
    
    input							   debug_clk;
	input              				   clk;//AXI4 clock, provides by system
	input							   deal_clk;
    input            				   rst_n;//asserted at low level
    
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
    
    output 	 						   buffer_wr_req;//write request to buffer
    output 	[`AXI_DATA_WIDTH-1:0]  	   buffer_wr_data;//write data to buffer
    output 	 			               buffer_rd_req;//request for reading buffer data
    output 							   buffer_rd_pre;//pre_reading data from buffer
    input 							   buffer_rd_empty;//the pre-reading FIFO is empty
    input 	[`AXI_DATA_WIDTH-1:0]	   buffer_rd_data;//read data
        
    
	input image_begin;//the image is ready from ps end, and can begin to read or write to axi
	input one_layer_finish;//one layer of machine learning finish

    
    input head_rd_need;//need to read head control data from axi
    input kernel_rd_need;
    input image_rd_need;
    input image_wr_need;//need to write dealt image to axi
    output [3:0]	information_operation;//indicate which operation is going on: head, kernel, image read, image write from low bit to high bit
    input [`HEAD_WIDTH-1:0]	head_data;//write to a RAM for iterating and telling the read and write kernel or image information
    input head_wr_req;//request for head_data write
    output [`KERNEL_NUM-1:0]	kernel_wr_num;//number of the kernel of every filter read from axi and write to ram.
    output [`FILTER_NUM-1:0]	filter_wr_num;//number of filter
    output [`KERNEL_SIZE-1:0]	kernel_wr_size;//size of one kernel
    output [`IMAGE_NUM-1:0]		image_wr_num;//image number read from axi and write to ram
    output [`IMAGE_SIZE-1:0]	image_wr_size;//image size read from axi and write to ram
    output		image_wr_finish;//finishing writing all data to axi
    output		image_rd_finish;//finishing reading all data from axi
    input		algorithm_finish;
    input		maxpooling_finish;
    
    input [`IMAGE_NUM-1:0]	image_toaxi_num;//image number returned to axi
    input [`IMAGE_SIZE-1:0]	image_toaxi_size;//size returned to axi    
    
    
    
 
	wire rd_req;//read request from axi
    wire [`AXI_ADDR_WIDTH-1:0]	rd_addr;//the read address
    wire [7:0]	rd_len;//the length of one read burst
    wire rd_finish;//finishing reading data
    wire   wr_req;//write request to axi
    wire [`AXI_ADDR_WIDTH-1:0]	wr_addr;//write address
    wire [7:0]	wr_len;//write burst length
    wire wr_finish;//finishing writing data 
 
 
    
    
    
axi_read_write_master axi_read_write_master_m1(
        .clk(clk),
        .debug_clk(debug_clk),
        .rst_n(rst_n),
        
        //AXI interface signals
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
        
        //information_read_write module
        .rd_req(rd_req),
        .rd_addr(rd_addr),
        .rd_len(rd_len),
        .rd_finish(rd_finish),
        
        .wr_req(wr_req),
        .wr_addr(wr_addr),
        .wr_len(wr_len),
        .wr_finish(wr_finish),
        
        //buffer_control module
        .buffer_wr_req(buffer_wr_req),
        .buffer_wr_data(buffer_wr_data),
        .buffer_rd_req(buffer_rd_req),
        .buffer_rd_pre(buffer_rd_pre),
        .buffer_rd_empty(buffer_rd_empty),
        .buffer_rd_data(buffer_rd_data),
        
        //output signal
        .err_out(err_out)
        
        );
        
        
        
      
information_read_write information_read_write_m1(
        	.clk(clk),
        	.deal_clk(deal_clk),
        	.rst_n(rst_n),
        	//axi_read_write_master module
        	.rd_req(rd_req),
        	.rd_addr(rd_addr),
        	.rd_len(rd_len),
        	.rd_finish(rd_finish),
        	.wr_req(wr_req),
        	.wr_addr(wr_addr),
        	.wr_len(wr_len),
        	.wr_finish(wr_finish),
        	
        	//interrupt module
        	.image_begin(image_begin),
        	.maxpooling_finish(maxpooling_finish),
        	.one_layer_finish(one_layer_finish),
        	.algorithm_finish(algorithm_finish),
        	//buffer_control module

        	
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
        	.image_wr_finish(image_wr_finish),
        	.image_rd_finish(image_rd_finish),
        	.image_toaxi_size(image_toaxi_size),
        	.image_toaxi_num(image_toaxi_num)
        
        
        
            );            
    
    
   
    
/*   
 wire tb_image_begin; 
axi_read_write_master_tb axi_read_write_master_tb_m1(
    .clk(clk),
	.rst_n(rst_n),
	
  	 .rd_req(rd_req),
    .rd_addr(rd_addr),
    .rd_len(rd_len),
    .rd_finish(rd_finish),
    
    .wr_req(wr_req),
    .wr_addr(wr_addr),
    .wr_len(wr_len),
    .wr_finish(wr_finish),
    
  	 .buffer_wr_req(buffer_wr_req),
    .buffer_wr_data(buffer_wr_data),
    .buffer_rd_req(buffer_rd_req),
    .buffer_rd_pre(buffer_rd_pre),
    .buffer_rd_empty(buffer_rd_empty),
    .buffer_rd_data(buffer_rd_data)



    );    
    
   */ 
   
   
   
/*   
information_read_write_tb information_read_write_tb_m1(
   	.clk(clk),
   	.rst_n(rst_n),
   	
    .tb_image_begin(tb_image_begin),

   	
   	.head_rd_need(head_rd_need),
   	.kernel_rd_need(kernel_rd_need),
   	.image_rd_need(image_rd_need),
   	.image_wr_need(image_wr_need),
   	.information_operation(information_operation),
   	
   	.head_wr_req(head_wr_req),
   	.head_data(head_data),
   	.buffer_wr_req(buffer_wr_req),
   	.buffer_wr_data(buffer_wr_data),
   	
   	
   	.image_wr_size(image_wr_size),
   	.image_wr_num(image_wr_num),
   	.kernel_wr_size(kernel_wr_size),
   	.kernel_wr_num(kernel_wr_num),
   	.filter_wr_num(filter_wr_num),
   	.image_wr_finish(image_wr_finish),
   	.image_rd_finish(image_rd_finish),
   	
   	.image_toaxi_size(image_toaxi_size),
   	.image_toaxi_num(image_toaxi_num)
       );   
   
   
*/   
   
   
   
   
    
endmodule
