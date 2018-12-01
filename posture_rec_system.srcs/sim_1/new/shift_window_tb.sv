`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/28 19:59:59
// Design Name: 
// Module Name: shift_window_tb
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


module shift_window_tb(
	input	clk,
	input	[`MAX_KERNEL_SIZE*`IMAGE_ELE_BITWIDTH-1:0]	data1,
	input	valid1
	
    );
    

 

logic [`IMAGE_ELE_BITWIDTH-1:0] data1_array[`MAX_KERNEL_SIZE];


 
int fd1;


parameter	DATA1_FILE	=	"F:/posture_rec/posture_recognition/posture_recognition.srcs/sim_1/imports/testfile/data1.txt";
 
  


  
genvar k;
for(k=0;k<`MAX_KERNEL_SIZE;k=k+1)begin: data1_loop
	assign	data1_array[k]	= data1[`IMAGE_ELE_BITWIDTH*(k+1)-1:`IMAGE_ELE_BITWIDTH*k];
end
 
 
    
initial begin
	
	@(posedge valid1);
	fd1=$fopen(DATA1_FILE,"w");
	@(negedge clk);
	
	forever begin
		
		if(valid1)begin
			for(int i=0;i<`MAX_KERNEL_SIZE;i++)begin
				$fdisplay(fd1,"%8h",data1_array[i]);
			end//for
			$fdisplay(fd1,"--------------");
		end	
		
		@(negedge clk);
			
	end//forever
	
	$fclose(fd1);
	
end    
    
    






    
    
endmodule