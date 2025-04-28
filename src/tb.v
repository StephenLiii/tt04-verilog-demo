`default_nettype none
`timescale 1ns / 1ps

module tb;

  // === 输入输出信号 ===
  reg clk = 0;
  reg rst_n = 0;
  wire [7:0] ui_in;
  wire [7:0] uo_out;
  wire [7:0] uio;

  // === 产生时钟信号 ===
  always #50 clk = ~clk;  // 10MHz 时钟，周期100ns

  // === 顶层模块实例化 ===
  tt_um_StephenLiii_twilight_cat uut (
    .clk(clk),
    .rst_n(rst_n),
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio(uio)
  );

  // === 输入初始化 ===
  assign ui_in = 8'h00;  // 你的项目暂时不用按键输入，保持全零

  // === 仿真控制 ===
  initial begin
    // 1. 保存波形
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    // 2. 复位流程
    rst_n = 0;
    #200;
    rst_n = 1;

    // 3. 运行一段时间，观察仿真
    #500000;  // 仿真 500,000ns = 0.5ms

    // 4. 结束仿真
    $finish;
  end

endmodule

