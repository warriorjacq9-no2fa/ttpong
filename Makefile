all: vga-test

vga-test:
	make -C test/vga-test all TOP_MODULE=tt_um_pong VERILOG_SRCS="../../src/main.v ../../src/vga.v"

gl:
	make -C test/gl all