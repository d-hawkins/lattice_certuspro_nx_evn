# -----------------------------------------------------------------------------
# radiant_utils.tcl
#
# 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Lattice Radiant script utilities.
#
# -----------------------------------------------------------------------------
# Notes
# -----
#
# 1. Radient Tcl console
#
#    The Radiant GUI does not show the Tcl console until after a project
#    is opened. That means this script needs to be run using the Radiant
#    Tcl console. Then once the project is created, the GUI can be used.
#
# -----------------------------------------------------------------------------

# Radiant 2024.2.1 has version 0.4.1
package require yaml

# -----------------------------------------------------------------------------
# Tool Check
# -----------------------------------------------------------------------------
#
proc radiant_tool_check {} {
	# Check the tool is Radiant
	set toolname [file rootname [file tail [info nameofexecutable]]]
	if {![string equal $toolname "radiantc"]} {
		error "Error: unexpected tool name '$toolname'!"
	}
	return
}

# -----------------------------------------------------------------------------
# Radiant project
# -----------------------------------------------------------------------------
#
# Dictionary parameters
#
#  Key             Description
#  -----           -----------
#  REPO            Repository path
#  BOARD           Board FPGA name, eg., certusnx_pro_evn
#  DESIGN          Design name, eg., blinky
#  PART            Radiant FPGA part number, eg., LFCPNX-100-9LFG672C
#  BUILD           Build directory, eg., build/radiant
#  SOURCES         List of source files
#  CONSTRAINTS     List of constraints files
#  PARAMETERS      List of HDL generics/parameters
#
proc radiant_create_project {params} {

	# Parameters
	set repo        [dict get $params REPO]
	set board       [dict get $params BOARD]
	set build       [dict get $params BUILD]
	set part        [dict get $params PART]
	set sources     [dict get $params SOURCES]
	set constraints [dict get $params CONSTRAINTS]

	# Check for an existing Radiant project
	set filename "${build}/${board}.rdf"
	if {[file exists $filename]} {
		error "Error: The Radiant project file already exists!"
	}

	# Create the build directory
	if {![file exists $build]} {
		file mkdir $build
	}
	cd $build

	# Add a timestamp to the YAML file
	set timestamp [clock format [clock seconds] -format "%m-%d-%Y %H:%M:%S"]
	dict set params TIMESTAMP $timestamp

	# Write the YAML parameters file
	# * The parameters are for use by the .SDC and .PDC files
	set filename $build/parameters.yml
	set fd [open $filename w]
	puts $fd [::yaml::dict2yaml $params 2 80]
	close $fd

	# Create the project
	#  * Use Lattice Synthesis Engine
	puts "radiant_utils.tcl: Create the project file"
	prj_create \
		-name $board \
		-impl "impl_1" \
		-dev $part \
		-performance "9_High-Performance_1.0V" \
		-synthesis "lse"

	# -------------------------------------------------------------------------
	# Source and Constraints
	# -------------------------------------------------------------------------
	#
	puts "radiant.tcl: Add source"
	foreach filename $sources {
		prj_add_source $filename
	}
	puts "radiant.tcl: Add constraints"
	foreach filename $constraints {
		prj_add_source $filename
	}
	prj_save

	# -------------------------------------------------------------------------
	# Project Settings
	# -------------------------------------------------------------------------
	#
	puts "radiant.tcl: Configure project settings"

	# Set the top-level
	prj_set_impl_opt -impl "impl_1" {top} $board

	# Turn on "IP Evaluation" so that bitstream generation works
	prj_set_strategy_value -strategy Strategy1 bit_ip_eval=True

	# (Optional) Configure HDL parameters
	if {[dict exists $params PARAMETERS]} {

		# Set the HDL_PARAM
		prj_set_impl_opt -impl "impl_1" {HDL_PARAM} \
			[dict get $params PARAMETERS]

		# Pre-script for writing HDL_PARAM to $build/hdl_param.txt
		# * Use 'syn' so that the HDL parameters file exists for use by .SDC
		prj_set_prescript -impl "impl_1" syn $repo/tcl/radiant_hdl_param.tcl
	}

	# Save the project
	prj_save

	return
}

