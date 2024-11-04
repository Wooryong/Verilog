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
    (* MARK_DEBUG = "true" *)
    input [1:0] KEY,
    input DOOR, WINDOW, // input [1:0] SENSOR,
    input CLK, RST,
    output reg ALARM, // LED0_RED
    output [6:0] AN,
    output CA 
    //output [3:0] TEST_PIN //
    );
 
    parameter CLK_FREQ = 125_000_000; // 125 MHz CLK
    /*
    assign TEST_PIN = { ALARM, count_done, start_count, CA }; 
    // Waveform Meas. - from SPI Pins 
    // CK_MISO (#1) - 
    // CK_SCK (#3) - 
    // CK_SS (#5) - 
    // CK_MOSI (#6) - 
    */
      
    // State Definition by using Localparam 
    localparam [1:0] // #State : 4 > 2-bit
        alarm       = 2'b00,
        disarmed    = 2'b01,
        armed       = 2'b10,
        wait_delay  = 2'b11;
                    
    // kEY : 11 = 잠금, 00 = 해제
    // 7-Segment 출력 위한 10 ms tick 신호 필요
    // wait_delay state 5초 시간 측정 필요  
    
    (* MARK_DEBUG = "true" *)
    reg [1:0] current_state; 
    reg [1:0] next_state; // FSM Current & Next States
    reg [1:0] state; // for 7-Segment 
    
    (* MARK_DEBUG = "true" *)
    wire [1:0] SENSOR;  
    assign SENSOR = { DOOR , WINDOW };   
    
    (* MARK_DEBUG = "true" *)
    reg start_count;
    (* MARK_DEBUG = "true" *)
    wire count_done; // reg count_done;
    
    (* MARK_DEBUG = "true" *)          
    reg [31:0] CNT_Seg; // 10 ms 간격 Toggle 
    (* MARK_DEBUG = "true" *) 
    reg [31:0] CNT_Wait; // Delay Check for 5s 
    
	// State Representation by 7-Segment  
	wire [3:0] Dig2Seg; // 7-Segment에 표시될 Digit 
	reg Pos_Sel; // 7-Segment에 표시되는 위치 - 잔상효과 이용 (10 ms 간격 Toggle)
	   	
	assign CA = Pos_Sel;
	assign Dig2Seg = Pos_Sel ? { 3'b0, state[1] } : { 3'b0, state[0] }; // Dig2Seg : 4-bit

	my_disp U0 ( .SW( Dig2Seg ), .AN(AN) ); // Input : Dig2Seg (4-bit; 0~9), Output : AN (7-bit; A~G) 

	// Generate 7-Segment Position Select Signal (10 ms Toggle)
    always @(posedge CLK)
    begin
        if ( RST == 1'b1 )    
        begin
            CNT_Seg <= 32'b0; Pos_Sel <= 1'b0;  
        end    
        else // RST == 1'b0
        begin                       
            if ( CNT_Seg > ( (CLK_FREQ-1)/100 ) ) // (CLK_FREQ - 1) / 100 for 10ms Toggle
            begin  
                CNT_Seg <= 32'b0; Pos_Sel <= ~Pos_Sel;
                /* //Sim. 시 주석처리 
                if ( ( current_state == wait_delay ) && ( start_count == 1'b1 ) )
                begin
                    if ( CNT_Wait == 499 ) // 5 sec = 500 * (10 ms)
                    begin
                        CNT_Wait <= 32'b0; count_done <= 1'b1;
                    end                	   
                    else CNT_Wait <= CNT_Wait + 1'b1;                                        	   
                end
                else // current_state != wait_delay 
                begin
                    CNT_Wait <= 32'b0; count_done <= 1'b0;                	
                end                	   
                */ //Sim. 시 주석처리
            end // if ( CNT_Seg == ( (CLK_FREQ-1)/100 ) )  
            else CNT_Seg <= CNT_Seg + 1'b1;                  	          	       
        end // else          	
	end // always @(posedge CLK)  
             
	// Count Delay in wait_delay state
	// Counting Start from 0    
    always @(posedge CLK)
    begin 
        if ( ( RST == 1'b1 ) || ( start_count == 1'b0 ) )       CNT_Wait <= 32'b0;      	    
        else                                                    CNT_Wait <= CNT_Wait + 1'b1;
        // ( RST == 1'b0 ) && ( start_count == 1'b1 )      
    end     
    assign count_done = ( CNT_Wait == ( (5 * CLK_FREQ) - 1 ) ) ? 1'b1 : 1'b0;
			    
    // Initialization - Start State 
    always @(posedge CLK)
    begin
        if ( RST == 1'b1 )  current_state <= disarmed;
        else                current_state <= next_state;                
    end // always @(posedge CLK)

     // 각 Current_state에서 외부 Input(SW)에 따른 State Transition 조건 및 Output (ALARM, State)
    always @(current_state, KEY, SENSOR, count_done)
    begin
        ALARM = 1'b0; start_count = 1'b0;
        case (current_state)
        disarmed : // 2'b01
            // State Transition 조건
            begin
                if ( KEY == 2'b11 ) next_state = armed;  
                else                next_state = disarmed;  
            // State Output (Event)                  
                state = 2'b01; // FSM_State = 2'b01           
            end
        armed : // 2'b10   
            begin
                if ( SENSOR != 2'b00 )                              next_state = wait_delay;  
                else if ( ( KEY == 2'b00 ) && ( SENSOR == 2'b00 ) ) next_state = disarmed;
                else                                                next_state = armed;  
            // State Output (Event)  
                state = 2'b10; // FSM_State = 2'b10           
            end     
        wait_delay : // 2'b11   
            begin
                if ( ( KEY == 2'b00 ) && ( count_done == 1'b0 ) )   next_state = disarmed;  
                else if ( count_done == 1'b1 )                      next_state = alarm;
                else                                                next_state = wait_delay;  
            // State Output (Event)  
                start_count = 1'b1;
                state = 2'b11; //  FSM_State = 2'b11            
            end                           
        alarm: // 2'b00   
            begin
                if ( KEY == 2'b00 ) next_state = disarmed;  
                else                next_state = alarm;  
            // State Output (Event)  
                ALARM = 1'b1;
                state = 2'b00; //  FSM_State = 2'b00          
            end
        default : next_state = disarmed;    
        endcase              
    end    
           
endmodule
