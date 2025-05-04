# Lattice Semiconductor CertusPro-NX Evaluation Board 'basic' design.

5/3/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

The 'basic' design blinks the Green LEDs using the FTDI USB interface 12MHz on-board oscillator.

The 12MHz oscillator does not start until the USB cable is connected to the host computer. JP6 (next to the USB connector) must be installed to connect the 12MHz to the FPGA.

-------------------------------------------------------------------------------
# Bitstream Generation

1. Start the Lattice Radiant 2024.2 Tcl Console

2. Change directory to the project and run the project setup and build script  
   ~~~
   cd c:/github/lattice_certuspro_nx_evn/designs/basic
   source scripts/radiant.tcl
   ~~~  
   The Radiant Tcl console is used, as the Radiant GUI will not display a Tcl console until a project is open.  
   Exit from the Radiant Tcl console when the script completes.

3. Start the Lattice Radiant 2024.2 GUI  
   Use "File > Open > Project" to open the Radiant project file (.rdf).

4. Timing Analysis  
   Select "Tools > Timing Analyzer", or click on the "Timing Analyzer" tool on the top-edge of the GUI.  
   Click on the "Query" tab, add the LEDs to the analysis, change the temperature to 0C, and click "Search".  
   This displays the worst-case timing slack. The 85C timing has higher setup slack, but the same hold slack (as the GUI does not update the hold timing).  
   Click on the worst-case setup or hold path to see the clock and data delays.  
   The timing should match the comments in the SDC file.

5. Program the board.  
   Power-up and connect to the USB interface on the CertusPro-NX Evaluation Board.  
   In the Radiant GUI, select "Tools > Programmer", or click on the "Programmer" tool on the top-edge of the GUI.  
   In the Radiant Programmer, select "Run > Program Device", or click on the "Program Device" tool on the top-edge of the GUI.
