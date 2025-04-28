`default_nettype none
`timescale 1ns / 1ps

module stars #(
    parameter XW = 10,                // 水平方向坐标位宽（sx）
    parameter YW = 9,                 // 垂直方向坐标位宽（sy）
    parameter COLRW = 12              // RGB颜色位宽，默认 4:4:4
)(
    input  wire clk_pix,              // 像素时钟
    input  wire rst,                  // 复位
    input  wire line,                 // 每行开始信号（未使用）
    input  wire [XW-1:0] sx,           // 当前像素x坐标
    input  wire [YW-1:0] sy,           // 当前像素y坐标
    input  wire [7:0] fade_level,      // 淡入淡出程度
    input  wire [15:0] frame_count,    // 帧计数器，用于控制闪烁
    output reg [COLRW-1:0] star_colr   // 输出颜色
);

    wire is_night;
    wire star_blink;

    assign is_night = (fade_level < 8'd64) || (fade_level > 8'd208);
    assign star_blink = frame_count[4];

    always @(*) begin
        star_colr = 12'h000; // 默认背景色（黑）

        if (is_night && star_blink) begin
            if (((sx >= 10'd80)  && (sx <= 10'd81)) && ((sy >= 9'd40)  && (sy <= 9'd41))) star_colr = 12'hFFF;
            else if (((sx >= 10'd140) && (sx <= 10'd141)) && ((sy >= 9'd60)  && (sy <= 9'd61))) star_colr = 12'hFFF;
            else if (((sx >= 10'd200) && (sx <= 10'd201)) && ((sy >= 9'd90)  && (sy <= 9'd91))) star_colr = 12'hFFF;
            else if (((sx >= 10'd260) && (sx <= 10'd261)) && ((sy >= 9'd30)  && (sy <= 9'd31))) star_colr = 12'hFFF;
            else if (((sx >= 10'd320) && (sx <= 10'd321)) && ((sy >= 9'd55)  && (sy <= 9'd56))) star_colr = 12'hFFF;
            else if (((sx >= 10'd380) && (sx <= 10'd381)) && ((sy >= 9'd75)  && (sy <= 9'd76))) star_colr = 12'hFFF;
            else if (((sx >= 10'd440) && (sx <= 10'd441)) && ((sy >= 9'd35)  && (sy <= 9'd36))) star_colr = 12'hFFF;
            else if (((sx >= 10'd500) && (sx <= 10'd501)) && ((sy >= 9'd65)  && (sy <= 9'd66))) star_colr = 12'hFFF;
            else if (((sx >= 10'd560) && (sx <= 10'd561)) && ((sy >= 9'd50)  && (sy <= 9'd51))) star_colr = 12'hFFF;
            else if (((sx >= 10'd600) && (sx <= 10'd601)) && ((sy >= 9'd85)  && (sy <= 9'd86))) star_colr = 12'hFFF;
            else if (((sx >= 10'd180) && (sx <= 10'd181)) && ((sy >= 9'd40)  && (sy <= 9'd41))) star_colr = 12'hFFF;
            else if (((sx >= 10'd420) && (sx <= 10'd421)) && ((sy >= 9'd70)  && (sy <= 9'd71))) star_colr = 12'hFFF;
        end
    end

endmodule

