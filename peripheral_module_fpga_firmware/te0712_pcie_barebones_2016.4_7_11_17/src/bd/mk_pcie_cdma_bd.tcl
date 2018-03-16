
################################################################
# This is a generated script based on design: system
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
# source system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z045ffg900-2
#    set_property BOARD_PART xilinx.com:zc706:part0:0.9 [current_project]


# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: axi_interconnect_block
proc create_hier_cell_axi_interconnect_block { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_axi_interconnect_block() - Empty argument(s)!"
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 cdma_m_axi_lite
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 cdma_s_axi
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 cdma_s_axi_sg
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 pcie_m_axi
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 pcie_m_axi_ctl
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 pcie_s_axi
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 translation_bram_m_axi
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_m_axi

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -from 0 -to 0 -type rst aresetn
  create_bd_pin -dir I -type clk pcie_ctl_aclk
  create_bd_pin -dir O -type clk user_aclk_out

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list CONFIG.NUM_MI {5} CONFIG.NUM_SI {3} CONFIG.STRATEGY {2}  ] $axi_interconnect_0

  # Create interface connections
  connect_bd_intf_net -intf_net cdma_data_bus [get_bd_intf_pins cdma_s_axi] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net cdma_lite_bus [get_bd_intf_pins cdma_m_axi_lite] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net cdma_sg_bus [get_bd_intf_pins cdma_s_axi_sg] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net pcie_ctl_bus [get_bd_intf_pins pcie_m_axi_ctl] [get_bd_intf_pins axi_interconnect_0/M04_AXI]
  connect_bd_intf_net -intf_net pcie_m_axi_bus [get_bd_intf_pins pcie_m_axi] [get_bd_intf_pins axi_interconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net pcie_s_axi_bus [get_bd_intf_pins pcie_s_axi] [get_bd_intf_pins axi_interconnect_0/S02_AXI]
  connect_bd_intf_net -intf_net translation_bram_axi_bus [get_bd_intf_pins translation_bram_m_axi] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net user_m_axi_bus [get_bd_intf_pins user_m_axi] [get_bd_intf_pins axi_interconnect_0/M02_AXI]

  # Create port connections
  connect_bd_net -net aclk [get_bd_pins aclk] [get_bd_pins user_aclk_out] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_0/S02_ACLK]
  connect_bd_net -net aresetn [get_bd_pins aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/M04_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_0/S02_ARESETN]
  connect_bd_net -net pcie_ctl_aclk [get_bd_pins pcie_ctl_aclk] [get_bd_pins axi_interconnect_0/M04_ACLK]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: pcie_cdma_subsystem
proc create_hier_cell_pcie_cdma_subsystem { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_pcie_cdma_subsystem() - Empty argument(s)!"
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 ext_pcie
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_m_axi

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 -type rst interconnect_aresetn
  create_bd_pin -dir O mmcm_lock
  create_bd_pin -dir I -from 0 -to 0 -type clk pcie_ref_clk_100MHz
  create_bd_pin -dir I -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -type clk user_aclk_out

  # Create instance: axi_cdma_0, and set properties
  set axi_cdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_cdma:4.1 axi_cdma_0 ]
  set_property -dict [ list CONFIG.C_M_AXI_DATA_WIDTH {64} CONFIG.C_M_AXI_MAX_BURST_LEN {64} CONFIG.C_INCLUDE_DRE {1}] $axi_cdma_0

  # Create instance: axi_interconnect_block
  create_hier_cell_axi_interconnect_block $hier_obj axi_interconnect_block

  # Create instance: axi_pcie_0, and set properties, setting to x1 pcie for the mean time...
  set axi_pcie_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_pcie:2.8 axi_pcie_0 ]
  set_property -dict [ list CONFIG.AXIBAR2PCIEBAR_0 {0xa0000000} CONFIG.AXIBAR2PCIEBAR_1 {0xc0000000} CONFIG.AXIBAR_AS_0 {true} CONFIG.AXIBAR_AS_1 {true} CONFIG.AXIBAR_NUM {2} CONFIG.BAR0_ENABLED {true} CONFIG.BAR0_SCALE {Kilobytes} CONFIG.BAR0_SIZE {64} CONFIG.BAR_64BIT {true} CONFIG.CLASS_CODE {0x058000} CONFIG.COMP_TIMEOUT {50ms} CONFIG.DEVICE_ID {0x7024} CONFIG.INTERRUPT_PIN {true} CONFIG.NO_OF_LANES {X1} CONFIG.NUM_MSI_REQ {1} CONFIG.PCIEBAR2AXIBAR_0 {0x81000000} CONFIG.PCIE_CAP_SLOT_IMPLEMENTED {true} CONFIG.S_AXI_SUPPORTS_NARROW_BURST {true}] $axi_pcie_0

  # Create instance: translation_bram, and set properties
  set translation_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 translation_bram ]
  set_property -dict [ list CONFIG.DATA_WIDTH {64}  ] $translation_bram

  # Create instance: translation_bram_mem, and set properties
  set translation_bram_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 translation_bram_mem ]
  set_property -dict [ list CONFIG.Memory_Type {True_Dual_Port_RAM}  ] $translation_bram_mem

  # Create interface connections
  connect_bd_intf_net -intf_net cdma_axi_dm_bus [get_bd_intf_pins axi_cdma_0/M_AXI] [get_bd_intf_pins axi_interconnect_block/cdma_s_axi]
  connect_bd_intf_net -intf_net cdma_axi_lite_bus [get_bd_intf_pins axi_cdma_0/S_AXI_LITE] [get_bd_intf_pins axi_interconnect_block/cdma_m_axi_lite]
  connect_bd_intf_net -intf_net cdma_axi_sg_bus [get_bd_intf_pins axi_cdma_0/M_AXI_SG] [get_bd_intf_pins axi_interconnect_block/cdma_s_axi_sg]
  connect_bd_intf_net -intf_net ext_pcie_bus [get_bd_intf_pins ext_pcie] [get_bd_intf_pins axi_pcie_0/pcie_7x_mgt]
  connect_bd_intf_net -intf_net pcie_axi_ctl_bus [get_bd_intf_pins axi_interconnect_block/pcie_m_axi_ctl] [get_bd_intf_pins axi_pcie_0/S_AXI_CTL]
  connect_bd_intf_net -intf_net pcie_m_axi_bus [get_bd_intf_pins axi_interconnect_block/pcie_s_axi] [get_bd_intf_pins axi_pcie_0/M_AXI]
  connect_bd_intf_net -intf_net pcie_s_axi_bus [get_bd_intf_pins axi_interconnect_block/pcie_m_axi] [get_bd_intf_pins axi_pcie_0/S_AXI]
  connect_bd_intf_net -intf_net translation_bram_axi_bus [get_bd_intf_pins axi_interconnect_block/translation_bram_m_axi] [get_bd_intf_pins translation_bram/S_AXI]
  connect_bd_intf_net -intf_net translation_bram_bram_porta [get_bd_intf_pins translation_bram/BRAM_PORTA] [get_bd_intf_pins translation_bram_mem/BRAM_PORTA]
  connect_bd_intf_net -intf_net translation_bram_bram_portb [get_bd_intf_pins translation_bram/BRAM_PORTB] [get_bd_intf_pins translation_bram_mem/BRAM_PORTB]
  connect_bd_intf_net -intf_net user_m_axi_bus [get_bd_intf_pins user_m_axi] [get_bd_intf_pins axi_interconnect_block/user_m_axi]

  # Create port connections
  #connect_bd_net -net axi_cdma_1_cdma_introut [get_bd_pins axi_cdma_0/cdma_introut] [get_bd_pins axi_pcie_0/INTX_MSI_Request]
  connect_bd_net -net axi_interconnect_aresetn [get_bd_pins interconnect_aresetn] [get_bd_pins axi_interconnect_block/aresetn]
  connect_bd_net -net axi_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins axi_cdma_0/s_axi_lite_aresetn] [get_bd_pins axi_pcie_0/axi_aresetn] [get_bd_pins translation_bram/s_axi_aresetn]
  connect_bd_net -net pcie_axi_aclk [get_bd_pins axi_cdma_0/m_axi_aclk] [get_bd_pins axi_cdma_0/s_axi_lite_aclk] [get_bd_pins axi_interconnect_block/aclk] [get_bd_pins axi_pcie_0/axi_aclk_out] [get_bd_pins translation_bram/s_axi_aclk]
  connect_bd_net -net pcie_ctl_aclk [get_bd_pins axi_interconnect_block/pcie_ctl_aclk] [get_bd_pins axi_pcie_0/axi_ctl_aclk_out]
  connect_bd_net -net pcie_mmcm_lock [get_bd_pins mmcm_lock] [get_bd_pins axi_pcie_0/mmcm_lock]
  connect_bd_net -net sys_clk_1 [get_bd_pins pcie_ref_clk_100MHz] [get_bd_pins axi_pcie_0/REFCLK]
  connect_bd_net -net user_aclk [get_bd_pins user_aclk_out] [get_bd_pins axi_interconnect_block/user_aclk_out]

  #adding constants
  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
  set_property name intx_msi_constant [get_bd_cells xlconstant_0]
  set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells intx_msi_constant]
  connect_bd_net [get_bd_pins intx_msi_constant/dout] [get_bd_pins axi_pcie_0/INTX_MSI_Request]

  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1
  set_property name msi_vector_constant [get_bd_cells xlconstant_1]
  set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {0}] [get_bd_cells msi_vector_constant]
  connect_bd_net [get_bd_pins msi_vector_constant/dout] [get_bd_pins axi_pcie_0/MSI_Vector_Num]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
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


  # Create interface ports
  #set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  #set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set ext_pcie [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 ext_pcie ]

  # Create ports
  set ext_reset_in [ create_bd_port -dir I -type rst ext_reset_in ]
  set_property -dict [ list CONFIG.POLARITY {ACTIVE_LOW}  ] $ext_reset_in
  set refclk_n [ create_bd_port -dir I -from 0 -to 0 refclk_n ]
  set refclk_p [ create_bd_port -dir I -from 0 -to 0 refclk_p ]

  # Create instance: pcie_cdma_subsystem
  create_hier_cell_pcie_cdma_subsystem [current_bd_instance .] pcie_cdma_subsystem

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0 ]
  set_property -dict [ list CONFIG.C_BUF_TYPE {IBUFDSGTE}  ] $util_ds_buf_0

  # Create instance: zynq_PS, and set properties
  #set zynq_PS [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 zynq_PS ]
  #set_property -dict [ list CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_EN_CLK0_PORT {1} CONFIG.PCW_EN_RST0_PORT {1} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_UIPARAM_DDR_PARTNO {Custom} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USE_HIGH_OCM {1} CONFIG.PCW_USE_M_AXI_GP0 {0} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.preset {ZC706*}  ] $zynq_PS

  # Create interface connections
  connect_bd_intf_net -intf_net pcie_cdma_subsystem_ext_pcie [get_bd_intf_ports ext_pcie] [get_bd_intf_pins pcie_cdma_subsystem/ext_pcie]
  #connect_bd_intf_net -intf_net pcie_cdma_subsystem_user_m_axi [get_bd_intf_pins pcie_cdma_subsystem/user_m_axi] [get_bd_intf_pins zynq_PS/S_AXI_HP0]
  #connect_bd_intf_net -intf_net zynq_PS_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins zynq_PS/DDR]
  #connect_bd_intf_net -intf_net zynq_PS_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins zynq_PS/FIXED_IO]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_1 [get_bd_ports refclk_n] [get_bd_pins util_ds_buf_0/IBUF_DS_N]
  connect_bd_net -net IBUF_DS_P_1 [get_bd_ports refclk_p] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
  connect_bd_net -net axi_interconnect_aresetn [get_bd_pins pcie_cdma_subsystem/interconnect_aresetn] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net axi_peripheral_aresetn [get_bd_pins pcie_cdma_subsystem/peripheral_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net ext_reset_in_1 [get_bd_ports ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net pcie_mmcm_locked [get_bd_pins pcie_cdma_subsystem/mmcm_lock] [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT [get_bd_pins pcie_cdma_subsystem/pcie_ref_clk_100MHz] [get_bd_pins util_ds_buf_0/IBUF_OUT]
  #connect_bd_net -net zynq_HP_aclk [get_bd_pins pcie_cdma_subsystem/user_aclk_out] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins zynq_PS/S_AXI_HP0_ACLK]

  # Create address segments
  #create_bd_addr_seg -range 0x4000 -offset 0x81008000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI_CTL/CTL0] DMA_2_PcieCtl
  #create_bd_addr_seg -range 0x100000 -offset 0x80000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI/BAR1] DMA_2_PcieDM
  #create_bd_addr_seg -range 0x100000 -offset 0x80800000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI/BAR0] DMA_2_PcieSG
  #create_bd_addr_seg -range 0x8000 -offset 0x81000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs pcie_cdma_subsystem/translation_bram/S_AXI/Mem0] DMA_2_TransBram
  #create_bd_addr_seg -range 0x100000 -offset 0x80000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data_SG] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI/BAR1] DMAsg_2_PcieDM
  #create_bd_addr_seg -range 0x100000 -offset 0x80800000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data_SG] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI/BAR0] DMAsg_2_PcieSG
  #create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs zynq_PS/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_zynq_PS_HP0_DDR_LOWOCM
  #create_bd_addr_seg -range 0x40000 -offset 0xFFFC0000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_cdma_0/Data] [get_bd_addr_segs zynq_PS/S_AXI_HP0/HP0_HIGH_OCM] SEG_zynq_PS_HP0_HIGH_OCM
  #create_bd_addr_seg -range 0x4000 -offset 0x8100C000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_pcie_0/M_AXI] [get_bd_addr_segs pcie_cdma_subsystem/axi_cdma_0/S_AXI_LITE/Reg] PCIe_2_DmaCtl
  #create_bd_addr_seg -range 0x4000 -offset 0x81008000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_pcie_0/M_AXI] [get_bd_addr_segs pcie_cdma_subsystem/axi_pcie_0/S_AXI_CTL/CTL0] PCIe_2_PcieCtl
  #create_bd_addr_seg -range 0x8000 -offset 0x81000000 [get_bd_addr_spaces pcie_cdma_subsystem/axi_pcie_0/M_AXI] [get_bd_addr_segs pcie_cdma_subsystem/translation_bram/S_AXI/Mem0] PCIe_2_TransBram
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


