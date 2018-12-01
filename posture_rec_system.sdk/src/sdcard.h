/*
 * sdcard.h
 *
 *  Created on: 2018Äê2ÔÂ27ÈÕ
 *      Author: anpingbo
 */

#ifndef SRC_SDCARD_H_
#define SRC_SDCARD_H_

#include <xparameters.h>
#include <ff.h>


extern FATFS fs;
extern FRESULT res_sd;

int sdcard_init();
int sdcard_read(char *file,u32 *buffer, unsigned int size);
int sdcard_write(char *file, u32 *buffer, unsigned int size);
int sdcard_print(char *file, u32 *buffer, unsigned int size);
unsigned int get_fileSize(char *file);



#endif /* SRC_SDCARD_H_ */
