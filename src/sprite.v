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

    wire signed [9:0] dx_signed = $signed(x) - $signed(sx);
    wire signed [9:0] dy_signed = $signed(y) - $signed({1'b0, sy});

    assign en = (
        ($unsigned(dx_signed[8] ? -dx_signed : dx_signed) < WIDTH_2) &&
        ($unsigned(dy_signed[9] ? -dy_signed : dy_signed) < HEIGHT_2)
    );
    assign r = {2{en}} & R;
    assign g = {2{en}} & G;
    assign b = {2{en}} & B;

endmodule
