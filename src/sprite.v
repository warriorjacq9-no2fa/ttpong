module sprite #( parameter
    WIDTH = 10,
    HEIGHT = 10,
    R = 2'b11,
    G = 2'b11,
    B = 2'b11
)
(
    input wire [9:0] x, y,
    input wire [9:0] sx,
    input wire [8:0] sy,
    output wire [1:0] r, g, b,
    output wire en
);
    localparam WIDTH_2 = WIDTH >> 1;
    localparam HEIGHT_2 = HEIGHT >> 1;

    assign en = (
        (x > sx - WIDTH_2 && x < sx + WIDTH_2) &&
        (y > sy - HEIGHT_2 && y < sy + HEIGHT_2)
    );
    assign r = {2{en}} & R;
    assign g = {2{en}} & G;
    assign b = {2{en}} & B;

endmodule
