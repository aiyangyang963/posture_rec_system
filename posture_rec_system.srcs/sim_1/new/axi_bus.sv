`timescale 1ns / 100ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/04 13:57:38
// Design Name: 
// Module Name: axi_bus
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: axi bus that read and write to ddr
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_bus(
	clk,
	
	acken,
	
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
	
	image_finish_inter,
	one_layer_finish

    );
    
    
    
    
    
input							clk;
input							acken;
    
input  [5:0]       			   awid;//ID for write-address
input  [`AXI_ADDR_WIDTH-1:0]      awaddr;//write address
input  [7:0]       			   awlen;//length of one burst write
input  [2:0]                      awsize;//burst size£º1£¬2£¬4£¬8£¬16£¬32£¬64£¬128
input  [1:0]                      awburst;//burst type
input                             awlock;//atomic access signaling
input  [3:0]                      awcache;//cache type
input  [2:0]                      awprot;//protection type
input  [3:0]                      awqos;//quality of service
input  [3:0]                      awregion;//region identifier
input                             awvalid;//the valid signal
output  logic                     awready;//the write address is ready

input  logic[`AXI_DATA_WIDTH-1:0]      wdata;//write data
input  [`AXI_VALID_BYTE-1:0]  	   wstrb;//indicate which byte lanes hold valid data. one strobe bit for each 8 bits
input                             wlast;//the last transfer in one burst write
input                             wvalid;//indicate that the data and strobe is valid
output   logic                    wready;//indicate that the slave have recieved the data


output   [5:0]                      bid;//responce ID tag
output   logic[1:0]                 bresp;//write responce
output   logic                      bvalid;//the response data is valid
input                               bready;//ready to recieve the write response

input  [5:0]                      arid;//identification tag for the read address group of signals
input  [`AXI_ADDR_WIDTH-1:0]      araddr;//read address
input  [7:0]                      arlen;//burst length
input  [2:0]                      arsize;//burst size
input  [1:0]                      arburst;//burst type
input                             arlock;//lock type
input  [3:0]                      arcache;//how transactions acess the memory system
input  [2:0]                      arprot;//protect type
input  [3:0]                      arqos;//quality of service
input  [3:0]                      arregion;//permits a single physical interface on a slave to be used 
input                             arvalid;//the read address is valid
output  logic                     arready;//the read address is acceptied

output   logic[5:0]                 rid;//read ID tag
output   logic[`AXI_DATA_WIDTH-1:0] rdata;//read data
output   logic[1:0]                 rresp;//read response
output   logic                      rlast;//the last read data
output   logic                      rvalid;//indicate that the read data is valid
input                              rready;//the read data is accepted    

input								image_finish_inter;
input								one_layer_finish;    
 
logic[`AXI_ADDR_WIDTH-1:0]	awaddr_s;//start of the awaddr
int unsigned awlength;


logic[`AXI_ADDR_WIDTH-1:0]	araddr_s;//start of the awaddr
int unsigned arlength;

parameter	IMAGE_FILE1	=	"F:/postureRec/posture_recognition/posture_recognition.srcs/sim_1/imports/file_ddr/image1.bin";
parameter	IMAGE_FILE2	=	"F:/postureRec/posture_recognition/posture_recognition.srcs/sim_1/imports/file_ddr/image2.bin";
parameter	KERNEL_FILE	=	"F:/postureRec/posture_recognition/posture_recognition.srcs/sim_1/imports/file_ddr/conv_parameter_arranged.bin";
parameter	HEAD_FILE	=	"F:/postureRec/posture_recognition/posture_recognition.srcs/sim_1/imports/file_ddr/conv_control.bin";
parameter	TEMP_IMAGE	=	"F:/postureRec/posture_recognition/posture_recognition.srcs/sim_1/imports/file_ddr/temp_image";
parameter  IMG_OPE	=	".txt";

logic[`AXI_DATA_WIDTH-1:0]	rdata_array[`MAX_BURST_LENGTH];
logic[`AXI_DATA_WIDTH-1:0]	wdata_array[`MAX_BURST_LENGTH];

int i=0;





int file_handle;
initial begin
		awready	=	1'b0;
		wready	=	1'b0;
		bresp	=	2'b0;
		bvalid	=	1'b0;
		arready	=	1'b0;//the read address is acceptied
		
		rid	=	5'b0;//read ID tag
		rdata	=	`AXI_DATA_WIDTH'h0;//read data
		rresp	=	2'b0;//read response
		rlast	=	1'b0;//the last read data
		rvalid	=	1'b0;//indicate that the read data is valid
		for(int i=0;i<`MAX_BURST_LENGTH;i++)begin
			rdata_array[i]	=	`AXI_DATA_WIDTH'h0;
			wdata_array[i]	=	`AXI_DATA_WIDTH'h0;
		end

end

int nlayer;
initial begin
	nlayer=0;
	forever begin
	@(posedge clk);
	if(one_layer_finish)
	 nlayer=nlayer+1;
	else if(image_finish_inter)
	nlayer=0;
	end
end

 
always
begin
	if(acken)begin	
			@(posedge awvalid);
			awready	=	1'b1;
			get_awaddr(awaddr, awlen, awsize, awaddr_s, awlength);	
			@(posedge clk);
			awready	=	1'b0;			
			wready	=	1'b0;
			
			while(i<awlength/`AXI_BYTE_NUM)begin
				
				if(wvalid)begin
					if(wlast)begin
						wdata_array[i] =	wdata;
						wready	=	1'b1;
						i++;
					end//if(wlast)
					else 
					begin
						if(i==awlength/(4*`AXI_BYTE_NUM))begin
							wready	=	1'b0;
							repeat(6) @(negedge clk);
							wready	=	1'b1;
							wdata_array[i] =	wdata;
							i++;
						end//if(i==awlength/(4*`AXI_BYTE_NUM))
						else 
						begin
							wdata_array[i] =	wdata;
							wready	=	1'b1;
							i++;
						end//else if(i==awlength/(4*`AXI_BYTE_NUM))
					end//else if(wlast)				
				end//if(wvalid)
				else begin
					wready	=	1'b0;						
				end//else (wvalid)				
				@(negedge clk);				
			end//while()
			
			i=0;
			wready	=	1'b0;				
			write_data(awaddr_s, awlength, wdata_array);
			write_middle_data(awlength, nlayer, wdata_array);
			
			repeat(4)begin
				@(posedge clk);
			end
			bresp	=	2'b00;//nomal access okay
			bvalid	=	1'b1;
			@(negedge bready);
			bvalid	=	1'b0;	
	end//if(acken)
	else
		@(posedge clk);		
end//always





initial begin
		@(posedge acken);
		forever begin
			@(posedge arvalid);
			get_araddr(araddr, arlen, arsize, araddr_s, arlength);	
			arready	=	1'b1;
			@(posedge clk);
			arready	=	1'b0;
			read_data(araddr_s, arlength, rdata_array);			
			begin: send_data
				for(int k=0;k<arlength/`AXI_BYTE_NUM;k++)begin
					if(k==arlength/`AXI_BYTE_NUM-1)begin
						rlast	=	1'b1;
						rdata	=	rdata_array[k];
						rvalid	=	1'b1;
						@(posedge clk);
						while(!rready);
						rvalid	=	1'b0;
						rlast	=	1'b0;
						
					end
					else begin
						rlast	=	1'b0;
						rdata	=	rdata_array[k];
						rvalid	=	1'b1;
						rresp	=	`AXI_OKAY;
						@(posedge clk);
						while(!rready);
					end
				end
			
					
			end
		end
end













//task for get the write address and length
task get_awaddr;
input	logic[`AXI_ADDR_WIDTH-1:0]	addr;
input  	logic[7:0]	len;//length of one burst write
input  	logic[2:0]  size;//burst size£º1£¬2£¬4£¬8£¬16£¬32£¬64£¬128


output	logic[`AXI_ADDR_WIDTH-1:0]	addr_s;//start of the awaddr
output	int unsigned length;


int unsigned size_a;

		
	addr_s	=	addr;
	size_a=size_cal(size);//get the real size
	length	=	(len+1)*size_a;



endtask


//task for get the write address and length
task get_araddr;
input	logic[`AXI_ADDR_WIDTH-1:0]	addr;
input  	logic[7:0]	len;//length of one burst write
input  	logic[2:0]  size;//burst size£º1£¬2£¬4£¬8£¬16£¬32£¬64£¬128

output	logic[`AXI_ADDR_WIDTH-1:0]	addr_s;//start of the awaddr
output	int unsigned length;

int unsigned size_a;

		
	addr_s	=	addr;
	size_a=size_cal(size);//get the real size
	length	=	(len+1)*size_a;



endtask



//calculate the size in one data
function int unsigned size_cal(input logic[2:0] asize);

	case(asize)
	3'b000:	return 1;
	3'b001: return 2;
	3'b010:	return 4;
	3'b011: return 8;
	3'b100: return 16;
	3'b101: return 32;
	3'b110:	return 64;
	3'b111: return 128;
	endcase



endfunction

 
 
 
 
task automatic write_data(
	input	logic[`AXI_ADDR_WIDTH-1:0]	awaddr_s,
	input	int unsigned awlength,
	ref logic[`AXI_DATA_WIDTH-1:0]	wdata_array[`MAX_BURST_LENGTH]
	);
	
	
	int file_in;	
	integer seek_code;
	
	
	if(awaddr_s >= `IMAGE_BASE_ADDR1 && awaddr_s < `IMAGE_BASE_ADDR2)
		file_in=$fopen(IMAGE_FILE1,"rb+");
	else if(awaddr_s >= `IMAGE_BASE_ADDR2 && awaddr_s < `KERNEL_BASE_ADDR)
		file_in=$fopen(IMAGE_FILE2,"rb+");
	seek_code=$fseek(file_in,awaddr_s,0);
	
	for(int n=0;n<awlength/`AXI_BYTE_NUM;n++)begin
		$fwrite(file_in, "%c%c%c%c%c%c%c%c",wdata_array[n][7:0], wdata_array[n][15:8], wdata_array[n][23:16], wdata_array[n][31:24],
		wdata_array[n][39:32], wdata_array[n][47:40], wdata_array[n][55:48],wdata_array[n][63:56]);
	end	
	$fclose(file_in);
			
endtask 
 
 

task automatic write_middle_data(
	input	int unsigned awlength,
	input	int nlayer,
	ref logic[`AXI_DATA_WIDTH-1:0]	wdata_array[`MAX_BURST_LENGTH]
	); 


int file_in;
string fileLabel = i_to_a(nlayer);
string fileDir=TEMP_IMAGE;
string fileOpe=IMG_OPE;
string fileName={fileDir, fileLabel, fileOpe};



file_in=$fopen(fileName, "a+");
//$fwrite(file_in, "%d:\n", 2*awlength/`AXI_BYTE_NUM);
for(int n=0;n<awlength/`AXI_BYTE_NUM;n++)begin
	$fwrite(file_in, "%f%c%f%c", i_to_real(wdata_array[n][31:0]), " ", i_to_real(wdata_array[n][63:32]), " ");
end
$fwrite(file_in, "%c", "\n");
$fclose(file_in);

endtask

function string i_to_a(input int i);
	string p;
	case(i)
	0: p="0";
	1: p="1";
	2: p="2";
	3: p="3";
	4: p="4";
	5: p="5";
	6: p="6";
	7: p="7";
	8: p="8";
	9: p="9";
	endcase
	return p;
endfunction



function shortreal i_to_real(
	input logic [31:0] data
); 
bit sign;
shortreal tail;
int exp;
shortreal exp_val;
shortreal result;

sign = data[31];
tail=0;
for(int i=0;i<=22;i++)begin
	if(data[i])
		tail=tail+1;
	tail=tail/2.0;	
end
tail=tail+1;


exp=0;
for(int j=30;j>=23;j--)begin
	if(data[j])
		exp=(exp<<1)+1;
	else
		exp=exp<<1;
end
exp=exp-127;

exp_val=1;
if(exp<0)begin
	while(exp!=0)begin
		exp_val=exp_val/2.0;
		exp++;
	end
end
else if(exp>0)begin
	while(exp!=0)begin
		exp_val=exp_val*2;
		exp--;
	end
end
else if(exp==0)begin
	exp_val=1;
end

result= sign ? -tail*exp_val : tail*exp_val;
return result;

endfunction   
 
 
 
 
task automatic read_data(
	input	logic[`AXI_ADDR_WIDTH-1:0]	araddr_s,
	input	int unsigned arlength,	
	ref	logic[`AXI_DATA_WIDTH-1:0]	rdata_array[`MAX_BURST_LENGTH]	
	);
	
	

	static logic[`AXI_DATA_WIDTH-1:0] rdata_temp;
	int unsigned file_out;
	int seek_code;
	int read_code;
	
	
	repeat(4)begin
		@(posedge clk);
	end
	
	if(araddr_s<`IMAGE_BASE_ADDR1)begin//head data
		file_out=$fopen(HEAD_FILE,"rb");		
	end
	else if(araddr_s>=`IMAGE_BASE_ADDR1 && araddr_s<`IMAGE_BASE_ADDR2)begin
		file_out=$fopen(IMAGE_FILE1,"rb");
		araddr_s=araddr_s-`IMAGE_BASE_ADDR1;
	end
	else if(araddr_s>=`IMAGE_BASE_ADDR2 && araddr_s<`KERNEL_BASE_ADDR)begin
		file_out=$fopen(IMAGE_FILE2,"rb");
		araddr_s=araddr_s-`IMAGE_BASE_ADDR2;
	end
	else if(araddr_s>=`KERNEL_BASE_ADDR)begin
		file_out=$fopen(KERNEL_FILE,"rb");
		araddr_s=araddr_s-`KERNEL_BASE_ADDR;
	end
	
	
	seek_code=$fseek(file_out, araddr_s, 0);	
	read_code=$fread(rdata_temp, file_out);
	for(int i=0;i<arlength/`AXI_BYTE_NUM;i++)begin
		if(!$feof(file_out))begin
			rdata_array[i]={rdata_temp[7:0], rdata_temp[15:8], rdata_temp[23:16],
							rdata_temp[31:24], rdata_temp[39:32], rdata_temp[47:40],
							rdata_temp[55:48], rdata_temp[63:56]};
			read_code=$fread(rdata_temp, file_out);
		end
		else
			break;
	end	
	$fclose(file_out);
	

	
endtask 







 

 
    
endmodule









