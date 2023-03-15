
set clock_cycle 1.0 
set io_delay 0.2 

set clock_port clk

create_clock -name clk -period $clock_cycle [get_ports $clock_port]

set_input_delay  $io_delay -clock $clock_port [all_inputs] 
set_output_delay $io_delay -clock $clock_port [all_outputs]


set_multicycle_path -setup 2 -from core_instance/sfp_instance/fifo_inst_int/rd_ptr* -to core_instance/sfp_instance/sfp_out_sign*
set_multicycle_path -hold 1 -from core_instance/sfp_instance/fifo_inst_int/rd_ptr* -to core_instance/sfp_instance/sfp_out_sign*
set_multicycle_path -setup 2 -from core_instance/sfp_instance/fifo_inst_int/q* -to core_instance/sfp_instance/sfp_out_sign*
set_multicycle_path -hold 1 -from core_instance/sfp_instance/fifo_inst_int/q* -to core_instance/sfp_instance/sfp_out_sign*
