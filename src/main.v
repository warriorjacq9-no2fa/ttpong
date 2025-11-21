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

    localparam BKG_R = 2'b11;
    localparam BKG_G = 2'b11;
    localparam BKG_B = 2'b10;

    assign uio_oe = 8'b0;

    reg [1:0] r, g, b;
    wire [10:0] x, y;
    wire de;
    wire hsync, vsync;

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

    wire s1_en;
    reg [1:0] s1_r, s1_g, s1_b;

    sprite #(.R(2'b01), .G(2'b00), .B(2'b00)) s1(
        .x(x),
        .y(y),
        .sx(11'd320),
        .sy(11'd240),
        .r(s1_r),
        .g(s1_g),
        .b(s1_b),
        .en(s1_en)
    );


    /* verilator lint_off LATCH */
    always @(*) begin // Display logic
        r = 0;
        g = 0;
        b = 0;
        if(de == 1) begin
            if(s1_en == 1) begin
                r = s1_r;
                g = s1_g;
                b = s1_b;
            end else begin
                r = BKG_R;
                g = BKG_G;
                b = BKG_B;
            end
        end
    end

    wire _unused = &{ui_in, uio_in, ena, 1'b0};
endmodule
