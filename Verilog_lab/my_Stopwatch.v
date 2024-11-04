`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/04 16:10:22
// Design Name: 
// Module Name: my_Stopwatch
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


module my_Stopwatch(
    input CLK, RST, BTN0,
    output [6:0] AN,
    output CA
    );
 
    parameter CLK_FREQ = 125_000_000; // Use 125 MHz SYSCLK    
    
    // State Definition by using Localparam 
    localparam [1:0] // #State : 4 > 2-bit
        CLEAR   = 2'b00, // CLR ��ȣ �߻� ��
        START   = 2'b01,
        STOP    = 2'b10;    

    // FSM Current & Next State
    reg [1:0] current_state; 
    reg [1:0] next_state; 
    
    reg [31:0] CNT_1s;
    
    reg start_count;
    reg CLR;

    
    always @(posedge CLK)
    begin
        if ( current_state == CLEAR )    
        begin
            CNT_1s <= 32'b0;  
        end    
        else // RST == 1'b0
        begin                       
            if ( CNT_Seg > ( (CLK_FREQ-1)/100 ) ) // (CLK_FREQ - 1) / 100 for 10ms Toggle
            begin  
                CNT_Seg <= 32'b0; Pos_Sel <= ~Pos_Sel;
            else CNT_Seg <= CNT_Seg + 1'b1;                  	          	       
        end // else          	
	end // always @(posedge CLK)      
    
    
    
    always @(posedge CLK)
    begin
        if ( ( current_state != CLEAR  ) && ( start_count == 1'b1 ) )    
    end
    
      
    // Initialization - Start State 
    always @(posedge CLK)
    begin
        if ( CLR == 1'b1 )  current_state <= CLEAR;
        else                current_state <= next_state;                
    end // always @(posedge CLK)    

     // �� Current_state���� �ܺ� Input(BUT)�� ���� State Transition ���� �� Output
    always @(current_state, BTN0, CLR)
    begin
        start_count = 1'b0;
        case (current_state)
        CLEAR : // 2'b00
            // State Transition ����
            begin
                if ( BTN0 == 1'b1 ) next_state = START;  
                else                next_state = CLEAR;  
            // State Output (Event)
            // �ð� ��� - 00�� or 0��                 
   
            end
        START : // 2'b01
            begin
                if ( BTN0 == 1'b1 )     next_state = STOP; 
                else if ( CLR == 1'b1 ) next_state = CLEAR;
                else                    next_state = START;
            // State Output (Event)
            // �ð� ��� - ��ȭ�ϴ� �ð�   
                 
                start_count = 1'b1; // �ð� ���� ����                               
            end 
        STOP : // 2'b10     
            begin
                if ( BTN0 == 1'b1 )     next_state = START; 
                else if ( CLR == 1'b1 ) next_state = CLEAR;
                else                    next_state = STOP;
            // State Output (Event)
            // �ð� ��� - ���� �ð�   
                // start_count = 1'b0; // �ð� ����                                            
            end                               
        default : next_state = CLEAR;    
        endcase              
    end 
    
endmodule
