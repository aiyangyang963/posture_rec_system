/*
 * data_store.h
 *
 *  Created on: 2017Äê12ÔÂ23ÈÕ
 *      Author: anpingbo
 */

#ifndef SRC_DATA_STORE_H_
#define SRC_DATA_STORE_H_

#include "xil_types.h"
#include <stdio.h>
#include <stdlib.h>



#define HEAD_SIZE 0x00080000
#define IMAGE_SIZE 0x00080000
#define KERNEL_SIZE 0x00100000

//#define HEAD_FILE "1:ctrl.bin"
#define HEAD_FILE "1:conv2_bin"
#define KERNEL_FILE "1:para.bin"
#define IMAGE_FILE "1:image1.bin"
//#define IMAGE_FILE "1:fmap0.bin"

extern u32 head_info[];
extern u32 image1_info[];
extern u32 image2_info[];
extern u32 kernel_info[];

extern char fnum;

void fillDDR();
void save_fmap_in_sd();
unsigned int fmap_size(char fnum);



#endif /* SRC_DATA_STORE_H_ */
