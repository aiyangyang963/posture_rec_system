`timescale 1ns / 1ps
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


module top(

	global_clk
		

    );
    
    



input							global_clk;


wire							axi_clk;
wire							rst_n;
wire							soft_rst_n;

wire  [5:0]       			   awid;//ID for write-address
wire  [`AXI_ADDR_WIDTH-1:0]      awaddr;//write address
wire  [7:0]       			   awlen;//length of one burst write
wire  [2:0]                      awsize;//burst size£º1£¬2£¬4£¬8£¬16£¬32£¬64£¬128
wire  [1:0]                      awburst;//burst type
wire                             awlock;//atomic access signaling
wire  [3:0]                      awcache;//cache type
wire  [2:0]                      awprot;//protection type
wire  [3:0]                      awqos;//quality of service
wire                             awvalid;//the valid signal
wire                              awready;//the write address is ready

wire  [`AXI_DATA_WIDTH-1:0]      wdata;//write data
wire  [`AXI_VALID_BYTE-1:0]  	   wstrb;//indicate which byte lanes hold valid data. one strobe bit for each 8 bits
wire                             wlast;//the last transfer in one burst write
wire                             wvalid;//indicate that the data and strobe is valid
wire                              wready;//indicate that the slave have recieved the data


wire   [5:0]                      bid;//responce ID tag
wire   [1:0]                      bresp;//write responce
wire                              bvalid;//the response data is valid
wire                             bready;//ready to recieve the write response

wire  [5:0]                      arid;//identification tag for the read address group of signals
wire  [`AXI_ADDR_WIDTH-1:0]      araddr;//read address
wire  [7:0]                      arlen;//burst length
wire  [2:0]                      arsize;//burst size
wire  [1:0]                      arburst;//burst type
wire                             arlock;//lock type
wire  [3:0]                      arcache;//how transactions acess the memory system
wire  [2:0]                      arprot;//protect type
wire  [3:0]                      arqos;//quality of service
wire                             arvalid;//the read address is valid
wire                              arready;//the read address is acceptied

wire   [5:0]                      rid;//read ID tag
wire   [`AXI_DATA_WIDTH-1:0]      rdata;//read data
wire   [1:0]                      rresp;//read response
wire                              rlast;//the last read data
wire                              rvalid;//indicate that the read data is valid
wire                             rready;//the read data is accepted




wire	image_begin_inter;//the image have been sampled and stored in ddr
wire	image_finish_inter;//all the images are dealt and give an interrupt to ps
wire	one_layer_finish;
wire	one_layer_finish_int;
wire [31:0] pl_message;    
    
pl_top pl_top_m1(
		.global_clk(global_clk),
		.rst_n(rst_n),
		.soft_rst_n(soft_rst_n),
		.axi_clk(axi_clk),
		
		
        .awid(awid),
		.awaddr(awaddr),
		.awlen(awlen),
		.awsize(awsize),
		.awburst(awburst),
		.awlock(awlock),
		.awcache(awcache),
		.awprot(awprot),
		.awqos(awqos),
		.awregion(),
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
		.arregion(),
		.arvalid(arvalid),
		.arready(arready),
		
		.rid(rid),
		.rdata(rdata),
		.rresp(rresp),
		.rlast(rlast),
		.rvalid(rvalid),
		.rready(rready),

		
		.image_begin_inter(image_begin_inter),
		.image_finish_inter(image_finish_inter),
		.pl_message(pl_message),
		.one_layer_finish(one_layer_finish),
		.one_layer_finish_int(one_layer_finish_int)

    );




system_wrapper system_wrapper_m1(
	.AXI_CLK(axi_clk),
    
    .AXI_TO_PL_araddr(araddr),
    .AXI_TO_PL_arburst(arburst),
    .AXI_TO_PL_arcache(arcache),
    .AXI_TO_PL_arid(arid),
    .AXI_TO_PL_arlen(arlen),
    .AXI_TO_PL_arlock(arlock),
    .AXI_TO_PL_arprot(arprot),
    .AXI_TO_PL_arqos(arqos),
    .AXI_TO_PL_arready(arready),
    .AXI_TO_PL_arsize(arsize),
    .AXI_TO_PL_arvalid(arvalid),
    
    .AXI_TO_PL_awaddr(awaddr),
    .AXI_TO_PL_awburst(awburst),
    .AXI_TO_PL_awcache(awcache),
    .AXI_TO_PL_awid(awid),
    .AXI_TO_PL_awlen(awlen),
    .AXI_TO_PL_awlock(awlock),
    .AXI_TO_PL_awprot(awprot),
    .AXI_TO_PL_awqos(awqos),
    .AXI_TO_PL_awready(awready),
    .AXI_TO_PL_awsize(awsize),
    .AXI_TO_PL_awvalid(awvalid),
    
    .AXI_TO_PL_bid(bid),
    .AXI_TO_PL_bready(bready),
    .AXI_TO_PL_bresp(bresp),
    .AXI_TO_PL_bvalid(bvalid),
    
    .AXI_TO_PL_rdata(rdata),
    .AXI_TO_PL_rid(rid),
    .AXI_TO_PL_rlast(rlast),
    .AXI_TO_PL_rready(rready),
    .AXI_TO_PL_rresp(rresp),
    .AXI_TO_PL_rvalid(rvalid),
    
    .AXI_TO_PL_wdata(wdata),
    .AXI_TO_PL_wlast(wlast),
    .AXI_TO_PL_wready(wready),
    .AXI_TO_PL_wstrb(wstrb),
    .AXI_TO_PL_wvalid(wvalid),
    
    .DEAL_FINISH_INT(image_finish_inter),
    .DEAL_START_INT_tri_o(image_begin_inter),
    .GLOBAL_RESET_N(rst_n)
    
);



















    
endmodule
