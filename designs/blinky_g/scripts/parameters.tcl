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
# The LED clock-to-output constraints were optimized for the Green LEDs. The
# Red and Yellow pass timing with these same constraints but the slack
# changes.
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
		# | Delay Type |   Green LEDs   |
		# |            |  Min     Max   |
		# |------------|----------------|
		# | Actual     | 4.669   9.173  |
		# | Constraint | 4.500   9.300  |
		# | Slack      | 0.169   0.127  |
		# | LED        | g[3]    g[7]   |
		#  -----------------------------
		#
		set params [list \
			USEIOFF              $useioff             \
			CLK_12MHZ_FREQUENCY  $clk_12mhz_frequency \
			LED_OUTPUT_MIN       4.5                  \
			LED_OUTPUT_MAX       9.3                  \
		]
	} else {
		#
		#  Fabric register delays at 0C
		#  -----------------------------
		# | Delay Type |   Green LEDs   |
		# |            |  Min     Max   |
		# |------------|----------------|
		# | Actual     | 4.740  10.223  |
		# | Constraint | 4.600  10.400  |
		# | Slack      | 0.140   0.177  |
		# | LED        | g[3]    g[6]   |
		#  -----------------------------
		#
		set params [list \
			USEIOFF              $useioff             \
			CLK_12MHZ_FREQUENCY  $clk_12mhz_frequency \
			LED_OUTPUT_MIN       4.6                  \
			LED_OUTPUT_MAX      10.4                  \
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
