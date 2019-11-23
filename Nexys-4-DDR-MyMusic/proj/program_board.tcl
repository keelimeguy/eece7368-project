# Project specific settings. These must be updated for each project.
set proj_name "MyMusic"
set main_file "MyMusic_main"

# Program the board with the compiled bitstream
set curDir [pwd]
open_hw
connect_hw_server
open_hw_target
current_hw_device [lindex [get_hw_devices xc7a100t_0] 0]
set_property PROGRAM.FILE [file normalize "$curDir/$proj_name.runs/impl_1/$main_file.bit"] [current_hw_device]
program_hw_devices [current_hw_device]
