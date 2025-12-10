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

    localparam SCR_R = 2'b11;
    localparam SCR_G = 2'b11;
    localparam SCR_B = 2'b11;

    localparam P1_R = 2'b11;
    localparam P1_G = 2'b00;
    localparam P1_B = 2'b00;

    localparam P2_R = 2'b00;
    localparam P2_G = 2'b01;
    localparam P2_B = 2'b11;

    localparam BALL_R = 2'b00;
    localparam BALL_G = 2'b11;
    localparam BALL_B = 2'b00;

    localparam P_SPD = 4;
    localparam B_SPD = 3;

    assign uio_oe = 8'b0;

    wire pad;

    reg [1:0] r, g, b;
    wire [9:0] x, y;
    wire de;
    wire hsync, vsync;
    
    wire p1_c, p2_c, w_cv, w_ch;

    wire p1_up, p1_dn, p1_srv;
    wire p2_up, p2_dn, p2_srv;
    reg [1:0] side; // side[1]: ball serve on left, side[0]: ball serve on right

    wire stereo_en;
    wire a_l, a_r;
    wire a_mono = a_l | a_r;

    reg signed [1:0] b_delta;
    reg signed [2:0] by_delta;

    assign {stereo_en, pad, p2_srv, p2_dn, p2_up, p1_srv, p1_dn, p1_up} = ui_in[7:0];

    assign uo_out[7:0] = {hsync, b[0], g[0], r[0], vsync, b[1], g[1], r[1]};
    assign uio_out[5:0] = {5'b0, de};
    assign uio_out[7:6] = stereo_en ? {a_r, a_l} : {a_mono, 1'b0};

    // ********************** AUDIO *********************

    // Set high when a beep is needed
    wire beep_low = p1_c || p2_c || w_cv;
    wire beep_high = w_ch || win;

    wire ball_r = (b_delta > 0);
    wire ball_l = ~ball_r;

    reg [15:0] tone_cnt;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tone_cnt <= 0;
        end else begin
            tone_cnt <= tone_cnt + 1;
        end
    end

    wire a_low  = tone_cnt[15];   // ~381 Hz
    wire a_high = tone_cnt[14];   // ~762 Hz

    assign a_r = ball_r ? (beep_low ? a_low : (beep_high ? a_high : 0)) : 0;
    assign a_l = ball_l ? (beep_low ? a_low : (beep_high ? a_high : 0)) : 0;

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

    reg [8:0] p1_y;

    reg [8:0] p2_y;

    reg [9:0] ball_x;
    reg [8:0] ball_y;

    sprite #(.HEIGHT(50)) p1(
        .x(x),
        .y(y),
        .sx(10'd40),
        .sy(p1_y),
        .en(p1_en)
    );

    sprite #(.HEIGHT(50)) p2(
        .x(x),
        .y(y),
        .sx(10'd600),
        .sy(p2_y),
        .en(p2_en)
    );

    sprite ball(
        .x(x),
        .y(y),
        .sx(ball_x),
        .sy(ball_y),
        .en(ball_en)
    );

    // ******************* COLLISIONS *******************

    // ***** MODULES *****

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

    wincoll w_cd(
        .sx(ball_x),
        .sy(ball_y),
        .coll_v(w_cv),
        .coll_h(w_ch) // TODO: scoring
    );

    // ***** CONTROL *****

    reg [3:0] score, score2;

    // Pack all event inputs into a single bus
    wire [5:0] evt_in = {w_cv, w_ch, p1_c, p2_c, p1_srv, p2_srv};
    reg  [5:0] evt_d;  // previous values

    // Rising edge detect (1 cycle pulse)
    wire [5:0] evt_rise = evt_in & ~evt_d;

    // Unpack edges
    wire w_cv_rise   = evt_rise[5];
    wire w_ch_rise   = evt_rise[4];
    wire p1_c_rise   = evt_rise[3];
    wire p2_c_rise   = evt_rise[2];
    wire p1_srv_rise = evt_rise[1];
    wire p2_srv_rise = evt_rise[0];

    reg [9:0] bx_next;
    reg by_rst;
    wire win = (score >= 9 || score2 > 9);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            by_delta    <= 3'b001;
            b_delta     <= 2'b00;
            side        <= 2'b01;
            evt_d       <= 6'b0;
            score       <= 4'b0;
            score2      <= 4'b0;
            bx_next     <= 10'b0;
            by_rst      <= 1'b0;
        end else begin
            // capture for edge detect
            evt_d <= evt_in;

            // collision responses (optimized)
            if (w_cv_rise)
                by_delta <= -by_delta;

            if (p1_c_rise) begin
                b_delta <= -b_delta;
                if(ball_y > p1_y + 5) begin
                    by_delta <= (by_delta < 0 ? -1 : 2);
                end else if(ball_y < p1_y - 1) begin
                    by_delta <= (by_delta < 0 ? -2 : 1);
                end else begin
                    by_delta <= (by_delta < 0 ? -1 : 1);
                end
            end

            if (p2_c_rise) begin
                b_delta <= -b_delta;
                if(ball_y > p2_y + 5) begin
                    by_delta <= (by_delta < 0 ? -1 : 2);
                end else if(ball_y < p2_y - 10) begin
                    by_delta <= (by_delta < 0 ? -2 : 1);
                end else begin
                    by_delta <= (by_delta < 0 ? -1 : 1);
                end
            end

            if (w_ch_rise) begin
                if(ball_l) begin
                    score <= score + 1;
                    b_delta <= 2'b0;
                    by_delta <= 3'b1;
                    bx_next <= 10'd575;
                    side[0] <= 1'b1;
                end else begin
                    score2 <= score2 + 1;
                    b_delta <= 2'b0;
                    by_delta <= 3'b1;
                    bx_next <= 10'd65;
                    side[1] <= 1'b1;
                end
                by_rst <= 1;
            end else begin
                by_rst <= 0;
            end

            // serve logic (optimized)
            if (p1_srv_rise && side[1]) begin
                b_delta <= 2'b01;
                side    <= 2'b00;
            end else if (p2_srv_rise && side[0]) begin
                b_delta <= 2'b11;
                side    <= 2'b00;
            end
        end
    end

    // ******************** SCORING  ********************

    localparam [149:0] nums = {
        15'b111_101_111_001_111, // 9
        15'b111_101_111_101_111, // 8
        15'b111_001_010_010_010, // 7
        15'b111_100_111_101_111, // 6
        15'b111_100_111_001_111, // 5
        15'b101_101_111_001_001, // 4
        15'b111_001_111_001_111, // 3
        15'b111_001_111_100_111, // 2
        15'b110_010_010_010_111, // 1
        15'b111_101_101_101_111  // 0
    };

    localparam SCORE1_X = 368;
    localparam SCORE1_Y = 440;
    localparam SCORE2_X = 272;
    localparam SCORE2_Y = 440;
    wire s1_en;
    wire s2_en;

    sprite #(.WIDTH(24), .HEIGHT(40)) sc_1 (
        .x(x),
        .y(y),
        .sx(SCORE1_X),
        .sy(SCORE1_Y),
        .en(s1_en)
    );


    sprite #(.WIDTH(24), .HEIGHT(40)) sc_2 (
        .x(x),
        .y(y),
        .sx(SCORE2_X),
        .sy(SCORE2_Y),
        .en(s2_en)
    );
    
    wire [10:0] col = (x - (SCORE1_X-12)) / 8;  // 0..2
    wire [10:0] row = (y - (SCORE1_Y-20)) / 8;  // 0..4
    wire [10:0] bit_index = row * 3 + (2 - col);   // 0..14

    wire [10:0] col2 = (x - (SCORE2_X-12)) / 8;  // 0..2
    wire [10:0] row2 = (y - (SCORE2_Y-20)) / 8;  // 0..4
    wire [10:0] bit_index2 = row2 * 3 + (2 - col2);   // 0..14

    // ******************** MOVEMENT ********************

    always @(*) begin // Display logic
        r = 0;
        g = 0;
        b = 0;

        if(de == 1 && win == 0) begin
            if(p1_en == 1) begin
                r = P1_R;
                g = P1_G;
                b = P1_B;
            end else if(p2_en == 1) begin
                r = P2_R;
                g = P2_G;
                b = P2_B;
            end else if(ball_en == 1) begin
                r = BALL_R;
                g = BALL_G;
                b = BALL_B;
            end else if(s1_en == 1) begin
                if (nums[(score * 8'd15) + bit_index[7:0]]) begin
                    r = SCR_R;
                    g = SCR_G;
                    b = SCR_B;
                end else begin
                    r = BKG_R;
                    g = BKG_G;
                    b = BKG_B;
                end
            end else if(s2_en == 1) begin
                if (nums[(score2 * 8'd15) + bit_index2[7:0]]) begin
                    r = 2'b11;
                    g = 2'b11;
                    b = 2'b11;
                end else begin
                    r = BKG_R;
                    g = BKG_G;
                    b = BKG_B;
                end
            end else begin
                // Middle line
                if((x > 315 && x < 325) && y[4]) begin
                    r = SCR_R;
                    g = SCR_G;
                    b = SCR_B;
                end else begin
                    r = BKG_R;
                    g = BKG_G;
                    b = BKG_B;
                end
            end
        end
    end

    reg sel_p1;
    wire signed [1:0] delta = 
        (sel_p1 ? (p1_up - p1_dn) : (p2_up - p2_dn));

    localparam _P_SPD = P_SPD;
    localparam _B_SPD = B_SPD;

    reg vsync_prev;
    wire vsync_negedge = vsync_prev && !vsync;

    reg [5:0] second_cnt;
    reg [5:0] second_tmp;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            vsync_prev <= 1'b0;
            second_cnt <= 6'b0;
            second_tmp <= 6'b0;

            p1_y <= 9'd240;
            p2_y <= 9'd240;

            ball_x <= 10'd575;
            ball_y <= 9'd240;

            sel_p1 <= 1'b0;
        end else begin
            vsync_prev <= vsync;
        
            if(vsync_negedge) begin

                if(sel_p1) begin
                    p1_y <= p1_y + {{7-_P_SPD{delta[1]}}, delta, {_P_SPD{1'b0}}};
                end else begin
                    p2_y <= p2_y + {{7-_P_SPD{delta[1]}}, delta, {_P_SPD{1'b0}}};
                end

                ball_x <= ball_x + {{8-_B_SPD{b_delta[1]}}, b_delta, {_B_SPD{1'b0}}};
                ball_y <= ball_y + {{6-_B_SPD{by_delta[2]}}, by_delta, {_B_SPD{1'b0}}};

                sel_p1 <= ~sel_p1;

                second_cnt <= second_cnt + 1;
                if(win && (second_tmp == 0)) begin
                    second_tmp <= second_cnt + 63;
                end
                if(second_tmp == second_cnt && win) begin
                    score <= 0;
                    score2 <= 0;
                end
            end
            if(by_rst) begin
                ball_x <= bx_next;
                ball_y <= 9'd240;
            end
        end
    end

    wire _unused = &{uio_in, ena, stereo_en, pad, bit_index[10:4], bit_index2[10:4], 1'b0};
endmodule
