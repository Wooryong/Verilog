`timescale 1ns / 1ps

module my_UART_TX(
    input RSTN, // Active-low RESET
    input CLK, //
    input TX_START, // UART TX Start
    input [7:0] DATA, // TX_DATA
    (* MARK_DEBUG="true" *)
    output TXD, // 
    output TX_READY // UART TX Ready Status
    );

// Parameters
parameter CLK_FREQ = 100_000_000; // Use 100 MHz PS CLK   
parameter BAUD_RATE = 115_200; // Baud rate     

wire RST;
assign RST = ~(RSTN);
 
assign TX_READY = ( current_state == IDLE ); 
 
// Generate Bit_CLK 
// CLK_FREQ / BAUD_RATE = 100_000_000 / 115_200 ~ 868 >> 10-bit
reg [9:0] CNT_BAUD; // 10-bit CNT
(* MARK_DEBUG="true" *)
reg Bit_CLK; // Baud Rate Tick Signal
always @(posedge CLK)
begin  
    if ( RST == 1'b1 ) begin
        CNT_BAUD <= 10'b0; Bit_CLK <= 1'b0;   
    end 
    else // RST == 1'b0
    begin
        CNT_BAUD <= ( CNT_BAUD == ( (CLK_FREQ/BAUD_RATE) - 1) ) ? 10'b0 : CNT_BAUD + 1'b1;
        Bit_CLK <= ( CNT_BAUD == ( (CLK_FREQ/BAUD_RATE) - 1) ); // posedge
    end
end
              
// Generate Parity-bit (Even Parity Mode)
// wire Parity;                  
// assign Parity = (^DATA); // 짝수개면 1'b0, 홀수개면 1'b1 

// State Definition by using Localparam 
localparam [1:0] // #State : 4 > 2-bit
    IDLE    = 2'b00,  
    START   = 2'b01,
    TX      = 2'b10;         
        
// FSM Current & Next State
(* MARK_DEBUG="true" *)
reg [1:0] current_state, next_state; 
// 
 
wire [10:0] SR; // Temp. Shift Register for 11-bit 
(* MARK_DEBUG="true" *)
reg [10:0] TX_data; //  
assign TXD = TX_data[0]; // TXD = LSB of SR

(* MARK_DEBUG="true" *)
reg [3:0] CNT_TX;
(* MARK_DEBUG="true" *)
reg TX_end;
// reg Load, Shift;    
  
// 1 Data Frame (11-bit) : Stop bit - Parity bit - Data - Start bit   
assign SR = (RST == 1'b1) || (current_state == IDLE) ? 11'b0 :
            (current_state == START) ? { 1'b1, DATA, 1'b0, 1'b1 } : 11'b0;
                 
always @(posedge CLK)
begin
    // RST or IDLE state : Initialize 
    if ( (RST == 1'b1) || (current_state == IDLE) ) 
    begin
        TX_data <= 11'b111_1111_1111;  
        CNT_TX <= 4'b0; TX_end <= 1'b0;  
    end 
       
    // START state : Data Parallel Load in Shift Register      
    else if ( current_state == START )
        TX_data <= SR; // State Transition : START > TX 
        
    // TX state : Data TX & Data Shift in Shift Register
    else if ( (current_state == TX) && (Bit_CLK == 1'b1) ) 
    begin 
        TX_data <= { 1'b1, TX_data[10:1] }; // bit Shift          
            
        CNT_TX <= (CNT_TX == 10) ? 4'b0 : CNT_TX + 1'b1;
        TX_end <= (CNT_TX == 10);                                           
    end // 
end

// (* MARK_DEBUG="true" *) 
reg State_start_en;
// (* MARK_DEBUG="true" *)
wire State_start;
always @(posedge CLK) 
begin  
    if (RST == 1'b1)  State_start_en <= 1'b0;          
    else // 
    begin	
        if ( (current_state == IDLE) && (TX_START == 1'b1) )    State_start_en <= 1'b1;
        else if ( current_state == START )                      State_start_en <= 1'b0; 
    end
end  
assign State_start = State_start_en & Bit_CLK; 
             
// Initialization - Start State 
always @(posedge CLK)
begin
    current_state <= (RST == 1'b1) ? IDLE : next_state;
end   
// 
    
// 각 Current_state에서 State Transition 조건 및 Output
always @(current_state, State_start, Bit_CLK, TX_end)
begin 
    case ( current_state )
    IDLE : // 2'b00
        // State Transition 조건
        begin
            if ( State_start == 1'b1 )  next_state = START; //                  
            else                        next_state = IDLE;  
            // State Output (Event)                                             
        end
    START : // 2'b01
         // State Transition 조건
        begin
            if ( Bit_CLK == 1'b1 ) next_state = TX; //                  
            else                   next_state = START;  
            // State Output (Event)           
        end                       	
    TX : // 2'b10
        // State Transition 조건    
        begin
            if ( TX_end == 1'b1 )   next_state = IDLE;             
            else                    next_state = TX;                             
            // State Output (Event)                
        end                                           
    default : next_state = IDLE;    
    endcase            
end            
               	
endmodule    