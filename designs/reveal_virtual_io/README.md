# Lattice Semiconductor CertusPro-NX Evaluation Board 'reveal_virtual_io' design.

5/11/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

The 'reveal_virtual_io' design demonstrates Lattice Radiant Reveal Status and Control Registers.

The example design blinks the Green, Red, and Yellow LEDs using the FTDI USB interface 12MHz on-board oscillator. The design routes the push buttons and DIP switches through dual-flip-flop synchronizers into the 12MHz domain. The Green, Red, and Yellow LEDs default to displaying a counting pattern. Pressing the PBs inverts the first 3 Green LEDs. Toggling the DIP switches inverts the Red LEDs.

The Reveal Virtual I/O controller is configured for:
 * 3-bit Status register for reading PBs
 * 8-bit Status register for reading SWs
 * 1-bit Control register for multiplexing the LEDs to be controlled by Reveal
 * 8-bit Control register for the Red LEDs
 * 8-bit Control register for the Green LEDs
 * 8-bit Control register for the Yellow LEDs

The 12MHz oscillator does not start until the USB cable is connected to the host computer. JP6 (next to the USB connector) must be installed to connect the 12MHz to the FPGA.

-------------------------------------------------------------------------------
# Bitstream Generation

1. Start the Lattice Radiant 2024.2 Tcl Console

2. Change directory to the project and run the project setup and build script  
   ~~~
   cd c:/github/lattice_certuspro_nx_evn/designs/reveal_virtual_io
   source scripts/radiant.tcl
   ~~~  
   The Radiant Tcl console is used, as the Radiant GUI will not display a Tcl console until a project is open.  
   Exit from the Radiant Tcl console when the script completes.  

3. Start the Lattice Radiant 2024.2 GUI  
   * Use "File > Open > Project" to open the Radiant project file (.rdf).

4. Timing Analysis  
   * Select "Tools > Timing Analyzer", or click on the "Timing Analyzer" tool on the top-edge of the GUI.  
   * Click on the "Query" tab, add the LEDs to the analysis, change the temperature to 0C, and click "Search".  
     This displays the worst-case timing slack. The 85C timing has higher setup slack, but the same hold slack (as the GUI does not update the hold timing).  
   * Click on the worst-case setup or hold path to see the clock and data delays.  
     The timing should match the comments in the parameters.tcl file.

5. Program the board  
   * Power-up and connect to the USB interface on the CertusPro-NX Evaluation Board.
   * In the Radiant GUI, select "Tools > Programmer", or click on the "Programmer" tool on the top-edge of the GUI.
   * In the Radiant Programmer, select "Run > Program Device", or click on the "Program Device" tool on the top-edge of the GUI.

6. Create a Radiant Reveal Analyzer/Controller Script (.rva)  
   * Select "Tools > Reveal Analyzer/Controller", or click on the "Reveal Analyzer/Controller" tool on the top-edge of the GUI.
   * Click the button for "Create a new file" and enter the name "certuspro_nx_evn".
   * For "USB port" click "Detect".
   * For "Debug device" click "Scan".
   * RVL source is automatically populated with the certuspro_nx_evn.rvl file (that was created in the build directory).
   * The "Import file into current implementation" checkbox is checked by default.
   * Click on "OK" and the .rva file is added to the project.

7. Run Radiant Reveal Virtual I/O Controller 
   * Click on the "User Status Register" tab to view the status registers.
   * Read the state of the PBs and SWs.
   * Click on the "User Control Register" tab to view the control registers.
   * Write 1 to rvl_led_sel to use Reveal to control the registers.
   * Write 0x11 to the Green LEDs, 0x33 to the Red LEDs, and 0x77 to the Yellow LEDs.
   * Look at the LEDs on the board to confirm the patterns.
   * Write 0 to rvl_led_sel and the LEDs will display the counting pattern.
   
8. Use the Radiant Tcl console  to control the Reveal Virtual I/O Controller  
   Click on the Tcl console tab in the Radiant GUI and then try some of the following:
   ~~~
   # Use Reveal to control the LEDs
   rva_run_controller -write_control "CON0" -data "1"
   
   # Green LEDs count
   for {set i 0} {$i < 255} {incr i} {set data [format "%.2X" $i]; rva_run_controller -write_control "CON1" -data $data;after 100;}
   
   # Red LEDs count
   for {set i 0} {$i < 255} {incr i} {set data [format "%.2X" $i]; rva_run_controller -write_control "CON2" -data $data;after 100;}
   
   # Yellow LEDs count
   for {set i 0} {$i < 255} {incr i} {set data [format "%.2X" $i]; rva_run_controller -write_control "CON3" -data $data;after 100;}
   ~~~  
  
