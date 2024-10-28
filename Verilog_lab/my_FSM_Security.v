`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/28 16:10:07
// Design Name: 
// Module Name: my_FSM_Security
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


module my_FSM_Security(
    input [1:0] KEY,
    input [1:0] SENSOR,
    input CLK, RST,
    output ALARM, // LED0_RED
    output [6:0] AN,
    output CA
    );
 
    parameter CLK_FREQ = 125_000_000;
    // State Definition by using Localparam 
    localparam [1:0] // #State : 4 > 2-bit
        disarmed    = 2'b00,
        armed       = 2'b01,
        wait_delay  = 2'b10,
        alarm       = 2'b11;     
    // key 11 잠금, 00 gowp 
    // 7-Segment 출력 위한 10 ms tick 신호 필요
    // wait_delay state 5초 시간 측정 필요  
    reg [1:0] current_state, next_state;
        
    reg count_done;
    reg start_count;
      
    reg [31:0] CNT_Segment; //  
    reg [31:0] CNT_wait_delay; // wait_delay State 시간 Count
    
    reg enable;
    
    // Generate Enable Signal (20 ms Toggle)
    initial CNT = 32'b0;
    initial enable = 1'b0;
    always @(posedge CLK)
    begin
        if ( RST == 1'b1 )    
        begin
            CNT <= 32'b0;
            enable <= 1'b0;  
        end    
        else // RST == 1'b0
        begin                       
            if ( CNT == 1_250_000 ) // 20 ms = 8 ns (125 MHz) * 2_500_000 // 10 ms = 8 ns (125 MHz) * 1_250_000
            begin  
                CNT <= 32'b0;
                enable <= ~enable;
            end  
            else
                CNT <= CNT + 1;              
        end // else  
    end // always @(posedge CLK)    
    
    
    // Initialization - Start State 
    always @(posedge CLK)
    begin
        if (RST)    current_state <= disarmed;
        else        current_state <= next_state;                
    end // always @(posedge CLK)


     // 각 Current_state에서 외부 Input(SW)에 따른 State Transition 조건 및 Output (LED)
    always @(current_state, KEY, SENSOR, count_done)
    begin
        case (current_state)
        disarmed : // 2'b00
            // State Transition 조건
            begin
                if ( KEY == 2'b11 ) next_state = armed;  
                else                next_state = disarmed;  
            // State Output (Event)  
                ALARM = 1'b0; //  
                start_count = 1'b0;
                state = 2'b00;           
            end
        armed : // 2'b01   
            begin
                if ( SENSOR != 2'b00 ) 
                    next_state = wait_delay;  
                else if ( ( KEY == 2'b00 ) && ( SENSOR == 2'b00 ) ) 
                    next_state = disarmed;
                else                
                    next_state = armed;  
            // State Output (Event)  
                ALARM = 1'b0; //  
                start_count = 1'b0;
                state = 2'b01;           
            end     
        wait_delay : // 2'b10   
            begin
                if ( ( KEY == 2'b00 ) && ( count_done == 1'b0 ) ) 
                    next_state = disarmed;  
                else if ( count_done == 1'b1 ) 
                    next_state = alarmed;
                else                
                    next_state = wait_delay;  
            // State Output (Event)  
                ALARM = 1'b0; //  
                start_count = 1'b1;
                state = 2'b10;           
            end                           
        alarm: // 2'b11   
            begin
                if ( KEY == 2'b00 ) next_state = disarmed;  
                else                next_state = alarm;  
            // State Output (Event)  
                ALARM = 1'b1; //  
                start_count = 1'b0;
                state = 2'b11;           
            end
        default : next_state = disarmed;    
        endcase              
    end    
            
    always @(posedge CLK)
    begin
        if ( start_count == 1'b1 ) 
                     
            
            
endmodule
