<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

It uses a custom VGA sync module to generate VGA sync signals, then uses pixel-clock-based logic to generate sprites and background color.

## How to test

### Software:

Use `make` to run the included vga-test submodule to run a graphical test in real time. Use `make gl` to run a gate-level test with the included vga-gl submodule.

Note: gate-level testing is not in real time, and presimulates the inputs and outputs. It also takes much longer to start, but will run at 60fps, as opposed to the variable fps of vga-test.

### Hardware:

Attach all external hardware. Be sure to enable reset. Press the P1SRV button to start the game, control with up and down.

## External hardware

TinyVGA PMOD, 6 buttons, 6 pullup resistors (10K) connected from button "output" to 3.3v. Optionally 6 100nF capacitors connected to the button "output" and ground, combined with 6 1K resistors in series from the button to the chip inputs, for debouncing.
