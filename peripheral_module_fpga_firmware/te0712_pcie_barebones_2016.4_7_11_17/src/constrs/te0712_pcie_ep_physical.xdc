# Sys Reset Pins
set_property IOSTANDARD LVCMOS15 [get_ports ext_reset_in]
set_property PULLUP true [get_ports ext_reset_in]
set_property LOC W15 [get_ports ext_reset_in] 

# PCIe Refclk Pins
set_property PACKAGE_PIN F10 [get_ports refclk_p[0]]
set_property PACKAGE_PIN E10 [get_ports refclk_n[0]]

# PCIe TX RX Pins
set_property PACKAGE_PIN B4 [get_ports ext_pcie_txp[0]]
set_property PACKAGE_PIN A4 [get_ports ext_pcie_txn[0]]
set_property PACKAGE_PIN B8 [get_ports ext_pcie_rxp[0]]
set_property PACKAGE_PIN A8 [get_ports ext_pcie_rxn[0]]

set_property PACKAGE_PIN K22 [get_ports led]
set_property IOSTANDARD LVCMOS25 [get_ports led]

