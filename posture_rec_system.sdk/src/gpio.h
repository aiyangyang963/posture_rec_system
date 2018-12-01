/*
 * gpio.h
 *
 *  Created on: 2017Äê12ÔÂ16ÈÕ
 *      Author: anpingbo
 */

#ifndef SRC_GPIO_H_
#define SRC_GPIO_H_

#include <xgpio.h>
#include <xparameters.h>
#include <xscugic.h>





extern XGpio image_inter_start;


extern int saveFmapIntr_flag;
extern int oneImage_finished;


void gpio_init();

void IntcTypeSetup(XScuGic *InstancePtr, int intId, int intType);
int PLSetupInterruptsystem(XScuGic *GicPtr, u16 intr_ID, Xil_InterruptHandler Handler);

void SaveLastImgHandler(void* data);





#endif /* SRC_GPIO_H_ */
