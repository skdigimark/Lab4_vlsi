//====================================================
// EELE 4054: Digital VLSI Design
// Author: Senoga Kawesa
// Date: November 14, 2026
// Description: Lab 4 Pre-loaded Up/Down Counter with 7-Segment Display
//====================================================

module LAB4_Counter (
    input wire clk,          // 50 MHz system clock (MAX10_CLK1_50)
    input wire rst_n,        // Synchronous reset, active low (KEY[0])
    input wire ena,          // Synchronous enable (SW[0])
    input wire [5:0] pre_ld, // 6-bit pre-loaded value (SW[6:1])
    output wire [7:0] disp0, // 1st 7-segment display (Units)
    output wire [7:0] disp1  // 2nd 7-segment display (Tens)
);

    // 1. Synchronizer for rst_n and ena (preventing metastability)
    reg rst_n_sync1, rst_n_sync2;
    reg ena_sync1, ena_sync2;

    always @(posedge clk) begin
        rst_n_sync1 <= rst_n;
        rst_n_sync2 <= rst_n_sync1;
        ena_sync1 <= ena;
        ena_sync2 <= ena_sync1;
    end

    // 2. Clock Divider for 0.5-second refresh rate (50 MHz -> 2 Hz)
    // 50,000,000 cycles / 2 = 25,000,000 cycles for half-period
    reg [24:0] clk_div_cnt;
    reg tick_05s;

    always @(posedge clk or negedge rst_n_sync2) begin
        if (!rst_n_sync2) begin
            clk_div_cnt <= 25'd0;
            tick_05s <= 1'b0;
        end else if (clk_div_cnt == 25'd24999999) begin
            clk_div_cnt <= 25'd0;
            tick_05s <= ~tick_05s; // Toggle every 0.5s
        end else begin
            clk_div_cnt <= clk_div_cnt + 1'b1;
            tick_05s <= 1'b0;
        end
    end

    // Detect positive edge of tick_05s to update counter every 0.5s
    reg tick_d;
    wire tick_pulse;
    always @(posedge clk) begin
        tick_d <= tick_05s;
    end
    assign tick_pulse = tick_05s & ~tick_d;

    // 3. 6-bit Down Counter
    reg [5:0] count_val;

    always @(posedge clk or negedge rst_n_sync2) begin
        if (!rst_n_sync2) begin
            count_val <= pre_ld; // Reset to pre-loaded value
        end else if (ena_sync2 && tick_pulse) begin
            if (count_val == 6'd0)
                count_val <= pre_ld; // Loop back or stop at 0
            else
                count_val <= count_val - 1'b1;
        end
    end

    // 4. Binary-to-Decimal Conversion (Tens and Units)
    wire [3:0] tens;
    wire [3:0] units;

    assign tens = count_val / 10;
    assign units = count_val % 10;

    // 5. 7-Segment Decoder Function (Table 1 mapping)
    function [7:0] seg_decoder(input [3:0] digit);
        begin
            case (digit)
                4'd0: seg_decoder = 8'b11000000;
                4'd1: seg_decoder = 8'b11111001;
                4'd2: seg_decoder = 8'b10100100;
                4'd3: seg_decoder = 8'b10110000;
                4'd4: seg_decoder = 8'b10011001;
                4'd5: seg_decoder = 8'b10010010;
                4'd6: seg_decoder = 8'b10000010;
                4'd7: seg_decoder = 8'b11111000;
                4'd8: seg_decoder = 8'b10000000;
                4'd9: seg_decoder = 8'b10011000;
                default: seg_decoder = 8'b11111111; // Blank
            endcase
        end
    endfunction

    assign disp0 = seg_decoder(units);
    assign disp1 = seg_decoder(tens);

endmodule
