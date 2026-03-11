`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Delhi
// Engineer: Naman Jain
// 
// Create Date: 09/24/2025 07:45:32 PM
// Design Name: 
// Module Name: Display_sprite
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


module Display_sprite #(
        // Size of signal to store  horizontal and vertical pixel coordinate
        parameter pixel_counter_width = 10,
        parameter OFFSET_BG_X = 200,
        parameter OFFSET_BG_Y = 150
    )
    (
        input clk,
        input BTNL,BTNR,BTNC,
        output HS, VS,
        output [11:0] vgaRGB
        
    );
    
    localparam bg1_width = 160;
    localparam bg1_height = 240;
    
    localparam main_car_width = 14;
    localparam main_car_height = 16;
    
    
    wire pixel_clock;
    wire [3:0] vgaRed, vgaGreen, vgaBlue;
    wire [pixel_counter_width-1:0] hor_pix, ver_pix;
    reg [11:0] output_color;
    reg [11:0] next_color;
    reg [15:0] bg_rom_addr;
    wire [11:0] bg_color;
    reg [7:0] car_rom_addr;
    wire [11:0] car_color;
    wire [11:0] rival_color;
    reg[7:0] rival_rom_addr;
    
    reg bg_on, car_on,rival_on;
    wire [pixel_counter_width-1:0] car_x, car_y;
    
    //Main display driver 
    VGA_driver #(
        .WIDTH(pixel_counter_width)
    )   display_driver (
        //DO NOT CHANGE, clock from basys 3 board
        .clk(clk),
        .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue),
        //DO NOT CHANGE, VGA signal to basys 3 board
        .HS(HS),
        .VS(VS),
        .vgaRGB(vgaRGB),
        //Output pixel clocks
        .pixel_clock(pixel_clock),
        //Horizontal and Vertical pixel coordinates
        .hor_pix(hor_pix),
        .ver_pix(ver_pix)
    );
    
    bg_rom bg1_rom (
        .clka(clk),
        .addra(bg_rom_addr),
        .douta(bg_color)
        
    );
    
    main_car_rom car1_rom (
        .clka(clk),
        .addra(car_rom_addr),
        .douta(car_color)
    );
    
    rival_car_rom rival1_rom (
          .clka(clk),
        .addra(rival_rom_addr),
        .douta(rival_color)
    );
    
        wire collide;
    
     wire [pixel_counter_width-1:0]rival_x,rival_y;
    
    rival_car_ctrl rival_car(
            .rival_x(rival_x),
            .rival_y(rival_y),
            .clk(clk),
            .collide(collide),
            .BTNC(BTNC)
            
            );
    
    car_fsm car_fsm_inst(
            .clk(clk),
            .rival_x(rival_x),
            .rival_y(rival_y),
            .BTNC(BTNC),
            .BTNL(BTNL),
            .BTNR(BTNR),
            .car_x(car_x),
            .car_y(car_y),
            .collide(collide)
            );
    
    reg[9:0] bg_offset_y;
    
    reg[20:0] counter;
    parameter integer delay=500000;
    
    
    always@(posedge clk)begin
    
        if(!collide)begin
        if (counter==delay)begin
            counter<=0;
            bg_offset_y<=bg_offset_y+1;
            end
         else begin
            counter<=counter+1;
            end
        end
    end

    always @ (posedge clk) begin : CAR_LOCATION
        if (hor_pix >= car_x && hor_pix < (car_x + main_car_width) && ver_pix >= car_y && ver_pix < (car_y + main_car_height)) begin
            car_rom_addr <= (hor_pix - car_x) + (ver_pix - car_y)*main_car_width;
            car_on <= 1;
        end
        else begin
            car_on <= 0;
        end
    end
    
   
    
    always @ (posedge clk) begin : RIVAL_CAR_LOCATION
        if (hor_pix >= rival_x && hor_pix < (rival_x + main_car_width) && ver_pix >= rival_y && ver_pix < (rival_y + main_car_height)) begin
            rival_rom_addr <= (hor_pix - rival_x) + (ver_pix - rival_y)*main_car_width;
            rival_on <= 1;
        end
        else begin
            rival_on <= 0;
        end
    end
    
    
    always @ (posedge clk) begin : BG_LOCATION
        if (hor_pix >= 0 + OFFSET_BG_X && hor_pix < bg1_width + OFFSET_BG_X && ver_pix >= 0 + OFFSET_BG_Y && ver_pix < bg1_height + OFFSET_BG_Y) begin
            bg_rom_addr <= (hor_pix - OFFSET_BG_X) + (ver_pix - OFFSET_BG_Y)*bg1_width;
            bg_rom_addr<= (hor_pix - OFFSET_BG_X) + ((ver_pix - OFFSET_BG_Y-bg_offset_y)%bg1_height)*bg1_width;
            bg_on <= 1;
        end
        else
            bg_on <= 0;
    end
    
    always @ (posedge clk) begin : MUX_VGA_OUTPUT
        if (car_on) begin
        if(car_color==12'b101000001010)begin
            next_color<=bg_color;
           end
          else begin
            next_color <= car_color;
        end
        end
        else if (rival_on) begin
        if(rival_color==12'b101000001010)begin
            next_color<=bg_color;
           end
          else begin
            next_color <= rival_color;
        end
        end
        else if (bg_on) begin
            next_color <= bg_color;
        end
        else
            next_color <= 0;
    end
    
    always @ (posedge pixel_clock) begin
    
         output_color<=next_color;
        
    end
    
    assign vgaRed = output_color[11:8];
    assign vgaGreen = output_color[7:4];
    assign vgaBlue = output_color[3:0];
    
    
endmodule