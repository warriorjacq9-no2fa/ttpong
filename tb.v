`timescale 1ns/1ps
`default_nettype none

module tb;
reg clk;
reg rst_n;
supply0 gnd;
supply1 pwr;

tt_um_pong dut
(
    .ui_in (8'b0),
    .rst_n (rst_n),
    .clk (clk)
);

localparam CLK_PERIOD = 2;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
end

initial begin
    clk <= 1'bx;
    rst_n <= 1'b1;
    #1;
    rst_n <= 1'b0;
    clk <= 1'b0;
    repeat(3) @(posedge clk);
    rst_n <= 1'b1;
    repeat(420000 * 4) @(posedge clk);
    $finish();
end

endmodule
`default_nettype wire