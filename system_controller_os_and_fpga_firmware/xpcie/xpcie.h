#ifndef __XPCIE_H
#define __XPCIE_H

#include <linux/dmapool.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/irqdomain.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/mutex.h>
#include <linux/list.h>
#include <linux/types.h>
#include <linux/cdev.h>
#include <linux/dmaengine.h>
#include <linux/dma-mapping.h>
#include <linux/ktime.h>

#define NUM_BARS 1
#define BUF_SIZE 2048
#define DESC_SIZE 32
#define DESC_ALIGN 64
#define DMA_BUF_SIZE 0x100000

/* IOCTL Commands */
#define SET_DMA 1
#define SET_PIO 2
#define RESET_DMA 3
#define STREAMING_DMA 4
#define COHERENT_DMA 5
#define TRANS_TIME 6
#define TRANS_SPEED 7
#define DMA_IS_IDLE 8

#define START_ADDR 0x81000000

/* Offsets for PCIe BAR */
#define BAR_BRAM 0x00000000
#define BAR_AXI_PCIE_CTL 0x00008000
#define BAR_AXI_CDMA_LITE 0x0000c000

/* Addresses on EP */
#define ZYNQ_HP0_DDR 0x00000000
#define AXI_PCIE_DM 0x80000000
#define AXI_PCIE_SG 0x80800000
#define BRAM 0x81000000
#define AXI_PCIE_CTL 0x81008000

/* DMA Stuff */
#define SGM 0x0a000100 /* Scatter Gather Mode */

/* PCIe Stuff */
#define PCIE_CONF_SPACE 0x000
#define VSEC 0x128
#define VSEC_HEADER 0x12C
#define BRIDGE_INFO 0x130
#define BRIDGE_SC 0x134
#define INTERRUPT_DECODE 0x138
#define INTERRUPT_MASK 0x13C
#define BUS_LOCATION 0x140
#define PHY_SC 0x144
#define RP_SC 0x148
#define RP_MSI_B1 0x14C
#define RP_MSI_B2 0x150
#define RP_ERROR_FIFO 0x154
#define RP_INTERRUPT_FIFO1 0x158
#define RP_INTERRUPT_FIFO2 0x15C
#define VSEC2 0x200
#define VSEC2_HEADER 0x204
#define AXIBAR2PCIEBAR_0U 0x208
#define AXIBAR2PCIEBAR_0L 0x20C
#define AXIBAR2PCIEBAR_1U 0x210
#define AXIBAR2PCIEBAR_1L 0x214
#define AXIBAR2PCIEBAR_2U 0x218
#define AXIBAR2PCIEBAR_2L 0x21C
#define AXIBAR2PCIEBAR_3U 0x220
#define AXIBAR2PCIEBAR_3L 0x224
#define AXIBAR2PCIEBAR_4U 0x228
#define AXIBAR2PCIEBAR_4L 0x22C
#define AXIBAR2PCIEBAR_5U 0x230
#define AXIBAR2PCIEBAR_5L 0x234

struct xpcie_dev {
	struct pci_dev *pdev;
	struct device *dev;

	struct device *dev_node;

	dev_t cdev_num;

	struct cdev cdev;

	int major;
	int minor; 

	struct mutex xpcie_mutex;
	spinlock_t dma_lock;

	char *buffer; /* Temporary buffer for transferred data */

	unsigned long bar_len[NUM_BARS];     	/* Length of device memory */
	void __iomem * bar[NUM_BARS]; 			/* Mapped address */

	struct xilinx_cdma_data *xdma;

	void *read_buf;
	dma_addr_t read_addr;

	void *write_buf;
	dma_addr_t write_addr;

	bool dma;
	bool polling;
	bool msi;
	bool finished;
	bool use_streaming;

	/* Details of transfer required for streaming DMA */
	dma_addr_t streaming_addr;
	enum dma_data_direction direction;
	size_t trans_len;
	bool streaming;

	atomic_t xpcie_available;

	ktime_t start_time;
	ktime_t end_time;
};

/* Per DMA specific operations should be embedded in the channel structure */
struct xilinx_cdma_data {
	void __iomem *regs;			/* Control status registers */
	spinlock_t lock;			/* Descriptor operation lock */
	struct device *dev;			/* The dma device */
	int irq;					/* Channel IRQ */
	int id;						/* Channel ID */
	int max_len;				/* Max data len per transfer */
	bool has_dre;				/* For unaligned transfers */
	int err;				/* Channel has errors */
	struct tasklet_struct tasklet;		/* Cleanup work after irq */
	u32 feature;				/* IP feature */
};

int xpcie_core_init(void);
void xpcie_core_exit(void);
int xpcie_dev_setup(struct xpcie_dev *xpcie);
void xpcie_dev_remove(struct xpcie_dev *xpcie);
int xilinx_cdma_setup(struct xpcie_dev *xpcie);
int xilinx_cdma_remove(struct xpcie_dev *xpcie);
irqreturn_t cdma_intr_handler(struct xilinx_cdma_data *xdma);
void xilinx_cdma_start_simple_transfer(struct xilinx_cdma_data *xdma, u32 src_addr, u32 dst_addr, u32 len);
int cdma_reset(struct xilinx_cdma_data *xdma);
int cdma_is_idle(struct xilinx_cdma_data *xdma);
irqreturn_t xpcie_intr_handler(int irq, void *data);

#endif /* __XPCIE_H */
