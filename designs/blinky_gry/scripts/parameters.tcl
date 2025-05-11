# -----------------------------------------------------------------------------
# parameters.tcl
#
# 5/3/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Design parameters utilities.
#
# This script is required in each of the design scripts directories.
# The common procedures are located in $repo/tcl/constraints_utils.tcl.
# The pre-synthesis script $repo/tcl/radiant_hdl_param.tcl reads the
# project HDL_PARAM setting and uses it to update the timing parameters.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Get Timing Parameters
# -----------------------------------------------------------------------------
#
# The design timing parameters change depending on the top-level parameter
# USEIOFF. The top-level parameter can be changed using the Radiant GUI, so
# Radiant is configured to run a pre-synthesis script that reads USEIOFF,
# and then writes the design timing constraints to a YAML file in the build
# directory.
#
proc get_timing_parameters {hdl_param} {

	# Extract the USEIOFF setting
	set useioff [get_hdl_param $hdl_param USEIOFF]

	# Clock frequency
	set clk_12mhz_frequency 12.000e6

	if {$useioff == 1} {
		#
		#  I/O register delays at 0C
		#  -----------------------------
		# | Delay Type |   G+R+Y LEDs   |
		# |            |  Min     Max   |
		# |------------|----------------|
		# | Actual     | 7.026   9.173  |
		# | Constraint | 6.900   9.300  |
		# | Slack      | 0.126   0.127  |
		# | LED        | y[7:0]  y[7:0] |
		#  -----------------------------
		#
		set params [list \
			USEIOFF              $useioff             \
			CLK_12MHZ_FREQUENCY  $clk_12mhz_frequency \
			LED_OUTPUT_MIN       6.9                  \
			LED_OUTPUT_MAX       9.3                  \
		]
	} else {
		#
		#  Fabric register delays at 0C
		#  -----------------------------
		# | Delay Type |   G+R+Y LEDs   |
		# |            |  Min     Max   |
		# |------------|----------------|
		# | Actual     | 6.859   9.584  |
		# | Constraint | 6.700   9.700  |
		# | Slack      | 0.159   0.116  |
		# | LED        | y[0]    g[0]   |
		#  -----------------------------
		#
		set params [list \
			USEIOFF              $useioff             \
			CLK_12MHZ_FREQUENCY  $clk_12mhz_frequency \
			LED_OUTPUT_MIN       6.7                  \
			LED_OUTPUT_MAX       9.7                  \
		]
	}
	return $params
}

# -----------------------------------------------------------------------------
# HDL_PARAM update
# -----------------------------------------------------------------------------
#
# The pre-script sources the project parameters.tcl script and calls
#
# > parameters_update $repo $board $design $build $hdl_param
#
# Each design creates a custom parameters.tcl with a customized callback
# to implement whatever project-specific changes are required.
#
# This procedure updates the SDC constraints based on USEIOFF.
#
proc parameters_update {repo board design build hdl_param} {

	# Update the YAML file
	set filename $build/parameters.yml
	yaml_parameters_update $filename $hdl_param

	# Update the SDC file
	#  * The SDC file needs to already exist in the build directory
	#  * The prj_source_add command does not work from a pre-script
	#
	# SDC template and project files
	set filename_i $repo/designs/$design/scripts/${board}_sdc.txt
	set filename_o $build/${board}.sdc
	update_sdc_file $filename_i $filename_o $hdl_param

	return
}
