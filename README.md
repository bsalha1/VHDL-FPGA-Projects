## About ##
These are various VHDL projects I've written to learn VHDL. They are built for the ICE40 products using icestorm, yosys, arachne-pnr and ghdl.

## How to Use ##
Must have an ICE40 FPGA and adjust the Makefile according to its specs. Also, adjust the .pcf file according to the desired pins for the clock(s), 
LEDs, IO, etc. Run `make` to build the binary .bin to load onto the FPGA.

To flash the FPGA with the hardware instructions (processor.bin), run `make flash` which simply executes the `icefunprog.py` script. Must have sudo permission to flash the device because it talks to a device node.

## Requirements ##
This type of building took me quite a long time to figure out since ICE does not have any tools for VHDL development. If you have any suggestions for simplifications, let me know!

**GHDL**: simulation and VHDL synthesis plugin for Yosys (below)

**Yosys**: synthesizing the logic

**Arachne-PNR**: placement and routing

**Icestorm**: formatting the program to load onto the ICE40 FPGA

```
sudo apt install build-essential clang bison flex libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz xdot pkg-config python python3 libftdi-dev qt5-default python3-dev libboost-dev
```

For debugging the simulation:

```
sudo apt install gtkwave
```

```
git clone https://github.com/cliffordwolf/yosys.git yosys
git clone https://github.com/cseed/arachne-pnr.git arachne-pnr
git clone https://github.com/cliffordwolf/icestorm.git icestorm
git clone https://github.com/ghdl/ghdl ghdl
git clone https://github.com/ghdl/ghdl-yosys-plugin ghdl-yosys-plugin
```

```
cd yosys
make -j$(nproc)
sudo make install
```

```
cd arachne-pnr
make -j$(nproc)
sudo make install
```

```
cd icestorm
make -j$(nproc)
sudo make install
```

```
cd ghdl
mkdir build
cd build
../configure --prefix=/usr/local
make
sudo make install
```

```
cd ghdl-yosys-plugin
make
sudo make install
```
