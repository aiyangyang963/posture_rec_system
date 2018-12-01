`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/04 11:36:25
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb;
    
wire	global_clk;
wire	axi_clk;
wire	rst_n; 
  
    

wire  [5:0]       			   awid;//ID for write-address
wire  [`AXI_ADDR_WIDTH-1:0]      awaddr;//write address
wire  [7:0]       			   awlen;//length of one burst write
wire  [2:0]                      awsize;//burst size£º1£¬2£¬4£¬8£¬16£¬32£¬64£¬128
wire  [1:0]                      awburst;//burst type
wire                             awlock;//atomic access signaling
wire  [3:0]                      awcache;//cache type
wire  [2:0]                      awprot;//protection type
wire  [3:0]                      awqos;//quality of service
wire  [3:0]                      awregion;//region identifier
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
wire  [3:0]                      arregion;//permits a single physical interface on a slave to be used 
wire                             arvalid;//the read address is valid
wire                              arready;//the read address is acceptied

wire   [5:0]                      rid;//read ID tag
wire   [`AXI_DATA_WIDTH-1:0]      rdata;//read data
wire   [1:0]                      rresp;//read response
wire                              rlast;//the last read data
wire                              rvalid;//indicate that the read data is valid
wire                             rready;//the read data is accepted

wire 							   led_1;//the AXI communication error    
wire							   led_2;//pll locked


wire	image_begin_inter;//the image have been sampled and stored in ddr
wire	image_finish_inter;//all the images are dealt and give an interrupt to ps 
wire	one_layer_finish; 
 
wire	acken; 
 

 
 
clk_rst clk_rst_m1(
	.global_clk(global_clk),
	.rst_n(rst_n),
	.clk_rst_n()
    ); 
 

axi_clk_gen axi_clk_gen_m1(
	.axi_clk(axi_clk)
);


start_control start_control_m1(
	.clk(axi_clk),
	.rst_n(rst_n),
	.image_begin_inter(image_begin_inter),
	.image_finish_inter(image_finish_inter),
	.en(acken)
);



axi_bus axi_bus_m1(
	.clk(axi_clk),
	
	.acken(acken),
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
	
	.image_finish_inter(image_finish_inter),
	.one_layer_finish(one_layer_finish)

    );
    
    
    
    
    
pl_top pl_top_DUT(
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

		.err_out(led_1),
		.locked_out(led_2),
		
		.image_begin_inter(image_begin_inter),
		.image_finish_inter(image_finish_inter),
		.one_layer_finish(one_layer_finish)

    );   
    
    
    
endmodule
