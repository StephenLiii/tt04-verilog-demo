`default_nettype none
`timescale 1ns / 1ps

module background_twilight (
    input  wire clk_pix,       // 像素时钟
    input  wire rst,           // 复位
    input  wire line,          // 每行开始信号
    input  wire [8:0] sy,      // 当前垂直坐标 (0-479)
    input  wire [7:0] fade_level, // 渐变程度 (0-255)
    output reg  [11:0] bg_colr // 背景颜色输出 (RGB444)
);

    reg [3:0] night_r, night_g, night_b;
    reg [3:0] day_r, day_g, day_b;
    reg [11:0] color_sky;

    wire [3:0] band;
    wire [11:0] color_ground;

    assign band = sy[8:5];      // 简单粗分16段（代替除法）
    assign color_ground = 12'h0C0; // 地面颜色（绿色）

    // 计算混合后的颜色 (在组合逻辑块里完成)
    always @(*) begin
        night_r = 4'h1;
        night_g = 4'h1;
        night_b = 4'h3;
        day_r = 4'h1;
        day_g = 4'hA;
        day_b = 4'hF;

        case (band)
            4'd0:  begin night_g=4'h1; night_b=4'h3; day_g=4'hA; day_b=4'hF; end
            4'd1:  begin night_g=4'h2; night_b=4'h4; day_g=4'hB; day_b=4'hF; end
            4'd2:  begin night_g=4'h3; night_b=4'h5; day_g=4'hC; day_b=4'hF; end
            4'd3:  begin night_g=4'h4; night_b=4'h6; day_g=4'hD; day_b=4'hF; end
            4'd4:  begin night_g=4'h5; night_b=4'h7; day_g=4'hE; day_b=4'hF; end
            4'd5:  begin night_g=4'h6; night_b=4'h8; day_g=4'hF; day_b=4'h5; end
            4'd6:  begin night_g=4'h7; night_b=4'h9; day_g=4'hF; day_b=4'hB; end
            4'd7:  begin night_g=4'h8; night_b=4'hA; day_g=4'hF; day_b=4'hF; end
            4'd8:  begin night_g=4'h9; night_b=4'hB; day_g=4'hF; day_b=4'h7; end
            4'd9:  begin night_g=4'hA; night_b=4'hC; day_g=4'hD; day_b=4'hF; end
            4'd10: begin night_g=4'hB; night_b=4'hD; day_g=4'hC; day_b=4'hF; end
            4'd11: begin night_g=4'hC; night_b=4'hE; day_g=4'hB; day_b=4'hF; end
            4'd12: begin night_g=4'hD; night_b=4'hE; day_g=4'hA; day_b=4'hF; end
            4'd13: begin night_g=4'hE; night_b=4'hD; day_g=4'h9; day_b=4'hF; end
            4'd14: begin night_g=4'hF; night_b=4'hA; day_g=4'h8; day_b=4'hF; end
            4'd15: begin night_g=4'hF; night_b=4'hF; day_g=4'h7; day_b=4'hF; end
        endcase

        color_sky[11:8] = ((night_r*(8'd255-fade_level) + day_r*fade_level) >> 8) & 4'hF;
        color_sky[7:4]  = ((night_g*(8'd255-fade_level) + day_g*fade_level) >> 8) & 4'hF;
        color_sky[3:0]  = ((night_b*(8'd255-fade_level) + day_b*fade_level) >> 8) & 4'hF;
    end

    always @(posedge clk_pix or posedge rst) begin
        if (rst) begin
            bg_colr <= 12'h000;
        end else if (line) begin
            if (sy >= 9'd320)
                bg_colr <= color_ground;
            else
                bg_colr <= color_sky;
        end
    end

endmodule
