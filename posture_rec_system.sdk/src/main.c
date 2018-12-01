/*
 * main.c
 *
 *  Created on: 2017Äê12ÔÂ7ÈÕ
 *      Author: anpingbo
 */

#include <xgpio.h>
#include <xparameters.h>
#include <stdio.h>
#include "gpio.h"
#include "data_store.h"
#include "interruptDef.h"
#include "common.h"


char fnum;
int saveFmapIntr_flag;
int oneImage_finished;

int main(){

	gpio_init();
	fillDDR();
	oneImage_finished=0;
	XGpio_DiscreteWrite(&image_inter_start,1,1);
	XGpio_DiscreteWrite(&image_inter_start,1,0);
	while(1){

		if(saveFmapIntr_flag){
			saveFmapIntr_flag=0;
			if(fnum==2){
				break;
			}

		}

		if(oneImage_finished){
			//XGpio_DiscreteWrite(&image_inter_start,1,1);
			//XGpio_DiscreteWrite(&image_inter_start,1,0);
			break;
		}

	}

	return 0;


}


