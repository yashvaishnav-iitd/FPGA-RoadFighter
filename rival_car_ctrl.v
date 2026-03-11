`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 04:06:57 PM
// Design Name: 
// Module Name: rival_car_ctrl
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

module rival_car_ctrl #(
    parameter [7:0] LFSR_SEED = 8'b01101101 
)(
    input wire collide,
    input wire BTNC,
    input wire clk,
    output reg [9:0] rival_x,
    output reg [9:0] rival_y
);

    // Road and sprite dimensions (adjust if needed)
    localparam RIVAL_CAR_WIDTH     = 14;
    localparam RIVAL_CAR_HEIGHT    = 16;
    localparam ROAD_LEFT           = 244;
    localparam ROAD_RIGHT          = 318;
    localparam ROAD_TOP            = 150;
    localparam ROAD_BOTTOM         = 390;
    localparam integer FRAME_DELAY         = 2000000;   // Number of frames per vertical step

    // LFSR for random horizontal spawn
    reg lfsr_reset;
    wire [7:0] rand;
    lfsr8 #(.SEED(LFSR_SEED)) RNG (
        .clk(clk),
        .reset(lfsr_reset),
        .rand(rand)
    );

    reg [20:0] frame_count;
    reg reset;
    wire respawn;
    assign respawn = rival_y + RIVAL_CAR_HEIGHT >= ROAD_BOTTOM;
    
    

    always @(posedge clk ) begin
        if (reset==0 || BTNC) begin
            lfsr_reset  <= 1'b1;
            frame_count <= 0;
           
            rival_y     <= ROAD_TOP;
            rival_x     <= ROAD_LEFT + (rand % (ROAD_RIGHT - ROAD_LEFT - RIVAL_CAR_WIDTH));
            reset<=1;
           
        end
        else if (collide) begin
            rival_x<=rival_x;
            rival_y<=rival_y;
         end   else begin
            lfsr_reset <= 1'b0;
            if (respawn) begin
                // Respawn rival car at a new random x-position
                
                lfsr_reset  <= 1'b1;
                rival_y     <= ROAD_TOP;
                rival_x     <= ROAD_LEFT + (rand % (ROAD_RIGHT - ROAD_LEFT - RIVAL_CAR_WIDTH));
                frame_count <= 0;
            end else  begin
                if (frame_count >= FRAME_DELAY - 1) begin
                    frame_count <= 0;
                    rival_y <= rival_y + 1;
                end else begin
                    frame_count <= frame_count + 1;
                end
            end
        end
    end

endmodule