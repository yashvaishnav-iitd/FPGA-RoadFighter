`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 04:05:13 PM
// Design Name: 
// Module Name: lfsr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lfsr8 #(
    parameter [7:0] SEED = 8'b00101101  
) (
    input clk,
    input reset,
    output reg [7:0] rand
);
    reg [7:0] lfsr_reg;
    always @(posedge clk or posedge reset) begin
        if (reset)
            lfsr_reg <= SEED;
        else
            // taps: 8,6,5,4 (x^8 + x^6 + x^5 + x^4 + 1)
            lfsr_reg <= {lfsr_reg[6:0], lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3]};
    end
    always @* rand = lfsr_reg;
endmodule