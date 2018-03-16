puts "Info:(TE) This block design file has been exported with Reference-Design Scripts from Trenz Electronic GmbH for Board Part:trenz.biz:te0712-01-200-1i:part0:1.0 with FPGA xc7a200tfbg484-1 at 2016-06-28T09:08:29."

################################################################
# This is a generated script based on design: msys
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source msys_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7a200tfbg484-1
#    set_property BOARD_PART trenz.biz:te0712-01-200-1i:part0:1.0 [current_project]



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_local_memory
proc create_hier_cell_microblaze_local_memory { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_microblaze_local_memory() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst LMB_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 lmb_bram ]
  set_property -dict [ list \
CONFIG.Memory_Type {True_Dual_Port_RAM} \
CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  #connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  #connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  #connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  #connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  #connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  #connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  #connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]
  #connect_bd_net -net microblaze_0_LMB_Rst [get_bd_pins LMB_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  #if { $parentCell eq "" } {
  #   set parentCell [get_bd_cells /]
  #}

  # Get object for parentCell
  #set parentObj [get_bd_cells $parentCell]
  #if { $parentObj == "" } {
  #   puts "ERROR: Unable to find parent cell <$parentCell>!"
  #   return
  #}

  # Make sure parentObj is hier blk
  #set parentType [get_property TYPE $parentObj]
  #if { $parentType ne "hier" } {
  #   puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
  #   return
  #}

  # Save current instance; Restore later
  #set oldCurInst [current_bd_instance .]

  # Set parent object as current
  #current_bd_instance $parentObj


  # Create interface ports
  set DDR3_SDRAM [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3_SDRAM ]
  set_property CONFIG.XML_INPUT_FILE {mig.prj} $DDR3_SDRAM
  #set ETH0_MDIO_MDC [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 ETH0_MDIO_MDC ]
  #set ETH0_RMII [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rmii_rtl:1.0 ETH0_RMII ]
  #set P0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 P0 ]
  #set PLL_I2C [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 PLL_I2C ]
  #set QSPI_FLASH [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 QSPI_FLASH ]
  #set UART0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART0 ]
  set sys_diff_clock [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {100000000} \
 ] $sys_diff_clock

  # Create ports
  #set phy_reset_out [ create_bd_port -dir O phy_reset_out ]
  #set reset [ create_bd_port -dir I -type rst reset ]
  #set_property -dict [ list \
#CONFIG.POLARITY {ACTIVE_HIGH} \
# ] $reset

  # Create instance: axi_iic_0, and set properties
  #set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_0 ]
  #set_property -dict [ list \
#CONFIG.IIC_BOARD_INTERFACE {PLL_I2C} \
#CONFIG.USE_BOARD_FLOW {true} \
# ] $axi_iic_0

  # Create instance: axi_mem_intercon, and set properties
  #set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  #set_property -dict [ list \
#CONFIG.NUM_MI {1} \
#CONFIG.NUM_SI {3} \
# ] $axi_mem_intercon

  # Create instance: axi_periph_intercon, and set properties
  #set axi_periph_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_periph_intercon ]
  #set_property -dict [ list \
#CONFIG.NUM_MI {2} \
# ] $axi_periph_intercon

  # Create instance: axis_asio_gpio_0, and set properties
  #set axis_asio_gpio_0 [ create_bd_cell -type ip -vlnv trenz.biz:user:axis_asio_gpio:1.0 axis_asio_gpio_0 ]
  #set_property -dict [ list \
#CONFIG.C_P0_BITS {160} \
#CONFIG.P0_BOARD_INTERFACE {asio} \
# ] $axis_asio_gpio_0

  # Create instance: interrupt_concat, and set properties
  #set interrupt_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 interrupt_concat ]
  #set_property -dict [ list \
#CONFIG.NUM_PORTS {1} \
# ] $interrupt_concat

  # Create instance: microblaze_local_memory
  #create_hier_cell_microblaze_local_memory [current_bd_instance .] microblaze_local_memory

  # Create instance: mii_to_rmii, and set properties
  #set mii_to_rmii [ create_bd_cell -type ip -vlnv xilinx.com:ip:mii_to_rmii:2.0 mii_to_rmii ]
  #set_property -dict [ list \
#CONFIG.RMII_BOARD_INTERFACE {ETH0_RMII} \
# ] $mii_to_rmii

  # Create instance: sys_console, and set properties
  #set sys_console [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 sys_console ]
  #set_property -dict [ list \
#CONFIG.C_BAUDRATE {115200} \
#CONFIG.UARTLITE_BOARD_INTERFACE {UART0} \
#CONFIG.USE_BOARD_FLOW {true} \
# ] $sys_console

  # Create instance: sys_debug, and set properties
  #set sys_debug [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 sys_debug ]
  #set_property -dict [ list \
#CONFIG.C_USE_UART {0} \
# ] $sys_debug

  # Create instance: sys_ethernet, and set properties
  #set sys_ethernet [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernetlite:3.0 sys_ethernet ]
  #set_property -dict [ list \
#CONFIG.MDIO_BOARD_INTERFACE {ETH0_MDIO_MDC} \
#CONFIG.USE_BOARD_FLOW {true} \
# ] $sys_ethernet

  # Create instance: sys_flash, and set properties
  #set sys_flash [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 sys_flash ]
  #set_property -dict [ list \
#CONFIG.C_FIFO_DEPTH {256} \
#CONFIG.C_SPI_MEMORY {3} \
#CONFIG.C_SPI_MODE {2} \
#CONFIG.QSPI_BOARD_INTERFACE {qspi_flash} \
#CONFIG.USE_BOARD_FLOW {true} \
# ] $sys_flash

  # Create instance: sys_intc, and set properties
  #set sys_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 sys_intc ]
  #set_property -dict [ list \
#CONFIG.C_HAS_FAST {1} \
# ] $sys_intc

  # Create instance: sys_microblaze, and set properties
 # set sys_microblaze [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:10.0 sys_microblaze ]
 # set_property -dict [ list \
#CONFIG.C_CACHE_BYTE_SIZE {8192} \
#CONFIG.C_DCACHE_BYTE_SIZE {8192} \
#CONFIG.C_DEBUG_ENABLED {1} \
#CONFIG.C_D_AXI {1} \
#CONFIG.C_D_LMB {1} \
#CONFIG.C_FSL_LINKS {1} \
#CONFIG.C_ICACHE_LINE_LEN {4} \
#CONFIG.C_ICACHE_STREAMS {0} \
#CONFIG.C_ICACHE_VICTIMS {0} \
#CONFIG.C_ILL_OPCODE_EXCEPTION {1} \
#CONFIG.C_I_LMB {1} \
#CONFIG.C_MMU_ZONES {2} \
#CONFIG.C_M_AXI_D_BUS_EXCEPTION {1} \
#CONFIG.C_M_AXI_I_BUS_EXCEPTION {1} \
#CONFIG.C_OPCODE_0x0_ILLEGAL {1} \
#CONFIG.C_PVR {0} \
#CONFIG.C_UNALIGNED_EXCEPTIONS {1} \
#CONFIG.C_USE_BARREL {1} \
#CONFIG.C_USE_DCACHE {1} \
#CONFIG.C_USE_DIV {0} \
#CONFIG.C_USE_HW_MUL {1} \
#CONFIG.C_USE_ICACHE {1} \
#CONFIG.C_USE_MMU {3} \
#CONFIG.C_USE_MSR_INSTR {1} \
#CONFIG.C_USE_PCMP_INSTR {1} \
#CONFIG.G_TEMPLATE_LIST {5} \
#CONFIG.G_USE_EXCEPTIONS {1} \
# ] $sys_microblaze

  # Create instance: sys_ram, and set properties
  set sys_ram [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.0 sys_ram ]
  set_property -dict [ list \
CONFIG.BOARD_MIG_PARAM {DDR3_SDRAM} \
CONFIG.RESET_BOARD_INTERFACE {reset} \
 ] $sys_ram

  # Create instance: sys_reset, and set properties
  #set sys_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_reset ]

  # Create instance: sys_timer, and set properties
  #set sys_timer [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 sys_timer ]
  #set_property -dict [ list \
#CONFIG.enable_timer2 {1} \
#CONFIG.mode_64bit {0} \
# ] $sys_timer

  # Create interface connections
  #connect_bd_intf_net -intf_net axi_ethernetlite_0_MDIO [get_bd_intf_ports ETH0_MDIO_MDC] [get_bd_intf_pins sys_ethernet/MDIO]
  #connect_bd_intf_net -intf_net axi_ethernetlite_0_MII [get_bd_intf_pins mii_to_rmii/MII] [get_bd_intf_pins sys_ethernet/MII]
  #connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_ports PLL_I2C] [get_bd_intf_pins axi_iic_0/IIC]
  #connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins sys_ram/S_AXI]
  #connect_bd_intf_net -intf_net axi_periph_intercon_M03_AXI [get_bd_intf_pins axi_iic_0/S_AXI] [get_bd_intf_pins axi_periph_intercon/M03_AXI]
  #connect_bd_intf_net -intf_net axi_periph_intercon_M05_AXI [get_bd_intf_pins axi_periph_intercon/M05_AXI] [get_bd_intf_pins sys_ethernet/S_AXI]
  #connect_bd_intf_net -intf_net axi_quad_spi_0_SPI_0 [get_bd_intf_ports QSPI_FLASH] [get_bd_intf_pins sys_flash/SPI_0]
  #connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports UART0] [get_bd_intf_pins sys_console/UART]
  #connect_bd_intf_net -intf_net axis_asio_gpio_0_M_AXIS [get_bd_intf_pins axis_asio_gpio_0/M_AXIS] [get_bd_intf_pins sys_microblaze/S0_AXIS]
  #connect_bd_intf_net -intf_net axis_asio_gpio_0_P0 [get_bd_intf_ports P0] [get_bd_intf_pins axis_asio_gpio_0/P0]
  #connect_bd_intf_net -intf_net microblaze_0_M_AXI_DC [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins sys_microblaze/M_AXI_DC]
  #connect_bd_intf_net -intf_net microblaze_0_M_AXI_IC [get_bd_intf_pins axi_mem_intercon/S01_AXI] [get_bd_intf_pins sys_microblaze/M_AXI_IC]
  #connect_bd_intf_net -intf_net ddr3_axi_bus [get_bd_intf_pins axi_mem_intercon/S02_AXI] [get_bd_intf_pins pcie_cdma_subsystem/user_m_axi]
  #connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins axi_periph_intercon/S00_AXI] [get_bd_intf_pins sys_microblaze/M_AXI_DP]
  #connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins axi_periph_intercon/M01_AXI] [get_bd_intf_pins sys_console/S_AXI]
  #connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins axi_periph_intercon/M02_AXI] [get_bd_intf_pins sys_timer/S_AXI]
  #connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins axi_periph_intercon/M00_AXI] [get_bd_intf_pins sys_flash/AXI_LITE]
  #connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins sys_debug/MBDEBUG_0] [get_bd_intf_pins sys_microblaze/DEBUG]
  #connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_local_memory/DLMB] [get_bd_intf_pins sys_microblaze/DLMB]
  #connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_local_memory/ILMB] [get_bd_intf_pins sys_microblaze/ILMB]
  #connect_bd_intf_net -intf_net microblaze_0_intc_axi [get_bd_intf_pins axi_periph_intercon/M01_AXI] [get_bd_intf_pins sys_intc/s_axi]
  #connect_bd_intf_net -intf_net microblaze_0_interrupt [get_bd_intf_pins sys_intc/interrupt] [get_bd_intf_pins sys_microblaze/INTERRUPT]
  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_ports DDR3_SDRAM] [get_bd_intf_pins sys_ram/DDR3]
  #connect_bd_intf_net -intf_net mii_to_rmii_0_RMII_PHY_M [get_bd_intf_ports ETH0_RMII] [get_bd_intf_pins mii_to_rmii/RMII_PHY_M]
  connect_bd_intf_net -intf_net sys_diff_clock_1 [get_bd_intf_ports sys_diff_clock] [get_bd_intf_pins sys_ram/SYS_CLK]
  #connect_bd_intf_net -intf_net sys_microblaze_M0_AXIS [get_bd_intf_pins axis_asio_gpio_0/S_AXIS] [get_bd_intf_pins sys_microblaze/M0_AXIS]

  # Create port connections
  #connect_bd_net -net axi_ethernetlite_0_phy_rst_n [get_bd_ports phy_reset_out] [get_bd_pins sys_ethernet/phy_rst_n]
  #connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins axi_iic_0/iic2intc_irpt] [get_bd_pins interrupt_concat/In4]
  #connect_bd_net -net axi_quad_spi_0_ip2intc_irpt [get_bd_pins interrupt_concat/In0] [get_bd_pins sys_flash/ip2intc_irpt]
  #connect_bd_net -net axi_timer_0_interrupt [get_bd_pins interrupt_concat/In0] [get_bd_pins sys_timer/interrupt]
  #connect_bd_net -net axi_uartlite_0_interrupt [get_bd_pins interrupt_concat/In1] [get_bd_pins sys_console/interrupt]
  #connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins sys_debug/Debug_SYS_Rst] [get_bd_pins sys_reset/mb_debug_sys_rst]
  #connect_bd_net -net microblaze_0_Clk [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins axi_periph_intercon/ACLK] [get_bd_pins axi_periph_intercon/M00_ACLK] [get_bd_pins axi_periph_intercon/M01_ACLK] [get_bd_pins axi_periph_intercon/M02_ACLK] [get_bd_pins axi_periph_intercon/M03_ACLK] [get_bd_pins axi_periph_intercon/M04_ACLK] [get_bd_pins axi_periph_intercon/M05_ACLK] [get_bd_pins axi_periph_intercon/S00_ACLK] [get_bd_pins axis_asio_gpio_0/axis_aclk] [get_bd_pins microblaze_local_memory/LMB_Clk] [get_bd_pins sys_console/s_axi_aclk] [get_bd_pins sys_ethernet/s_axi_aclk] [get_bd_pins sys_flash/ext_spi_clk] [get_bd_pins sys_flash/s_axi_aclk] [get_bd_pins sys_intc/processor_clk] [get_bd_pins sys_intc/s_axi_aclk] [get_bd_pins sys_microblaze/Clk] [get_bd_pins sys_ram/ui_clk] [get_bd_pins sys_reset/slowest_sync_clk] [get_bd_pins sys_timer/s_axi_aclk]
  #connect_bd_net -net pcie_cdma_subsystem_user_aclk_out [get_bd_pins axi_mem_intercon/S02_ACLK] [get_bd_pins pcie_cdma_subsystem/user_aclk_out]
  #connect_bd_net -net microblaze_0_intr [get_bd_pins interrupt_concat/dout] [get_bd_pins sys_intc/intr]
  #connect_bd_net -net mig_7series_0_mmcm_locked [get_bd_pins sys_ram/mmcm_locked] [get_bd_pins sys_reset/dcm_locked]
  connect_bd_net -net mig_7series_0_ui_addn_clk_0 [get_bd_pins sys_ram/clk_ref_i] [get_bd_pins sys_ram/ui_addn_clk_0]
  connect_bd_net -net mig_7series_0_ui_clk_sync_rst [get_bd_pins sys_ram/ui_clk_sync_rst] [get_bd_pins sys_reset/ext_reset_in]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins sys_ram/sys_rst]
  #connect_bd_net -net rst_mig_7series_0_100M_bus_struct_reset [get_bd_pins microblaze_local_memory/LMB_Rst] [get_bd_pins sys_reset/bus_struct_reset]
  #connect_bd_net -net rst_mig_7series_0_100M_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins axi_periph_intercon/ARESETN] [get_bd_pins sys_reset/interconnect_aresetn]
  #connect_bd_net -net rst_mig_7series_0_100M_mb_reset [get_bd_pins sys_intc/processor_rst] [get_bd_pins sys_microblaze/Reset] [get_bd_pins sys_reset/mb_reset]
  #connect_bd_net -net rst_mig_7series_0_100M_peripheral_aresetn [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_mem_intercon/S02_ARESETN] [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins axi_periph_intercon/M00_ARESETN] [get_bd_pins axi_periph_intercon/M01_ARESETN] [get_bd_pins axi_periph_intercon/M02_ARESETN] [get_bd_pins axi_periph_intercon/M03_ARESETN] [get_bd_pins axi_periph_intercon/M04_ARESETN] [get_bd_pins axi_periph_intercon/M05_ARESETN] [get_bd_pins axi_periph_intercon/S00_ARESETN] [get_bd_pins axis_asio_gpio_0/axis_aresetn] [get_bd_pins mii_to_rmii/rst_n] [get_bd_pins sys_console/s_axi_aresetn] [get_bd_pins sys_ethernet/s_axi_aresetn] [get_bd_pins sys_flash/s_axi_aresetn] [get_bd_pins sys_intc/s_axi_aresetn] [get_bd_pins sys_ram/aresetn] [get_bd_pins sys_reset/peripheral_aresetn] [get_bd_pins sys_timer/s_axi_aresetn]
  #connect_bd_net -net sys_ethernet_ip2intc_irpt [get_bd_pins interrupt_concat/In3] [get_bd_pins sys_ethernet/ip2intc_irpt]
  #connect_bd_net -net sys_ram_ui_addn_clk_2 [get_bd_pins mii_to_rmii/ref_clk] [get_bd_pins sys_ram/ui_addn_clk_2]
  
  #Adding connections for barebones PCIe-CDMA
  #connect_bd_intf_net -boundary_type upper [get_bd_intf_pins pcie_cdma_subsystem/user_m_axi] [get_bd_intf_pins sys_ram/S_AXI]
  #connect_bd_net [get_bd_pins sys_ram/ui_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]  
  connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins pcie_cdma_subsystem/user_aclk_out]
  connect_bd_net [get_bd_pins sys_ram/sys_rst] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  
  #Adding interconnect to interface with DDR memory
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
  connect_bd_intf_net -boundary_type upper [get_bd_intf_pins pcie_cdma_subsystem/user_m_axi] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins sys_ram/S_AXI]
  connect_bd_net [get_bd_pins pcie_cdma_subsystem/user_aclk_out] [get_bd_pins axi_interconnect_0/ACLK] -boundary_type upper
  connect_bd_net [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins pcie_cdma_subsystem/user_aclk_out] -boundary_type upper
  connect_bd_net [get_bd_pins sys_ram/ui_clk] [get_bd_pins axi_interconnect_0/M00_ACLK]
  connect_bd_net [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  
  
  #Adding second proc_reset for to sync with RAM clock
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1
  set_property -dict [list CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_0]
  connect_bd_net [get_bd_pins proc_sys_reset_1/dcm_locked] [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net [get_bd_ports ext_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins sys_ram/aresetn]
  connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN]
  connect_bd_net [get_bd_pins sys_ram/ui_clk] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  
  
  # Create address segments
  #create_bd_addr_seg -range 0x10000 -offset 0x40E00000 [get_bd_addr_spaces sys_microblaze/Data] [get_bd_addr_segs sys_ethernet/S_AXI/Reg] SEG_axi_ethernetlite_0_Reg
  #create_bd_addr_seg -range 0x10000 -offset 0x40800000 [get_bd_addr_spaces sys_microblaze/Data] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] SEG_axi_iic_0_Reg
  #create_bd_addr_seg -range 0x10000 -offset 0x41C00000 [get_bd_addr_spaces sys_microblaze/Data] [get_bd_addr_segs sys_timer/S_AXI/Reg] SEG_axi_timer_0_Reg
  #create_bd_addr_seg -range 0x20000 -offset 0x0 [get_bd_addr_spaces sys_microblaze/Data] [get_bd_addr_segs microblaze_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  #create_bd_addr_seg -range 0x20000 -offset 0x0 [get_bd_addr_spaces sys_microblaze/Instruction] [get_bd_addr_segs microblaze_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  #create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces sys_microblaze/Data] [get_bd_addr_segs sys_intc/s_axi/Reg] SEG_microblaze_0_axi_intc_Reg
  #create_bd_addr_seg -range 0x40000000 -offset 0x80000000 [get_bd_addr_spaces sys_microblaze/Data] [get_bd_addr_segs sys_ram/memmap/memaddr] SEG_mig_7series_0_memaddr
  #create_bd_addr_seg -range 0x40000000 -offset 0x80000000 [get_bd_addr_spaces sys_microblaze/Instruction] [get_bd_addr_segs sys_ram/memmap/memaddr] SEG_mig_7series_0_memaddr
  #create_bd_addr_seg -range 0x10000 -offset 0x40600000 [get_bd_addr_spaces sys_microblaze/Data] [get_bd_addr_segs sys_console/S_AXI/Reg] SEG_sys_console_Reg
  #create_bd_addr_seg -range 0x10000 -offset 0x44A00000 [get_bd_addr_spaces sys_microblaze/Data] [get_bd_addr_segs sys_flash/AXI_LITE/Reg] SEG_sys_flash_Reg
  
  create_bd_addr_seg -range 0x4000 -offset 0x81008000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI_CTL/CTL0] DMA_2_PcieCtl
  create_bd_addr_seg -range 0x100000 -offset 0x80000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI/BAR1] DMA_2_PcieDM
  create_bd_addr_seg -range 0x100000 -offset 0x80800000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI/BAR0] DMA_2_PcieSG
  create_bd_addr_seg -range 0x8000 -offset 0x81000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs pcie_cdma_subsystem/translation_bram/S_AXI/Mem0] DMA_2_TransBram
  create_bd_addr_seg -range 0x100000 -offset 0x80000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data_SG] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI/BAR1] DMAsg_2_PcieDM
  create_bd_addr_seg -range 0x100000 -offset 0x80800000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data_SG] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI/BAR0] DMAsg_2_PcieSG
  #create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs zynq_PS/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_zynq_PS_HP0_DDR_LOWOCM
  #create_bd_addr_seg -range 0x40000 -offset 0xFFFC0000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs zynq_PS/S_AXI_HP0/HP0_HIGH_OCM] SEG_zynq_PS_HP0_HIGH_OCM
  create_bd_addr_seg -range 0x4000 -offset 0x8100C000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_pcie_0/M_AXI] [get_bd_addr_segs pcie_cdma_subsystem/axi_cdma_0/S_AXI_LITE/Reg] PCIe_2_DmaCtl
  create_bd_addr_seg -range 0x4000 -offset 0x81008000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_pcie_0/M_AXI] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI_CTL/CTL0] PCIe_2_PcieCtl
  create_bd_addr_seg -range 0x8000 -offset 0x81000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_pcie_0/M_AXI] [get_bd_addr_segs pcie_cdma_subsystem/translation_bram/S_AXI/Mem0] PCIe_2_TransBram
  create_bd_addr_seg -range 1G -offset 0x00000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs {sys_ram/memmap/memaddr}] DMA_2_DDR

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port PLL_I2C -pg 1 -y 560 -defaultsOSRD
preplace port P0 -pg 1 -y 80 -defaultsOSRD
preplace port UART0 -pg 1 -y 480 -defaultsOSRD
preplace port ETH0_RMII -pg 1 -y 160 -defaultsOSRD
preplace port phy_reset_out -pg 1 -y 140 -defaultsOSRD
preplace port QSPI_FLASH -pg 1 -y 640 -defaultsOSRD
preplace port ETH0_MDIO_MDC -pg 1 -y 210 -defaultsOSRD
preplace port DDR3_SDRAM -pg 1 -y 330 -defaultsOSRD
preplace port reset -pg 1 -y 350 -defaultsOSRD
preplace port sys_diff_clock -pg 1 -y 260 -defaultsOSRD
preplace inst sys_reset -pg 1 -lvl 6 -y 100 -defaultsOSRD
preplace inst sys_ram -pg 1 -lvl 5 -y 450 -defaultsOSRD
preplace inst sys_debug -pg 1 -lvl 2 -y 360 -defaultsOSRD
preplace inst axi_periph_intercon -pg 1 -lvl 1 -y 550 -defaultsOSRD
preplace inst axi_iic_0 -pg 1 -lvl 5 -y 800 -defaultsOSRD
preplace inst sys_microblaze -pg 1 -lvl 3 -y 370 -defaultsOSRD
preplace inst mii_to_rmii -pg 1 -lvl 5 -y 190 -defaultsOSRD
preplace inst sys_ethernet -pg 1 -lvl 4 -y 110 -defaultsOSRD
preplace inst sys_console -pg 1 -lvl 5 -y 660 -defaultsOSRD
preplace inst microblaze_local_memory -pg 1 -lvl 4 -y 280 -defaultsOSRD
preplace inst sys_flash -pg 1 -lvl 5 -y 930 -defaultsOSRD
preplace inst axis_asio_gpio_0 -pg 1 -lvl 5 -y 50 -defaultsOSRD
preplace inst sys_intc -pg 1 -lvl 2 -y 180 -defaultsOSRD
preplace inst interrupt_concat -pg 1 -lvl 6 -y 880 -defaultsOSRD
preplace inst sys_timer -pg 1 -lvl 2 -y 530 -defaultsOSRD
preplace inst axi_mem_intercon -pg 1 -lvl 4 -y 560 -defaultsOSRD
preplace netloc axi_quad_spi_0_SPI_0 1 5 12 NJ 640 NJ 640 NJ 640 NJ 640 NJ 640 NJ 640 NJ 640 NJ 640 NJ 640 NJ 640 NJ 640 NJ
preplace netloc mig_7series_0_mmcm_locked 1 5 1 1990
preplace netloc axi_ethernetlite_0_MDIO 1 4 13 NJ 120 NJ 210 NJ 210 NJ 210 NJ 210 NJ 210 NJ 210 NJ 210 NJ 210 NJ 210 NJ 210 NJ 210 NJ
preplace netloc microblaze_0_axi_periph_M04_AXI 1 1 4 NJ 750 NJ 750 NJ 750 NJ
preplace netloc axi_periph_intercon_M05_AXI 1 1 3 NJ 70 NJ 70 1280
preplace netloc mig_7series_0_DDR3 1 5 12 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ
preplace netloc sys_microblaze_M0_AXIS 1 3 2 1210 30 NJ
preplace netloc mig_7series_0_ui_addn_clk_0 1 4 2 1690 330 1940
preplace netloc microblaze_0_intr 1 1 6 390 20 NJ 20 NJ 20 NJ 270 NJ 270 2410
preplace netloc axi_uartlite_0_interrupt 1 5 1 2000
preplace netloc axi_iic_0_iic2intc_irpt 1 5 1 1940
preplace netloc axis_asio_gpio_0_M_AXIS 1 2 4 680 -20 NJ -20 NJ -20 1960
preplace netloc axi_periph_intercon_M03_AXI 1 1 4 NJ 740 NJ 740 NJ 740 NJ
preplace netloc microblaze_0_Clk 1 0 6 20 330 380 430 650 490 1180 190 1650 310 1960
preplace netloc microblaze_0_interrupt 1 2 1 NJ
preplace netloc microblaze_0_intc_axi 1 1 1 350
preplace netloc sys_diff_clock_1 1 0 5 NJ 260 NJ 280 NJ 270 NJ 390 NJ
preplace netloc microblaze_0_ilmb_1 1 3 1 1260
preplace netloc microblaze_0_M_AXI_DC 1 3 1 1210
preplace netloc axi_mem_intercon_M00_AXI 1 4 1 1680
preplace netloc microblaze_0_axi_dp 1 0 4 0 50 NJ 50 NJ 50 1190
preplace netloc axi_ethernetlite_0_phy_rst_n 1 4 13 1670 260 NJ 200 NJ 140 NJ 140 NJ 140 NJ 140 NJ 140 NJ 140 NJ 140 NJ 140 NJ 140 NJ 140 NJ
preplace netloc axis_asio_gpio_0_P0 1 5 12 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 NJ
preplace netloc mii_to_rmii_0_RMII_PHY_M 1 5 12 NJ 190 NJ 160 NJ 160 NJ 160 NJ 160 NJ 160 NJ 160 NJ 160 NJ 160 NJ 160 NJ 160 N
preplace netloc rst_mig_7series_0_100M_peripheral_aresetn 1 0 7 -10 310 370 80 NJ 80 1240 720 1660 580 NJ 580 2420
preplace netloc rst_mig_7series_0_100M_interconnect_aresetn 1 0 7 10 290 NJ 290 NJ 250 1220 380 NJ 290 NJ 290 2390
preplace netloc rst_mig_7series_0_100M_bus_struct_reset 1 3 4 1280 370 NJ 280 NJ 280 2400
preplace netloc microblaze_0_axi_periph_M01_AXI 1 1 4 NJ 710 NJ 710 NJ 710 NJ
preplace netloc microblaze_0_M_AXI_IC 1 3 1 1200
preplace netloc axi_uartlite_0_UART 1 5 12 NJ 480 NJ 480 NJ 480 NJ 480 NJ 480 NJ 480 NJ 480 NJ 480 NJ 480 NJ 480 NJ 480 NJ
preplace netloc axi_iic_0_IIC 1 5 12 NJ 560 NJ 560 NJ 560 NJ 560 NJ 560 NJ 560 NJ 560 NJ 560 NJ 560 NJ 560 NJ 560 NJ
preplace netloc sys_ram_ui_addn_clk_2 1 4 2 1690 320 1950
preplace netloc rst_mig_7series_0_100M_mb_reset 1 1 6 390 420 670 470 NJ 410 NJ 570 NJ 570 2430
preplace netloc mig_7series_0_ui_clk_sync_rst 1 5 1 1970
preplace netloc microblaze_0_dlmb_1 1 3 1 1230
preplace netloc microblaze_0_axi_periph_M02_AXI 1 1 1 NJ
preplace netloc microblaze_0_debug 1 2 1 NJ
preplace netloc axi_ethernetlite_0_MII 1 4 1 NJ
preplace netloc sys_ethernet_ip2intc_irpt 1 4 2 NJ 1010 2040
preplace netloc reset_1 1 0 5 NJ 300 NJ 300 NJ 480 NJ 400 NJ
preplace netloc mdm_1_debug_sys_rst 1 2 4 NJ 240 NJ 360 NJ 300 1950
preplace netloc axi_quad_spi_0_ip2intc_irpt 1 5 1 2030
preplace netloc axi_timer_0_interrupt 1 2 4 N 560 NJ 730 NJ 730 NJ
levelinfo -pg 1 -40 170 520 960 1440 1820 2230 2470 2520 2570 2620 2670 2720 2770 2820 2870 2920 2960 -top -30 -bot 1020
",
}

  # Restore current instance
  #current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""



