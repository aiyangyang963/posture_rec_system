/*
 * interruptDef.c
 *
 *  Created on: 2017��12��26��
 *      Author: anpingbo
 */


#include "interruptDef.h"





int setupInterruptSystem(XScuGic *GicPtr){



	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				 (Xil_ExceptionHandler)XScuGic_InterruptHandler,
				 GicPtr);


	Xil_ExceptionEnable();
	return XST_SUCCESS;



}
