`default_nettype none
`timescale 1ns / 1ps

module fade_level_generator (
    input  wire clk,           // 时钟输入
    input  wire rst,           // 异步复位
    output reg  [7:0] fade_level, // 淡入淡出等级（0=最暗，255=最亮）
    output wire direction      // 方向指示（0=变亮，1=变暗）
);

    reg direction_r;            // 内部方向标志位
    reg [19:0] counter;          // 节奏计数器

    assign direction = direction_r;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fade_level <= 8'd0;
            direction_r <= 1'b0; // 初始为夜晚，慢慢变亮
            counter <= 20'd0;
        end else begin
            if (counter == 20'd0) begin
                // 每次 counter 归零时更新 fade_level
                if (direction_r == 1'b0) begin
                    // 变亮
                    if (fade_level < 8'd255)
                        fade_level <= fade_level + 1'b1;
                    else
                        direction_r <= 1'b1; // 到顶后开始变暗
                end else begin
                    // 变暗
                    if (fade_level > 8'd0)
                        fade_level <= fade_level - 1'b1;
                    else
                        direction_r <= 1'b0; // 到0后开始变亮
                end
            end
            counter <= counter + 1'b1;
        end
    end

endmodule

