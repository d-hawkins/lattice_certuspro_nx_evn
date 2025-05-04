# -----------------------------------------------------------------------------
# radiant.tcl
#
# 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Lattice Radiant build script for the CertusPro-NX Evaluation Board.
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

# -----------------------------------------------------------------------------
# Board
# -----------------------------------------------------------------------------
#
# Board
set board certuspro_nx_evn

# -----------------------------------------------------------------------------
# Design Directories
# -----------------------------------------------------------------------------
#
set top     [file normalize [pwd]]
set src     $top/src
set scripts $top/scripts

# Design name
set design  [file tail $top]

# -----------------------------------------------------------------------------
# Build Directory
# -----------------------------------------------------------------------------
#
# A build directory needs to support the generation of files from multiple
# tools. For example, Lattice Radiant designs require a directory for the
# Radiant generated files, could require a Questasim simulation directory,
# and for Radiant Propel designs, an Eclipse workspace. These needs can be
# accommodated by a top-level build directory containing directories based
# on the tool name, eg.,
#
# - $build/radiant     Radiant files
# - $build/questasim   Questasim files
# - $build/propel      Propel files
#
# The default build directory is created within the design, eg.,
#
# - build = c:/github/certusnx_pro_evn/basic/build
#
# An environment variable can be used to specify the build, eg.,
#
# - RADIANT_BUILD = c:/temp/build
# - build = ${RADIANT_BUILD}/certusnx_pro_evn/basic
#
# The environment variable approach generates the build artifacts outside of
# the design git repository, which can be useful for design automation.
#
if {[info exists RADIANT_BUILD]} {
	# User Tcl environment over-ride
	set build [file normalize ${RADIANT_BUILD}]/${board}/${design}/radiant
} elseif {[info exists ::env(RADIANT_BUILD)]} {
	# User environment over-rider
	set build [file normalize $::env(RADIANT_BUILD)]/${board}/${design}/radiant
} else {
	# Default build location
	set build $top/build/radiant
}
puts "radiant.tcl: build = $build"

# -----------------------------------------------------------------------------
# Tool Check
# -----------------------------------------------------------------------------
#
# Check the tool is Radiant
set toolname [file rootname [file tail [info nameofexecutable]]]
if {![string equal $toolname "radiantc"]} {
	error "radiant.tcl: Error: unexpected tool name '$toolname'!"
}

# -----------------------------------------------------------------------------
# Project
# -----------------------------------------------------------------------------
#
set filename ${build}/${board}.rdf
if {[file exists $filename]} {
	puts "radiant.tcl: $filename"
	error "radiant.tcl: Error: The Radiant project file already exists!"
}

# Create the build directory
if {![file exists $build]} {
	file mkdir $build
}
cd $build

# Use Lattice Synthesis Engine
puts "radiant.tcl: Create the project file"
prj_create \
	-name $board \
	-impl "impl_1" \
	-dev LFCPNX-100-9LFG672C \
	-performance "9_High-Performance_1.0V" \
	-synthesis "lse"

# -----------------------------------------------------------------------------
# Source and Constraints
# -----------------------------------------------------------------------------
#
puts "radiant.tcl: Add source and constraints"
set filenames [list \
	$src/certuspro_nx_evn.sv      \
	$scripts/certuspro_nx_evn.sdc \
	$scripts/certuspro_nx_evn.pdc \
]
foreach filename $filenames {
	prj_add_source $filename
}
prj_save

# -----------------------------------------------------------------------------
# Project Settings
# -----------------------------------------------------------------------------
#
puts "radiant.tcl: Configure project settings"

# Set the top-level
prj_set_impl_opt -impl "impl_1" {top} $board

# Turn on "IP Evaluation" so that bitstream generation works
prj_set_strategy_value -strategy Strategy1 bit_ip_eval=True

# Save the project
prj_save

# -----------------------------------------------------------------------------
# Bitstream Generation
# -----------------------------------------------------------------------------
#
# This section can be commented and the GUI used to generate the bitstream.
puts "radiant.tcl: Generate the bitstream"
prj_run Export -impl impl_1

# Confirm bitstream generation
set filename $build/impl_1/${board}_impl_1.bit
if {[file exists $filename]} {
	puts "radiant.tcl: Bitstream generation completed"
} else {
	error "radiant.tcl: Error: Bitstream generation failed!"
}

# Save the project
# * Ensures the green checkboxes in the GUI remain checked
prj_save

# -----------------------------------------------------------------------------
# Project Close
# -----------------------------------------------------------------------------
#
puts "radiant.tcl: Close the project"
prj_close
cd $top


