create_clock -period 5.6 -name clk -waveform {0.000 2.800} -add [get_ports clk]
set_input_delay -clock clk -min 0 [get_ports sin_re]
set_input_delay -clock clk -min 0 [get_ports sin_im]
set_output_delay -clock clk -min 0 [get_ports sout_re]
set_output_delay -clock clk -min 0 [get_ports sout_im]

