`default_nettype none
`timescale 1ns / 1ps

module tt_um_StephenLiii_twilight_cat (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  ui_in,
    output wire [7:0]  uo_out,
    inout  wire [7:0]  uio
);

    // === WIRING ===
    wire rst_pix = ~rst_n;

    // === DISPLAY SYNC ===
    localparam CORDW = 16;
    wire signed [CORDW-1:0] sx, sy;
    wire hsync, vsync, de, frame, line;

    display_480p #(.CORDW(CORDW)) display_inst (
        .clk_pix(clk), .rst_pix(rst_pix),
        .hsync(hsync), .vsync(vsync), .de(de),
        .frame(frame), .line(line),
        .sx(sx), .sy(sy)
    );

    // === SOUND ===
    wire AUD_PWM, AUD_SD;
    Ode_to_Joy_player music_inst (
        .clk(clk),
        .AUD_PWM(AUD_PWM),
        .AUD_SD(AUD_SD)
    );

    // === SPRITE POSITION ===
    localparam H_RES = 640;
    localparam SPR_WIDTH = 32, SPR_HEIGHT = 20, SPR_SCALE = 2, SPR_SPX = 2;
    localparam SPR_DRAWW = SPR_WIDTH * 2**SPR_SCALE;
    reg signed [CORDW-1:0] sprx_r, spry_r;

    always @(posedge clk) begin
        if (frame) begin
            if (sprx_r <= -SPR_DRAWW)
                sprx_r <= H_RES;
            else
                sprx_r <= sprx_r - SPR_SPX;
        end
        if (rst_pix) begin
            sprx_r <= H_RES;
            spry_r <= 240;
        end
    end

    wire signed [CORDW-1:0] sprx = sprx_r;
    wire signed [CORDW-1:0] spry = spry_r;

    // === SPRITE ===
    localparam CIDXW = 4;
    wire drawing;
    wire [CIDXW-1:0] spr_pix_indx;

    sprite #(
        .CORDW(CORDW), .H_RES(H_RES), .SX_OFFS(3),
        .SPR_WIDTH(SPR_WIDTH), .SPR_HEIGHT(SPR_HEIGHT), .SPR_SCALE(SPR_SCALE),
        .SPR_DATAW(CIDXW)
    ) sprite_inst (
        .clk(clk), .rst(rst_pix), .line(line),
        .sx(sx), .sy(sy),
        .sprx(sprx), .spry(spry),
        .pix(spr_pix_indx), .drawing(drawing)
    );

    // === CLUT ===
    wire [11:0] spr_pix_colr;
    clut_cat clut_inst (
        .index(spr_pix_indx),
        .colr_out(spr_pix_colr)
    );

    // === BACKGROUND ===
    wire [11:0] bg_colr;
    background_twilight #(.COLRW(12)) bg_inst (
        .clk_pix(clk), .rst(rst_pix), .line(line), .sy(sy), .fade_level(fade_level), .bg_colr(bg_colr)
    );

    // === FADE LEVEL ===
    wire [7:0] fade_level;
    wire direction;
    fade_level_generator fade_inst (
        .clk(clk), .rst(rst_pix),
        .fade_level(fade_level),
        .direction(direction)
    );

    // === STARS ===
    wire [11:0] star_colr;
    stars #(.XW(CORDW), .YW(CORDW), .COLRW(12)) stars_inst (
        .clk_pix(clk), .rst(rst_pix), .line(line),
        .sx(sx), .sy(sy),
        .fade_level(fade_level),
        .frame_count({8'd0, fade_level}),
        .star_colr(star_colr)
    );

    // === SUNRISE ===
    wire [11:0] sun_colr;
    sunrise #(.XW(CORDW), .YW(CORDW), .COLRW(12)) sun_inst (
        .clk_pix(clk), .rst(rst_pix), .line(line),
        .sx(sx), .sy(sy),
        .fade_level(fade_level), .direction(direction),
        .sun_colr(sun_colr)
    );

    // === PIXEL COMPOSITING ===
    wire [11:0] paint_colr;
    assign paint_colr = (drawing && spr_pix_indx != 4'h9) ? spr_pix_colr :
                        (sun_colr != 12'd0) ? sun_colr :
                        (star_colr != 12'd0) ? star_colr :
                        bg_colr;

    // === OUTPUT MAPPING ===
    assign uo_out[0] = hsync;
    assign uo_out[1] = vsync;
    assign uo_out[2] = paint_colr[11];
    assign uo_out[3] = paint_colr[7];
    assign uo_out[4] = paint_colr[3];
    assign uo_out[5] = AUD_PWM;
    assign uo_out[6] = AUD_SD;
    assign uo_out[7] = 1'b0;

    // === UIO HIGH-Z ===
    assign uio = 8'bzzzz_zzzz;

endmodule

