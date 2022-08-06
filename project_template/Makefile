# Project setup
PROJ      = phycat


BUILD     = ./build
TB_OUT_DIR = $(BUILD)/vcd
DEVICE    = 1k
#DEVICE    = 8k
FOOTPRINT = tq144


# Source Directories 
MODULES_SRC_DIR = ./modules
TB_SRC_DIR = ./tb

#Source Files 
TOP_FILE = top.v 
MODULE_FILES  =  $(wildcard $(MODULES_SRC_DIR)/*.v)

#Test bench Src and output files
TB_SRC_FILES = $(notdir $(wildcard $(TB_SRC_DIR)/*_tb.v))
TB_OUT_FILES = $(addprefix $(TB_OUT_DIR)/, $(TB_SRC_FILES:.v=.out))
TB_VCD_FILES = $(addprefix $(TB_OUT_DIR)/, $(TB_SRC_FILES:.v=.vcd))


.PHONY: all clean burn

all:$(BUILD)/$(PROJ).bin


$(BUILD)/$(PROJ).bin: $(FILES) Makefile
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	yosys -p "synth_ice40 -top top -blif $(BUILD)/$(PROJ).blif" $(TOP_FILE) $(MODULE_FILES)
	# Place and route using arachne
	arachne-pnr -d $(DEVICE) -P $(FOOTPRINT) -o $(BUILD)/$(PROJ).asc -p constraints/pinmap_$(FOOTPRINT).pcf $(BUILD)/$(PROJ).blif
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

burn:   $(BUILD)/$(PROJ).bin
	iceprog $<


testbench: $(TB_VCD_FILES)

#Create .out file for each testbench file 
$(TB_OUT_DIR)/%.out : $(TB_SRC_DIR)/%.v
	mkdir -p $(TB_OUT_DIR)
	iverilog -o $@ $? $(MODULE_FILES)

#run .out files to create .vcd files
$(TB_OUT_DIR)/%.vcd : $(TB_OUT_DIR)/%.out
	cd $(TB_OUT_DIR) ; ../../$? >> /dev/null;
	mv $(TB_OUT_DIR)/dump.vcd $@
	rm $?


clean:
	rm -rf build/*