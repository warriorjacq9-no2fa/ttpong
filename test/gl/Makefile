TAG := $(shell curl -s https://api.github.com/repos/warriorjacq9-no2fa/ttpong/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

VERILOG_SRCS = build/release/tt_um_pong.v
VERILOG_SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

all: gl

gl: release
	

release:
	mkdir -p build/release
	curl -sfSL -o build/release.zip https://github.com/warriorjacq9-no2fa/ttpong/releases/download/$(TAG)/release.zip
	bsdtar -xf build/release.zip --strip-components=1 -C build/release