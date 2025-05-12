# -----------------------------------------------------------------------------
# certuspro_nx_evn_rvl.tcl
#
# 5/11/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Lattice Radiant Reveal Logic Analyzer core creation script.
#
# This script creates Reveal Status and Control registers.
#
# -----------------------------------------------------------------------------

proc create_reveal_rvl {board filename} {

	# New Reveal Logic Analyzer
	rvl_new_project -stage presyn
	rvl_add_controller

	# Status registers: PBs and SWs
	rvl_set_controller -item StatReg -set_opt {insert=on}
	rvl_set_controller -item StatReg -add STAT1
	rvl_set_controller -item StatReg -name STAT0 -add_sig {{rvl_pb[2:0]}}
	rvl_set_controller -item StatReg -name STAT1 -add_sig {{rvl_sw[7:0]}}

	# Control registers: LED multiplexer control and G+R+Y outputs
	rvl_set_controller -item ConReg -set_opt {insert=on}
	rvl_set_controller -item ConReg -add CON1
	rvl_set_controller -item ConReg -add CON2
	rvl_set_controller -item ConReg -add CON3
	rvl_set_controller -item ConReg -name CON0 -add_sig {rvl_led_sel}
	rvl_set_controller -item ConReg -name CON1 -add_sig {{rvl_led_g[7:0]}}
	rvl_set_controller -item ConReg -name CON2 -add_sig {{rvl_led_r[7:0]}}
	rvl_set_controller -item ConReg -name CON3 -add_sig {{rvl_led_y[7:0]}}

	# Save
	rvl_save_project -overwrite $filename
	return
}
