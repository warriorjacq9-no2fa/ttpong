TAG := $(shell curl -s https://api.github.com/repos/warriorjacq9-no2fa/ttpong/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

PDK_ROOT = $(PWD)/test/gl/build/pdk

VERILOG_SRCS = $(PWD)/test/gl/build/release/tt_um_pong.v
VERILOG_SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

all: gl

gl: release build/pdk/.installed
	$(MAKE) -C vga-gl TOP_MODULE="tt_um_pong" VERILOG_SRCS="$(VERILOG_SRCS)"

nodisp: release build/pdk/.installed
	iverilog tb.v $(VERILOG_SRCS) -DFUNCTIONAL -DUSE_POWER_PINS -DSIM -DUNIT_DELAY=\#1 -o tb.vvp
	vvp tb.vvp
	gtkwave tb.vcd tb.gtkw


release:
	mkdir -p build/release
	curl -sfSL -o build/release.zip https://github.com/warriorjacq9-no2fa/ttpong/releases/download/$(TAG)/release.zip
	bsdtar -xf build/release.zip --strip-components=1 -C build/release

build/pdk/.installed:
	mkdir -p build/pdk
	curl -sfSL -o build/sky130.tar.zst https://github.com/fossi-foundation/ciel-releases/releases/download/sky130-0fe599b2afb6708d281543108caf8310912f54af/sky130_fd_sc_hd.tar.zst
	tar -xf build/sky130.tar.zst -C build/pdk
	touch build/pdk/.installed

clean:
	make -C vga-gl clean
	rm -rf *.vcd *.vvp build/