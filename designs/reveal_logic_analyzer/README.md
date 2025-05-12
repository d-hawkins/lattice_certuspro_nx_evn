# Lattice Semiconductor CertusPro-NX Evaluation Board 'reveal_logic_analyzer' design.

5/11/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

The 'reveal_logic_analyzer' design demonstrates the Lattice Radiant Reveal Logic Analyzer.

The example design blinks the Green, Red, and Yellow LEDs using the FTDI USB interface 12MHz on-board oscillator. The design routes the push buttons and DIP switches through dual-flip-flop synchronizers into the 12MHz domain. The Reveal Logic Analyzer is configured to trigger on the falling-edge of the synchronized version of the push-button with the silkscreen SW1 (push button index 0 in the SystemVerilog code).

The 12MHz oscillator does not start until the USB cable is connected to the host computer. JP6 (next to the USB connector) must be installed to connect the 12MHz to the FPGA.

-------------------------------------------------------------------------------
# Bitstream Generation

1. Start the Lattice Radiant 2024.2 Tcl Console

2. Change directory to the project and run the project setup and build script  
   ~~~
   cd c:/github/lattice_certuspro_nx_evn/designs/reveal_logic_analyzer
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

7. Run Radiant Reveal Logic Analysis 
   * The Reveal Analyzer/Controller GUI starts with a status of "Ready".
   * Click on the green run button in the GUI (to the right of "Ready") and when the logic analyzer indicates "Running" push the push button SW1 (the bottom left of the four push buttons).
   * Change the DIP switch settings, arm the logic analyzer, hold down a second push button, and then press SW1 again to trigger.  
     The logic analyzer waveforms will update to show the captured DIP switch and push button settings.
   * Change the trigger unit to trigger when the push button is high.
   * Hold the push button down, arm the logic analyzer, and release the push button.  
     The logic analyzer waveforms will update to show the captured DIP switch and push button settings.
   * Logic Analyzer Bug: If the logic analyzer does not appear to work, press the manual trigger (next to the green trigger) and inspect the trigger waveforms. If they all appear correct, but the trigger is still not working, change the trigger unit setting from 0 to 1 and try triggering, and then go back to 0 and try triggering. There must be an initialization bug within the logic analyzer software.
   
   
