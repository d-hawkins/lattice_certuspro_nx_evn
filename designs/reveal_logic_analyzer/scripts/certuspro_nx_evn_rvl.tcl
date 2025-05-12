# -----------------------------------------------------------------------------
# certuspro_nx_evn_rvl.tcl
#
# 5/11/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Lattice Radiant Reveal Logic Analyzer core creation script.
#
# -----------------------------------------------------------------------------
# Notes
# -----
#
# 1. "No valid core is selected or specified."
#
#    The Radiant Tcl console would generate this message if any command
#    was used without the -core $corename option.
#
# 2. "WARNING <2120260> - '' is not in this trigger unit."
#
#    The command to add pb_sync:0 generates this message, but the source
#    of the warning is not obvious! This warning is likely internal to
#    Radiant Reveal, rather than something wrong with this Tcl script.
#
# -----------------------------------------------------------------------------

proc create_reveal_rvl {board filename} {

	# New Reveal Logic Analyzer
	rvl_new_project -stage presyn
	set corename ${board}_LA0
	rvl_add_core $corename

	# Add the LED counter and the synchronized PBs and SWs
	rvl_add_trace -core $corename {{count[29:0]}}
	rvl_add_trace -core $corename {{pb_sync[2:0]}}
	rvl_add_trace -core $corename {{sw_sync[7:0]}}

	# Use 12MHz for the clock
	rvl_set_traceoptn -core $corename SampleClk=clk_12mhz

	# Buffer depth
	rvl_set_traceoptn -core $corename BufferDepth=1024

	# Trigger Unit
	# * Trigger on falling-edge of push button 0, i.e., (pb_sync[0] == 1'b0)
	rvl_add_tu -core $corename -radix Bin
	rvl_set_tu -core $corename -name TU1 -set_sig {pb_sync:0}
	rvl_set_tu -core $corename -name TU1 -val 0

	# Trigger Expression
	rvl_add_te -core $corename
	rvl_set_te -core $corename -expression TU1 TE1

	# Save
	rvl_save_project -overwrite $filename
	return
}
