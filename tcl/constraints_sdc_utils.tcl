# -----------------------------------------------------------------------------
# constraints_sdc_utls.tcl
#
# 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Lattice CertusPro-NX Evaluation Board Timing Constraints Tcl Procedures.
#
# These procedures are used by the HDL_PARAM pre-synthesis script for
# reading HDL_PARAM, reading design-specific parameters, and for modifying
# YAML and SDC files.
#
# -----------------------------------------------------------------------------
# References
# ----------
#
# [1] Lattice, "CertusPro-NX Evaluation Board", 2025
#     https://www.latticesemi.com/products/developmentboardsandkits/certuspro-nxevaluationboard
#     Ordering Part Number: LFCPNX-EVN
#
# -----------------------------------------------------------------------------

# Radiant 2024.2.1 has version 0.4.1
package require yaml

# -----------------------------------------------------------------------------
# Parse an HDL_PARAM key-value pair
# -----------------------------------------------------------------------------
#
# This procedure was written to parse USEIOFF, but it was generalzed for
# reading any HDL_PARAM key-value pair.
#
# In the Radiant GUI parameter lists are separated by a semicolon, eg.,
# parameters USEIOFF=1 and WIDTH=8 would be entered as USEIOFF=1;WIDTH=8,
# but Radiant returns a list without the semicolons, eg.,
#
# > set hdl_param [prj_set_impl_opt -impl impl_1 {HDL_PARAM}]
# USEIOFF=1 WIDTH=8
# > llength $hdl_param
# 2
#
# The USEIOFF parameters is read via:
#
# > set useioff [get_hdl_param $hdl_param USEIOFF]
#
proc get_hdl_param {hdl_param key} {
	set index [lsearch $hdl_param "${key}*"]
	if {$index != -1} {
		# Key-value pair
		set key_value [lindex $hdl_param $index]
		# Return the key
		return [lindex [split $key_value =] 1]
	} else {
		error "Error: $key was not found!"
	}
}

# -----------------------------------------------------------------------------
# Update the YAML parameters file
# -----------------------------------------------------------------------------
#
proc yaml_parameters_update {filename hdl_param} {

	# The YAML file should already exist
	if {![file exists $filename]} {
		error "Error: YAML file not found!"
	}

	# Read the existing YAML file
	set fd [open $filename r]
	set buffer [read $fd]
	close $fd
	set params [::yaml::yaml2dict $buffer]

	# 5/3/2025:
	# Static SDC files are now generated in the build area, rather
	# than SDC scripts that read the YAML parameters file.

	# Extract the USEIOFF setting
#	set useioff [get_hdl_param $hdl_param USEIOFF]

	# Update the timing parameters
#	set timing_params [get_timing_parameters $useioff]
#	dict for {key value} $timing_params {
#		dict set params $key $value
#	}

	# Update the HDL parameters
	dict set params PARAMETERS $hdl_param

	# Update the timestamp
	set timestamp [clock format [clock seconds] -format "%m-%d-%Y %H:%M:%S"]
	dict set params TIMESTAMP $timestamp

	# Write the YAML parameters file
	set fd [open $filename w]
	puts $fd [::yaml::dict2yaml $params 2 80]
	close $fd

	return
}

# -----------------------------------------------------------------------------
# Update the SDC file
# -----------------------------------------------------------------------------
#
# The USEIOBUF parameter can be changed in the GUI and that change in top-level
# parameter requires changing the timing constraints. The SDC needs to be
# generated using only SDC supported Tcl commands, as the Radiant GUI does not
# create the Tcl environment consistently. For example, the "Pre-Synthesis
# Constraint Editor" and the "Post-Synthesis Timing Constraint Editor" do not
# connect the Tcl stdout channel, so the puts command does not work.
# The prj_add_source command did not work correctly when called from the
# pre-script: the .SDC file appeared to be added correctly, but it never
# appeared in the GUI (perhaps a Tcl project context issue). The work-around
# was to create an empty .SDC file in the build area and add that to the
# project during initial creating. The pre-script then updates the contents
# of the file that is already part of the Radiant project.
#
proc update_sdc_file {filename_i filename_o hdl_param} {

	# Get the timing parameters
	set params [get_timing_parameters $hdl_param]

	# Read the SDC template
	set fd [open $filename_i r]
	set buffer [read $fd]
	close $fd

	# Add the file DATE to the dictionary
	set date [clock format [clock seconds] -format "%m/%d/%Y"]
	dict set params DATE $date

	# Search and replace parameters
	#  * Replace each of the template strings "${key}_VAL" with $value
	dict for {key value} $params {
		set buffer [string map [list ${key}_VAL $value] $buffer]
	}

	# Write the SDC file
	set fd [open $filename_o w]
	puts $fd $buffer
	close $fd

	return
}
