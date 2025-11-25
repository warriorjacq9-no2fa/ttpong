all: vga-test

vga-test:
	$(MAKE) -C test/vga-test all TOP_MODULE=tt_um_pong VERILOG_SRCS="../../src/main.v ../../src/vga.v ../../src/sprite.v ../../src/coll.v"

nodisp:
	iverilog -g2012 tb.v src/main.v src/vga.v src/sprite.v src/coll.v -o tb.vvp -DVGA_TEST
	vvp tb.vvp
	gtkwave tb.vcd tb.gtkw

gl:
	$(MAKE) -C test/gl all

clean:
	$(MAKE) -C test/gl clean
	$(MAKE) -C test/vga-test clean