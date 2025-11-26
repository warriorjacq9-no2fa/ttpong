/* verilator lint_off DECLFILENAME */
module tt_um_pong (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    localparam BKG_R = 2'b00;
    localparam BKG_G = 2'b00;
    localparam BKG_B = 2'b00;

    localparam SPR_R = 2'b00;
    localparam SPR_G = 2'b01;
    localparam SPR_B = 2'b00;

    localparam P_SPD = 3;
    localparam B_SPD = 3;

    assign uio_oe = 8'b0;

    reg [1:0] r, g, b;
    wire [9:0] x, y;
    wire de;
    wire hsync, vsync;

    wire p1_up, p1_dn, p1_srv;
    wire p2_up, p2_dn, p2_srv;

    assign {p2_srv, p2_dn, p2_up, p1_srv, p1_dn, p1_up} = ui_in[5:0];

    assign uo_out[7:0] = {hsync, b[0], g[0], r[0], vsync, b[1], g[1], r[1]};
    assign uio_out[7:0] = {de, 7'b0};


    // ******************** GRAPHICS ********************
    vga vga (
	    .clk(clk), 
	    .hsync(hsync),
		.vsync(vsync),
		.x(x),
		.y(y),
		.de(de),
        .rst_n(rst_n)
	);

    wire p1_en, p2_en, ball_en;

    wire [1:0] p1_r, p1_g, p1_b;
    reg [8:0] p1_y;

    wire [1:0] p2_r, p2_g, p2_b;
    reg [8:0] p2_y;

    wire [1:0] ball_r, ball_g, ball_b;
    reg [9:0] ball_x;
    reg [8:0] ball_y;

    sprite #(.R(SPR_R), .G(SPR_G), .B(SPR_B), .HEIGHT(50)) p1(
        .x(x),
        .y(y),
        .sx(10'd40),
        .sy(p1_y),
        .r(p1_r),
        .g(p1_g),
        .b(p1_b),
        .en(p1_en)
    );

    sprite #(.R(SPR_R), .G(SPR_G), .B(SPR_B), .HEIGHT(50)) p2(
        .x(x),
        .y(y),
        .sx(10'd600),
        .sy(p2_y),
        .r(p2_r),
        .g(p2_g),
        .b(p2_b),
        .en(p2_en)
    );

    sprite #(.R(SPR_R), .G(SPR_G), .B(SPR_B)) ball(
        .x(x),
        .y(y),
        .sx(ball_x),
        .sy(ball_y),
        .r(ball_r),
        .g(ball_g),
        .b(ball_b),
        .en(ball_en)
    );

    // ******************* COLLISIONS *******************

    reg signed [1:0] b_delta;
    wire p1_c, p2_c;

    coll #(.HEIGHT_1(50)) p1_cd(
        .s1x(10'd40),
        .s1y(p1_y),
        .s2x(ball_x),
        .s2y(ball_y),
        .coll(p1_c)
    );

    coll #(.HEIGHT_1(50)) p2_cd(
        .s1x(10'd600),
        .s1y(p2_y),
        .s2x(ball_x),
        .s2y(ball_y),
        .coll(p2_c)
    );

    // ******************** GAMEPLAY ********************

    always @(*) begin // Display logic
        r = 0;
        g = 0;
        b = 0;

        if(de == 1) begin
            if(p1_en == 1) begin
                r = p1_r;
                g = p1_g;
                b = p1_b;
            end else if(p2_en == 1) begin
                r = p2_r;
                g = p2_g;
                b = p2_b;
            end else if(ball_en == 1) begin
                r = ball_r;
                g = ball_g;
                b = ball_b;
            end else begin
                r = BKG_R;
                g = BKG_G;
                b = BKG_B;
            end
        end
    end

    reg sel_p1;
    wire signed [1:0] delta = 
        (sel_p1 ? (p1_up - p1_dn) : (p2_up - p2_dn));
    reg [1:0] side; // side[1]: ball serve on left, side[0]: ball serve on right

// Since VGA_TEST runs at ~30FPS due to computation limits, run at double
// speeds when under it. This won't affect production testing.
`ifdef VGA_TEST
    localparam _P_SPD = P_SPD + 1;
`else
    localparam _P_SPD = P_SPD;
`endif

`ifdef VGA_TEST
    localparam _B_SPD = B_SPD + 1;
`else
    localparam _B_SPD = B_SPD;
`endif

    reg vsync_prev;
    wire vsync_negedge = vsync_prev && !vsync;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            p1_y <= 9'd240;

            p2_y <= 9'd240;

            ball_x <= 10'd575;
            ball_y <= 9'd240;
            b_delta <= 2'b0;

            sel_p1 <= 1'b0;

            side <= 2'b01;
        end else begin
            if(p1_srv && side[1]) begin
                b_delta <= 2'b01;
                side <= 2'b0;
            end else if(p2_srv && side[0]) begin
                b_delta <= 2'b11;
                side <= 2'b0;
            end

            if(p1_c) begin
                b_delta <= 2'b01;
            end else if(p2_c) begin
                b_delta <= 2'b11;
            end

            vsync_prev <= vsync;
        
            if(vsync_negedge) begin

                if(sel_p1) begin
                    p1_y <= p1_y + {{7-_P_SPD{delta[1]}}, delta, {_P_SPD{1'b0}}};
                end else begin
                    p2_y <= p2_y + {{7-_P_SPD{delta[1]}}, delta, {_P_SPD{1'b0}}};
                end

                ball_x <= ball_x + {{8-_B_SPD{b_delta[1]}}, b_delta, {_B_SPD{1'b0}}};

                sel_p1 <= ~sel_p1;
            end
        end
    end

    wire _unused = &{ui_in[7:6], uio_in, ena, p1_srv, p2_srv, 1'b0};
endmodule
