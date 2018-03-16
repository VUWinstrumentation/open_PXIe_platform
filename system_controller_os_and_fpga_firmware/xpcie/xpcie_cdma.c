/*
 * Xilinx Central DMA Engine support
 *
 * Copyright (C) 2010 - 2013 Xilinx, Inc. All rights reserved.
 *
 * Based on the Freescale DMA driver.
 *
 * Description:
 *  . Axi CDMA engine, it does transfers between memory and memory
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */
#include <linux/dmapool.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/irqdomain.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/dma-mapping.h>
#include <linux/cdev.h>
#include <linux/pci.h>
#include <linux/delay.h>
#include "xpcie.h"

/* DMA IP masks */
#define XILINX_DMA_IP_CDMA	0x00200000	/* A Central DMA IP */

/* Device Id in the private structure */
#define XILINX_DMA_DEVICE_ID_SHIFT	28

/* Hw specific definitions */
#define XILINX_CDMA_MAX_TRANS_LEN	0x7FFFFF /* Max transfer length */

/* Register Offsets */
#define XILINX_CDMA_CONTROL_OFFSET	0x00 /* Control Reg */
#define XILINX_CDMA_STATUS_OFFSET	0x04 /* Status Reg */
#define XILINX_CDMA_CDESC_OFFSET	0x08 /* Current descriptor Reg */
#define XILINX_CDMA_TDESC_OFFSET	0x10 /* Tail descriptor Reg */
#define XILINX_CDMA_SRCADDR_OFFSET	0x18 /* Source Address Reg */
#define XILINX_CDMA_DSTADDR_OFFSET	0x20 /* Dest Address Reg */
#define XILINX_CDMA_BTT_OFFSET		0x28 /* Bytes to transfer Reg */

/* General register bits definitions */
#define XILINX_CDMA_CR_RESET_MASK	0x00000004 /* Reset DMA engine */

#define XILINX_CDMA_SR_IDLE_MASK	0x00000002 /* DMA channel idle */

#define XILINX_CDMA_XR_IRQ_IOC_MASK	0x00001000 /* Completion interrupt */
#define XILINX_CDMA_XR_IRQ_DELAY_MASK	0x00002000 /* Delay interrupt */
#define XILINX_CDMA_XR_IRQ_ERROR_MASK	0x00004000 /* Error interrupt */
#define XILINX_CDMA_XR_IRQ_ALL_MASK	0x00007000 /* All interrupts */

#define XILINX_CDMA_XR_DELAY_MASK	0xFF000000 /* Delay timeout counter */
#define XILINX_CDMA_XR_COALESCE_MASK	0x00FF0000 /* Coalesce counter */

#define XILINX_CDMA_DELAY_SHIFT		24 /* Delay counter shift */
#define XILINX_CDMA_COALESCE_SHIFT	16 /* Coaelsce counter shift */

#define XILINX_CDMA_DELAY_MAX		0xFF /* Maximum delay counter value */
/* Maximum coalescing counter value */
#define XILINX_CDMA_COALESCE_MAX	0xFF

#define XILINX_CDMA_CR_SGMODE_MASK	0x00000008 /* Scatter gather mode */

/* BD definitions for Axi Cdma */
#define XILINX_CDMA_BD_STS_ALL_MASK	0xF0000000

/* Feature encodings */
#define XILINX_CDMA_FTR_DATA_WIDTH_MASK	0x000000FF /* Data width mask, 1024 */
#define XILINX_CDMA_FTR_HAS_SG		0x00000100 /* Has SG */
#define XILINX_CDMA_FTR_HAS_SG_SHIFT	8 /* Has SG shift */

/* Delay loop counter to prevent hardware failure */
#define XILINX_CDMA_RESET_LOOP	1000000
#define XILINX_CDMA_HALT_LOOP	1000000

/* Hardware descriptor */
struct xilinx_cdma_desc_hw {
	u32 next_desc;	/* 0x00 */
	u32 pad1;	/* 0x04 */
	u32 src_addr;	/* 0x08 */
	u32 pad2;	/* 0x0C */
	u32 dest_addr;	/* 0x10 */
	u32 pad3;	/* 0x14 */
	u32 control;	/* 0x18 */
	u32 status;	/* 0x1C */
} __aligned(64);

/* Software descriptor */
struct xilinx_cdma_desc_sw {
	struct xilinx_cdma_desc_hw hw;
	struct list_head node;
	struct list_head tx_list;
	struct dma_async_tx_descriptor async_tx;
} __aligned(64);

/* IO accessors */
static inline void
cdma_write(struct xilinx_cdma_data *xdma, u32 reg, u32 val)
{
	iowrite32(val, xdma->regs + reg);
}

static inline u32 cdma_read(struct xilinx_cdma_data *xdma, u32 reg)
{
	return ioread32(xdma->regs + reg);
}

int cdma_is_idle(struct xilinx_cdma_data *xdma)
{
	return cdma_read(xdma, XILINX_CDMA_STATUS_OFFSET) &
	       XILINX_CDMA_SR_IDLE_MASK;
}
EXPORT_SYMBOL(cdma_is_idle);

void xilinx_cdma_start_simple_transfer(struct xilinx_cdma_data *xdma, u32 src_addr, u32 dst_addr, u32 len)
{
	unsigned long flags;
	u32 btt;

	spin_lock_irqsave(&xdma->lock, flags);

	/* If hardware is busy, cannot submit */
	if (!cdma_is_idle(xdma)) {
		dev_info(xdma->dev, "DMA controller still busy %x\n",
			cdma_read(xdma, XILINX_CDMA_STATUS_OFFSET));
		goto out_unlock;
	}

	btt = min_t(u32, len, XILINX_CDMA_MAX_TRANS_LEN);

	/* Enable interrupts */
	cdma_write(xdma, XILINX_CDMA_CONTROL_OFFSET,
		   cdma_read(xdma, XILINX_CDMA_CONTROL_OFFSET) |
		   XILINX_CDMA_XR_IRQ_ALL_MASK);

	cdma_write(xdma, XILINX_CDMA_SRCADDR_OFFSET, src_addr);
	printk(KERN_ALERT "SRCADDR: 0x%x\n\r",cdma_read(xdma,XILINX_CDMA_SRCADDR_OFFSET));
	cdma_write(xdma, XILINX_CDMA_DSTADDR_OFFSET, dst_addr);
	printk(KERN_ALERT "DSTADDR: 0x%x\n\r",cdma_read(xdma,XILINX_CDMA_DSTADDR_OFFSET));
	/* Start the transfer */
	cdma_write(xdma, XILINX_CDMA_BTT_OFFSET,
		   btt);
	printk(KERN_ALERT "XILINX_CDMA_BTT_OFFSET: 0x%x\n\r",cdma_read(xdma,XILINX_CDMA_BTT_OFFSET));

out_unlock:
	spin_unlock_irqrestore(&xdma->lock, flags);
}
EXPORT_SYMBOL(xilinx_cdma_start_simple_transfer);

/* Reset hardware */
int cdma_reset(struct xilinx_cdma_data *xdma)
{
	int loop = XILINX_CDMA_RESET_LOOP;
	u32 tmp;
	cdma_write(xdma, XILINX_CDMA_CONTROL_OFFSET,
		   cdma_read(xdma, XILINX_CDMA_CONTROL_OFFSET) |
		   XILINX_CDMA_CR_RESET_MASK);
	tmp = cdma_read(xdma, XILINX_CDMA_CONTROL_OFFSET) &
	      XILINX_CDMA_CR_RESET_MASK;
	/* Wait for the hardware to finish reset */
	while (loop && tmp) {
		tmp = cdma_read(xdma, XILINX_CDMA_CONTROL_OFFSET) &
		      XILINX_CDMA_CR_RESET_MASK;
		loop -= 1;
	}

	if (!loop) {
		dev_err(xdma->dev, "reset timeout, cr %x, sr %x\n",
			cdma_read(xdma, XILINX_CDMA_CONTROL_OFFSET),
			cdma_read(xdma, XILINX_CDMA_STATUS_OFFSET));
		return -EBUSY;
	}

	cdma_write(xdma, XILINX_CDMA_CONTROL_OFFSET,
			   cdma_read(xdma, XILINX_CDMA_CONTROL_OFFSET) & ~XILINX_CDMA_CR_SGMODE_MASK);

	return 0;
}

irqreturn_t cdma_intr_handler(struct xilinx_cdma_data *xdma)
{
	u32 stat, reg;

	reg = cdma_read(xdma, XILINX_CDMA_CONTROL_OFFSET);

	/* Disable intr */
	cdma_write(xdma, XILINX_CDMA_CONTROL_OFFSET,
		   reg & ~XILINX_CDMA_XR_IRQ_ALL_MASK);

	stat = cdma_read(xdma, XILINX_CDMA_STATUS_OFFSET);
	printk(KERN_ALERT "XILINX_CDMA_STATUS_OFFSET: 0x%x\n\r",stat);
	if (!(stat & XILINX_CDMA_XR_IRQ_ALL_MASK))
		return IRQ_NONE;

	/* Ack the interrupts */
	cdma_write(xdma, XILINX_CDMA_STATUS_OFFSET,
		   XILINX_CDMA_XR_IRQ_ALL_MASK);

	/* Check for only the interrupts which are enabled */
	stat &= (reg & XILINX_CDMA_XR_IRQ_ALL_MASK);

	if (stat & XILINX_CDMA_XR_IRQ_ERROR_MASK) {
		dev_err(xdma->dev,
			"Channel has errors %x, cdr %x tdr %x\n",
			(u32)cdma_read(xdma, XILINX_CDMA_STATUS_OFFSET),
			(u32)cdma_read(xdma, XILINX_CDMA_CDESC_OFFSET),
			(u32)cdma_read(xdma, XILINX_CDMA_TDESC_OFFSET));
		xdma->err = 1;
	}

	/*
	 * Device takes too long to do the transfer when user requires
	 * responsiveness
	 */
	if (stat & XILINX_CDMA_XR_IRQ_DELAY_MASK)
		dev_dbg(xdma->dev, "Inter-packet latency too long\n");

	if (stat & XILINX_CDMA_XR_IRQ_IOC_MASK){
		/* Do nothing */
	}

	return IRQ_HANDLED;
}
EXPORT_SYMBOL(cdma_intr_handler);

int xilinx_cdma_setup(struct xpcie_dev *xpcie)
{
	struct xilinx_cdma_data *xdma;
	int ret = 0;

	xdma = devm_kzalloc(xpcie->dev, sizeof(*xdma), GFP_KERNEL);
	if (!xdma)
		return -ENOMEM;

	xdma->dev = xpcie->dev;
	xdma->regs = xpcie->bar[0] + BAR_AXI_CDMA_LITE;
	xpcie->xdma = xdma;

	xdma->max_len = XILINX_CDMA_MAX_TRANS_LEN;

	/* Read whether data realignment applied. For now assume no. */
	xdma->has_dre = false;

	/* Initialize the channel */
	ret = cdma_reset(xdma);
	if (ret) {
		dev_err(xdma->dev, "Reset channel failed\n");
		return ret;
	}

	spin_lock_init(&xdma->lock);

	xdma->irq = xpcie->pdev->irq;

	dev_info(xpcie->dev, "Setting up xilinx axi cdma engine...Successful\n");

	return ret;
}
EXPORT_SYMBOL(xilinx_cdma_setup);

int xilinx_cdma_remove(struct xpcie_dev *xpcie)
{
	struct xilinx_cdma_data *xdma;

	xdma = xpcie->xdma;

	kfree(xdma);

	return 0;
}
EXPORT_SYMBOL(xilinx_cdma_remove);
