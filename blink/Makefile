# Makefile for ICE40 FPGA 

# Project setup
PROJ = blink
FILES = blink_ice40.vhdl clock_divider.vhdl
ENTITY = blink_ice40
TESTBENCH_FILE = blink_ice40_tb.vhdl
TESTBENCH_ENTITY = blink_ice40_tb
FLAGS = -fsynopsys --std=08

# Driver setup
NODE = /dev/ttyACM0

# Device setup (shown on chip as ICE40{VERSION}{DEVICE}{PACKAGE})
VERSION = hx
DEVICE = 8k
PACKAGE = cb132

# Compile and synthesize code into ice40 binary
all:
	yosys -m ghdl -p "ghdl $(FLAGS) $(FILES) -e $(ENTITY); synth_ice40 -blif $(PROJ).blif"
	arachne-pnr -d $(DEVICE) -P $(PACKAGE) -p ice40$(VERSION)$(DEVICE)$(PACKAGE).pcf -o $(PROJ).txt $(PROJ).blif
	icepack $(PROJ).txt $(PROJ).bin

# Simulate the code using given testbench and view waveform
sim:
	ghdl -a $(FLAGS) $(TESTBENCH_FILE) $(FILES)
	ghdl -e $(FLAGS) $(TESTBENCH_ENTITY)
	ghdl -r $(FLAGS) $(TESTBENCH_ENTITY) --wave=wave.ghw --stop-time=1us
	gtkwave wave.ghw
	
# Push ice40 binary to FPGA connected via USB to NODE
flash:
	sudo python3 ../icefunprog.py $(NODE) $(PROJ).bin

clean:
	rm *.bin *blif *.txt