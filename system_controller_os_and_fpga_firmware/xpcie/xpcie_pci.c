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

MODULE_DESCRIPTION("Xilinx PCIe driver");
MODULE_AUTHOR("Matthew Bourne");
MODULE_ALIAS("xpcie");
MODULE_LICENSE("GPL v2");

#define PCI_VENDOR_ID_XILINX	0x10ee
#define PCI_DEVICE_ID_XILINX_1	0x0007
#define PCI_DEVICE_ID_XILINX_2	0x7011
#define PCI_DEVICE_ID_XILINX_3	0x7024

static const struct pci_device_id xpcieids[] = {
	{PCI_DEVICE(PCI_VENDOR_ID_XILINX, PCI_DEVICE_ID_XILINX_1)},
	{PCI_DEVICE(PCI_VENDOR_ID_XILINX, PCI_DEVICE_ID_XILINX_2)},
	{PCI_DEVICE(PCI_VENDOR_ID_XILINX, PCI_DEVICE_ID_XILINX_3)},
	{ /* End: all zeroes */ }
};

static const char xpciename[] = "xpcie";

static int xpcie_map_bars(struct xpcie_dev *xpcie);
static void xpcie_unmap_bars(struct xpcie_dev *xpcie);

static int xpcie_map_bars(struct xpcie_dev *xpcie)
{
	/* Map the device memory regions into kernel virtual address space.
	Report their sizes in devInfo.barLengths */
	int i = 0;
	for (i = 0; i < NUM_BARS; i++){
		/* Check all BARs for memory-mapped or I/O-mapped. The driver is
		* intended to be memory-mapped.
		*/
		if (!(pci_resource_flags(xpcie->pdev, i) & IORESOURCE_MEM)) {
			dev_err(xpcie->dev, "BAR %d is of wrong type, aborting.\n", i);
			return (-1);
		}

		xpcie->bar_len[i] = pci_resource_len(xpcie->pdev, i);

		/* Check for messed up BAR */
		if (xpcie->bar_len[i] < 1) {
			dev_warn(xpcie->dev, "BAR #%d length is less than 1 byte.\n", i);
			continue;
		}

		/* If we have a valid bar region then map the device memory or
		IO region into kernel virtual address space */  
		xpcie->bar[i] = pci_iomap(xpcie->pdev, i, xpcie->bar_len[i]);

		if (!xpcie->bar[i]) {
			dev_err(xpcie->dev, "Could not map BAR #%d.\n", i);
			return (-1);
		}

		dev_info(xpcie->dev, "BAR[%d] mapped at 0x%p with length %lu.\n", i, xpcie->bar[i], xpcie->bar_len[i]);
	}
	return 0;
}  

static void xpcie_unmap_bars(struct xpcie_dev *xpcie)
{
	int i;
	for (i = 0; i < NUM_BARS; i++) {
		if (xpcie->bar[i]) {
			pci_iounmap(xpcie->pdev, xpcie->bar[i]);
			xpcie->bar[i] = NULL;
		}
	}
}

static int xpcie_probe(struct pci_dev *pdev, const struct pci_device_id *id)
{
	int rc = 0;

	/* Create structure holding device infomation */
	struct xpcie_dev *xpcie;

	/* Allocate memory for xpcie */
	xpcie = kzalloc(sizeof(struct xpcie_dev), GFP_KERNEL); 

	if (!xpcie) {
		dev_err(&pdev->dev, "Failed to allocate memory. Aborting.\n");
		rc = -ENOMEM;
		goto fail_kzalloc;		
	}

	xpcie->pdev = pdev;
	xpcie->dev = &pdev->dev;

	pci_set_drvdata(pdev, xpcie);

	rc = pci_enable_device(pdev);

	if (rc) {
		dev_err(xpcie->dev, "pci_enable_device() failed. Aborting.\n");
		goto fail_enable;
	}

	rc = pci_request_regions(pdev, xpciename);

	if (rc) {
		dev_err(xpcie->dev, "pci_request_regions() failed. Aborting.\n");
		goto fail_request_regions;
	}

	/* Map all Base Address Registers. There is currently only one */
	if (xpcie_map_bars(xpcie)) {
		rc = -EIO;
		goto fail_map_bars;
	}

	/* Used to allow bus mastering (or DMA) */
	pci_set_master(pdev);

	/* Try to set up a single MSI interrupt */
	if (pci_enable_msi(pdev)) {
		/* If unsuccessful, use legacy interrupts */
		dev_warn(xpcie->dev,
			"Failed to enable MSI interrupts\n");
		xpcie->msi = false;
	}
	else
		xpcie->msi = true;

	/* Request the irq regardless if using msi or legacy */
	rc = request_irq(pdev->irq, xpcie_intr_handler, IRQF_SHARED, xpciename, xpcie);
	if (rc) {
		dev_warn(xpcie->dev,
			"Failed to register interrupt handler, DMA will operate in polling mode\n");
		xpcie->polling = true;
	}
	else
		xpcie->polling = false;

	/* Use 32 bit DMA addressing */
	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
		dev_err(xpcie->dev, "Failed to set DMA mask. Aborting.\n");
		rc = -ENODEV;
		goto failed_dmamask;
	}

	/* Setup the rest of device */
	rc = xpcie_dev_setup(xpcie);

	if (!rc)
		return 0;

	failed_dmamask:
	if(xpcie->polling == false)
		free_irq(pdev->irq, xpcie);

	if(xpcie->msi == true)
		pci_disable_msi(pdev);

	xpcie_unmap_bars(xpcie);

	fail_map_bars:
	pci_release_regions(pdev);

	fail_request_regions:
	pci_disable_device(pdev);

	fail_enable:
	kfree (xpcie);

	fail_kzalloc:

	dev_err(xpcie->dev, "Failed to load xpcie driver.\n");

	return rc;
}

static void xpcie_remove(struct pci_dev *pdev)
{
	struct xpcie_dev *xpcie = pci_get_drvdata(pdev);

	xpcie_dev_remove(xpcie);

	if(xpcie->polling == false)
		free_irq(pdev->irq, xpcie);

	if(xpcie->msi == true)
		pci_disable_msi(pdev);

	xpcie_unmap_bars(xpcie);
	pci_release_regions(pdev);
	pci_disable_device(pdev);

	pci_set_drvdata(pdev, NULL);

	kfree(xpcie);
}

MODULE_DEVICE_TABLE(pci, xpcieids);

static struct pci_driver xpcie_driver = {
	.name = xpciename,
	.id_table = xpcieids,
	.probe = xpcie_probe,
	.remove = xpcie_remove,
};

static int __init xpcie_init(void)
{
	int rc = 0;
	rc = xpcie_core_init();
	if (rc != 0)
		return rc;
	printk(KERN_ALERT "Registring pci driver testing\n");
	rc = pci_register_driver(&xpcie_driver);
	printk(KERN_ALERT "Registration complete\n");
	return rc;
}

static void __exit xpcie_exit(void)
{
	pci_unregister_driver(&xpcie_driver);
	xpcie_core_exit();
}

module_init(xpcie_init);
module_exit(xpcie_exit);
