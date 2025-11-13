TAG := $(shell curl -s https://api.github.com/repos/warriorjacq9-no2fa/ttpong/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
TAG_PDK := $(shell curl -s https://api.github.com/repos/warriorjacq9-no2fa/sky130-gltest/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

PDK_ROOT = $(PWD)/test/gl/build/pdk

VERILOG_SRCS = $(PWD)/test/gl/build/release/tt_um_pong.v
VERILOG_SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

all: gl

gl: release build/pdk/.installed
	iverilog -DFUNCTIONAL -DGL_TEST -DUSE_POWER_PINS -DSIM -DUNIT_DELAY=\#1 \
	$(VERILOG_SRCS) tb.v -o tb.vvp
	vvp tb.vvp
	gtkwave tb.vcd tb.gtkw

release:
	mkdir -p build/release
	curl -sfSL -o build/release.zip https://github.com/warriorjacq9-no2fa/ttpong/releases/download/$(TAG)/release.zip
	bsdtar -xf build/release.zip --strip-components=1 -C build/release

build/pdk/.installed:
	mkdir -p build/pdk
	curl -sfSL -o build/sky130A.tar.gz https://github.com/warriorjacq9-no2fa/sky130-gltest/releases/download/$(TAG_PDK)/sky130A.tar.gz
	tar -xf build/sky130A.tar.gz -C build/pdk
	touch build/pdk/.installed