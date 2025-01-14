`timescale 1ns / 1ps

module my_UART_RX(
    input RSTN, CLK,
    (* MARK_DEBUG="true" *)
    input RXD,
    (* MARK_DEBUG="true" *)
    output reg [7:0] RX_DATA,
    (* MARK_DEBUG="true" *)
    output RX_DONE
    );

wire RST;
assign RST = ~RSTN;

// assign DATA = (RX_RDY) ? RX_DATA : DATA; 
assign RX_DONE = RX_RDY;
  
// Parameters
parameter CLK_FREQ = 100_000_000; // Use 100 MHz PS CLK or 125 MHz SYSCLK
parameter BAUD_RATE = 115_200; // Baud rate 
parameter Oversampling_Rate = 16;
parameter Max_CNT = CLK_FREQ / BAUD_RATE / Oversampling_Rate; // ~54  

// *** UART_Baud_gen Block *** //
// Generate Over-sampling CLK : baud_x16_en
// PS CLK : 100 MHz & Baud_rate = 115,200 bps & Over-sampling_rate = 16 >> Max. Count = 54
// (* MARK_DEBUG="true" *)
reg [5:0] CNT_OVER_CLK; // 6-bit CNT for Max. Count(54) 
(* MARK_DEBUG="true" *)
reg baud_x16_en; // Baud Rate Over-sampling(x16) CLK
always @(posedge CLK)
begin
    if ( RST == 1'b1 ) begin
    //if ( (RST == 1'b1) || (current_state == IDLE) ) begin
        CNT_OVER_CLK <= 6'b0; baud_x16_en <= 1'b0;   
    end 
    else // (RST == 1'b0) && (current_state != IDLE)
    begin	
        CNT_OVER_CLK <= ( CNT_OVER_CLK == (Max_CNT - 1) ) ? 6'b0 : CNT_OVER_CLK + 1'b1;
        baud_x16_en <= ( CNT_OVER_CLK == (Max_CNT - 1) );                      
    end // else // RST == 1'b0           
end   
// *** UART_Baud_gen Block *** //  


// *** UART_RX_CTL Block *** //
// IN : RST, CLK, RXD, baud_x16_en & OUT : RX_RDY, RX_DATA[7:0]
// Use FSM (IDLE - START - RX - STOP) 
// State Definition by using Localparam 
localparam [1:0] // #State : 4 > 2-bit
    IDLE    = 2'b00,  
    START   = 2'b01,
    RX      = 2'b10;
//    STOP    = 2'b11;  
          
// FSM Current & Next State
(* MARK_DEBUG="true" *)
reg [1:0] current_state, next_state; 

// (* MARK_DEBUG="true" *)
reg RX_start;
// (* MARK_DEBUG="true" *)
reg RX_RDY; // State Transition Signal
// (* MARK_DEBUG="true" *)
reg over_sample_cnt_done; // Capture RXD at center of Bit
// (* MARK_DEBUG="true" *)
reg bit_cnt_done; // Count the end of Bits  
// (* MARK_DEBUG="true" *)
reg [3:0] CNT_Sampling; // 16 Over-sampling per 1-bit 
// (* MARK_DEBUG="true" *)
reg [2:0] CNT_RX_bit; // Count Received Data bit
// (* MARK_DEBUG="true" *)
// reg [7:0] RX_DATA; // Received Data Reposit

always @(posedge CLK)
// always @(posedge baud_x16_en)
begin
    if ( (RST == 1'b1) || (current_state == IDLE) ) begin
        RX_start <= 1'b0; RX_RDY <= 1'b0;
        over_sample_cnt_done <= 1'b0; bit_cnt_done <= 1'b0; 
        CNT_Sampling <= 4'b0; CNT_RX_bit <= 4'b0; 
        // RX_DATA <= 8'b0;                
    end
    //
    else // (RST == 1'b0) && (current_state != IDLE)
    begin   
        // START state : During Start-bit 
        // if ( current_state == START )
        if ( (current_state == START) && (baud_x16_en == 1'b1) )
        begin
            RX_DATA <= 8'b0;  
            
            CNT_Sampling <= (CNT_Sampling == 15) ? 4'b0 : CNT_Sampling + 1'b1;
            RX_start <= (CNT_Sampling == 15);         
        end // if ( current_state == START )    
           
        // RX state : During Data-bit (Data Receive)
        // else if ( current_state == RX ) 
        else if ( (current_state == RX) && (baud_x16_en == 1'b1) )
        begin
            RX_start <= 1'b0; // After State Transition, Reset
            
            CNT_Sampling <= (CNT_Sampling == 15) ? 4'b0 : CNT_Sampling + 1'b1;
            
            over_sample_cnt_done <= (CNT_Sampling == 7);
            RX_DATA <= (CNT_Sampling == 7) ? { RXD , RX_DATA[7:1] } : RX_DATA; // MSB & Right Shift
            
            bit_cnt_done <= (CNT_Sampling == 15);
            if ( CNT_Sampling == 15 ) begin
                CNT_RX_bit <= (CNT_RX_bit == 7) ? 3'b0 : CNT_RX_bit + 1'b1;     
                RX_RDY <= (CNT_RX_bit == 7);
            end                                                                
        end // else if ( current_state == RX )  
              
    end // else // RST == 1'b0            
end
// *** UART_RX_CTL Block *** //

// *** FSM *** //
// Initialization - Start State 
always @(posedge CLK)
begin
    if ( RST == 1'b1 )  current_state <= IDLE;
    else                current_state <= next_state;                
end    
//  

// 각 Current_state에서 State Transition 조건 및 Output
always @(current_state, RXD, baud_x16_en, RX_start, RX_RDY)
begin 
    //
    case ( current_state )
    IDLE : begin
        if ( (RXD == 1'b0) && (baud_x16_en == 1'b1) )      next_state = START; // Start bit : '0'      
        // && (baud_x16_en == 1'b1) : for Sync.           
        else                    next_state = IDLE; // Default : RXD = 1'b1         
        end                            
    START : begin       
        if ( RX_start == 1'b1 ) next_state = RX; //                  
        else                    next_state = START;  
        end 
    RX : begin
        if ( RX_RDY == 1'b1 )   next_state = IDLE; //                  
        else                    next_state = RX;  
        end         
    default : next_state = IDLE;                                     
    endcase 
end
// *** FSM *** //

endmodule