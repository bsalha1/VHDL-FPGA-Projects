# Makefile for ICE40 FPGA 

# Project setup
PROJ = processor
FILES = processor.vhdl control_unit.vhdl instruction_rom.vhdl
ENTITY = processor_ice40
TESTBENCH_FILE = processor_tb.vhdl
TESTBENCH_ENTITY = processor_tb
FLAGS = --std=08 -fsynopsys

# Driver setup
NODE = /dev/ttyACM0

# Device setup (shown on chip as ICE40{VERSION}{DEVICE}{PACKAGE})
VERSION = hx
DEVICE = 8k
PACKAGE = cb132

# Compile and synthesize code into ice40 binary
all:
	yosys -m ghdl -p "ghdl $(FILES) -e $(ENTITY); synth_ice40 -blif $(PROJ).blif"
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