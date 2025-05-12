# -----------------------------------------------------------------------------
# certuspro_nx_evn.sdc
#
# DATE_VAL D. W. Hawkins (dwh@caltech.edu)
#
# Lattice Radiant Timing Constraints.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Design Parameters
# -----------------------------------------------------------------------------
#
# 12MHz oscillator
set CLK_12MHZ_FREQUENCY 12.000e6

# PB and SW are asynchronous inputs
# * These constraints represent the setup/hold on the input registers
# * Setup/hold margins are both under 0.5ns
set PB_INPUT_SETUP      -1.5
set PB_INPUT_HOLD        2.0
set SW_INPUT_SETUP      -1.5
set SW_INPUT_HOLD        2.0

# LED clock-to-output
# * Min/max margins are both under 0.5ns
set LED_OUTPUT_MIN       6.5
set LED_OUTPUT_MAX      11.0

# =============================================================================
# 12MHz Clock Domain
# =============================================================================
#
# -----------------------------------------------------------------------------
# Clock Constraints
# -----------------------------------------------------------------------------
#
set clk_12mhz_period [format "%.3f" [expr {1.0e9/$CLK_12MHZ_FREQUENCY}]]
create_clock -name {clk_12mhz} -period $clk_12mhz_period [get_ports clk_12mhz]
set_clock_groups -group [get_clocks clk_12mhz] -asynchronous

# -----------------------------------------------------------------------------
# PB input constraints
# -----------------------------------------------------------------------------
#
# Input delay values
set min $PB_INPUT_HOLD
set max [expr {$clk_12mhz_period - $PB_INPUT_SETUP}]

# Input delay constraints
set_input_delay -clock [get_clocks clk_12mhz] -min $min [get_ports {pb[*]}]
set_input_delay -clock [get_clocks clk_12mhz] -max $max [get_ports {pb[*]}]

# -----------------------------------------------------------------------------
# SW input constraints
# -----------------------------------------------------------------------------
#
# Input delay values
set min $SW_INPUT_HOLD
set max [expr {$clk_12mhz_period - $SW_INPUT_SETUP}]

# Input delay constraints
set_input_delay -clock [get_clocks clk_12mhz] -min $min [get_ports {sw[*]}]
set_input_delay -clock [get_clocks clk_12mhz] -max $max [get_ports {sw[*]}]

# -----------------------------------------------------------------------------
# LED output Constraints
# -----------------------------------------------------------------------------
#
# Constraints
set min -$LED_OUTPUT_MIN
set max [expr {$clk_12mhz_period - $LED_OUTPUT_MAX}]

# Green LEDs
set_output_delay -clock [get_clocks clk_12mhz] -min $min [get_ports {led_g[*]}]
set_output_delay -clock [get_clocks clk_12mhz] -max $max [get_ports {led_g[*]}]

# Red LEDs
set_output_delay -clock [get_clocks clk_12mhz] -min $min [get_ports {led_r[*]}]
set_output_delay -clock [get_clocks clk_12mhz] -max $max [get_ports {led_r[*]}]

# Yellow LEDs
set_output_delay -clock [get_clocks clk_12mhz] -min $min [get_ports {led_y[*]}]
set_output_delay -clock [get_clocks clk_12mhz] -max $max [get_ports {led_y[*]}]
