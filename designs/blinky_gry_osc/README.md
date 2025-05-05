# Lattice Semiconductor CertusPro-NX Evaluation Board 'blinky_gry_osc' design.

5/3/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

The 'blinky_gry_osc' design blinks the Green, Red, and Yellow LEDs using three clock sources:  
* Green: 12MHz external clock
* Red: HFOSC internal oscillator at 50MHz (450MHz/9)
* Yellow: LFOSC internal oscillator at 32kHz

The 12MHz oscillator does not start until the USB cable is connected to the host computer. JP6 (next to the USB connector) must be installed to connect the 12MHz to the FPGA.

The top-level design parameter USEIOFF controls whether the LED outputs are registered using I/O Registers (USEIOFF=1) or fabric registers (USEIOFF=0). The SDC timing constraints are configured with clock-to-output minimum and maximum values that result in under 0.2ns of slack. The clock-to-output delays differ for the two different USEIOFF settings. The build script (scripts/radiant.tcl) generates two project variants: (1) USEIOFF = 1 and (2) USEIOFF = 0. The build script generates SDC constraints files in each of the build directories. The USEIOFF parameter can be changed in the Radiant GUI using "Project > Active Implementation > Set Top-Level Unit" and then editing the "HDL Parameters" field, eg., USEIOFF=1. The project build script defines USEIOFF for each of the project variants, but once the projects are open using the Radiant GUI, the value of USEIOFF can be changed, and the project rebuilt. During build, a pre-synthesis script reads the HDL parameters GUI value, extracts USEIOFF, and updates the SDC constraints.

-------------------------------------------------------------------------------
# Bitstream Generation

1. Start the Lattice Radiant 2024.2 Tcl Console

2. Change directory to the project and run the project setup script  
   ~~~
   cd c:/github/lattice_certuspro_nx_evn/designs/blinky_gry_osc
   source scripts/radiant.tcl
   ~~~  
   The Radiant Tcl console is used, as the Radiant GUI will not display a Tcl console until a project is open.  
   Exit from the Radiant Tcl console when the script completes.  
   The script builds two design variants.

3. Start the Lattice Radiant 2024.2 GUI  
   Use "File > Open > Project" to open the Radiant project file (.rdf) for a build variant.

4. Timing Analysis  
   Select "Tools > Timing Analyzer", or click on the "Timing Analyzer" tool on the top-edge of the GUI.  
   Click on the "Query" tab, add the LEDs to the analysis, change the temperature to 0C, and click "Search".  
   This displays the worst-case timing slack. The 85C timing has higher setup slack, but the same hold slack (as the GUI does not update the hold timing).  
   Click on the worst-case setup or hold path to see the clock and data delays.  
   The timing should match the comments in the parameters.tcl file.

5. Program the board.  
   Power-up and connect to the USB interface on the CertusPro-NX Evaluation Board.  
   In the Radiant GUI, select "Tools > Programmer", or click on the "Programmer" tool on the top-edge of the GUI.  
   In the Radiant Programmer, select "Run > Program Device", or click on the "Program Device" tool on the top-edge of the GUI.
