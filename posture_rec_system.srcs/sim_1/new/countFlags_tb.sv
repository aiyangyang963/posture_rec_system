`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/25 16:29:18
// Design Name: 
// Module Name: countFlags_tb
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


module countFlags_tb(
	input clk,
	input rst_n,
	input flag1,
	input flag2,
	input flag3
    );
    
    
countFlags_Program countFlags_Program_m(
    	.clk(clk),
    	.rst_n(rst_n),
    	.flag1(flag1),
    	.flag2(flag2),
    	.flag3(flag3)
        );    
    
      
endmodule

program countFlags_Program(
	input clk,
	input rst_n,
	input flag1,
	input flag2,
	input flag3
    );
parameter  CLOCK_LIMITE = 500;    
    
int flag1_cnt;
int flag2_cnt;
int flag3_cnt;
int flag1_clock_cnt;
int flag2_clock_cnt;
int flag3_clock_cnt;
int outFile;
initial begin
	flag1_cnt = 0;
	flag2_cnt = 0;
	flag3_cnt = 0;
	flag1_clock_cnt = 0;
	flag2_clock_cnt = 0;
	flag3_clock_cnt = 0;
	@(posedge rst_n);
	@(posedge flag1);
	fork
		while(flag1_clock_cnt < CLOCK_LIMITE)begin
			if(flag1)begin
				flag1_cnt = flag1_cnt + 1;
				flag1_clock_cnt = 0;
			end
			else begin
				flag1_clock_cnt = flag1_clock_cnt + 1;				
			end
			@(posedge clk);
		end//while(floag1)
		
		while(flag2_clock_cnt < CLOCK_LIMITE)begin
			if(flag2)begin
				flag2_cnt = flag2_cnt + 1;
				flag2_clock_cnt = 0;
			end
			else begin
				flag2_clock_cnt = flag2_clock_cnt + 1;				
			end
			@(posedge clk);
		end//while(floag2)		

		while(flag3_clock_cnt < CLOCK_LIMITE)begin
			if(flag3)begin
				flag3_cnt = flag3_cnt + 1;
				flag3_clock_cnt = 0;
			end
			else begin
				flag3_clock_cnt = flag3_clock_cnt + 1;				
			end
			@(posedge clk);
		end//while(floag3)	
			
	join
	
	$display("Flag1 is: %d \n flag2 is: %d \n flag3 is: %d \n", flag1_cnt, flag2_cnt, flag3_cnt);
	flag1_cnt = 0;
	flag2_cnt = 0;
	flag3_cnt = 0;	
end  

endprogram
