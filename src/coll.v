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
