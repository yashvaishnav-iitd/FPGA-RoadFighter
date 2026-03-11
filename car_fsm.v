`timescale 1ns / 1ps

module car_fsm(
    input wire clk,
    input wire rival_x,
    input wire rival_y,
    input wire BTNL,
    input wire BTNR,
    input wire BTNC,      // center (restart)
    output reg [9:0] car_x,
    output reg [9:0] car_y,
    output reg collide
    
);

debouncer btnc_deb(
    .clk(clk),
    .btn_in(BTNC),
    .btn_out(btnc)
    );
debouncer btnl_deb(
    .clk(clk),
    .btn_in(BTNL),
    .btn_out(btnl)
    );
debouncer btnr_deb(
    .clk(clk),
    .btn_in(BTNR),
    .btn_out(btnr)
    );
    

    // Car/road parameters
    localparam CAR_INIT_X    = 270;
    localparam CAR_INIT_Y    = 300;
    localparam X_LEFT_BOUND  = 244;
    localparam X_RIGHT_BOUND = 304;
    localparam RIVAL_CAR_WIDTH     = 14;
    localparam RIVAL_CAR_HEIGHT    = 16;
    localparam MAIN_CAR_WIDTH     = 14;
    localparam MAIN_CAR_HEIGHT    = 16;

 
       localparam START    = 3'd0;
       localparam IDLE     = 3'd1;
       localparam LEFTCAR  = 3'd2;
       localparam RIGHTCAR = 3'd3;
       localparam COLLIDE  = 3'd4;
        reg[2:0] current_state, next_state;

        localparam STEP = 2;
    
        reg rst;
      


wire cars_collide ;

assign cars_collide=
    (car_x <= rival_x + RIVAL_CAR_WIDTH) &&
    (car_x + MAIN_CAR_WIDTH >= rival_x)  &&
    (car_y <= rival_y + RIVAL_CAR_HEIGHT) &&
    (car_y + MAIN_CAR_HEIGHT >= rival_y);
  

        
        
    always @(posedge clk ) begin
        if (rst==0) begin
            car_x <= CAR_INIT_X;
            car_y <= CAR_INIT_Y;
            current_state <= START;
            rst<=1;
        end 
        
        
        else begin
            current_state <= next_state;
            case (current_state)
                START: begin
                    car_x <= CAR_INIT_X;
                    car_y <= CAR_INIT_Y;
                    collide<=0;
                   
                end
                LEFTCAR: begin
                    if (car_x > X_LEFT_BOUND && !cars_collide)
                        car_x <= car_x - STEP;
                end
                RIGHTCAR: begin
                    if (car_x < X_RIGHT_BOUND && !cars_collide)
                        car_x <= car_x + STEP;
                end
                COLLIDE:begin
                    car_x<=car_x;
                    collide<=1;
                    end
                IDLE: begin
                    car_x <= car_x;
                    end
            endcase
        end
        end
    

    always @(*) begin
        next_state = current_state;
        case (current_state)
            START:     next_state = IDLE;
            IDLE:      if (cars_collide) next_state=COLLIDE;
                        else if (btnl) next_state = LEFTCAR;
                       else if (btnr) next_state = RIGHTCAR;
                       else if (btnc) next_state = START;
                       
            LEFTCAR:
                 if (car_x <= X_LEFT_BOUND || cars_collide) next_state = COLLIDE;
                  else if (btnl)   next_state = LEFTCAR;
                     else             next_state = IDLE;
            
        RIGHTCAR:
    if (car_x >= X_RIGHT_BOUND || cars_collide) next_state = COLLIDE;
    else if (btnr)   next_state = RIGHTCAR;
    else             next_state = IDLE;
            COLLIDE:   if (btnc)
                    next_state = START;
                    
        endcase
    end
endmodule