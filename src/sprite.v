module sprite #( parameter
    WIDTH = 10,
    HEIGHT = 10
)
(
    input wire [9:0] x, y,
    input wire [9:0] sx,
    input wire [8:0] sy,
    output wire en
);

    assign en = (
        (x > sx - (WIDTH / 2) && x < sx + (WIDTH / 2)) &&
        (y > sy - (HEIGHT / 2) && y < sy + (HEIGHT / 2))
    );

endmodule
