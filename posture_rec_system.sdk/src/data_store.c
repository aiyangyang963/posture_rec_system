/*
 * data_store.c
 *
 *  Created on: 2017Äê12ÔÂ23ÈÕ
 *      Author: anpingbo
 */




#include "data_store.h"
#include "sdcard.h"
#include <string.h>
#include <stdio.h>


u32 head_info[HEAD_SIZE] __attribute__((section(".headSection")));
u32 image1_info[IMAGE_SIZE] __attribute__((section(".image1Section")));
u32 image2_info[IMAGE_SIZE] __attribute__((section(".image2Section")));
u32 kernel_info[KERNEL_SIZE] __attribute__((section(".kernelSection")));

char fnum;

void fillDDR(){

	unsigned int fsize;
	unsigned int bufferSize;
	sdcard_init();
	fsize=get_fileSize(HEAD_FILE)/sizeof(u32);
	bufferSize=(fsize<HEAD_SIZE)?fsize:HEAD_SIZE;
	sdcard_read(HEAD_FILE,head_info, bufferSize);

	fsize=get_fileSize(KERNEL_FILE)/sizeof(u32);
	bufferSize=(fsize<KERNEL_SIZE)?fsize:KERNEL_SIZE;
	sdcard_read(KERNEL_FILE,kernel_info,bufferSize);

	fsize=get_fileSize(IMAGE_FILE)/sizeof(u32);
	bufferSize=(fsize<IMAGE_SIZE)?fsize:IMAGE_SIZE;
	sdcard_read(IMAGE_FILE,image1_info,bufferSize);


}


unsigned int fmap_size(char fnum){
	unsigned int size;
	switch(fnum){
	case 0:size=100352;break;
	case 1:size=50176;break;
	case 2:size=25088;break;
	case 3:size=12544;break;
	case 4:size=6272;break;
	case 5:size=12544;break;
	case 6:size=1960;break;
	default:size=0;break;
	}

	return size;
}


void save_fmap_in_sd(){
	char file[15];
	strcpy(file,"0:fmap");
	char fnumStr[6];
	fnumStr[0]=fnum+48;
	fnumStr[1]='.';
	fnumStr[2]='b';
	fnumStr[3]='i';
	fnumStr[4]='n';
	fnumStr[5]='\0';
	strcat(file,fnumStr);


	unsigned int size=fmap_size(fnum);
	if(fnum%2==0)
		sdcard_write(file,image2_info,size);
	else
		sdcard_write(file,image1_info,size);


}



