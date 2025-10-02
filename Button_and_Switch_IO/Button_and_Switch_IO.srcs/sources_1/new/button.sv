`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Self
// Engineer: Tushar Prasanna Swaminathan
// 
// Create Date: 09/30/2025 04:27:16 PM
// Design Name: Button Debounce and LED Control
// Module Name: button
// Project Name: ARTY S7-50 Button and Switch IO
// Target Devices: ARTY S7-50
// Tool Versions: Vivado 2024.1
// Description: This module debounces a button input and 
//              controls LED patterns based on button presses.
// 
// Dependencies: -
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module button #(
    parameter integer CLK_HZ      = 12_000_000,
    parameter integer DEBOUNCE_MS = 10
)(
    input         CLK12MHZ,
    input         ck_rst,
    input  [3:0]  btn,
    output [3:0]  led
);
    // Clock
    wire clk = CLK12MHZ;
    wire rst = ~ck_rst; // active high reset
    // ----------------------------
    // 1) Synchronize BTN0 (use others later)
    // ----------------------------
    reg [1:0] btn_sync = 2'b00;
    always @(posedge clk) begin
        if (rst)
            btn_sync <= 2'b00;
        else
            btn_sync <= {btn_sync[0], btn[0]};
    end
    wire btn_clean = btn_sync[1];

    // ----------------------------
    // 2) Debounce (~DEBOUNCE_MS)
    // cycles = CLK_HZ * (ms/1000)
    // ----------------------------
    localparam integer DB_MAX = (CLK_HZ/1000) * DEBOUNCE_MS - 1; // ~120_000 for 12MHz, 10ms
    localparam integer DB_W   = (DB_MAX < 2) ? 1 : $clog2(DB_MAX+1);

    reg [DB_W-1:0] debounce_cnt = {DB_W{1'b0}};
    reg            btn_debounced = 1'b0;

    always @(posedge clk) begin
        if (rst) begin
            debounce_cnt  <= {DB_W{1'b0}};
            btn_debounced <= 1'b0;
        end else if (btn_clean == btn_debounced) begin
            debounce_cnt <= {DB_W{1'b0}};
        end else begin
            if (debounce_cnt == DB_MAX[DB_W-1:0]) begin
                btn_debounced <= btn_clean;
                debounce_cnt  <= {DB_W{1'b0}};
            end else begin
                debounce_cnt <= debounce_cnt + 1'b1;
            end
        end
    end

    // -----------------------------------------------------------------------
    // Checking if the btn_debounced is being pressed for more than 2 seconds.
    // -----------------------------------------------------------------------
    localparam integer LONG_PRESS_MAX = (CLK_HZ) * 2 - 1; // ~24_000_000 for 12MHz, 2s
    localparam integer LONG_PRESS_W   = (LONG_PRESS_MAX < 2) ? 1 : $clog2(LONG_PRESS_MAX+1);
    reg [LONG_PRESS_W-1:0] long_press_cnt = {LONG_PRESS_W{1'b0}};
    reg long_pressed = 1'b0;
    always @(posedge clk) begin
        if (rst) begin
            long_press_cnt <= {LONG_PRESS_W{1'b0}};
            long_pressed   <= 1'b0;
        end else if (!btn_debounced) begin
            long_press_cnt <= {LONG_PRESS_W{1'b0}};
            long_pressed   <= 1'b0;
        end else if (btn_debounced) begin
            if (long_press_cnt == LONG_PRESS_MAX[LONG_PRESS_W-1:0]) begin
                long_pressed <= 1'b1;
            end else begin
                long_press_cnt <= long_press_cnt + 1'b1;
            end
        end
    end

    // ----------------------------
    // 3) Rising edge detect (debounced)
    // ----------------------------
    reg btn_prev = 1'b0;
    always @(posedge clk) begin
        if (rst)
            btn_prev <= 1'b0;
        else
            btn_prev <= btn_debounced;
    end
    wire btn_rise = btn_debounced & ~btn_prev;

    // ----------------------------
    // 4) State machine (4 patterns)
    // ----------------------------
    reg [1:0] state = 2'd0;
    always @(posedge clk) begin
        if (rst)
            state <= 2'd0;
        else if (btn_rise)
            state <= state + 2'd1;
    end

    // ----------------------------
    // 5) Slow counter for animation
    // ----------------------------
    reg [22:0] slow = 23'd0; // ~1.4Hz at 12MHz when using slow[22:20]
    always @(posedge clk) begin
        if (rst)
            slow <= 23'd0;
        else
            slow <= slow + 1'b1;
    end

    // ----------------------------
    // 6) LED patterns
    // ----------------------------
    reg [3:0] leds = 4'b0001;
    always @* begin
        if (long_pressed) begin
            leds = 4'b0001 << slow[22:21]; 
        end else begin
            case (state)
                2'b00: leds = 4'b0000;                                // one LED
                2'b01: leds = 4'b1010;                                // alternate
                2'b10: leds = 4'b0101;                                // Different alternate
                2'b11: leds = 4'b1111;                                // running pattern (rotates)
                default: leds = 4'b0000;
            endcase
        end
    end

    assign led = leds;

endmodule


