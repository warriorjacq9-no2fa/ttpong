module coll #( parameter
    WIDTH_1 = 10,
    HEIGHT_1 = 10,
    WIDTH_2 = 10,
    HEIGHT_2 = 10
)
(
    input wire [9:0] s1x, s2x,
    input wire [8:0] s1y, s2y,
    output wire coll
);

    wire [9:0] dx = (s1x > s2x ? s1x - s2x : s2x - s1x);
    wire [8:0] dy = (s1y > s2y ? s1y - s2y : s2y - s1y);

    assign coll = (
        (dx * 2 <= (WIDTH_1 + WIDTH_2)) &&
        (dy * 2 <= (HEIGHT_1 + HEIGHT_2))
    ) ? 1'b1 : 1'b0;

endmodule
/* verilator lint_off DECLFILENAME */
module wincoll #( parameter
    S_WIDTH = 640,
    S_HEIGHT = 480,
    WIDTH = 10,
    HEIGHT = 10
)
(
    input wire [9:0] sx,
    input wire [8:0] sy,
    output wire coll_v, coll_h
);

    localparam W2 = WIDTH / 2;
    localparam H2 = HEIGHT / 2;

    assign coll_h = (sx <= W2 || sx >= S_WIDTH - W2);
    assign coll_v = (sy <= H2 || sy >= S_HEIGHT - H2);

endmodule
