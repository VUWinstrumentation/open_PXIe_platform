###############################################################################
# Timing Constraints
###############################################################################
#

create_clock -period 10.000 -name sys_clk [get_ports refclk_p]
create_clock -period 10.000 -name sys_diff_clk [get_ports sys_diff_clock_p]
set_false_path -from [get_ports ext_reset_in]


