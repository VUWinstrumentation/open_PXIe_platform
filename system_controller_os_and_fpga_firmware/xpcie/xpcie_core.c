#include <linux/init.h>
#include <linux/module.h>
#include <linux/pci.h>
#include <linux/interrupt.h>
#include <linux/fs.h>
#include <asm/uaccess.h>   /* copy_to_user */
#include <linux/slab.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/mutex.h>
#include "xpcie.h"

MODULE_DESCRIPTION("Xilinx PCIe driver core functions");
MODULE_AUTHOR("Matthew Bourne");
MODULE_ALIAS("xpcie_core");
MODULE_LICENSE("GPL v2");

static int xpcie_init_chrdev (struct xpcie_dev *xpcie);
static void xpcie_cleanup_chrdev(struct xpcie_dev *xpcie);

static const char xpciename[] = "xpcie";   /* Name of driver in proc */
static struct class *xpcie_class;

/****************************************************************************
* Prototypes
*****************************************************************************/

static inline void pcie_reg_write(struct xpcie_dev *xpcie, u32 reg, u32 val)
{
	//dev_info(xpcie->dev,"pcie_reg_write->write_addr_reg_write val value: 0x%x\n",val);	
	printk(KERN_ALERT "pcie_reg_write->write_addr_reg_write val value: 0x%x, reg value : 0x%x\n",val,reg);	
	iowrite32(val, xpcie->bar[0] + BAR_AXI_PCIE_CTL + reg);
}

static inline u32 pcie_reg_read(struct xpcie_dev *xpcie, u32 reg)
{
	//dev_info(xpcie->dev,"pcie_reg_read->read_addr_reg_write val value: 0x%x\n",val);	
	//printk(KERN_ALERT "pcie_reg_read->read_addr_reg_write val value: 0x%x\n",val);	
	return ioread32(xpcie->bar[0] + BAR_AXI_PCIE_CTL + reg);
}

static inline void bram_write(u32 reg, u32 val, struct xpcie_dev *xpcie)
{
	iowrite32(val, xpcie->bar[0] + BAR_BRAM + reg);
}

static inline u32 bram_read(u32 reg, struct xpcie_dev *xpcie)
{
	return ioread32(xpcie->bar[0] + BAR_BRAM + reg);
}

static void dma_stream_setup(struct xpcie_dev *xpcie, void *host_addr, size_t len, enum dma_data_direction direction) {
	xpcie->streaming = true;
	xpcie->trans_len = len;
	xpcie->direction = direction;
	xpcie->streaming_addr = dma_map_single(xpcie->dev, host_addr, len, direction);
}

static void dma_stream_end(struct xpcie_dev *xpcie) {
	dma_unmap_single(xpcie->dev, xpcie->streaming_addr, xpcie->trans_len, xpcie->direction);
	xpcie->streaming = false;
}

static int xpcie_lock_device(struct xpcie_dev *xpcie){
	if (! atomic_dec_and_test (&xpcie->xpcie_available)) {
		atomic_inc(&xpcie->xpcie_available);
		return -EBUSY; 
	}
	return 0;
}

static void xpcie_release_device(struct xpcie_dev *xpcie){
	atomic_inc(&xpcie->xpcie_available);
}

static void simple_pcie_dma_transfer(struct xpcie_dev *xpcie, dma_addr_t host_addr, u32 ep_addr, size_t len, enum dma_data_direction direction){
	pcie_reg_write(xpcie, AXIBAR2PCIEBAR_1L, (u32)host_addr);
	dev_info(xpcie->dev,"simple_pcie_dma_transfer host_addr value: 0x%x ep_addr value: 0x%x\n",(u32)host_addr);
	if (direction == DMA_TO_DEVICE)
		xilinx_cdma_start_simple_transfer(xpcie->xdma, AXI_PCIE_DM, ep_addr, len);
	else if (direction == DMA_FROM_DEVICE)
		xilinx_cdma_start_simple_transfer(xpcie->xdma, ep_addr, AXI_PCIE_DM, len);
	else
		dev_err(xpcie->dev, "No valid dma direction found. Unable to transfer. Aborting.\n");
	if (xpcie->polling == true) {
		while (!cdma_is_idle(xpcie->xdma)) {}
		/* Even though interrupts are not used, this will clear the IRQ bit on the CDMA unit */
		cdma_intr_handler(xpcie->xdma);
	}
}

static void streaming_dma_transfer(struct xpcie_dev *xpcie, void *host_addr, u32 ep_addr, size_t len, enum dma_data_direction direction){
	dma_stream_setup(xpcie, host_addr, len, direction);
	simple_pcie_dma_transfer(xpcie, xpcie->streaming_addr, ep_addr, len, direction);
}

irqreturn_t xpcie_intr_handler(int irq, void *data)
{
	struct xpcie_dev *xpcie = data;
	irqreturn_t ret;

	/* Currently only CDMA unit triggers interrupts so uses this handler */
	ret = cdma_intr_handler(xpcie->xdma);

	if (ret == IRQ_NONE) {
		/* No interrupt detected */
		goto out;
	}

	if (xpcie->streaming == true)
		dma_stream_end(xpcie);

	xpcie->finished = true;

	out:
	return ret;
}
EXPORT_SYMBOL(xpcie_intr_handler);

static int xpcie_open(struct inode *inode, struct file *filp)
{
	int rc = 0;
	struct xpcie_dev *xpcie;
	xpcie = container_of(inode->i_cdev, struct xpcie_dev, cdev);

	rc = xpcie_lock_device(xpcie);
	if (rc < 0)
		goto out;

	filp->private_data = xpcie;
	dev_info(xpcie->dev,"Open: module opened\n");

	out:
	return rc;
}

static int xpcie_release(struct inode *inode, struct file *filp)
{
	int rc = 0;
	struct xpcie_dev *xpcie = filp->private_data;
	dev_info(xpcie->dev,"Release: module released\n");
	xpcie_release_device(xpcie);
	return rc;
}

static ssize_t xpcie_write(struct file *filp, const char __user *buf, size_t count,
	loff_t *f_pos)
{
	struct xpcie_dev *xpcie = filp->private_data;
	ssize_t rc = 0;
	dev_info(xpcie->dev,"In xpcie_write function\n");
	dev_info(xpcie->dev,"f_pos value: 0x%x\n",f_pos);
	if (xpcie->dma == false) {
		//dev_info(xpcie->dev,"In if condition\n");
		if (copy_from_user(xpcie->buffer, buf, count)){
			rc = -EFAULT;
			goto out;
		}
		if (*f_pos >= xpcie->bar_len[0])
			goto out;
		if (*f_pos + count > xpcie->bar_len[0])
			count = xpcie->bar_len[0] - *f_pos;
		memcpy_toio(xpcie->bar[0] + *f_pos, xpcie->buffer, count);
	}
	else{
		//dev_info(xpcie->dev,"In else condition\n");
		xpcie->start_time = ktime_get();
		xpcie->trans_len = count;
		if (xpcie->use_streaming == true) {
			//dev_info(xpcie->dev,"In if condition\n");
			if (copy_from_user(xpcie->buffer, buf, count)) {
				//dev_info(xpcie->dev,"In if condition\n");
				rc = -EFAULT;
				goto out;
			}
			xpcie->finished = false;
			streaming_dma_transfer(xpcie, xpcie->buffer, (u32)*f_pos, count, DMA_TO_DEVICE);
			while (xpcie->finished == false) {
				dev_info(xpcie->dev,"In streaming dma write while loop\n");
				/* Do nothing. Wait for completion */
			}
		}
		else {
			//dev_info(xpcie->dev,"In else condition\n");
			if (copy_from_user(xpcie->write_buf, buf, count)) {
				//dev_info(xpcie->dev,"In if condition\n");
				rc = -EFAULT;
				goto out;
			}
			xpcie->finished = false;
			simple_pcie_dma_transfer(xpcie, xpcie->write_addr, (u32)*f_pos, count, DMA_TO_DEVICE);
			while (xpcie->finished == false) {
				//dev_info(xpcie->dev,"In simple pcie dma write while loop\n");
				/* Do nothing. Wait for completion */
			}
		}
		xpcie->end_time = ktime_get();
	}

	//dev_info(xpcie->dev,"xpcie->write_buf: 0x%x\n", (u32)xpcie->write_buf);	
	dev_info(xpcie->dev,"xpcie_write: 0x%x bytes have been written at position 0x%x\n", (unsigned int)count, (u32)*f_pos);
	//dev_info(xpcie->dev,"write_addr: 0x%x\n",(u32)xpcie->write_addr);
	*f_pos += count;
	rc = count;
	dev_info(xpcie->dev,"Finished xpcie_write funtion\n");
	out:
	return rc;
}

static ssize_t xpcie_read(struct file *filp, char __user *buf, size_t count, loff_t *f_pos)
{
	struct xpcie_dev *xpcie = filp->private_data;
	ssize_t rc = 0;
	dev_info(xpcie->dev,"In xpcie_read function\n");
	if (xpcie->dma == false) {
		if (*f_pos >= xpcie->bar_len[0])
			goto out;
		if (*f_pos + count > xpcie->bar_len[0])
			count = xpcie->bar_len[0] - *f_pos;
		if (!xpcie->bar[0])
			goto out;
		memcpy_fromio(xpcie->buffer, xpcie->bar[0] + *f_pos, count);
		if (copy_to_user(buf, xpcie->buffer, count)) {
			rc = -EFAULT;
			goto out;
		}
	}
	else {
		xpcie->start_time = ktime_get();
		xpcie->trans_len = count;
		if (xpcie->use_streaming == true) {
			xpcie->finished = false;
			streaming_dma_transfer(xpcie, xpcie->buffer, (u32)*f_pos, count, DMA_FROM_DEVICE);
			while (xpcie->finished == false) {
				dev_info(xpcie->dev,"In streaming dma read while loop\n");
				/* Do nothing. Wait for completion */
			}
			if (copy_to_user(buf, xpcie->buffer, count)){
				rc = -EFAULT;
				goto out;
			}
		}
		else {
			xpcie->finished = false;
			simple_pcie_dma_transfer(xpcie, xpcie->read_addr, (u32)*f_pos, count, DMA_FROM_DEVICE);
			while (xpcie->finished == false) {
				//dev_info(xpcie->dev,"In simple pcie read while loop\n");
				/* Do nothing. Wait for completion */
			}
			if (copy_to_user(buf, xpcie->read_buf, count)) {
				rc = -EFAULT;
				goto out;
			}
		}
		xpcie->end_time = ktime_get();
	}

	dev_info(xpcie->dev,"xpcie_read: 0x%x bytes have been read at position 0x%x\n", (unsigned int)count, (u32)*f_pos);
	//dev_info(xpcie->dev,"read_addr: 0x%x\n",(u32)xpcie->read_addr);
	//dev_info(xpcie->dev,"bar_addr:0x%p\n",xpcie->bar[0]);
	*f_pos += count;
	rc = count;
	dev_info(xpcie->dev,"Finished xpcie_read funtion\n");
	out:
	return rc;
}

long xpcie_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
	struct xpcie_dev *xpcie = filp->private_data;
	long temp;
	switch (cmd) {
	case SET_DMA:
		xpcie->dma = true;
		break;
	case SET_PIO:
		xpcie->dma = false;
		break;
	case RESET_DMA:
		cdma_reset(xpcie->xdma);
		break;
	case STREAMING_DMA:
		xpcie->use_streaming = true;
		break;
	case COHERENT_DMA:
		xpcie->use_streaming = false;
		break;
	case TRANS_TIME:
		return ktime_to_ns(ktime_sub(xpcie->end_time, xpcie->start_time));
		break;
	case TRANS_SPEED:
		temp = ktime_to_ns(ktime_sub(xpcie->end_time, xpcie->start_time));
		if (temp == 0)
			return 0;
		return 1000*(xpcie->trans_len)/temp;
		break;
	case DMA_IS_IDLE:
		return cdma_is_idle(xpcie->xdma);
		break;
	default:
		break;
	}
	return 0;
}

static loff_t xpcie_llseek(struct file *filp, loff_t offset, int whence)
{
	struct xpcie_dev *xpcie = filp->private_data;
	loff_t newpos;
	int rc = 0;

	switch(whence) {
	case 0: /* SEEK_SET */
		newpos = offset;
		break;
	case 1: /* SEEK_CUR */
		newpos = filp->f_pos + offset;
		break;
	case 2: /* SEEK_END */
		newpos = xpcie->bar_len[0] + offset;
		break;
	default:
		rc = -EINVAL;
		goto end;
	}
	
	if (newpos < 0){ 
		rc = -EINVAL;
		goto end;
	}

	rc = newpos;
	filp->f_pos = newpos;

	end:
	return rc;
}

struct file_operations xpcie_fops = {
	.read = xpcie_read,
	.write = xpcie_write,
	.unlocked_ioctl = xpcie_ioctl,
	.open = xpcie_open,
	.release = xpcie_release,
	.llseek = xpcie_llseek,
};

static int xpcie_init_chrdev(struct xpcie_dev *xpcie)
{
	char devname[48];

	int rc = alloc_chrdev_region(&xpcie->cdev_num, 0, 1, xpciename);

	if (rc) {
		dev_warn(xpcie->dev, "Failed to obtain major/minors. Aborting.");
		goto fail_alloc;
	}

	xpcie->major = MAJOR(xpcie->cdev_num);
	xpcie->minor = MINOR(xpcie->cdev_num);

	cdev_init(&xpcie->cdev, &xpcie_fops);
	xpcie->cdev.owner = THIS_MODULE;
	xpcie->cdev.ops = &xpcie_fops;

	rc = cdev_add(&xpcie->cdev, xpcie->cdev_num, 1);

	if (rc) {
		dev_warn(xpcie->dev, "Failed to add cdev. Aborting.\n");
		goto fail_add;
	}

	snprintf(devname, sizeof(devname)-1, "%s_%x", xpciename, xpcie->pdev->bus->number);

	xpcie->dev_node = device_create(xpcie_class, NULL, xpcie->cdev_num, NULL, "%s", devname);

	if (IS_ERR(xpcie->dev_node)) {
		dev_warn(xpcie->dev, "Failed to create %s device. Aborting.\n", devname);
		goto fail_create;
	}

	return 0;

	/* ERROR HANDLING */

	fail_create:
	cdev_del(&xpcie->cdev);

	fail_add:
	unregister_chrdev_region(xpcie->cdev_num, 1);

	fail_alloc:

	return rc;
}

static void xpcie_cleanup_chrdev(struct xpcie_dev *xpcie)
{
	device_destroy(xpcie_class, xpcie->cdev_num);
	cdev_del(&xpcie->cdev);
	unregister_chrdev_region(xpcie->cdev_num, 1);
	dev_info(xpcie->dev, "Removed device file.\n");
}

int xpcie_dev_setup(struct xpcie_dev *xpcie)
{
	int rc;

	/* Enable atomic variable which only allows device to be opened in one place */
	atomic_set(&xpcie->xpcie_available, 1);

	/* If DMA transfers are taking place, buffer needs to be aligned to size of DMA transfer window */
	xpcie->buffer = kmalloc (DMA_BUF_SIZE, GFP_KERNEL);
	if (!xpcie->buffer) {
    	dev_err(xpcie->dev, "Couldn't allocate memory for buffer! Aborting.\n");
    	rc = -ENOMEM;
		goto fail_buffer;
	}

	/* Setup the CDMA engine */
	rc = xilinx_cdma_setup(xpcie);
	if (rc) {
		dev_err(xpcie->dev, "CDMA engine failed. Can only perform PIO transfers");
		xpcie->dma = false;
	}
	else {
		/* Setup coherent buffer for write transfers */
		printk(KERN_DEBUG "xpcie->write_addr before dma_alloc_coherent: 0x%x",(u32)xpcie->write_addr);
		xpcie->write_buf = dma_alloc_coherent(xpcie->dev, DMA_BUF_SIZE, &xpcie->write_addr, GFP_KERNEL);
		printk(KERN_DEBUG "xpcie->write_addr after dma_alloc_coherent: 0x%x",(u32)xpcie->write_addr);
		if (!xpcie->write_buf) {
			dev_err(xpcie->dev, "Could not allocate write buffer for DMA! Aborting.");
			goto write_buf_fail;
		}

		/* Setup coherent buffer for read transfers */
		printk(KERN_DEBUG "xpcie->read_addr before dma_alloc_coherent: 0x%x",(u32)xpcie->read_addr);
		xpcie->read_buf = dma_alloc_coherent(xpcie->dev, DMA_BUF_SIZE, &xpcie->read_addr, GFP_KERNEL);
		printk(KERN_DEBUG "xpcie->read_addr after dma_alloc_coherent: 0x%x",(u32)xpcie->read_addr);
		if (!xpcie->read_buf) {
			dev_err(xpcie->dev, "Could not allocate read buffer for DMA! Aborting.");
			goto read_buf_fail;
		}
		xpcie->use_streaming = false;
		xpcie->dma = true;
	}

	/* Create character device */
	rc = xpcie_init_chrdev(xpcie);

	if (rc)
		goto failed_chrdev;

	return rc;

	failed_chrdev:
	if(xpcie->dma)
		dma_free_coherent(xpcie->dev, DMA_BUF_SIZE, xpcie->read_buf, xpcie->write_addr);

	read_buf_fail:
	if(xpcie->dma)
		dma_free_coherent(xpcie->dev, DMA_BUF_SIZE, xpcie->write_buf, xpcie->write_addr);

	xilinx_cdma_remove(xpcie);

	write_buf_fail:
	kfree(xpcie->buffer);

	fail_buffer:

	return rc;
}

void xpcie_dev_remove(struct xpcie_dev *xpcie)
{
	xpcie_cleanup_chrdev(xpcie);

	if (xpcie->dma == true) {
		dma_free_coherent(xpcie->dev, DMA_BUF_SIZE, xpcie->write_buf, xpcie->write_addr);
		dma_free_coherent(xpcie->dev, DMA_BUF_SIZE, xpcie->read_buf, xpcie->read_addr);
	}

	xilinx_cdma_remove(xpcie);

	kfree(xpcie->buffer);
}

int xpcie_core_init()
{
	int rc = 0;

	xpcie_class = class_create(THIS_MODULE, xpciename);
	if (IS_ERR(xpcie_class)) {
		rc = PTR_ERR(xpcie_class);
		pr_warn("Failed to register class xpcie\n");
		return rc;
	}

	return rc;
}

void xpcie_core_exit()
{
	class_destroy(xpcie_class);
}
