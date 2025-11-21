all: vga-test

vga-test:
	make -C test/vga-test all TOP_MODULE=tt_um_pong VERILOG_SRCS="../../src/main.v ../../src/vga.v ../../src/sprite.v"

nodisp:
	iverilog -g2012 tb.v src/main.v src/vga.v src/sprite.v -o tb.vvp
	vvp tb.vvp
	gtkwave tb.vcd tb.gtkw

gl:
	make -C test/gl all

clean:
	make -C test/gl clean
	make -C test/vga-test clean