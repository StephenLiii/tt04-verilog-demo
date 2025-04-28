`default_nettype none
`timescale 1ns / 1ps

module sunrise #(
    parameter XW = 10,              // 水平坐标位宽（sx）
    parameter YW = 9,               // 垂直坐标位宽（sy）
    parameter COLRW = 12            // 颜色位宽，默认 RGB444
)(
    input  wire clk_pix,             // 像素时钟
    input  wire rst,                 // 复位（未使用）
    input  wire line,                // 行开始信号（未使用）
    input  wire [XW-1:0] sx,          // 当前像素的水平坐标
    input  wire [YW-1:0] sy,          // 当前像素的垂直坐标
    input  wire [7:0] fade_level,     // 淡入淡出程度
    input  wire direction,            // 渐变方向：0=日出，1=日落
    output reg  [COLRW-1:0] sun_colr  // 输出颜色（太阳或背景）
);

    localparam [11:0] COLOR_SUN = 12'hFF0;  // 太阳颜色（亮黄色）
    localparam [9:0] RADIUS = 10'd24;       // 太阳半径（24像素）

    reg [9:0] sun_x;
    reg [8:0] sun_y;
    reg [23:0] dist2;
    reg signed [11:0] dx;
    reg signed [11:0] dy;

    always @(*) begin
        // 默认太阳位置（不可见）
        sun_x = 10'd0;
        sun_y = 9'd500;

        if (direction == 1'b0 && fade_level > 8'd63 && fade_level <= 8'd255) begin
            if (fade_level <= 8'd112) begin
                // 日出阶段
                sun_x = 10'd640 - ((fade_level - 8'd64) * 10'd80) / (112 - 64);
                sun_y = 9'd310 - ((fade_level - 8'd64) * 9'd210) / (112 - 64);
            end else if (fade_level <= 8'd238) begin
                // 悬挂阶段
                sun_x = 10'd560 - ((fade_level - 8'd113) * 10'd400) / (238 - 113);
                sun_y = 9'd100;
            end else begin
                // 日落阶段
                sun_x = 10'd160 - ((fade_level - 8'd239) * 10'd80) / (255 - 239);
                sun_y = 9'd100 + ((fade_level - 8'd239) * 9'd210) / (255 - 239);
            end
        end
    end

    always @(*) begin
        dx = sx - sun_x;
        dy = sy - sun_y;
        dist2 = dx * dx + dy * dy;

        if (sun_y < 9'd480 && dist2 <= RADIUS * RADIUS)
            sun_colr = COLOR_SUN;
        else
            sun_colr = 12'h000;
    end

endmodule


