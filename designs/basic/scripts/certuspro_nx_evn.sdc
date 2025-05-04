# -----------------------------------------------------------------------------
# certuspro_nx_evn.sdc
#
# 4/25/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Lattice CertusPro-NX Evaluation Board Timing Constraints.
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

# -----------------------------------------------------------------------------
# Design Parameters
# -----------------------------------------------------------------------------
#
# LED clock-to-output timing constriants
# --------------------------------------
#
# The timing parameters were adjusted until the slack was under 0.2ns.
#
#  Delays at 0C
#  -----------------------------
# | Delay Type |   Green LEDs   |
# |            |  Min     Max   |
# |------------|----------------|
# | Actual     | 6.917   9.635  |
# | Constraint | 6.800   9.800  |
# | Slack      | 0.117   0.165  |
# | LED        | g[1]    g[6]   |
#  -----------------------------
#
set CLK_12MHZ_FREQUENCY 12.000e6
set LED_OUTPUT_MIN      6.8
set LED_OUTPUT_MAX      9.8

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
# Output Constraints
# -----------------------------------------------------------------------------
#
# Constraints
set min -$LED_OUTPUT_MIN
set max [expr {$clk_12mhz_period - $LED_OUTPUT_MAX}]

# LEDs
set_output_delay -clock [get_clocks clk_12mhz] -min $min [get_ports {led[*]}]
set_output_delay -clock [get_clocks clk_12mhz] -max $max [get_ports {led[*]}]

