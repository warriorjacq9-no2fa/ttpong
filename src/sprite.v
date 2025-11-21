module sprite #(
    WIDTH = 10,
    HEIGHT = 10,
    R = 2'hF,
    G = 2'hF,
    B = 2'hF
)
(
    input reg [10:0] x, y,
    input reg [10:0] sx, sy,
    output wire [1:0] r, g, b,
    output wire en
);

    assign en = (
        (x > sx - (WIDTH / 2) && x < sx + (WIDTH / 2)) &&
        (y > sy - (HEIGHT / 2) && y < sy + (HEIGHT / 2))
    );
    assign {r, g, b} = (en ? {R, G, B} : {2'bx, 2'bx, 2'bx});

endmodule
