`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/29 09:23:54
// Design Name: 
// Module Name: my_security
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


module my_security(
    input RST, CLK,
    input [1:0] KEY,
    input DOOR, WINDOW,
    output reg ALARM_SIREN,
    output reg CA,
    output [6:0] AN
    );
parameter CLK_FREQ = 125_000_000/100;    
localparam [1:0] disarmed = 2'b00,
                armed = 2'b01,
                wait_delay = 2'b10,
                alarm = 2'b11;
reg [1:0] curr_state, next_state;
reg [20:0] cnt;
reg        tick; // 10 ms Toggle
reg  [8:0] cnt_5sec;
reg         start_cnt;
wire        cnt_done;
wire    [1:0] sensor;
reg  [1:0]   state;
wire [3:0] digit;
initial CA = 1'b0;

assign digit[3:1] = 3'd0;
assign digit[0] = CA ? state[1] : state[0];

assign sensor = {DOOR, WINDOW};

always @(posedge CLK)
    if(RST)
        curr_state <= disarmed;
    else
        curr_state <= next_state;
/// curr_state end

always @(curr_state, sensor, KEY,cnt_done)
begin
    ALARM_SIREN = 1'b0;
    start_cnt = 1'b0;
    
    case (curr_state)
        disarmed : begin
            if(KEY == 2'b11)
                next_state = armed;
            else
                next_state = disarmed;
            state = 2'b00;   
            end                         
        armed : begin
            if(|sensor)
                next_state = wait_delay;
            else if(KEY == 2'b00) // if 조건문 우선순위로 조건 간단화
                next_state = disarmed;
            else
                next_state = armed;                
            state = 2'b01;
        end            
        wait_delay : begin
            if(cnt_done)
                next_state = alarm;
            else if(KEY == 2'b00) // if 조건문 우선순위로 조건 간단화
                next_state = disarmed;
            else
                next_state = wait_delay;
            start_cnt = 1'b1; //
            state = 2'b10;
        end            
        alarm : begin
            if(KEY == 2'b00)
                next_state = disarmed;
            else
                next_state = alarm;
            ALARM_SIREN = 1'b1; //
            state = 2'b11;
        end            
        default : next_state = disarmed;
    endcase                                            
end // always                                

// tick cnt
always @(posedge CLK)
    if(RST) begin
        cnt <= 21'd0;
        tick <= 1'b0;
    end else begin
        if (cnt == (CLK_FREQ -1)) begin
            cnt <= 21'd0;
            tick <= 1'b1;
        end else begin
            cnt <= cnt + 1;
            tick <= 1'b0;
        end            
    end // tick cnt if(RST)

// 5sec cnt
always @(posedge CLK)
    if(RST || (start_cnt == 1'b0))
        cnt_5sec <= 9'd0;
    else if(start_cnt && tick)
        cnt_5sec <= cnt_5sec + 1;

assign cnt_done = (cnt_5sec == 499) ? 1'b1 : 1'b0;    

// CA gen
always @(posedge CLK)
    if (tick)
        CA <= ~CA;                                          

disp_mod disp_inf ( .DIGIT(digit), .AN(AN));
                                                        
endmodule

