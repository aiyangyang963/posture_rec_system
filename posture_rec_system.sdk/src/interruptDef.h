/*
 * interruptDef.h
 *
 *  Created on: 2017Äê12ÔÂ26ÈÕ
 *      Author: anpingbo
 */

#ifndef SRC_INTERRUPTDEF_H_
#define SRC_INTERRUPTDEF_H_

#include <xscugic.h>
#include "xparameters.h"



#define INTC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID
#define INT_TYPE_RISING_EDGE    0x03
#define INT_TYPE_HIGHLEVEL      0x01
#define INT_TYPE_MASK           0x03
#define INT_CFG0_OFFSET 0x00000C00



int setupInterruptSystem(XScuGic *GicPtr);

#endif /* SRC_INTERRUPTDEF_H_ */
