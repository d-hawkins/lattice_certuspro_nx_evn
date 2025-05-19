# Lattice Semiconductor CertusPro-NX Evaluation Board 'ahblite_example' design.

5/3/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

The 'ahblite_example' design demonstrates the use of the AHB-Lite BFM (bus functional model).

-------------------------------------------------------------------------------
# Questasim Simulation

1. Start Questasim

2. Change directory to the project
   ~~~
   cd c:/github/lattice_certuspro_nx_evn/designs/ahblite_example
   ~~~  

3. Run the questasim script
   ~~~
   source scripts/questasim.tcl
   ~~~  

   The script ends with a list of testbench procedures  
   ~~~
   # Testbench Procedures
   # --------------------
   #  
   # ahblite_example_tb - run the testbench
   #  
   ~~~  

4. Run the testbench procedure ahblite_example_tb  
   Example console output
   ~~~
   VSIM> ahblite_example_tb

   # ==========================================================
   # AHB-Lite BFM stimulus
   # ==========================================================
   #  
   #  
   # ----------------------------------------------------------
   # Reset
   # ----------------------------------------------------------
   #  
   # Deassert reset
   #  
   # ----------------------------------------------------------
   # write single
   # ----------------------------------------------------------
   #  
   # write 16 locations
   # (addr, data) = (00000000, 12340000)
   # (addr, data) = (00000004, 12340001)
   # (addr, data) = (00000008, 12340002)
   # (addr, data) = (0000000c, 12340003)
   # (addr, data) = (00000010, 12340004)
   # (addr, data) = (00000014, 12340005)
   # (addr, data) = (00000018, 12340006)
   # (addr, data) = (0000001c, 12340007)
   # (addr, data) = (00000020, 12340008)
   # (addr, data) = (00000024, 12340009)
   # (addr, data) = (00000028, 1234000a)
   # (addr, data) = (0000002c, 1234000b)
   # (addr, data) = (00000030, 1234000c)
   # (addr, data) = (00000034, 1234000d)
   # (addr, data) = (00000038, 1234000e)
   # (addr, data) = (0000003c, 1234000f)
   #  
   # ----------------------------------------------------------
   # Read single
   # ----------------------------------------------------------
   #  
   # Read 16 locations
   # (addr, data) = (00000000, 12340000)
   # (addr, data) = (00000004, 12340001)
   # (addr, data) = (00000008, 12340002)
   # (addr, data) = (0000000c, 12340003)
   # (addr, data) = (00000010, 12340004)
   # (addr, data) = (00000014, 12340005)
   # (addr, data) = (00000018, 12340006)
   # (addr, data) = (0000001c, 12340007)
   # (addr, data) = (00000020, 12340008)
   # (addr, data) = (00000024, 12340009)
   # (addr, data) = (00000028, 1234000a)
   # (addr, data) = (0000002c, 1234000b)
   # (addr, data) = (00000030, 1234000c)
   # (addr, data) = (00000034, 1234000d)
   # (addr, data) = (00000038, 1234000e)
   # (addr, data) = (0000003c, 1234000f)
   #  
   # ----------------------------------------------------------
   # write burst
   # ----------------------------------------------------------
   #  
   # write 16 locations using burst INCR
   #  
   # ----------------------------------------------------------
   # Read single
   # ----------------------------------------------------------
   #  
   # Read 16 locations
   # (addr, data) = (00000000, 56780000)
   # (addr, data) = (00000004, 56780001)
   # (addr, data) = (00000008, 56780002)
   # (addr, data) = (0000000c, 56780003)
   # (addr, data) = (00000010, 56780004)
   # (addr, data) = (00000014, 56780005)
   # (addr, data) = (00000018, 56780006)
   # (addr, data) = (0000001c, 56780007)
   # (addr, data) = (00000020, 56780008)
   # (addr, data) = (00000024, 56780009)
   # (addr, data) = (00000028, 5678000a)
   # (addr, data) = (0000002c, 5678000b)
   # (addr, data) = (00000030, 5678000c)
   # (addr, data) = (00000034, 5678000d)
   # (addr, data) = (00000038, 5678000e)
   # (addr, data) = (0000003c, 5678000f)
   #  
   # ----------------------------------------------------------
   # End simulation
   # ----------------------------------------------------------
   #  
   # Break in Module ahblite_example_tb at test/ahblite_example_tb.sv line 316
   ~~~
   
