`timescale 1ns / 1ps
`include "network_parameters.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/27 10:53:03
// Design Name: 
// Module Name: data_write
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


 

module data_write(
	data_transport.master a

    );



int fd1;
int fd2;

logic [`KERNEL_BITWIDTH-1:0] data1_array[`PARALLEL_NUM];
logic [`KERNEL_BITWIDTH-1:0] data2_array[`PARALLEL_NUM][`MAX_KERNEL_SIZE];


parameter	DATA1_FILE	=	"F:/posture_rec/posture_recognition/posture_recognition.srcs/sim_1/imports/testfile/data1.txt";
parameter	DATA2_FILE	=	"F:/posture_rec/posture_recognition/posture_recognition.srcs/sim_1/imports/testfile/data2.txt";



genvar k;
for(k=0;k<`PARALLEL_NUM;k=k+1)begin: data1_loop
	assign	data1_array[k]	=	a.data1[`KERNEL_BITWIDTH*(k+1)-1:`KERNEL_BITWIDTH*k];
end


genvar p;
genvar q;
for(p=0;p<`PARALLEL_NUM;p=p+1)begin: data2_loop1
	for(q=0;q<`MAX_KERNEL_SIZE;q=q+1) begin:data2_loop2
		assign	data2_array[p][q]	=	a.data2[`KERNEL_ELE_BITWIDTH*(p*`MAX_KERNEL_SIZE+q+1)-1:`KERNEL_ELE_BITWIDTH*(p*`MAX_KERNEL_SIZE+q)];
	end
end



initial begin: data_write
	
	fork 
		
		 begin: data1_write
		 fd1=$fopen(DATA1_FILE,"w");
		 forever begin
		 			
			@(posedge a.valid1);
			#0;
			while(a.valid1)begin
				for(int i=0;i<`PARALLEL_NUM;i++)begin
					$fdisplay(fd1, "%h ",data1_array[i]);
				end//for
				$fdisplay(fd1,"\n");	
				@(posedge a.clk);
			end//while
			
			
		end//forever	
			$fclose(fd1);
		end//begin
		
		
		
		 begin: data2_write
		 fd2=$fopen(DATA2_FILE,"w");
		 forever begin
			
			@(posedge a.valid2);	
			#0;
			while(a.valid2)begin
				$fdisplay(fd2, "----------------------------------------");
				for(int i=0;i<`PARALLEL_NUM;i++)begin
					for(int j=0;j<`MAX_KERNEL_SIZE;j++)begin
						$fdisplay(fd2, "%h ",data2_array[i][j]);
					end
				end//for
				$fdisplay(fd2, "\n");	
				@(posedge a.clk);
			end//while
			
			
		end//forever	
			$fclose(fd2);
		end//begin




	
	join
	
	
end









    
    
    
endmodule
