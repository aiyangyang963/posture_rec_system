`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: hotzone company
// Engineer: An Pingbo
// 
// Create Date: 2017/09/27 16:35:25
// Design Name: 
// Module Name: load_image_tb
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


module load_image_tb(
	input	clk,
	input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	data1,
	input	[`PARALLEL_NUM-1:0]	valid1,
	input	[`IMAGE_ELE_BITWIDTH*`PARALLEL_NUM-1:0]	data2,
	input	[`PARALLEL_NUM-1:0]	valid2
	
    );
    
logic valid1_or;
logic valid2_or;  

logic [`IMAGE_ELE_BITWIDTH-1:0] data1_array[`PARALLEL_NUM];
logic [`IMAGE_ELE_BITWIDTH-1:0] data2_array[`PARALLEL_NUM];

 
int fd1;
int fd2; 

parameter	DATA1_FILE	=	"F:/posture_rec/posture_recognition/posture_recognition.srcs/sim_1/imports/testfile/data1.txt";
parameter	DATA2_FILE	=	"F:/posture_rec/posture_recognition/posture_recognition.srcs/sim_1/imports/testfile/data2.txt";
  
  
assign	  valid1_or	=  |valid1;
assign	  valid2_or	=  |valid2;  
  
genvar k;
for(k=0;k<`PARALLEL_NUM;k=k+1)begin: data1_loop
	assign	data1_array[k]	= data1[`IMAGE_ELE_BITWIDTH*(k+1)-1:`IMAGE_ELE_BITWIDTH*k];
	assign	data2_array[k]	= data2[`IMAGE_ELE_BITWIDTH*(k+1)-1:`IMAGE_ELE_BITWIDTH*k];
end
 
 
    
initial begin
	
	@(posedge valid1_or);
	fd1=$fopen(DATA1_FILE,"w");
	
	forever begin
		while(valid1_or)begin
			for(int i=0;i<`PARALLEL_NUM;i++)begin
				if(valid1[i])
					$fdisplay(fd1,"%8h",data1_array[i]);
				else
					$fdisplay(fd1,"%8h",32'hxxxx);
			end//for
			@(posedge clk);
		end//while
	end//forever
	
	$fclose(fd1);
	
end    
    
    




initial begin
	
	@(posedge valid2_or);
	fd2=$fopen(DATA2_FILE,"w");
	
	forever begin
		while(valid2_or)begin
			for(int i=0;i<`PARALLEL_NUM;i++)begin
				if(valid2[i])
					$fdisplay(fd2,"%8h",data2_array[i]);
				else
					$fdisplay(fd2,"%8h",32'hxxxx);
			end//for
			@(posedge clk);
		end//while
	end//forever
	
	$fclose(fd2);
	
end




    
    
endmodule
