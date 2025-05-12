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

# Part number
set part LFCPNX-100-9LFG672C

# -----------------------------------------------------------------------------
# Design Directories
# -----------------------------------------------------------------------------
#
set top     [file normalize [pwd]]
set repo    [file dirname [file dirname $top]]
set src     $top/src
set scripts $top/scripts

# Design name
set design  [file tail $top]

# Radiant utilities
source $repo/tcl/radiant_utils.tcl

# -----------------------------------------------------------------------------
# Tool check
# -----------------------------------------------------------------------------
#
radiant_tool_check

# =============================================================================
# Design Parameters
# =============================================================================
#
# Source code
set sources [list \
	$src/certuspro_nx_evn.sv \
	$repo/ip/cdc_async_bit/src/cdc_async_bit_no_rst.sv \
]

# Constraints
set constraints [list \
	$scripts/certuspro_nx_evn.pdc \
	$scripts/certuspro_nx_evn.sdc \
]

# Design parameters
set params [list \
	REPO                 $repo                \
	DESIGN               $design              \
	BOARD                $board               \
	PART                 $part                \
	SOURCES              $sources             \
	CONSTRAINTS          $constraints         \
]

# =============================================================================
# Synthesis loop
# =============================================================================
#
puts "[string repeat = 80]"
puts "Starting synthesis"
puts "[string repeat - 80]"

# Time each loop
set t_start [clock clicks -milliseconds]

# Check for out-of-tree build directory
catch {unset radiant_build}
if {[info exists RADIANT_BUILD]} {
	# User Tcl environment over-ride
	set radiant_build [file normalize ${RADIANT_BUILD}]
} elseif {[info exists ::env(RADIANT_BUILD)]} {
	# User environment over-ride
	set radiant_build [file normalize $::env(RADIANT_BUILD)]
}

# Build directory
if {[info exists radiant_build]} {
	set build $radiant_build/$board/$design/radiant
} else {
	set build $repo/designs/$design/build/radiant
}
puts "radiant.tcl: build = $build"

# Build directory
dict set params BUILD $build

# Create the project
radiant_create_project $params

# -----------------------------------------------------------------------------
# Reveal Logic Analyzer
# -----------------------------------------------------------------------------
#
# Create the Reveal logic analyzer
set filename $build/${board}.rvl
source $scripts/certuspro_nx_evn_rvl.tcl
create_reveal_rvl $board $filename
prj_add_source $filename
prj_save

# -----------------------------------------------------------------------------
# Bitstream Generation
# -----------------------------------------------------------------------------
#
puts "radiant.tcl: Generate the bitstream"
prj_run Export -impl impl_1

# Confirm bitstream generation
set filename $build/impl_1/${board}_impl_1.bit
if {[file exists $filename]} {
	puts "radiant.tcl: Bitstream generation completed"
} else {
	puts "Error: Bitstream generation failed!"
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

# Elapsed time
set t_end [clock clicks -milliseconds]
set t_elapsed [expr {($t_end - $t_start)/60000.0}]
set elapsed_time [format "%.3f minutes" $t_elapsed]
puts "Elapsed time: $elapsed_time"

puts "---------------------------------"
puts "All done!"
puts "---------------------------------"
