/*
 * Copyright (C) 2014 - 2015 Xilinx, Inc.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Use of the Software is limited solely to applications:
 * (a) running on a Xilinx device, or
 * (b) that interact with a Xilinx device through a bus or interconnect.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 */
#include "xpfw_config.h"
#ifdef ENABLE_PM

#include "pm_periph.h"
#include "pm_common.h"
#include "pm_node.h"
#include "pm_master.h"
#include "xpfw_rom_interface.h"
#include "lpd_slcr.h"
#include "pm_gic_proxy.h"

/* Always-on slave has only one state */
#define PM_AON_SLAVE_STATE	0U

static const u32 pmAonFsmStates[] = {
	[PM_AON_SLAVE_STATE] = PM_CAP_WAKEUP | PM_CAP_ACCESS | PM_CAP_CONTEXT,
};

static const PmSlaveFsm pmSlaveAonFsm = {
	DEFINE_SLAVE_STATES(pmAonFsmStates),
	.trans = NULL,
	.transCnt = 0U,
	.enterState = NULL,
};

static u32 pmSlaveAonPowers[] = {
	DEFAULT_POWER_ON,
};

#define PM_GENERIC_SLAVE_STATE_UNUSED	0U
#define PM_GENERIC_SLAVE_STATE_RUNNING	1U

/* Generic slaves state transition latency values */
#define PM_GENERIC_SLAVE_UNUSED_TO_RUNNING_LATENCY	304
#define PM_GENERIC_SLAVE_RUNNING_TO_UNUSED_LATENCY	6
static const u32 pmGenericSlaveStates[] = {
	[PM_GENERIC_SLAVE_STATE_UNUSED] = 0U,
	[PM_GENERIC_SLAVE_STATE_RUNNING] = PM_CAP_CONTEXT | PM_CAP_WAKEUP |
			PM_CAP_ACCESS | PM_CAP_CLOCK | PM_CAP_POWER,
};

static const PmStateTran pmGenericSlaveTransitions[] = {
	{
		.fromState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.toState = PM_GENERIC_SLAVE_STATE_UNUSED,
		.latency = PM_GENERIC_SLAVE_RUNNING_TO_UNUSED_LATENCY,
	}, {
		.fromState = PM_GENERIC_SLAVE_STATE_UNUSED,
		.toState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latency = PM_GENERIC_SLAVE_UNUSED_TO_RUNNING_LATENCY,
	},
};

static u32 pmGenericSlavePowers[] = {
	DEFAULT_POWER_OFF,
	DEFAULT_POWER_ON,
};

static const PmSlaveFsm pmGenericSlaveFsm = {
	DEFINE_SLAVE_STATES(pmGenericSlaveStates),
	DEFINE_SLAVE_TRANS(pmGenericSlaveTransitions),
	.enterState = NULL,
};

static PmWakeEventGicProxy pmRtcWake = {
	.wake = {
		.derived = &pmRtcWake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC27_MASK |
		LPD_SLCR_GICP0_IRQ_MASK_SRC26_MASK,
	.group = 0U,
};

PmSlave pmSlaveRtc_g = {
	.node = {
		.derived = &pmSlaveRtc_g,
		.nodeId = NODE_RTC,
		.class = &pmNodeClassSlave_g,
		.parent = NULL,
		.clocks = NULL,
		.currState = PM_AON_SLAVE_STATE,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmSlaveAonPowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmRtcWake.wake,
	.slvFsm = &pmSlaveAonFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmTtc0Wake = {
	.wake = {
		.derived = &pmTtc0Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC6_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC5_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC4_MASK,
	.group = 1U,
};

PmSlave pmSlaveTtc0_g = {
	.node = {
		.derived = &pmSlaveTtc0_g,
		.nodeId = NODE_TTC_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmTtc0Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmTtc1Wake = {
	.wake = {
		.derived = &pmTtc1Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC9_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC8_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC7_MASK,
	.group = 1U,
};

PmSlave pmSlaveTtc1_g = {
	.node = {
		.derived = &pmSlaveTtc1_g,
		.nodeId = NODE_TTC_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmTtc1Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmTtc2Wake = {
	.wake = {
		.derived = &pmTtc2Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC12_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC11_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC10_MASK,
	.group = 1U,
};

PmSlave pmSlaveTtc2_g = {
	.node = {
		.derived = &pmSlaveTtc2_g,
		.nodeId = NODE_TTC_2,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmTtc2Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmTtc3Wake = {
	.wake = {
		.derived = &pmTtc3Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC15_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC14_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC13_MASK,
	.group = 1U,
};

PmSlave pmSlaveTtc3_g = {
	.node = {
		.derived = &pmSlaveTtc3_g,
		.nodeId = NODE_TTC_3,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmTtc3Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmUart0Wake = {
	.wake = {
		.derived = &pmUart0Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC21_MASK,
	.group = 0U,
};

PmSlave pmSlaveUart0_g = {
	.node = {
		.derived = &pmSlaveUart0_g,
		.nodeId = NODE_UART_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmUart0Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmUart1Wake = {
	.wake = {
		.derived = &pmUart1Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC22_MASK,
	.group = 0U,
};

PmSlave pmSlaveUart1_g = {
	.node = {
		.derived = &pmSlaveUart1_g,
		.nodeId = NODE_UART_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmUart1Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmSpi0Wake = {
	.wake = {
		.derived = &pmSpi0Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC19_MASK,
	.group = 0U,
};

PmSlave pmSlaveSpi0_g = {
	.node = {
		.derived = &pmSlaveSpi0_g,
		.nodeId = NODE_SPI_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmSpi0Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmSpi1Wake = {
	.wake = {
		.derived = &pmSpi1Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC20_MASK,
	.group = 0U,
};

PmSlave pmSlaveSpi1_g = {
	.node = {
		.derived = &pmSlaveSpi1_g,
		.nodeId = NODE_SPI_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmSpi1Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmI2C0Wake = {
	.wake = {
		.derived = &pmI2C0Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC17_MASK,
	.group = 0U,
};

PmSlave pmSlaveI2C0_g = {
	.node = {
		.derived = &pmSlaveI2C0_g,
		.nodeId = NODE_I2C_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmI2C0Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmI2C1Wake = {
	.wake = {
		.derived = &pmI2C1Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC18_MASK,
	.group = 0U,
};

PmSlave pmSlaveI2C1_g = {
	.node = {
		.derived = &pmSlaveI2C1_g,
		.nodeId = NODE_I2C_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmI2C1Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmSD0Wake = {
	.wake = {
		.derived = &pmSD0Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC18_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC16_MASK,
	.group = 1U,
};

PmSlave pmSlaveSD0_g = {
	.node = {
		.derived = &pmSlaveSD0_g,
		.nodeId = NODE_SD_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmSD0Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmSD1Wake = {
	.wake = {
		.derived = &pmSD1Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC19_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC17_MASK,
	.group = 1U,
};

PmSlave pmSlaveSD1_g = {
	.node = {
		.derived = &pmSlaveSD1_g,
		.nodeId = NODE_SD_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmSD1Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmCan0Wake = {
	.wake = {
		.derived = &pmCan0Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC23_MASK,
	.group = 0U,
};

PmSlave pmSlaveCan0_g = {
	.node = {
		.derived = &pmSlaveCan0_g,
		.nodeId = NODE_CAN_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmCan0Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmCan1Wake = {
	.wake = {
		.derived = &pmCan1Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC24_MASK,
	.group = 0U,
};

PmSlave pmSlaveCan1_g = {
	.node = {
		.derived = &pmSlaveCan1_g,
		.nodeId = NODE_CAN_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmCan1Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmEth0Wake = {
	.wake = {
		.derived = &pmEth0Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC25_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC24_MASK,
	.group = 1U,
};

PmSlave pmSlaveEth0_g = {
	.node = {
		.derived = &pmSlaveEth0_g,
		.nodeId = NODE_ETH_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmEth0Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmEth1Wake = {
	.wake = {
		.derived = &pmEth1Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC27_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC26_MASK,
	.group = 1U,
};

PmSlave pmSlaveEth1_g = {
	.node = {
		.derived = &pmSlaveEth1_g,
		.nodeId = NODE_ETH_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmEth1Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmEth2Wake = {
	.wake = {
		.derived = &pmEth2Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC29_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC28_MASK,
	.group = 1U,
};

PmSlave pmSlaveEth2_g = {
	.node = {
		.derived = &pmSlaveEth2_g,
		.nodeId = NODE_ETH_2,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmEth2Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmEth3Wake = {
	.wake = {
		.derived = &pmEth3Wake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC31_MASK |
		LPD_SLCR_GICP1_IRQ_MASK_SRC30_MASK,
	.group = 1U,
};

PmSlave pmSlaveEth3_g = {
	.node = {
		.derived = &pmSlaveEth3_g,
		.nodeId = NODE_ETH_3,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmEth3Wake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmAdmaWake = {
	.wake = {
		.derived = &pmAdmaWake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP2_IRQ_MASK_SRC19_MASK |
		LPD_SLCR_GICP2_IRQ_MASK_SRC18_MASK |
		LPD_SLCR_GICP2_IRQ_MASK_SRC17_MASK |
		LPD_SLCR_GICP2_IRQ_MASK_SRC16_MASK |
		LPD_SLCR_GICP2_IRQ_MASK_SRC15_MASK |
		LPD_SLCR_GICP2_IRQ_MASK_SRC14_MASK |
		LPD_SLCR_GICP2_IRQ_MASK_SRC13_MASK |
		LPD_SLCR_GICP2_IRQ_MASK_SRC12_MASK,
	.group = 2U,
};

PmSlave pmSlaveAdma_g = {
	.node = {
		.derived = &pmSlaveAdma_g,
		.nodeId = NODE_ADMA,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmAdmaWake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmNandWake = {
	.wake = {
		.derived = &pmNandWake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC14_MASK,
	.group = 0U,
};

PmSlave pmSlaveNand_g = {
	.node = {
		.derived = &pmSlaveNand_g,
		.nodeId = NODE_NAND,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmNandWake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmQSpiWake = {
	.wake = {
		.derived = &pmQSpiWake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC15_MASK,
	.group = 0U,
};

PmSlave pmSlaveQSpi_g = {
	.node = {
		.derived = &pmSlaveQSpi_g,
		.nodeId = NODE_QSPI,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmQSpiWake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmGpioWake = {
	.wake = {
		.derived = &pmGpioWake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP0_IRQ_MASK_SRC16_MASK,
	.group = 0U,
};

PmSlave pmSlaveGpio_g = {
	.node = {
		.derived = &pmSlaveGpio_g,
		.nodeId = NODE_GPIO,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmGpioWake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveSata_g = {
	.node = {
		.derived = &pmSlaveSata_g,
		.nodeId = NODE_SATA,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainFpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveGpu_g = {
	.node = {
		.derived = &pmSlaveGpu_g,
		.nodeId = NODE_GPU,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainFpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlavePcie_g = {
	.node = {
		.derived = &pmSlavePcie_g,
		.nodeId = NODE_PCIE,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainFpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlavePcap_g = {
	.node = {
		.derived = &pmSlavePcap_g,
		.nodeId = NODE_PCAP,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveGdma_g = {
	.node = {
		.derived = &pmSlaveGdma_g,
		.nodeId = NODE_GDMA,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainFpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveDP_g = {
	.node = {
		.derived = &pmSlaveDP_g,
		.nodeId = NODE_DP,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainFpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

static PmWakeEventGicProxy pmIpiApuWake = {
	.wake = {
		.derived = &pmIpiApuWake,
		.class = &pmWakeEventClassGicProxy_g,
	},
	.mask = LPD_SLCR_GICP1_IRQ_MASK_SRC3_MASK,
	.group = 1U,
};

PmSlave pmSlaveIpiApu_g = {
	.node = {
		.derived = &pmSlaveIpiApu_g,
		.nodeId = NODE_IPI_APU,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = &pmIpiApuWake.wake,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveIpiRpu0_g = {
	.node = {
		.derived = &pmSlaveIpiRpu0_g,
		.nodeId = NODE_IPI_RPU_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveIpiRpu1_g = {
	.node = {
		.derived = &pmSlaveIpiRpu1_g,
		.nodeId = NODE_IPI_RPU_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveIpiPl0_g = {
	.node = {
		.derived = &pmSlaveIpiPl0_g,
		.nodeId = NODE_IPI_PL_0,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveIpiPl1_g = {
	.node = {
		.derived = &pmSlaveIpiPl1_g,
		.nodeId = NODE_IPI_PL_1,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveIpiPl2_g = {
	.node = {
		.derived = &pmSlaveIpiPl2_g,
		.nodeId = NODE_IPI_PL_2,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlaveIpiPl3_g = {
	.node = {
		.derived = &pmSlaveIpiPl3_g,
		.nodeId = NODE_IPI_PL_3,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainLpd_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

PmSlave pmSlavePl_g = {
	.node = {
		.derived = &pmSlavePl_g,
		.nodeId = NODE_PL,
		.class = &pmNodeClassSlave_g,
		.parent = &pmPowerDomainPld_g.power,
		.clocks = NULL,
		.currState = PM_GENERIC_SLAVE_STATE_RUNNING,
		.latencyMarg = MAX_LATENCY,
		.flags = 0U,
		DEFINE_PM_POWER_INFO(pmGenericSlavePowers),
	},
	.class = NULL,
	.reqs = NULL,
	.wake = NULL,
	.slvFsm = &pmGenericSlaveFsm,
	.flags = 0U,
};

#endif
