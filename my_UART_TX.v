`timescale 1ns / 1ps

module my_UART_TX(
    (* MARK_DEBUG="true" *)
    input RST, CLK, // RST - BTN0, CLK - SYSCLK
    (* MARK_DEBUG="true" *)
    input BTN1, // for State Transition
    input [3:0] SW, // Din = 0100_XXXX
    (* MARK_DEBUG="true" *)
    output Dout, // Dout
    output LED_IDLE, LED_START, LED_STOP, // LED Colors by State
    (* MARK_DEBUG="true" *) 
    output Busy // LED
    );
    
// State Representation by LED 
assign LED_IDLE = ( current_state == IDLE ); // LED0_R
assign LED_START = ( current_state == START ); // LED0_G
// assign LED_TX = ( current_state == TX ); // LED0_B
assign LED_STOP = ( current_state == STOP ); // LED0_B
  
// Parameters
parameter CLK_FREQ = 125_000_000; // Use 125 MHz SYSCLK    
parameter BAUD_RATE = 115_200; // Baud rate     
 
// Generate Bit_CLK 
// CLK_FREQ / BAUD_RATE = 125_000_000 / 115_200 ~ 1085 >> 11-bit
reg [10:0] CNT_BAUD; // 11-bit CNT
(* MARK_DEBUG="true" *)
reg Bit_CLK; // Baud Rate CLK
always @(posedge CLK)
begin  
    if ( RST == 1'b1 ) begin
        CNT_BAUD <= 11'b0; Bit_CLK <= 1'b0;   
    end 
    else // RST == 1'b0
    begin
        CNT_BAUD <= ( CNT_BAUD == ( (CLK_FREQ/BAUD_RATE) - 1) ) ? 11'b0 : CNT_BAUD + 1'b1;
        Bit_CLK <= ( CNT_BAUD == ( (CLK_FREQ/BAUD_RATE) - 1) ); // posedge
    end
end
              
wire [7:0] Din;
assign Din = { 4'b0100, SW }; // (64 + SW)
// ASCII Code : 'A' (65) 

// Generate Parity-bit (Even Parity Mode)
wire Parity;                  
assign Parity = (^Din); // 짝수개면 1'b0, 홀수개면 1'b1 
    
// De-bounce Code for BTN
reg BTN1_chk1, BTN1_chk2; 
(* MARK_DEBUG="true" *)
wire BTN1_press;	  	  	
always @(posedge CLK) 
begin  
        BTN1_chk1 <= BTN1;
        BTN1_chk2 <= BTN1_chk1;                            	
end 
assign BTN1_press = BTN1_chk1 & ~BTN1_chk2; 
//
  	
// Generate State Transition Signals 
// Ready : IDLE to START & TX_start : START to TX & Standby : STOP to IDLE
(* MARK_DEBUG="true" *)
reg Ready_en, TX_start_en, Standby_en;
(* MARK_DEBUG="true" *)
wire Ready, TX_start, Standby; 	
always @(posedge CLK) 
begin  
    if ( RST == 1'b1 ) begin
        Ready_en <= 1'b0; TX_start_en <= 1'b0; Standby_en <= 1'b0;        
    end 
    else // RST == 1'b0
    begin	
        if ( (current_state == IDLE) && (BTN1_press == 1'b1) )  Ready_en <= 1'b1;
        else if ( current_state == START )                      Ready_en <= 1'b0; 
        
        if ( (current_state == START) && (BTN1_press == 1'b1) ) TX_start_en <= 1'b1;
        else if ( current_state == TX )                         TX_start_en <= 1'b0;  
        
        if  ( (current_state == STOP) && (BTN1_press == 1'b1) ) Standby_en <= 1'b1;
        else if ( current_state == IDLE )                       Standby_en <= 1'b0;
    end
end 
                           
// Sync. to Bit_CLK         	
assign Ready = Ready_en & Bit_CLK;
assign TX_start = TX_start_en & Bit_CLK;
assign Standby = Standby_en & Bit_CLK;
//   
  	
// State Definition by using Localparam 
localparam [1:0] // #State : 4 > 2-bit
    IDLE    = 2'b00,  
    START   = 2'b01,
    TX      = 2'b10,    
    STOP    = 2'b11;         
        
// FSM Current & Next State
(* MARK_DEBUG="true" *)
reg [1:0] current_state, next_state; 
// 
 
(* MARK_DEBUG="true" *)
wire [10:0] SR; // Shift Register for 11-bit 
(* MARK_DEBUG="true" *)
reg [10:0] TX_data; // Temp. 
assign Dout = TX_data[0]; // Dout = LSB of SR

(* MARK_DEBUG="true" *) 
reg [3:0] CNT_TX;
(* MARK_DEBUG="true" *)
reg Send, TX_end;
(* MARK_DEBUG="true" *)   
reg Load, Shift;    
  
// 1 Data Frame (11-bit) : Stop bit - Parity bit - Data - Start bit   
assign SR = (RST == 1'b1) || (current_state == IDLE) ? 11'b0 :
            (Load == 1'b1) ? { 1'b1, Parity, Din, 1'b0 } : 11'b0;
                 
always @(posedge CLK)
begin
    // RST or IDLE state : Initialize 
    if ( (RST == 1'b1) || (current_state == IDLE) ) begin
        TX_data <= 11'b111_1111_1111;  
        CNT_TX <= 4'b0; TX_end <= 1'b0;  
    end 
       
    // START state : Data Parallel Load in Shift Register      
    else if ( (Load == 1'b1) && (TX_start == 1'b1) )
        TX_data <= SR; // State Transition : START > TX 
        
    // TX state : Data TX & Data Shift in Shift Register
    else if ( (Shift == 1'b1) && (Bit_CLK == 1'b1) ) begin 
        TX_data <= { 1'b1, TX_data[10:1] };           
            
        CNT_TX <= (CNT_TX == 10) ? 4'b0 : CNT_TX + 1'b1;
        TX_end <= (CNT_TX == 10);                                           
    end // else if ( Shift == 1'b1 )
end
    
// Generate Send, Busy Signals
always @(posedge CLK)
begin
    if ( (RST == 1'b1) || (current_state == IDLE) ) Send <= 1'b0;    
    else // (RST == 1'b0) && (current_state != IDLE)
    begin            
        if ( TX_start == 1'b1 ) Send <= 1'b1; // START state & BTN (START to TX) 
        else if ( Busy == 1'b0 ) Send <= 1'b0;
    end   
end
assign Busy = ((Send == 1'b1) && (TX_end == 1'b0) );

         
// Initialization - Start State 
always @(posedge CLK)
begin
    current_state <= (RST == 1'b1) ? IDLE : next_state;
end   
// 
    
// 각 Current_state에서 State Transition 조건 및 Output
always @(current_state, Ready, TX_start, TX_end, Send)
begin 
    Load = 1'b0; Shift = 1'b0;
    case ( current_state )
    IDLE : // 2'b00
        // State Transition 조건
        begin
            if ( Ready == 1'b1 )    next_state = START; // if ( BTN1 == 1'b1 ) next_state = START;                 
            else                    next_state = IDLE;  
            // State Output (Event)                
                             
        end
    START : // 2'b01
         // State Transition 조건
        begin
            if ( TX_start == 1'b1 ) next_state = TX; // if ( BTN1 == 1'b1 ) next_state = TX;                 
            else                    next_state = START;  
            // State Output (Event)  
            Load = 1'b1;
              
        end                       	
    TX : // 2'b10
        // State Transition 조건    
        begin
            if ( TX_end == 1'b1 )   next_state = STOP;             
            else                    next_state = TX;                             
            // State Output (Event)    
            Shift = 1'b1;
            
        end                
     STOP : // 2'b11
        // State Transition 조건    
        begin
            if ( Send == 1'b0 ) next_state = IDLE; // if ( BTN1 == 1'b1 ) next_state = IDLE;  
            // if ( Standby == 1'b1 )  next_state = IDLE;           
            else                next_state = STOP;                                                                 
            // State Output (Event)    
                        
        end                            
    default : next_state = IDLE;    
    endcase            
end            
               	
endmodule    