`default_nettype none
`timescale 1ns / 1ps

// Tiny Tapeout compliant: hardcoded CLUT for cat sprite

module clut_cat (
    input  wire [3:0] index,      // 4-bit color index from rom_sprite_cat
    output reg  [11:0] colr_out   // 12-bit RGB color output
);

    always @(*) begin
        case (index)
            4'h0: colr_out = 12'hF80; // Orange (body)
            4'h1: colr_out = 12'hFC7; // Light Orange (highlights)
            4'h2: colr_out = 12'hFFF; // White (eyes, chest)
            4'h3: colr_out = 12'hFBE; // Cream (details)
            4'h4: colr_out = 12'hF6D; // Light Greenish (background)
            4'h5: colr_out = 12'h000; // Black (outlines)
            4'h6: colr_out = 12'h06B; // Deep Blue (transparent / base)
            4'h7: colr_out = 12'h000; // unused
            4'h8: colr_out = 12'h000; // unused
            4'h9: colr_out = 12'h000; // unused
            4'hA: colr_out = 12'h000; // unused
            4'hB: colr_out = 12'h000; // unused
            4'hC: colr_out = 12'h000; // unused
            4'hD: colr_out = 12'h000; // unused
            4'hE: colr_out = 12'h000; // unused
            4'hF: colr_out = 12'h000; // unused
            default: colr_out = 12'h000; // Safety fallback
        endcase
    end

endmodule

