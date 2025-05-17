# -----------------------------------------------------------------------------
# constraints_pdc_utls.tcl
#
# 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Lattice CertusPro-NX Evaluation Board Physical Design Constraints
# Tcl Procedures.
#
# -----------------------------------------------------------------------------
# References
# ----------
#
# [1] Lattice, "CertusPro-NX Evaluation Board", 2025
#     https://www.latticesemi.com/products/developmentboardsandkits/certuspro-nxevaluationboard
#     Ordering Part Number: LFCPNX-EVN
#
# [2] Lattice Semiconductor, "CertusPro-NX Evaluation Board Schematic",
#     Revision 1.0, Aug 2021 (SCHEM_LFCPNX-EVN_REVB_08042021.pdf).
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Bank Voltage Constraints
# -----------------------------------------------------------------------------
#
# Per the schematic [2]:
#
#  Bank  VCCIO   Common  Voltage
#  ----  ------  ------  -------
#   0    VCCIO0          1.8V (default) or 3.3V
#   1    VCCIO1          3.3V
#   2    VCCIO2          1.8V, 2.5V, or 3.3V (default)
#   3    VCCIO3  3+4+5   1.2V, 1.8V (default), or VCC_ADJ
#   4    VCCIO4  3+4+5
#   5    VCCIO5  3+4+5
#   6    VCCIO6          1.8V, 2.5V, or 3.3V (default)
#   7    VCCIO7          1.8V, 2.5V, or 3.3V (default)
#
# Banks 3+4+5 are the high-performance banks. They connect to the FMC.
#
proc set_bank_voltage_constraints {} {

	ldc_set_vcc -bank 0 1.8
	ldc_set_vcc -bank 1 3.3
	ldc_set_vcc -bank 2 3.3
	ldc_set_vcc -bank 3 1.8
	ldc_set_vcc -bank 4 1.8
	ldc_set_vcc -bank 5 1.8
	ldc_set_vcc -bank 6 3.3
	ldc_set_vcc -bank 7 3.3

	# sysCONFIG bank voltage settings
	ldc_set_sysconfig {CONFIGIO_VOLTAGE_BANK0=1.8 CONFIGIO_VOLTAGE_BANK1=3.3}

	return
}

# -----------------------------------------------------------------------------
# Pin Constraints
# -----------------------------------------------------------------------------
#
proc get_pin_constraints {} {

	# -------------------------------------------------------------------------
	# Clocks
	# -------------------------------------------------------------------------
	#
	# Bank 1 (3.3V)
	dict set pin clk_12mhz  {PIN R4   IO_TYPE LVCMOS33}

	# Bank 7 (3.3V)
	dict set pin clk_125mhz {PIN N25  IO_TYPE LVCMOS33}

	# -------------------------------------------------------------------------
	# Green LEDs
	# -------------------------------------------------------------------------
	#
	# The bit order is reversed relative to the schematic, so the LSB on the
	# PCB is on the right-side of the 8 LEDs.
	#
	dict set pin led_g(7)  {PIN N5  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_g(6)  {PIN N6  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_g(5)  {PIN N7  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_g(4)  {PIN N8  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_g(3)  {PIN L6  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_g(2)  {PIN N9  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_g(1)  {PIN L8  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_g(0)  {PIN M9  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}

	# -------------------------------------------------------------------------
	# Red LEDs
	# -------------------------------------------------------------------------
	#
	# The bit order is reversed relative to the schematic, so the LSB on the
	# PCB is on the right-side of the 8 LEDs.
	#
	dict set pin led_r(7)  {PIN T4  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_r(6)  {PIN T5  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_r(5)  {PIN T6  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_r(4)  {PIN T7  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_r(3)  {PIN U8  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_r(2)  {PIN T8  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_r(1)  {PIN R9  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_r(0)  {PIN P9  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}

	# -------------------------------------------------------------------------
	# Yellow LEDs
	# -------------------------------------------------------------------------
	#
	# The bit order is reversed relative to the schematic, so the LSB on the
	# PCB is on the right-side of the 8 LEDs.
	#
	dict set pin led_y(7)  {PIN N1  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_y(6)  {PIN N2  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_y(5)  {PIN N3  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_y(4)  {PIN M1  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_y(3)  {PIN M2  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_y(2)  {PIN M3  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_y(1)  {PIN L3  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}
	dict set pin led_y(0)  {PIN N4  IO_TYPE LVCMOS33  SLEWRATE MED  DRIVE 8}

	# -------------------------------------------------------------------------
	# Push Buttons
	# -------------------------------------------------------------------------
	#
	# * Bank 0 at 1.8V (p4 [2])
	# * Radiant "Physical Designer" shows GLITCHFILTER = ON, HYSTERESIS = ON
	#
	dict set pin pb(0)  {PIN J5  IO_TYPE LVCMOS18}
	dict set pin pb(1)  {PIN J2  IO_TYPE LVCMOS18}
	dict set pin pb(2)  {PIN J3  IO_TYPE LVCMOS18}

	# -------------------------------------------------------------------------
	# DIP Switches
	# -------------------------------------------------------------------------
	#
	# * Bank 0 at 1.8V (p4 [2])
	# * Radiant "Physical Designer" shows GLITCHFILTER = ON, HYSTERESIS = ON
	# * The LSB on the PCB is on the right-hand side (closest to the SMAs)
	#
	dict set pin sw(0)  {PIN K8  IO_TYPE LVCMOS18}
	dict set pin sw(1)  {PIN K7  IO_TYPE LVCMOS18}
	dict set pin sw(2)  {PIN K6  IO_TYPE LVCMOS18}
	dict set pin sw(3)  {PIN K4  IO_TYPE LVCMOS18}
	dict set pin sw(4)  {PIN K3  IO_TYPE LVCMOS18}
	dict set pin sw(5)  {PIN K2  IO_TYPE LVCMOS18}
	dict set pin sw(6)  {PIN J7  IO_TYPE LVCMOS18}
	dict set pin sw(7)  {PIN J6  IO_TYPE LVCMOS18}

	return $pin
}

# -----------------------------------------------------------------------------
# Apply Pin Constraints
# -----------------------------------------------------------------------------
#
#
# This procedure takes two arguments:
#
# * 'ports' is a list of top-level pin names  eg.
#
#   tcl> set ports [lsort [get_ports *]]
#
# * 'pin_constraints' is the constraints dictionary
#
#   tcl> set pin_constraints [get_pin_constraints]
#
#   The dictionary content can be manipulated to rename pins or to modify
#   constraint values (or to add new constraints).
#
proc apply_pin_constraints {ports pin_constraints} {

	# JTAG pins
	set jtag_ports [list TCK TMS TDI TDO]

	# Loop over the top-level ports list
	foreach port $ports {

		# Skip JTAG pins (they are auto-assigned)
		if {[lsearch $jtag_ports $port] != -1} {
			continue
		}

		# Convert port name (with square brackets) to pin name
		# * Replace square brackets with paranthesis
		set pin [string map {\[ ( \] )} $port]

		# Check that the pin name exists in the dictionary
		# * Top-level port names must match the dictionary names
		if {![dict exists $pin_constraints $pin]} {
			error "Error: Invalid top-level port name $port!"
		}

		# Apply the pin constraints
		set constraints [dict get $pin_constraints $pin]

		# Pin constraint
		set val [dict get $constraints PIN]
		catch {puts "certuspro_nx_evn_utils.tcl: ldc_set_location -site \{$val\} \{$port\}"}
		ldc_set_location -site $val [get_ports $port]

		# Port constraints
		# * Remove {PIN <value>} from the dictionary
		set iobuf {}
		dict for {key val} $constraints {
			if {[string equal $key PIN]} {
				continue
			}
			lappend iobuf "$key=$val"
		}
		if {[string length $iobuf]} {
			catch {puts "certuspro_nx_evn_utils.tcl: ldc_set_port -iobuf \{$iobuf\} \{$port\}"}
			ldc_set_port -iobuf $iobuf [get_ports $port]
		}
	}
	return
}

