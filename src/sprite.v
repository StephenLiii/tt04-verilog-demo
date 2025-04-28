`default_nettype none
`timescale 1ns / 1ps

module sprite #(
    parameter CORDW = 16,
    parameter H_RES = 640,
    parameter SX_OFFS = 2,
    parameter SPR_WIDTH = 32,
    parameter SPR_HEIGHT = 20,
    parameter SPR_SCALE = 0,
    parameter SPR_DATAW = 4
)(
    input wire clk,
    input wire rst,
    input wire line,
    input wire signed [CORDW-1:0] sx,
    input wire signed [CORDW-1:0] sy,
    input wire signed [CORDW-1:0] sprx,
    input wire signed [CORDW-1:0] spry,
    output reg [SPR_DATAW-1:0] pix,
    output reg drawing
);

    // sprite bitmap ROM
    localparam SPR_ROM_DEPTH = SPR_WIDTH * SPR_HEIGHT;
    localparam SPR_ADDRW = 10;  // 640 pixels -> 10 bits address

    wire [SPR_DATAW-1:0] spr_rom_data;
    reg [SPR_ADDRW-1:0] spr_rom_addr;

    rom_sprite_cat spr_rom (
        .addr(spr_rom_addr),
        .data(spr_rom_data)
    );

    reg [$clog2(SPR_WIDTH)-1:0] bmap_x;
    reg [SPR_SCALE:0] cnt_x;
    reg signed [CORDW-1:0] sprx_r, spry_r;
    reg signed [CORDW-1:0] spr_diff;
    reg spr_active;
    reg spr_begin;
    reg spr_end;
    reg line_end;

    reg [2:0] state;
    localparam IDLE      = 3'd0;
    localparam REG_POS   = 3'd1;
    localparam ACTIVE    = 3'd2;
    localparam WAIT_POS  = 3'd3;
    localparam SPR_LINE  = 3'd4;
    localparam WAIT_DATA = 3'd5;

    always @(*) begin
        spr_diff = (sy - spry_r) >>> SPR_SCALE;
        spr_active = (spr_diff >= 0) && (spr_diff < SPR_HEIGHT);
        spr_begin = (sx >= sprx_r - SX_OFFS);
        spr_end = (bmap_x == SPR_WIDTH-1);
        line_end = (sx == H_RES - SX_OFFS);
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            spr_rom_addr <= 0;
            bmap_x <= 0;
            cnt_x <= 0;
            pix <= 0;
            drawing <= 0;
        end else begin
            if (line) begin
                state <= REG_POS;
                pix <= 0;
                drawing <= 0;
            end else begin
                case (state)
                    REG_POS: begin
                        state <= ACTIVE;
                        sprx_r <= sprx;
                        spry_r <= spry;
                    end
                    ACTIVE: state <= spr_active ? WAIT_POS : IDLE;
                    WAIT_POS: begin
                        if (spr_begin) begin
                            state <= SPR_LINE;
                            spr_rom_addr <= spr_diff * SPR_WIDTH + (sx - sprx_r) + SX_OFFS;
                            bmap_x <= 0;
                            cnt_x <= 0;
                        end
                    end
                    SPR_LINE: begin
                        if (line_end) state <= WAIT_DATA;
                        pix <= spr_rom_data;
                        drawing <= 1;
                        if (SPR_SCALE == 0 || cnt_x == (2**SPR_SCALE-1)) begin
                            if (spr_end) state <= WAIT_DATA;
                            spr_rom_addr <= spr_rom_addr + 1;
                            bmap_x <= bmap_x + 1;
                            cnt_x <= 0;
                        end else begin
                            cnt_x <= cnt_x + 1;
                        end
                    end
                    WAIT_DATA: begin
                        state <= IDLE;
                        pix <= 0;
                        drawing <= 0;
                    end
                    default: state <= IDLE;
                endcase
            end
        end
    end

endmodule


