# Lattice CertusPro-NX Evaluation Board

5/4/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

This repository contains projects targeting the Lattice CertusPro-NX Evaluation Board (LFCPNX-EVN).

https://www.latticesemi.com/products/developmentboardsandkits/certuspro-nxevaluationboard

Directory           | Contents
--------------------|-----------
doc                 | Documentation
designs             | Radiant designs
tcl                 | Tcl scripts
references          | Reference documentation

## Evaluation Board Jumper Configuration

Review the Lattice CertusPro-NX Evaluation Board User Guide for the default jumper configurations. Jumper JP6 (near the USB connector) needed to be installed to connect the FTDI 12MHz to an FPGA clock pin.

## Git LFS Installation

This repository was created using the github web interface, then checked out using Windows 10 WSL, and git LFS was installed using

~~~
$ git clone git@github.com:d-hawkins/lattice_certuspro_nx_evn.git
$ cd lattice_certuspro_nx_evn/
$ git lfs install
~~~

The .gitattributes file from another repo was then copied to this repo, and that file checked in.

~~~
$ git add .gitattributes
$ git commit -m "Git LFS tracking" .gitattributes
$ git push
~~~

The .gitattributes file contains file extension patterns for the majority of binary file types that could be checked into the repo (additional patterns can be added as needed).

