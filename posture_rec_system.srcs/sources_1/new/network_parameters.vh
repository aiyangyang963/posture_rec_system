//AXI4 varivables definition
`define 		AXI_DATA_WIDTH		64//data width of AXI bus
`define 		AXI_ADDR_WIDTH		32//address width of AXI bus
`define 		AXI_VALID_BYTE		8//valid data bytes of AXI bus
`define 		AXI_BYTE_NUM		8//AXI_DATA_WIDTH/8
`define 		AXI_OKAY			2'b00//indicator that the result of the transportation from or to AXI bus, indicate that the transportation from or to AXI bus is successful
`define 		AXI_EXOKAY			2'b01//indicator that the result of the transportation from or to AXI bus
`define 		AXI_SLVER			2'b10//indicator that the result of the transportation from or to AXI bus
`define 		AXI_DECER			2'b11//indicator that the result of the transportation from or to AXI bus
`define 		MAX_BURST_LENGTH	256//the max burst length for one transfer in AXI bus
`define			MAX_BURST_HEAD_LENGTH	1//the max burst length of the head information in AXI bus
`define 		BURST_LENGTH_WIDTH	8//the data width of the burst length


`define 		HEAD_WIDTH			64//data width of the head information
`define 		KERNEL_NUM			5//the data width of kernel number
`define			KERNEL_NUM_RED		3//reduced data width of kernel number, for example {`KERNEL_NUM_RED'h0,kernel_wr_num}

`define 		FILTER_NUM			8//data width of filter number

`define 		KERNEL_BITWIDTH		64//data width of kernel, same with the AXI bus data width
`define			KERNEL_ELE_BITWIDTH	32//2 kernel elemnets in one transfer in AXI bus, so the elemnet width is 32
`define 		KERNEL_SIZE			4//data width of kernel size, 3X3, 1X1

`define			BIAS_ELE_BITWIDTH	32//the data width of the bias
`define			DIV_ELE_BITWIDTH	32//the data width of the divider

`define			MAX_KERNEL_SIZE		9//the max number of elemnets in one convolution kernel, for 3X3=9
`define			MAX_KERNEL_BIAS_DIV_LEN	6//the number of elements including kernel(3X3), bias, divider is 11, after aligned in 2 elemnets, will be 6
`define			KERNEL_STEP			3//data width of kernel shift step
`define 		IMAGE_NUM			13//data width of image number
`define 		IMAGE_SIZE			8//data width of image size
`define 		IMAGE_BITWIDTH		64//the data width of image data in AXI bus
`define			IMAGE_ELE_BITWIDTH	32//the data width of image element





`define 	SUB_A_WIDTH		16//in sub_com module
`define 	SUB_B_WIDTH		9//in sub_com module




`define 	HEAD_BASE_ADDR			32'h7100_0000//the DDR base address for containing head information
`define 	KERNEL_BASE_ADDR		32'h7120_0000//the DDR base address for containing kernel, bias, divider
`define 	IMAGE_BASE_ADDR1		32'h7160_0000//the 1 DDR base address for containing image
`define		IMAGE_BASE_ADDR2		32'h7180_0000//the 2 DDR base address for containing image
`define 	ADDR_HIGH_BIT_WIDTH		24//32-8
`define 	ADDR_LOW_BIT_WIDTH		8//32-8


`define 	PARALLEL_NUM		8//number of parallel channels
`define 	PARALLEL_WIDTH		4//data width of parallel channel

`define 	IMAGE_RAM_ADDR_WIDTH	12//the ram address width for containing image
`define 	IMAGE_RAM_ADDR_WIDTH2	13//the ram address width for containing image

`define 	CNT_WIDTH		16//in counter_addr module
`define 	RESULT_BITWIDTH	 16//PARALLEL_WIDTH+IMAGE_RAM_ADDR_WIDTH



`define		POSTIMAGE_BITWIDTH		64//data width for deal_PostImage module
`define		POSTIMAGE_CHANNEL		8//parallel channels
`define		POSTIMAGE_CHANNEL_BITWIDTH		4//data width of the number of channel
`define		POSTIMAGE_RAMDEPTH_WIDTH		12//ram adress width for storing the output image

`define		WINDOW_ROW			3//in convolution, the buffer have WINDOW_ROW lines image data
`define		WINDOW_COL			8//in convolution, the buffer have WINDOW_COL columns image data
`define		WINDOW_ROW_BITWIDTH		2//data width of WINDOW_ROW
`define		WINDOW_COL_BITWIDTH		3//data width of WINDOW_COL

`define		FLT_MAX		32'hFFFFFFFF


`define		INTER_DELAY		2//delay for interrupt
`define		INTER_DELAY_BITWIDTH	4//data width for interrupt delay
`define		LAYER_NUM	7//network layers
`define		LAYER1_RETURN_NUM	8//the returned number of image in layer 1
`define		LAYER2_RETURN_NUM	16//the returned number of image in layer 2
`define		LAYER3_RETURN_NUM	32//......................................3
`define		LAYER4_RETURN_NUM	64//.....................................4
`define		LAYER5_RETURN_NUM	128//.....................................5
`define		LAYER6_RETURN_NUM	256//.....................................6
`define		LAYER7_RETURN_NUM	40//....................................7



`define 	EXPONET_WIDTH 8//in rect linear


