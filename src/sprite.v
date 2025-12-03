module sprite #( parameter
    WIDTH = 10,
    HEIGHT = 10
)
(
    input wire [9:0] x, 
    input wire [9:0] y,
    input wire [9:0] sx,
    input wire [8:0] sy,
    output wire en
);

    wire [9:0] dx = (x > sx) ? (x - sx) : (sx - x);
    wire [9:0] dy = (y > {1'b0, sy}) ? (y - sy) : (sy - y);

    assign en = (dx < (WIDTH/2)) && (dy < (HEIGHT/2));

endmodule
