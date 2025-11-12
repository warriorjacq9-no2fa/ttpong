s/\.[VNP][A-Z]+\( *[A-Za-z0-9_]+ *\),? *//g
s/(, *)?(VPWR|VGND|VPB|VNB)(, *)?//g
/inout[[:space:]]*;$/d
1i\`timescale 1ns\/1ps \n\/* verilator lint_off PINMISSING *\/\n\/* verilator lint_off PINNOCONNECT *\/