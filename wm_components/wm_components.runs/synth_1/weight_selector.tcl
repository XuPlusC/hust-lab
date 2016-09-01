# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/sabertazimi/gitrepo/dld/wm_components/wm_components.cache/wt [current_project]
set_property parent.project_path /home/sabertazimi/gitrepo/dld/wm_components/wm_components.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
read_verilog -library xil_defaultlib /home/sabertazimi/gitrepo/dld/wm_components/wm_components.srcs/sources_1/new/weight_selector.v
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/sabertazimi/gitrepo/dld/wm_components/wm_components.srcs/constrs_1/new/weight_selector.xdc
set_property used_in_implementation false [get_files /home/sabertazimi/gitrepo/dld/wm_components/wm_components.srcs/constrs_1/new/weight_selector.xdc]


synth_design -top weight_selector -part xc7a100tcsg324-1


write_checkpoint -force -noxdef weight_selector.dcp

catch { report_utilization -file weight_selector_utilization_synth.rpt -pb weight_selector_utilization_synth.pb }
