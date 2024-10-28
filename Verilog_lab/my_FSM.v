`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/28 10:32:11
// Design Name: 
// Module Name: my_FSM
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
// Moore FSM Machine 
module my_FSM(
    input CLK,
    input RST,
    input [1:0] SW, // Din 
    // output reg [1:0] LED // Dout
    output [6:0] AN,
    output CA
    );
    
    // State Definition by using Localparam 
    localparam [1:0] // #State : 4 > 2-bit
        idle    = 2'b00,
        state_A = 2'b01,
        state_B = 2'b10,
        state_C = 2'b11;  
        /* // Gray Code
        idle    = 2'b00,
        state_A = 2'b01,
        state_B = 2'b11,
        state_C = 2'b10;      
        */
    reg [1:0] current_state, next_state;
    // reg [1:0] state;
    
    reg [31:0] CNT;
    reg enable; // 10 ms 주기 (7-Segment Digit 위치변경)

    wire [3:0] disp_data;
    
    assign CA = enable;

    // assign disp_data = BTN ? digit1 : digit0;        
    assign disp_data = enable ? { 3'b0, current_state[1] } : { 3'b0, current_state[0] }; // disp_data : 4-bit
    // current_state : 2'b00, 2'b01, 2'b10, 2'b11 > 2'b[digit1][digit0]
    my_disp U0 ( .SW( disp_data ), .AN(AN) ); // Input : disp_data (4-bit; 0~9), Output : AN (7-bit; A~G) 
 
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
        if (RST)    current_state <= idle;
        else        current_state <= next_state;                
    end // always @(posedge CLK)
     
    // 각 Current_state에서 외부 Input(SW)에 따른 State Transition 조건 및 Output (LED)
    always @(current_state, SW)
    begin
        case (current_state)
        idle : // 2'b00
            // State Transition 조건
            begin
                if (SW == 2'b01)        next_state = state_A; // 조건 만족 시에만 State Change
                // else if (SW == 2'b10)   next_state = state_C; // 이전 상태로 돌아가기 (Gray_code)
                else                    next_state = idle; // else문 생략 시 Latch 생성
            // State Output (Event)  
                // LED = 2'b00; //  
                // state = 2'b00;           
            end
        state_A : // 2'b01
            begin
                if (SW == 2'b10)        next_state = state_B;
                // else if (SW == 2'b00)   next_state = idle; // 이전 상태로 돌아가기 (Gray_code) 
                else                    next_state = state_A;
                
                // LED = 2'b01;
                // state = 2'b01;
            end
        state_B : // 2'b10 (2'b11)
            begin
                if (SW == 2'b11)        next_state = state_C;
                // else if (SW == 2'b01)   next_state = state_A; // 이전 상태로 돌아가기 (Gray_code) 
                else                    next_state = state_B;
                
                // LED = 2'b10;
                // state = 2'b10;
            end        
        state_C : // 2'b11 (2'b10)
            begin
                if (SW == 2'b00)        next_state = idle;
                // else if (SW == 2'b11)   next_state = state_B; // 이전 상태로 돌아가기 (Gray_code) 
                else                    next_state = state_C;
                
                // LED = 2'b11;
                // state = 2'b11;
            end 
        default : next_state = idle;                       
        endcase             
    end // always @(current_state, SW)

endmodule
