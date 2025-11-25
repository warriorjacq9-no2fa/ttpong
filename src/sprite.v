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

    assign en = (
        (x > sx - (WIDTH / 2) && x < sx + (WIDTH / 2)) &&
        (y > sy - (HEIGHT / 2) && y < sy + (HEIGHT / 2))
    );
    assign {r, g, b} = en ? {R, G, B} : 6'bxxxxxx;

endmodule
