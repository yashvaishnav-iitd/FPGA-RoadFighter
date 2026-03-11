`timescale 1ns / 1ps

module debouncer(
    input clk,        // 100 MHz main clock from Basys 3
    input btn_in,     // Direct input from button pin
    output reg btn_out // Debounced, one-clock-wide pulse on button press
);
    // Adjust this parameter if you want the debounce window longer or shorter
    parameter integer DELAY = 2_500_000; // 25 ms at 100MHz

    reg [21:0] count = 0;
    reg btn_in_sync_0 = 0, btn_in_sync_1 = 0;
    reg btn_state = 0;

    // 2-stage sync for metastability
    always @(posedge clk) begin
        btn_in_sync_0 <= btn_in;
        btn_in_sync_1 <= btn_in_sync_0;
    end

    // Debounce finite state machine
    always @(posedge clk) begin
        if (btn_state == btn_in_sync_1) begin
            count <= 0;
            btn_out <= 0;
            btn_state<=0;
        end else begin
            count <= count + 1;
            if (count >= DELAY) begin
                btn_state <= btn_in_sync_1;
                btn_out <= btn_in_sync_1; // output a single-cycle pulse on new button level
                count <= 0;
            end
        end
    end
endmodule