# Nexys4 DDR MyMusic Project
Built with Vivado 2018.2

## Command Line Usage

1. `cd ./proj`
2. `vivado -mode batch -source create_project.tcl`
3. `vivado -mode batch -source run_project.tcl MyMusic.xpr`
4. `vivado -mode batch -source program_board.tcl`
5. Once complete, the board will run the program until turned off or re-programmed
6. `cleanup.sh` will clean up all generated files by the above, if desired

## IDE Usage

1. Open Vivado
2. In Vivado Tcl prompt, `cd` to ./proj
3. Run `source ./create_project.tcl`
4. Click "Generate Bitstream" under "Flow Navigator" on left
5. Click "Yes" to run Synthesis and Implementation
6. Set number of jobs and click "OK" to begin
7. Once complete, select "Open Hardware Manager" in popup and click "OK"
9. Plug the board into the computer
8. Select "Open target" near the top
9. Select "Open new target.."
10. Follow the GUI, connecting to "Local server"
11. When connected, click "Program device" near the top
12. Make sure the .bit file is selected and click "Program"
13. Once complete, the board will run the program until turned off or re-programmed

## References
- [Nexys-4-DDR-__skeleton__](https://github.com/keelimeguy/FPGA-Vivado-skeletons/tree/master/Nexys-4-DDR-__skeleton__)
- [Nexys 4 GPIO Demo](https://reference.digilentinc.com/learn/programmable-logic/tutorials/nexys-4-ddr-gpio-demo/start)
- [Nexys 4 Serial Port](https://forum.digilentinc.com/topic/766-vhdl-uart-rx-for-nexys4-ddr/)
