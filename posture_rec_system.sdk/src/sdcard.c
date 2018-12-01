/*
 * sdcard.c
 *
 *  Created on: 2018Äê2ÔÂ27ÈÕ
 *      Author: anpingbo
 */

#include "sdcard.h"
#include "common.h"
#include <xil_printf.h>
#include <xsdps.h>
#include <diskio.h>
#include <ff.h>
#include "parameters.h"



FATFS fs;
FRESULT res_sd;

int sdcard_init(){



	res_sd=f_mount(&fs,"1:",1);
	if(res_sd==FR_NO_FILESYSTEM){
		xil_printf("ERROR: No file system\n");
#ifdef MKFS_SD
		xil_printf("begin to format the SD .........\n");
		res_sd=f_mkfs("1:",0,0);
		if(res_sd==FR_OK){
			xil_printf("succeed to format SD \n");
			res_sd=f_mount(NULL,"1:",1);
			res_sd=f_mount(&fs,"1:",1);
			if(res_sd==FR_OK){
				xil_printf("succeed to mount the SD\n");
				return 1;
			}
			else{
				xil_printf("ERROR: when mount the file system\n");
				return 0;
			}
		}//if(res_sd==FR_OK)
		else{
			xil_printf("ERROR: when format the file system\n");
			return 0;
		}
#endif
		return 0;
	}
	else if(res_sd==FR_OK){
		xil_printf("succeed to mount file system\n");
		return 1;
	}
	else{
		xil_printf("ERROR: cannot mount file system\n");
		return 0;
	}


}


int sdcard_read(char *file,u32 *buffer, unsigned int size){
	FIL fin;
	unsigned int br;
	res_sd=f_open(&fin,file,FA_READ);
	if(res_sd!=FR_OK){
		xil_printf("ERROR: cannot open the file %s\n",file);
		return 0;
	}
	res_sd=f_read(&fin,buffer,sizeof(u32)*size,&br);
	f_close(&fin);

#ifdef DEBUG
	xil_printf("--------------the initial data is: ----------------\n");
	for(int i=0;i<size;i++){
		xil_printf("%d ", buffer[i]);
		if(size%40==39)
			xil_printf("\n");
	}
	xil_printf("------------------------------------------------------------\n");
#endif

	if(res_sd==FR_OK){
		xil_printf("succeed to read %d data from file %s\n",br,file);
		return 1;
	}
	else{
		xil_printf("ERROR: read from file %s\n", file);
		return 0;
	}

}


int sdcard_write(char *file, u32 *buffer, unsigned int size){
	FIL fout;
	unsigned int bw;
	res_sd=f_open(&fout,file,FA_WRITE | FA_CREATE_ALWAYS);
	if(res_sd==FR_EXIST){
		xil_printf("WARN: file %s exist\n",file);

	}
	else if(res_sd!=FR_OK){
		xil_printf("ERROR: when open file %s\n",file);
		return 0;
	}

	res_sd=f_write(&fout,buffer,sizeof(u32)*size,&bw);
	f_close(&fout);

#ifdef DEBUG
	xil_printf("--------------the feature map data is: ----------------\n");
	for(int i=0;i<size;i++){
		xil_printf("%d ", buffer[i]);
		if(size%40==39)
			xil_printf("\n");
	}
	xil_printf("------------------------------------------------------------\n");
#endif

	if(res_sd==FR_OK){
		xil_printf("succeed to write %d, data to file %s\n",bw,file);
		return 1;
	}
	else{
		xil_printf("ERROR: write to file %s\n",file);
		return 0;
	}
}


int sdcard_print(char *file, u32 *buffer, unsigned int size){

	FIL fout;
	int fprintf_flag;
	res_sd=f_open(&fout,file,FA_WRITE | FA_CREATE_ALWAYS);
	if(res_sd==FR_EXIST){
		xil_printf("WARN: file %s exist\n",file);

	}
	else if(res_sd!=FR_OK){
		xil_printf("ERROR: when open file %s\n",file);
		return 0;
	}

	for(int i=0;i<size;i++){
		fprintf_flag=f_printf(&fout,"%f",*(float*)(&buffer[i]));
	}
	f_printf(&fout,"\n");
	f_close(&fout);


	if(fprintf_flag!=EOF){
		xil_printf("succeed to write %d, data to file %s\n",size,file);
		return 1;
	}
	else{
		xil_printf("ERROR: write to file %s\n",file);
		return 0;
	}
}






unsigned int get_fileSize(char *file){
	unsigned int fsize;
	FIL fin;
	res_sd=f_open(&fin,file,FA_READ);
	fsize=file_size(&fin);
	f_close(&fin);
	return fsize;
}

