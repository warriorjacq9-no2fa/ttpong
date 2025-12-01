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

    wire pad;

    reg [1:0] r, g, b;
    wire [9:0] x, y;
    wire de;
    wire hsync, vsync;
    wire a_mono;
    
    wire p1_c, p2_c;

    wire p1_up, p1_dn, p1_srv;
    wire p2_up, p2_dn, p2_srv;

    wire stereo_en;

    assign {stereo_en, pad, p2_srv, p2_dn, p2_up, p1_srv, p1_dn, p1_up} = ui_in[7:0];

    assign uo_out[7:0] = {hsync, b[0], g[0], r[0], vsync, b[1], g[1], r[1]};
    assign uio_out[5:0] = {5'b0, de};
    assign uio_out[7:6] = {a_mono, 1'b0};

    // ********************** AUDIO *********************

    // Set high when a beep is needed
    wire beep_low = p1_c;
    wire beep_high = p2_c;

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

    assign a_mono = (beep_low ? a_low : (beep_high ? a_high : 0));

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

    reg signed [1:0] b_delta;

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
                r = SPR_R;
                g = SPR_G;
                b = SPR_B;
            end else if(p2_en == 1) begin
                r = SPR_R;
                g = SPR_G;
                b = SPR_B;
            end else if(ball_en == 1) begin
                r = SPR_R;
                g = SPR_G;
                b = SPR_B;
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

    localparam _P_SPD = P_SPD;
    localparam _B_SPD = B_SPD;

    reg vsync_prev;
    wire vsync_negedge = vsync_prev && !vsync;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            vsync_prev <= 1'b0;

            p1_y <= 9'd240;
            p2_y <= 9'd240;

            ball_x <= 10'd575;
            ball_y <= 9'd240;
            b_delta <= 2'b0;

            sel_p1 <= 1'b0;

            side <= 2'b01;
        end else begin
            if(p1_srv && side[1]) begin
                b_delta <= 2'b11;
                side <= 2'b0;
            end else if(p2_srv && side[0]) begin
                b_delta <= 2'b01;
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

    wire _unused = &{uio_in, ena, stereo_en, pad, 1'b0};
endmodule
