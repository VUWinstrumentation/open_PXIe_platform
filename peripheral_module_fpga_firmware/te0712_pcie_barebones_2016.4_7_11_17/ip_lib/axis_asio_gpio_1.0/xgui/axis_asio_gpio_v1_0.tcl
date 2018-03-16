# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Board [ipgui::add_page $IPINST -name "Board"]
  ipgui::add_param $IPINST -name "USE_BOARD_FLOW" -parent ${Board}
  ipgui::add_param $IPINST -name "C_PORT_ADDR_WIDTH" -parent ${Board}
  ipgui::add_param $IPINST -name "P0_BOARD_INTERFACE" -parent ${Board}

  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_P0_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_P1_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_P2_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_P3_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_P0_MODE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_P1_MODE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_P2_MODE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_P3_MODE" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_P0_BITS { PARAM_VALUE.C_P0_BITS } {
	# Procedure called to update C_P0_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_P0_BITS { PARAM_VALUE.C_P0_BITS } {
	# Procedure called to validate C_P0_BITS
	return true
}

proc update_PARAM_VALUE.C_P0_MODE { PARAM_VALUE.C_P0_MODE } {
	# Procedure called to update C_P0_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_P0_MODE { PARAM_VALUE.C_P0_MODE } {
	# Procedure called to validate C_P0_MODE
	return true
}

proc update_PARAM_VALUE.C_P1_BITS { PARAM_VALUE.C_P1_BITS } {
	# Procedure called to update C_P1_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_P1_BITS { PARAM_VALUE.C_P1_BITS } {
	# Procedure called to validate C_P1_BITS
	return true
}

proc update_PARAM_VALUE.C_P1_MODE { PARAM_VALUE.C_P1_MODE } {
	# Procedure called to update C_P1_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_P1_MODE { PARAM_VALUE.C_P1_MODE } {
	# Procedure called to validate C_P1_MODE
	return true
}

proc update_PARAM_VALUE.C_P2_BITS { PARAM_VALUE.C_P2_BITS } {
	# Procedure called to update C_P2_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_P2_BITS { PARAM_VALUE.C_P2_BITS } {
	# Procedure called to validate C_P2_BITS
	return true
}

proc update_PARAM_VALUE.C_P2_MODE { PARAM_VALUE.C_P2_MODE } {
	# Procedure called to update C_P2_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_P2_MODE { PARAM_VALUE.C_P2_MODE } {
	# Procedure called to validate C_P2_MODE
	return true
}

proc update_PARAM_VALUE.C_P3_BITS { PARAM_VALUE.C_P3_BITS } {
	# Procedure called to update C_P3_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_P3_BITS { PARAM_VALUE.C_P3_BITS } {
	# Procedure called to validate C_P3_BITS
	return true
}

proc update_PARAM_VALUE.C_P3_MODE { PARAM_VALUE.C_P3_MODE } {
	# Procedure called to update C_P3_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_P3_MODE { PARAM_VALUE.C_P3_MODE } {
	# Procedure called to validate C_P3_MODE
	return true
}

proc update_PARAM_VALUE.C_PORT_ADDR_WIDTH { PARAM_VALUE.C_PORT_ADDR_WIDTH } {
	# Procedure called to update C_PORT_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PORT_ADDR_WIDTH { PARAM_VALUE.C_PORT_ADDR_WIDTH } {
	# Procedure called to validate C_PORT_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.P0_BOARD_INTERFACE { PARAM_VALUE.P0_BOARD_INTERFACE } {
	# Procedure called to update P0_BOARD_INTERFACE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.P0_BOARD_INTERFACE { PARAM_VALUE.P0_BOARD_INTERFACE } {
	# Procedure called to validate P0_BOARD_INTERFACE
	return true
}

proc update_PARAM_VALUE.USE_BOARD_FLOW { PARAM_VALUE.USE_BOARD_FLOW } {
	# Procedure called to update USE_BOARD_FLOW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_BOARD_FLOW { PARAM_VALUE.USE_BOARD_FLOW } {
	# Procedure called to validate USE_BOARD_FLOW
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_M_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_M_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_S_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_S_AXIS_TDATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_P1_BITS { MODELPARAM_VALUE.C_P1_BITS PARAM_VALUE.C_P1_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_P1_BITS}] ${MODELPARAM_VALUE.C_P1_BITS}
}

proc update_MODELPARAM_VALUE.C_P2_BITS { MODELPARAM_VALUE.C_P2_BITS PARAM_VALUE.C_P2_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_P2_BITS}] ${MODELPARAM_VALUE.C_P2_BITS}
}

proc update_MODELPARAM_VALUE.C_P3_BITS { MODELPARAM_VALUE.C_P3_BITS PARAM_VALUE.C_P3_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_P3_BITS}] ${MODELPARAM_VALUE.C_P3_BITS}
}

proc update_MODELPARAM_VALUE.C_PORT_ADDR_WIDTH { MODELPARAM_VALUE.C_PORT_ADDR_WIDTH PARAM_VALUE.C_PORT_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PORT_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_PORT_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_P0_BITS { MODELPARAM_VALUE.C_P0_BITS PARAM_VALUE.C_P0_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_P0_BITS}] ${MODELPARAM_VALUE.C_P0_BITS}
}

proc update_MODELPARAM_VALUE.C_P0_MODE { MODELPARAM_VALUE.C_P0_MODE PARAM_VALUE.C_P0_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_P0_MODE}] ${MODELPARAM_VALUE.C_P0_MODE}
}

proc update_MODELPARAM_VALUE.C_P1_MODE { MODELPARAM_VALUE.C_P1_MODE PARAM_VALUE.C_P1_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_P1_MODE}] ${MODELPARAM_VALUE.C_P1_MODE}
}

proc update_MODELPARAM_VALUE.C_P2_MODE { MODELPARAM_VALUE.C_P2_MODE PARAM_VALUE.C_P2_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_P2_MODE}] ${MODELPARAM_VALUE.C_P2_MODE}
}

proc update_MODELPARAM_VALUE.C_P3_MODE { MODELPARAM_VALUE.C_P3_MODE PARAM_VALUE.C_P3_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_P3_MODE}] ${MODELPARAM_VALUE.C_P3_MODE}
}

