# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/sabertazimi/gitrepo/dld/starter/starter.cache/wt [current_project]
set_property parent.project_path /home/sabertazimi/gitrepo/dld/starter/starter.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
read_verilog -library xil_defaultlib {
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/integer_to_bcd.v
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/bcd_to_segment.v
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/time_to_segment.v
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/timer.v
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/ring.v
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/time_displayer.v
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/tick_divider.v
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/range_divider.v
  /home/sabertazimi/gitrepo/dld/starter/starter.srcs/sources_1/new/clock.v
}
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/sabertazimi/gitrepo/dld/starter/starter.srcs/constrs_1/new/clock.xdc
set_property used_in_implementation false [get_files /home/sabertazimi/gitrepo/dld/starter/starter.srcs/constrs_1/new/clock.xdc]


synth_design -top clock -part xc7a100tcsg324-1


write_checkpoint -force -noxdef clock.dcp

catch { report_utilization -file clock_utilization_synth.rpt -pb clock_utilization_synth.pb }
