`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: 
// 
// Create Date: 2017/08/26 16:34:12
// Design Name: 
// Module Name: image_read_buffer_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: control write and read from image ram
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module image_read_buffer_control(
	clk,
	load_head_clk,
	rst_n,
	
	image_rd_need,
	image_wr_finish,
	image_wr_num,
	image_wr_size,
	
	image_wr_req,
	image_wr_data,
	
	infor_update,
	image_rd_update,
	image_rd_ready,
	algorithm_finish,
	

	kernel_rd_num,
	image_rd_size,
	load_image_clk,
	load_image_rd,
	load_image_rd_addr,
	load_image_rd_q,
	load_image_valid
	
			
    );
 
 
/////////////////////////////////////inputs and outputs/////////////////////////////////////////////    
input clk;
input load_head_clk;
input rst_n;

(*DONT_TOUCH="TRUE"*)output reg	image_rd_need;//need to read image from axi
(*DONT_TOUCH="TRUE"*)input	image_wr_finish;//the last image data
(*DONT_TOUCH="TRUE"*)input [`IMAGE_NUM-1:0]	image_wr_num;//in writing image operation, the bumber of images
(*DONT_TOUCH="TRUE"*)input [`IMAGE_SIZE-1:0]	image_wr_size;//the size of image sizeXsize

(*DONT_TOUCH="TRUE"*)input image_wr_req;
input [`IMAGE_BITWIDTH-1:0]	image_wr_data;

(*DONT_TOUCH="TRUE"*)input	infor_update;
input	image_rd_update;//need to update the image ram
output	reg	image_rd_ready;//the image have been download to ram
input	algorithm_finish;

input	[`KERNEL_NUM-1:0]	kernel_rd_num;
input [`IMAGE_SIZE-1:0] image_rd_size;
input load_image_clk;
input load_image_rd;
input [`IMAGE_SIZE*2+7:0]	load_image_rd_addr;//{num,row[7:0],column[7:0]}
output [`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	load_image_rd_q;//all the 24 ram data
output reg[`PARALLEL_NUM-1:0]	load_image_valid;//which channel is valid


////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////instantiates ram//////////////////////////////////
wire wea	[`PARALLEL_NUM-1:0];
wire ena	[`PARALLEL_NUM-1:0];
reg [`PARALLEL_NUM-1:0]	enb	;
wire [`IMAGE_RAM_ADDR_WIDTH-1:0]	image_wr_addr;
wire [`IMAGE_RAM_ADDR_WIDTH2-1:0]	image_ram_rd_addr;
wire	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	ram_rd_q;



genvar i;
for(i=0;i<`PARALLEL_NUM;i=i+1)begin : image_ram_loop

	image_ram image_ram_m1(
		.clka(clk),    // input wire clka
		.wea(wea[i]),      // input wire [0 : 0] wea
		.addra(image_wr_addr),  // input wire [11 : 0] addra
		.dina(image_wr_data),    // input wire [63 : 0] dina
		.clkb(load_image_clk),    // input wire clkb
		.addrb(image_ram_rd_addr),  // input wire [12 : 0] addrb
		.doutb(ram_rd_q[`IMAGE_ELE_BITWIDTH*(i+1)-1:`IMAGE_ELE_BITWIDTH*i])  // output wire [31 : 0] doutb
	);


end
////////////////////////////////////////////////////////////////////////////////////////





//////////////////////////////write address generation/////////////////////////////////
wire [`PARALLEL_WIDTH-1:0]	image_wr_ram_n;//the number of image ram
wire [`IMAGE_SIZE+`IMAGE_SIZE-1:0]	image_wr_size2_div;
wire	image_wr_ram_number_record_en;//enable record how many rams one image take
reg	[`PARALLEL_WIDTH-1:0]	oneimage_wr_ram_number_record;//the number of rams one image occupy
wire [7:0] recordImageNum_inRAM;

always @(posedge clk)
begin
		if(image_wr_size2_div[`IMAGE_RAM_ADDR_WIDTH-1:0] == 0)
			oneimage_wr_ram_number_record	<=	image_wr_size2_div[`IMAGE_SIZE+`IMAGE_SIZE-1:`IMAGE_RAM_ADDR_WIDTH];
		else
			oneimage_wr_ram_number_record	<=	image_wr_size2_div[`IMAGE_SIZE+`IMAGE_SIZE-1:`IMAGE_RAM_ADDR_WIDTH] + 1;
end




multi_div multi_div_m1(
	.clk(clk),
	.multi1(image_wr_size),
	.multi2(image_wr_size),
	.result(image_wr_size2_div)
);



//by counting image size, number to generate the address
counter_addr counter_addr_m1(
	.clk(clk),
	.rst_n(rst_n),
	
	.en(image_wr_req),
	.cnti_threshold(image_wr_num),
	.cntk_threshold(image_wr_size2_div),
	.cntk_threshold_reach(image_wr_ram_number_record_en),
	.recordImageNum_inRAM(recordImageNum_inRAM),
	.result({image_wr_ram_n,image_wr_addr})

);



///////////////////////////////////////////////////////////////////////////////////////
    
//////////////////////////image ram strobe/////////////////////////////////////////////
wire [`PARALLEL_WIDTH-1:0] k[`PARALLEL_NUM-1:0];

		assign k[0]	=	`PARALLEL_WIDTH'd0;
		assign k[1]	=	`PARALLEL_WIDTH'd1;
		assign k[2]	=	`PARALLEL_WIDTH'd2;
		assign k[3]	=	`PARALLEL_WIDTH'd3;
		assign k[4]	=	`PARALLEL_WIDTH'd4;
		assign k[5]	=	`PARALLEL_WIDTH'd5;
		assign k[6]	=	`PARALLEL_WIDTH'd6;
		assign k[7]	=	`PARALLEL_WIDTH'd7;


genvar j;
for(j=0;j<`PARALLEL_NUM;j=j+1)begin : image_wr_ram_strobe_loop
	assign ena[j]	=	(image_wr_ram_n == k[j] && image_wr_req) ? 1'b1 : 1'b0;
	assign wea[j]	=	(image_wr_ram_n == k[j] && image_wr_req) ? 1'b1 : 1'b0;
end

/////////////////////////////////////////////////////////////////////////////////////    
 
 
 
//////////////////////////////cross clock///////////////////////////////////////////////
reg [`IMAGE_SIZE-1:0]image_rd_size_in_load_image_clk;
reg [`IMAGE_SIZE-1:0]image_rd_size_in_load_image_clk_r;
reg [`IMAGE_SIZE*2-1:0] image_rd_pixelNum;


always @(posedge load_image_clk)
begin
		image_rd_size_in_load_image_clk <= image_rd_size;
		image_rd_size_in_load_image_clk_r <= image_rd_size_in_load_image_clk;
end

always @(posedge load_image_clk)
begin
	if(image_rd_size_in_load_image_clk[0])//odd size image
		image_rd_pixelNum <= image_rd_size_in_load_image_clk * image_rd_size_in_load_image_clk + 1'b1;
	else
		image_rd_pixelNum <= image_rd_size_in_load_image_clk * image_rd_size_in_load_image_clk;
end
//////////////////////////////////////////////////////////////////////////////////////////     
 
 

 
    
    
/////////////////////////////////////read address decode//////////////////////////////
wire [`PARALLEL_WIDTH-1:0]	image_ram_rd_strobe;
reg load_image_rd_r;
reg	[`PARALLEL_WIDTH-1:0]	image_wr_ram_number_record;//record the number of rams all the images occupy
wire	[`IMAGE_RAM_ADDR_WIDTH2-1:0]	image_ram_rd_addr_num0;//without image number the address
reg	[`IMAGE_RAM_ADDR_WIDTH2-1:0]	image_ram_rd_start_addr;//the start address for each image
wire [`IMAGE_RAM_ADDR_WIDTH2-2:0]	image_ram_rd_start_addr_temp;
reg [`PARALLEL_WIDTH-1:0]image_wr_ram_number_record_in_load_image_clk_domain;
reg [`PARALLEL_WIDTH-1:0]image_wr_ram_number_record_in_load_image_clk_domain_r;

(*DONT_TOUCH="TRUE"*)reg [`IMAGE_SIZE+`IMAGE_SIZE-1:0]	image_wr_size2_div_in_load_image_clk_domain;
(*DONT_TOUCH="TRUE"*)reg [`IMAGE_SIZE+`IMAGE_SIZE-1:0]	image_wr_size2_div_in_load_image_clk_domain_r;


reg	[`PARALLEL_WIDTH-1:0]	oneimage_wr_ram_number_record_in_load_image_clk_domain;
reg	[`PARALLEL_WIDTH-1:0]	oneimage_wr_ram_number_record_in_load_image_clk_domain_r;
(*DONT_TOUCH="TRUE"*)reg [7:0] load_image_rd_pointer_inRAM;

reg [7:0] recordImageNum_inRAM_inLoadImageClk, recordImageNum_inRAM_inLoadImageClk_r;


always @(posedge load_image_clk)
begin
		image_wr_size2_div_in_load_image_clk_domain <= image_wr_size2_div;
		image_wr_size2_div_in_load_image_clk_domain_r <= image_wr_size2_div_in_load_image_clk_domain;
end

always @(posedge clk)
begin
		if(image_wr_ram_number_record_en)
			image_wr_ram_number_record	<=	image_wr_ram_n + 1'b1;
end



always @(posedge load_image_clk)
begin
		image_wr_ram_number_record_in_load_image_clk_domain <= image_wr_ram_number_record;
		image_wr_ram_number_record_in_load_image_clk_domain_r <= image_wr_ram_number_record_in_load_image_clk_domain;
end



always @(posedge load_image_clk)
begin
		oneimage_wr_ram_number_record_in_load_image_clk_domain <= oneimage_wr_ram_number_record;
		oneimage_wr_ram_number_record_in_load_image_clk_domain_r <= oneimage_wr_ram_number_record_in_load_image_clk_domain;
end
always @(posedge load_image_clk)
begin
	recordImageNum_inRAM_inLoadImageClk <= recordImageNum_inRAM;
	recordImageNum_inRAM_inLoadImageClk_r <= recordImageNum_inRAM_inLoadImageClk;
end


//pointerOfImage_inRAM pointerOfImage_inRAM_m(
//	.clk(load_image_clk),
//	.rst_n(),
//	.endOfPointer(recordImageNum_inRAM_inLoadImageClk_r),
//	.virtual_pointer(load_image_rd_addr[`IMAGE_SIZE*2+7:`IMAGE_SIZE*2]),
//	.real_pointer(load_image_rd_pointer_inRAM)
//    );

always @(posedge load_image_clk)
begin
	load_image_rd_pointer_inRAM <= load_image_rd_addr[`IMAGE_SIZE*2+7:`IMAGE_SIZE*2];
end

    
assign image_ram_rd_start_addr_temp = load_image_rd_pointer_inRAM * image_rd_pixelNum;
always @(posedge load_image_clk)
begin
		image_ram_rd_start_addr	<=	image_ram_rd_start_addr_temp;

end





always @(posedge load_image_clk)
begin
		load_image_rd_r	<=	load_image_rd;		
end






genvar p;
for(p=0;p<`PARALLEL_NUM;p=p+1)begin: enb_loop	
	always @(posedge load_image_clk)
	begin
			if(image_wr_ram_number_record_in_load_image_clk_domain_r == oneimage_wr_ram_number_record_in_load_image_clk_domain_r)begin
				enb[p]	<=	(image_ram_rd_strobe == p) ? load_image_rd_r : 1'b0;					
			end
			else
				case(oneimage_wr_ram_number_record_in_load_image_clk_domain_r)
				`PARALLEL_WIDTH'd1:
					enb[p]	<=	load_image_rd_r;
				`PARALLEL_WIDTH'd2:begin
					enb[p]	<=	(image_ram_rd_strobe == p || image_ram_rd_strobe + 2'd2 == p || image_ram_rd_strobe + 3'd4 == p || image_ram_rd_strobe + 3'd6 == p) ? load_image_rd_r : 1'b0;
				end
				`PARALLEL_WIDTH'd3:begin
					enb[p]	<=	(image_ram_rd_strobe == p || image_ram_rd_strobe + 2'd3 == p) ? load_image_rd_r : 1'b0;
				end
				`PARALLEL_WIDTH'd4:begin
					enb[p]	<=	(image_ram_rd_strobe == p || image_ram_rd_strobe + 3'd4 == p) ? load_image_rd_r : 1'b0;
				end
				default:
					enb[p]	<=	1'h0;
				endcase
			
	end
end








image_ram_rd_addr_add image_ram_rd_addr_add_m1(
  .A(image_ram_rd_addr_num0),      // input wire [12 : 0] A
  .B(image_ram_rd_start_addr),      // input wire [12 : 0] B
  .CLK(load_image_clk),  // input wire CLK
  .S(image_ram_rd_addr)      // output wire [12 : 0] S
);



multi_rd_addr multi_rd_addr_m1(
	.clk(load_image_clk),
	.rst_n(rst_n),
	.en(load_image_rd),
	.size(image_rd_size_in_load_image_clk_r),
	.multi1(load_image_rd_addr[`IMAGE_SIZE-1:0]),//col_addr
	.multi2(load_image_rd_addr[`IMAGE_SIZE*2-1:`IMAGE_SIZE]),//row_addr
	.result({image_ram_rd_strobe, image_ram_rd_addr_num0})
);


//////////////////////////////////////////////////////////////////////////////////////     
    

/////////////////////////////////channel choose////////////////////////////////////////
reg [`PARALLEL_NUM-1:0]	image_rd_valid_temp;
reg [`PARALLEL_NUM-1:0]	image_rd_valid_temp1;
reg	load_image_rd_r1, load_image_rd_r2, load_image_rd_r3;


always @(posedge load_image_clk)begin
		load_image_rd_r1	<=	load_image_rd_r;
		load_image_rd_r2	<=	load_image_rd_r1;
		load_image_rd_r3	<=	load_image_rd_r2;
end



	
always @(posedge load_image_clk)begin
		image_rd_valid_temp	<=	enb;
		image_rd_valid_temp1	<=	image_rd_valid_temp;		
end




ram_to_cal_virtual_path ram_to_cal_virtual_path_m1(
	.clk(load_image_clk),
	.data(ram_rd_q),
	.choose(image_rd_valid_temp1),
	.q(load_image_rd_q)

);


 
always @(posedge load_image_clk or negedge rst_n) 
begin
	if(!rst_n)
		load_image_valid	<=	'h0;
	else
		case(kernel_rd_num[`PARALLEL_WIDTH-1:0])
		`PARALLEL_WIDTH'd1:begin
			load_image_valid[0]	<=	load_image_rd_r3;
			load_image_valid[1]	<=	1'b0;
			load_image_valid[2]	<=	1'b0;
			load_image_valid[3]	<=	1'b0;
			load_image_valid[4]	<=	1'b0;
			load_image_valid[5]	<=	1'b0;
			load_image_valid[6]	<=	1'b0;
			load_image_valid[7]	<=	1'b0;
		end
		`PARALLEL_WIDTH'd2:begin
			load_image_valid[0]	<=	load_image_rd_r3;
			load_image_valid[1]	<=	load_image_rd_r3;
			load_image_valid[2]	<=	1'b0;
			load_image_valid[3]	<=	1'b0;
			load_image_valid[4]	<=	1'b0;
			load_image_valid[5]	<=	1'b0;
			load_image_valid[6]	<=	1'b0;
			load_image_valid[7]	<=	1'b0;
		end
		`PARALLEL_WIDTH'd3:begin
			load_image_valid[0]	<=	load_image_rd_r3;
			load_image_valid[1]	<=	load_image_rd_r3;
			load_image_valid[2]	<=	load_image_rd_r3;
			load_image_valid[3]	<=	1'b0;
			load_image_valid[4]	<=	1'b0;
			load_image_valid[5]	<=	1'b0;
			load_image_valid[6]	<=	1'b0;
			load_image_valid[7]	<=	1'b0;
		end	
		`PARALLEL_WIDTH'd4:begin
			load_image_valid[0]	<=	load_image_rd_r3;
			load_image_valid[1]	<=	load_image_rd_r3;
			load_image_valid[2]	<=	load_image_rd_r3;
			load_image_valid[3]	<=	load_image_rd_r3;
			load_image_valid[4]	<=	1'b0;
			load_image_valid[5]	<=	1'b0;
			load_image_valid[6]	<=	1'b0;
			load_image_valid[7]	<=	1'b0;
		end	
		`PARALLEL_WIDTH'd5:begin
			load_image_valid[0]	<=	load_image_rd_r3;
			load_image_valid[1]	<=	load_image_rd_r3;
			load_image_valid[2]	<=	load_image_rd_r3;
			load_image_valid[3]	<=	load_image_rd_r3;
			load_image_valid[4]	<=	load_image_rd_r3;
			load_image_valid[5]	<=	1'b0;
			load_image_valid[6]	<=	1'b0;
			load_image_valid[7]	<=	1'b0;
		end	
		`PARALLEL_WIDTH'd6:begin
			load_image_valid[0]	<=	load_image_rd_r3;
			load_image_valid[1]	<=	load_image_rd_r3;
			load_image_valid[2]	<=	load_image_rd_r3;
			load_image_valid[3]	<=	load_image_rd_r3;
			load_image_valid[4]	<=	load_image_rd_r3;
			load_image_valid[5]	<=	load_image_rd_r3;
			load_image_valid[6]	<=	1'b0;
			load_image_valid[7]	<=	1'b0;
		end	
		`PARALLEL_WIDTH'd7:begin
			load_image_valid[0]	<=	load_image_rd_r3;
			load_image_valid[1]	<=	load_image_rd_r3;
			load_image_valid[2]	<=	load_image_rd_r3;
			load_image_valid[3]	<=	load_image_rd_r3;
			load_image_valid[4]	<=	load_image_rd_r3;
			load_image_valid[5]	<=	load_image_rd_r3;
			load_image_valid[6]	<=	load_image_rd_r3;
			load_image_valid[7]	<=	1'b0;
		end	
		`PARALLEL_WIDTH'd8:begin
			load_image_valid[0]	<=	load_image_rd_r3;
			load_image_valid[1]	<=	load_image_rd_r3;
			load_image_valid[2]	<=	load_image_rd_r3;
			load_image_valid[3]	<=	load_image_rd_r3;
			load_image_valid[4]	<=	load_image_rd_r3;
			load_image_valid[5]	<=	load_image_rd_r3;
			load_image_valid[6]	<=	load_image_rd_r3;
			load_image_valid[7]	<=	load_image_rd_r3;
		end	
		endcase

end

//////////////////////////////////////////////////////////////////////////////////////////








  
    
////////////////////////////////////////read need request///////////////////////////////
reg infor_update_in_clk_domain;
reg infor_update_in_clk_domain_r;
reg image_rd_update_in_clk_domain;
reg image_rd_update_in_clk_domain_r;
(*DONT_TOUCH="TRUE"*)reg [3:0] inforUpdate_delay=0;
reg infor_update_r=1'b0;
reg algorithm_finish_req = 1'b0;
reg algorithm_finish_req_r, algorithm_finish_req_r1;
reg algorithm_finish_ack = 1'b0;
reg algorithm_finish_ack_r, algorithm_finish_ack_r1;



always @(posedge load_head_clk)
begin
	if(inforUpdate_delay != 4'h0 || infor_update)
		inforUpdate_delay <= inforUpdate_delay + 1'b1;
end
always @(posedge load_head_clk)
begin
	if(inforUpdate_delay != 4'h0)
		infor_update_r <= 1'b1;
	else
		infor_update_r <= 1'b0;
end
always @(posedge clk)
begin
		infor_update_in_clk_domain <= infor_update_r;
		infor_update_in_clk_domain_r <= infor_update_in_clk_domain;
end

always @(posedge clk)
begin
		image_rd_update_in_clk_domain <= image_rd_update;
		image_rd_update_in_clk_domain_r <= image_rd_update_in_clk_domain;
end

always @(posedge load_image_clk)
begin
	if(algorithm_finish)
		algorithm_finish_req <= 1'b1;
	else if(algorithm_finish_ack_r1)
		algorithm_finish_req <= 1'b0;
end
always @(posedge clk)
begin
	algorithm_finish_req_r <= algorithm_finish_req;
	algorithm_finish_req_r1 <= algorithm_finish_req_r;
end
always @(posedge clk)
begin
	if(algorithm_finish_req_r1)
		algorithm_finish_ack <= 1'b1;
	else 
		algorithm_finish_ack <= 1'b0;
end
always @(posedge load_image_clk)
begin
	algorithm_finish_ack_r <= algorithm_finish_ack;
	algorithm_finish_ack_r1 <= algorithm_finish_ack_r;
end
always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			image_rd_ready	<=	1'b0;
		else if(image_wr_finish)
			image_rd_ready	<=	1'b1;
		else if((image_rd_update_in_clk_domain_r && infor_update_in_clk_domain_r) || algorithm_finish_req_r1)
			image_rd_ready	<=	1'b0;
end

always @(posedge clk or negedge rst_n)
begin
		if(!rst_n)
			image_rd_need	<=	1'b0;
		else if(image_rd_update_in_clk_domain_r && infor_update_in_clk_domain_r)
			image_rd_need	<=	1'b1;
		else if(image_wr_finish)
			image_rd_need	<=	1'b0;
end
///////////////////////////////////////////////////////////////////////////////////////    
    













    
    
endmodule







