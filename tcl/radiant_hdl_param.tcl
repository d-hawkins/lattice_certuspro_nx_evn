# -----------------------------------------------------------------------------
# radiant_hdl_param.tcl
#
# 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Lattice Radiant pre-script for writing HDL_PARAM to file.
#
# Configure the project to use this script before synthesis using:
#
# > prj_set_prescript -impl impl_1 syn $tcl/radiant_hdl_param.tcl
#
# -----------------------------------------------------------------------------
# Notes
# -----
#
# 1. HDL_PARAM
#
#    The blinky LED designs were used to investigate the clock-to-output delay
#    variation when outputs are driven from I/O registers or fabric registers.
#
#    Radiant does not have a .PDC constraint to control the use of I/O
#    registers, so the top-level design uses the HDL parameter USEIOFF to
#    control the placement (using syn_useioff). The Radiant GUI can set the
#    HDL parameter using "Project > Active Implementation > Set Top-Level Unit"
#    and then editing the "HDL Parameters" field, eg., USEIOFF=1.
#
#    The blinky LED SDC constraints are configured to result in under 0.2ns of
#    slack. The SDC clock-to-output minimum and maximum values are different
#    for the two USEIOFF settings. SDC Tcl does not support the prj_* commands
#    needed to read HDL_PARAM, and the Radiant GUI does not connect up the
#    Tcl stdout channel for use by .SDC or .PDC files when using the
#    GUI constraints editor.
#
#    This pre-script is used prior to synthesis to read the HDL_PARAM string
#    and to update the build design files, eg., update the SDC constraints.
#    An earlier version of this script wrote a YAML file in the build area
#    and the SDC file read the YAML. This worked, but the fact that Radiant
#    GUI did not connect Tcl stdout made debugging difficult, so the scheme
#    to write out SDC files was adopted.
#
# -----------------------------------------------------------------------------

# Radiant 2024.2.1 has version 0.4.1
package require yaml

# -----------------------------------------------------------------------------
# Started Message
# -----------------------------------------------------------------------------
#
puts "[string repeat = 80]"
puts "radiant_hdl_param.tcl: Started"
puts "[string repeat - 80]"

# -----------------------------------------------------------------------------
# Directories
# -----------------------------------------------------------------------------
#
catch {puts "radiant_hdl_param.tcl: pwd = [pwd]"}

# This script runs from build/radiant_<variant>/impl_1
set build [file dirname [file normalize [pwd]]]

# Find the parameters YAML file
set filename $build/parameters.yml
if {![file exists $filename]} {
#	puts "radiant_hdl_param.tcl: .yml = $filename"
	error "radiant_hdl_param.tcl: Error parameters file not found!"
}

# Read the parameters YAML file and convert to dictionary
set fd [open $filename r]
set buffer [read $fd]
close $fd
set params [::yaml::yaml2dict $buffer]

# Check for the keys used in this script
set keys [list REPO BOARD DESIGN PARAMETERS]
foreach key $keys {
	if {![dict exists $params $key]} {
		error "radiant_hdl_param.tcl: Error $key key missing!"
	}
}

# Repository path
set repo   [dict get $params REPO]

# Board name
set board  [dict get $params BOARD]

# Design name
set design [dict get $params DESIGN]

# -----------------------------------------------------------------------------
# Design Parameters Utility Script
# -----------------------------------------------------------------------------
#
source $repo/tcl/constraints_sdc_utils.tcl
source $repo/designs/$design/scripts/parameters.tcl

# -----------------------------------------------------------------------------
# Radiant Project
# -----------------------------------------------------------------------------
#
# Project RDF file
set filename $build/${board}.rdf
if {![file exists $filename]} {
#	puts "radiant_hdl_param.tcl: .rdf = $filename"
	error "radiant_hdl_param.tcl: Error: Radiant project not found!"
}

# -----------------------------------------------------------------------------
# Read the project HDL_PARAM settings
# -----------------------------------------------------------------------------
#
# Project open
prj_open $filename

# Read the GUI HDL_PARAM entry
set hdl_param [prj_set_impl_opt -impl "impl_1" {HDL_PARAM}]
puts "radiant_hdl_param.tcl: HDL_PARAM = \{$hdl_param\}"

prj_close

# -----------------------------------------------------------------------------
# Project-specific callback
# -----------------------------------------------------------------------------
#
# Note:
#  - This is called with the project closed
#  - prj_add_source did not work in the parameters_update call
#  - A blank SDC was added to the project during creation
#
parameters_update $repo $board $design $build $hdl_param

# -----------------------------------------------------------------------------
# Ended Message
# -----------------------------------------------------------------------------
#
puts "[string repeat = 80]"
puts "radiant_hdl_param.tcl: Ended"
puts "[string repeat - 80]"

