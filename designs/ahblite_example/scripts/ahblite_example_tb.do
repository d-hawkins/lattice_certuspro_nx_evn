onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ahblite_example_tb/rst_n
add wave -noupdate /ahblite_example_tb/clk
add wave -noupdate /ahblite_example_tb/hready
add wave -noupdate /ahblite_example_tb/hresp
add wave -noupdate /ahblite_example_tb/hrdata
add wave -noupdate /ahblite_example_tb/htrans
add wave -noupdate /ahblite_example_tb/hwrite
add wave -noupdate /ahblite_example_tb/hsize
add wave -noupdate /ahblite_example_tb/hburst
add wave -noupdate /ahblite_example_tb/haddr
add wave -noupdate /ahblite_example_tb/hwdata
add wave -noupdate /ahblite_example_tb/hprot
add wave -noupdate /ahblite_example_tb/hmastlock
add wave -noupdate -expand /ahblite_example_tb/hregs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 127
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1380750 ps}
