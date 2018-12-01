`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/08/21 09:34:31
// Design Name: 
// Module Name: axi_read_write_master
// Project Name: posture_recognition
// Target Devices: zynq7020
// Tool Versions: 2016.3
// Description: AXI4 interface control
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_read_write_master(
    clk,
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
    
    rd_req,
    rd_addr,
    rd_len,
    rd_finish,
    
    wr_req,
    wr_addr,
    wr_len,
    wr_finish,
    
    buffer_wr_req,
    buffer_wr_data,
    buffer_rd_req,
    buffer_rd_pre,
    buffer_rd_empty,
    buffer_rd_data,
    
    err_out
    
    );
    
    
/////////////////////////////////////////////inputs and outputs////////////////////////////////////////////////////////    
input              				   clk;//AXI4 clock, provides by system
input							   debug_clk;
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
output                            wlast;//the last transfer in one burst write
output  reg                        wvalid;//indicate that the data and strobe is valid
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

input 				               rd_req;//request for reading AXI4 data
input 	[`AXI_ADDR_WIDTH-1:0]	   rd_addr;//read address
input 	[7:0]		               rd_len;//read length
output 				               rd_finish;//finishing reading from AXI4

input 				               wr_req;//write request
input 	[`AXI_ADDR_WIDTH-1:0]	   wr_addr;//write address
input 	[7:0]		               wr_len;//write length
output 				               wr_finish;//finishing writing data

output 	reg						   buffer_wr_req;//write request to buffer
output 	reg[`AXI_DATA_WIDTH-1:0]   buffer_wr_data;//write data to buffer
output 	 			               buffer_rd_req;//request for reading buffer data
output 							   buffer_rd_pre;//pre_reading data from buffer
input 							   buffer_rd_empty;//the pre-reading FIFO is empty
input 	[`AXI_DATA_WIDTH-1:0]	   buffer_rd_data;//read data

output 							   err_out;//the AXI communication error
   
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    




/////////////////////////////////////////////write and read control registers//////////////////////////////////////
reg 			write_req_reg;//register for request writing data
reg 			read_req_reg;//register for request reading data


always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			write_req_reg		<=	1'b0;
		else if(wr_req)
			write_req_reg		<=	1'b1;//wr_req asserts
		else if(wr_finish)
			write_req_reg		<=	1'b0;//wr_finish de-asserts
end

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			read_req_reg		<=	1'b0;
		else if(rd_req)
			read_req_reg		<=	1'b1;//rd_req asserts
		else if(rd_finish)
			read_req_reg		<=	1'b0;//rd_finish de-asserts
end



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    





////////////////////////////////////////////////read and write control state machine//////////////////////////////
reg 	[6:0]		axi_write_read_control;//the write and read control state
parameter 			axi_write_read_idle			=	7'h00,
					axi_write_read_ReadAddr		=	7'h01,
					axi_write_read_read			=   7'h02,
					axi_write_read_WriteAddr	=  	7'h04,
					axi_write_read_wait_pre		=	7'h08,
					axi_write_read_write		=	7'h10,
					axi_write_read_write_resp	=	7'h20,
					axi_write_read_end			=	7'h40;
					
			
wire 				write_len_cnt_finish;					
					
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			axi_write_read_control			<=	axi_write_read_idle;
		else
			case(axi_write_read_control)
			axi_write_read_idle:
				if(read_req_reg)
					axi_write_read_control			<=	axi_write_read_ReadAddr;
				else if(write_req_reg)
					axi_write_read_control			<=	axi_write_read_WriteAddr;
					
			axi_write_read_ReadAddr:
				if(arready)
					axi_write_read_control			<=	axi_write_read_read;
			axi_write_read_read:
				if(rlast)//after the last read data, read state is over
					axi_write_read_control			<=	axi_write_read_end;
			
			axi_write_read_WriteAddr:
				if(awready)
					axi_write_read_control			<=	axi_write_read_wait_pre;
			axi_write_read_wait_pre:
				if(!buffer_rd_empty)
					axi_write_read_control			<=	axi_write_read_write;
			axi_write_read_write:
				if(write_len_cnt_finish)
					axi_write_read_control			<=	axi_write_read_write_resp;
			axi_write_read_write_resp:
				if(bvalid)//write response is send
					axi_write_read_control			<=	axi_write_read_end;
			axi_write_read_end:
				axi_write_read_control			<=	axi_write_read_idle;
			default:
				axi_write_read_control			<=	axi_write_read_idle;
			endcase	
		
end


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////write data control//////////////////////////////////////////////////

assign 			awvalid		=	(axi_write_read_control == axi_write_read_WriteAddr) ? 1'b1 : 1'b0;
assign 			awaddr		=	(axi_write_read_control == axi_write_read_WriteAddr) ? wr_addr : `AXI_ADDR_WIDTH'h0;
assign 			awlen		=	(axi_write_read_control == axi_write_read_WriteAddr) ? wr_len : 8'h0;


assign 			awid		=	6'h0;//default value. This signal dosen't work
assign 			awsize		=   3'b011;//the maximum bytes are 8. which is equal to data width 64bits
assign 			awburst		=	2'b01;//the burst mode is increasing write address
assign 			awlock		=	1'b0;//normal access
assign 			awcache		=	4'h0;//non-bufferable
assign 			awprot		=	3'b100;//priviledged, secure, data access
assign 			awqos		=	4'h0;//not participate any QoS
assign 			awregion	=	4'h0;//not used


//when bvalid is asserted in state write_resp, assert bready signal
assign 		bready		=	(axi_write_read_control == axi_write_read_write_resp && bvalid) ? 1'b1 : 1'b0;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////read from buffer and write to AXI////////////////////////////////
reg 	[7:0]	write_len_cnt;//counter of write length
wire	axi_write_read_write_duration;
reg		axi_write_read_write_duration_r;
wire	axi_write_read_write_duration_pos;
reg		buffer_rd_empty_r;
wire	buffer_rd_empty_neg;

assign	axi_write_read_write_duration = (axi_write_read_control == axi_write_read_write) ? 1'b1 : 1'b0;
always @(posedge clk)
begin
	axi_write_read_write_duration_r <= axi_write_read_write_duration;
end

assign	axi_write_read_write_duration_pos = axi_write_read_write_duration && !axi_write_read_write_duration_r;


always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			write_len_cnt	<=	8'h0;
		else if(write_len_cnt == wr_len && wvalid && wready)//clear the counter
			write_len_cnt	<=	8'h0;
		else if(wready && wvalid)
			write_len_cnt	<=	write_len_cnt + 1'b1;
end

assign 	write_len_cnt_finish	=	(write_len_cnt == wr_len && wready && wvalid) ? 1'b1 : 1'b0;

assign 		buffer_rd_pre		=	wr_req;//a write request initiate pre-reading from RAM to FIFO


always @(posedge clk)
begin
	buffer_rd_empty_r <= buffer_rd_empty;
end
assign buffer_rd_empty_neg = !buffer_rd_empty && buffer_rd_empty_r;
//the data have been accepted and begin to read another data
assign  buffer_rd_req = (axi_write_read_write_duration_pos ||
						 (axi_write_read_control == axi_write_read_write && wready && !wlast && !buffer_rd_empty) ||
						 (axi_write_read_control == axi_write_read_write && buffer_rd_empty_neg));
assign 	wr_finish	=	wlast;


assign	wlast	=	write_len_cnt_finish;//the last data have been accepted




always @(posedge clk)
begin
		if(buffer_rd_req)
			wvalid	<=	1'b1;
		else if(axi_write_read_control == axi_write_read_write && !wready && !wlast)
			wvalid	<=	wvalid;//wait until wready is asserted
		else
			wvalid	<=	1'b0;
end

assign 	wdata		=	buffer_rd_data;



assign wstrb	=	`AXI_VALID_BYTE'hFF;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////read control/////////////////////////////////////////////////////////////
assign 		araddr		=	(axi_write_read_control == axi_write_read_ReadAddr) ? rd_addr : `AXI_ADDR_WIDTH'h0;
assign 		arvalid		=	(axi_write_read_control == axi_write_read_ReadAddr) ? 1'b1 : 1'b0;
assign 		arlen		=	(axi_write_read_control == axi_write_read_ReadAddr) ? rd_len : 8'h0;


assign 			arid		=	6'h0;//default value. This signal dosen't work
assign 			arsize		=   3'b011;//the maximum bytes are 8. which is equal to data width 64bits
assign 			arburst		=	2'b01;//the burst mode is increasing write address
assign 			arlock		=	1'b0;//normal access
assign 			arcache		=	4'h0;//non-bufferable
assign 			arprot		=	3'b100;//priviledged, secure, data access
assign 			arqos		=	4'h0;//not participate any QoS
assign 			arregion	=	4'h0;//not used




assign 		rready		=	(axi_write_read_control == axi_write_read_read && rvalid) ? 1'b1 : 1'b0;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////read data from AXI and write to buffer////////////////////////////////
always @(posedge clk)
begin
		if(axi_write_read_control == axi_write_read_read && rvalid)
			buffer_wr_req	<=	1'b1;
		else
			buffer_wr_req	<=	1'b0;
end


always @(posedge clk)
begin
		if(axi_write_read_control == axi_write_read_read && rvalid)
			buffer_wr_data	<=	rdata;
end




assign 		rd_finish		=	rlast;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////read and write response VS error////////////////////////////////////////////
//reg 	err_pulse;//one pulse is generated when read or write to AXI4


//always @(posedge clk)
//begin
//		if((bresp != `AXI_OKAY && bvalid) ||
//			(axi_write_read_control == axi_write_read_read
//				&& rvalid && rresp != `AXI_OKAY))
//			err_pulse	<=	1'b1;
//		else
//			err_pulse	<=	1'b0;
//end




//err_detect err_detect_m1(
//	.clk(clk),
//	.rst_n(rst_n),
//	.err_pulse(err_pulse),
//	.err_threshold(8'd10),//set 10 error as the generation threshold
//	.err_out(err_out)
//);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////










//axiInter_ila axiInter(
//	.clk(clk), // input wire clk


//	.probe0(awaddr), // input wire [31:0]  probe0  
//	.probe1(awlen), // input wire [7:0]  probe1 
//	.probe2(wdata), // input wire [63:0]  probe2 
//	.probe3(wlast), // input wire [0:0]  probe3 
//	.probe4(araddr), // input wire [31:0]  probe4 
//	.probe5(arlen), // input wire [7:0]  probe5 
//	.probe6(rdata), // input wire [63:0]  probe6 
//	.probe7(rlast), // input wire [0:0]  probe7 
//	.probe8(buffer_rd_req), // input wire [0:0]  probe8 
//	.probe9(buffer_rd_empty), // input wire [0:0]  probe9 
//	.probe10(wr_req), // input wire [0:0]  probe10 
//	.probe11(axi_write_read_control) // input wire [6:0]  probe11 
//);


    
    
endmodule
