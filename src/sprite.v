module sprite #(
    WIDTH = 10,
    HEIGHT = 10,
    R = 2'b11,
    G = 2'b11,
    B = 2'b11
)
(
    input reg [9:0] x, y,
    input reg [9:0] sx, sy,
    output wire [1:0] r, g, b,
    output wire en
);

    assign en = (
        (x > sx - (WIDTH / 2) && x < sx + (WIDTH / 2)) &&
        (y > sy - (HEIGHT / 2) && y < sy + (HEIGHT / 2))
    );
    assign {r, g, b} = en ? {R, G, B} : 6'bxxxxxx;

endmodule
