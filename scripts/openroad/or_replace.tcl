read_lef $::env(MERGED_LEF_UNPADDED)
read_def $::env(CURRENT_DEF)

# global_placement \
# 	-density $::env(PL_TARGET_DENSITY) \
# 	-verbose 3

set_replace_verbose_level_cmd 1

set_replace_density_cmd $::env(PL_TARGET_DENSITY)

if { $::env(PL_INITIAL_PLACEMENT) } {
	set_replace_overflow_cmd 0.9
	set_replace_initial_place_max_iter_cmd 20
}

if { $::env(PL_TIME_DRIVEN) } {
	read_lib $::env(LIB_SYNTH)
	read_sdc $::env(SCRIPTS_DIR)/base.sdc
	read_verilog $::env(yosys_result_file_tag).v
} else {
	set_replace_disable_timing_driven_mode_cmd
}

if { !$::env(PL_ROUTABILITY_DRIVEN) } {
	set_replace_disable_routability_driven_mode_cmd
} else {
	FastRoute::set_capacity_adjustment $::env(GLB_RT_ADJUSTMENT)
	FastRoute::set_max_layer $::env(GLB_RT_MAXLAYER)
	FastRoute::add_layer_adjustment 1 $::env(GLB_RT_L1_ADJUSTMENT)
	FastRoute::add_layer_adjustment 1 $::env(GLB_RT_L1_ADJUSTMENT)
	FastRoute::set_unidirectional_routing $::env(GLB_RT_UNIDIRECTIONAL)
	FastRoute::set_overflow_iterations 150
	set_replace_routability_max_density_cmd [expr $::env(PL_TARGET_DENSITY) + 0.1]
	set_replace_routability_max_inflation_iter_cmd 10
}

# set_replace_pad_right_cmd 1
replace_initial_place_cmd
replace_nesterov_place_cmd
replace_reset_cmd

write_def $::env(SAVE_DEF)
