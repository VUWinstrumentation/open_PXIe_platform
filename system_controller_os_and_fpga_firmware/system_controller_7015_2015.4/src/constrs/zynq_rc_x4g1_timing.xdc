#create_clock -period 10.000 -name REFCLK -waveform {0.000 5.000} [get_pins zynq_rc_x4g1_i/util_ds_buf_0/IBUF_OUT[0]]
#create_clock -period 8.000 -name clk125 -waveform {0.000 4.000} [get_nets zynq_rc_x4g1_wrapper_i/zynq_rc_x4g1_i/clk_wiz_1_clk_out1]
