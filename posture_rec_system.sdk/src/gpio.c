/*
 * gpio.c
 *
 *  Created on: 2017Äê12ÔÂ16ÈÕ
 *      Author: anpingbo
 *  description: initialize the GPIO
 */


#include <xgpio.h>
#include <xparameters.h>
#include <xil_exception.h>
#include "gpio.h"
#include "interruptDef.h"
#include "data_store.h"


XGpio image_inter_start;
char fnum;



int saveFmapIntr_flag;
int oneImage_finished;





void gpio_init(){

	XScuGic GicPtr;
	saveFmapIntr_flag=0;
	fnum=0;
	int status;
	status=XGpio_Initialize(&image_inter_start,XPAR_AXI_GPIO_0_DEVICE_ID);
	if(status != XST_SUCCESS){
		xil_printf("ERROR: cannot initialize gpio\n");
		return;
	}
	XGpio_SetDataDirection(&image_inter_start,1,0x00);//set the gpio as output
	XGpio_DiscreteWrite(&image_inter_start,1,0);

	PLSetupInterruptsystem(&GicPtr, XPAR_FABRIC_DEAL_FINISH_INT_INTR, SaveLastImgHandler);

}


void IntcTypeSetup(XScuGic *InstancePtr, int intId, int intType)
{
    int mask;

    intType &= INT_TYPE_MASK;
    mask = XScuGic_DistReadReg(InstancePtr, INT_CFG0_OFFSET + (intId/16)*4);
    mask &= ~(INT_TYPE_MASK << (intId%16)*2);
    mask |= intType << ((intId%16)*2);
    XScuGic_DistWriteReg(InstancePtr, INT_CFG0_OFFSET + (intId/16)*4, mask);
}



int PLSetupInterruptsystem(XScuGic *GicPtr, u16 intr_ID,  Xil_InterruptHandler Handler){

	int Status;
	XScuGic_Config *GicConfig;


	GicConfig = XScuGic_LookupConfig(intr_ID);
	if (NULL == GicConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(GicPtr, GicConfig,
					   GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status=setupInterruptSystem(GicPtr);
	if(Status != XST_SUCCESS){
		return XST_FAILURE;
	}

	Status = XScuGic_Connect(GicPtr, intr_ID, Handler, (void*)(1));

	if(Status != XST_SUCCESS) return XST_FAILURE;

	XScuGic_SetPriorityTriggerType(GicPtr, intr_ID, 0, 3);

	XScuGic_Enable(GicPtr, intr_ID);

	return XST_SUCCESS;
}



void SaveLastImgHandler(void* data){


	oneImage_finished=1;
	fnum=0;
	save_fmap_in_sd();
	fnum=1;
	save_fmap_in_sd();
	xil_printf("one image have been finished!\n");
	xil_printf("---------------------------------\n");




}






