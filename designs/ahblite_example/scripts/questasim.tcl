# -----------------------------------------------------------------------------
# questasim.tcl
#
# 4/27/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Questasim simulation script.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Tool Check
# -----------------------------------------------------------------------------
#
proc tool_check {} {
	# Check the tool is QuestaSim (vish)
	set toolname [file rootname [file tail [info nameofexecutable]]]
	if {![string equal $toolname "vish"]} {
		error "Error: unexpected tool name '$toolname'!"
	}
	return
}

# -----------------------------------------------------------------------------
# Questasim Libraries
# -----------------------------------------------------------------------------
#
proc setup_libraries {work} {

	# Skip if the directory already exists (user must delete)
	if {[file exist $work]} {
		return
	}

	# Setup the work directory
	echo "Setting up work directory"
	file mkdir $work
	vlib $work
	vmap work $work

	return
}

# -----------------------------------------------------------------------------
# Tool Check
# -----------------------------------------------------------------------------
#
tool_check

# -----------------------------------------------------------------------------
# Questasim Libraries
# -----------------------------------------------------------------------------
#
# Questasim work
set work build/questasim/work
setup_libraries $work

# -----------------------------------------------------------------------------
# Testbench
# -----------------------------------------------------------------------------
#
# AHB-Lite BFM
# * There is also a clock_reset generator and a UART BFM
vlog C:/lscc/propel/2024.2/builder/rtf/ip/vip/latticesemi.com_ip_ahbl_master_bfm_lite_1.0.0/rtl/AHBL_Master_Lite_IF.sv

# Testbench
vlog test/ahblite_example_tb.sv

# -----------------------------------------------------------------------------
# Simulation procedures
# -----------------------------------------------------------------------------
#
proc ahblite_example_tb {} {

	vsim -t ps -voptargs=+acc +nowarnTSCALE ahblite_example_tb
	do scripts/ahblite_example_tb.do
	run -a
}

echo " "
echo "Testbench Procedures"
echo "--------------------"
echo " "
echo "ahblite_example_tb - run the testbench"
echo " "
