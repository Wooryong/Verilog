`timescale 1ns / 1ps

module my_UART_RX(
    // (* MARK_DEBUG="true" *)
    input RST, CLK,
    // (* MARK_DEBUG="true" *)
    input RXD,
    output reg Error,    
    output [6:0] AN,
    output CA
    // output LED_IDLE, LED_RX, LED_STOP // LED Colors by State
    );

// State Representation by LED 
// assign LED_IDLE = ( current_state == IDLE ); // LED0_R
// assign LED_RX = ( current_state == RX ); // LED0_G
// assign LED_STOP = ( current_state == STOP ); // LED0_B
    
// Parameters
parameter CLK_FREQ = 125_000_000; // Use 125 MHz SYSCLK    
parameter BAUD_RATE = 9600; // Baud rate 
parameter Oversampling_Rate = 16;
parameter Max_CNT = CLK_FREQ / BAUD_RATE / Oversampling_Rate; // 813  

// *** UART_Baud_gen Block *** //
// Generate Over-sampling CLK : baud_x16_en
// SYSCLK : 125 MHz & Baud_rate = 9,600 bps & Over-sampling_rate = 16 >> Max. Count = 813
// (* MARK_DEBUG="true" *)
reg [9:0] CNT_OVER_CLK; // 10-bit CNT for Max. Count(813) 
// (* MARK_DEBUG="true" *)
reg baud_x16_en; // Baud Rate Over-sampling(x16) CLK
always @(posedge CLK)
begin
    // if ( RST == 1'b1 ) begin
    if ( RST == 1'b1 ) begin
        CNT_OVER_CLK <= 10'b0; baud_x16_en <= 1'b0;   
    end 
    else // (RST == 1'b0) && (current_state != IDLE)
    begin	
        CNT_OVER_CLK <= ( CNT_OVER_CLK == (Max_CNT - 1) ) ? 10'b0 : CNT_OVER_CLK + 1'b1;
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
    RX      = 2'b10,    
    STOP    = 2'b11;  
          
// FSM Current & Next State
// (* MARK_DEBUG="true" *)
reg [1:0] current_state, next_state; 

// (* MARK_DEBUG="true" *)
reg RX_start, RX_RDY, Parity_done; // State Transition Signal
// (* MARK_DEBUG="true" *)
reg over_sample_cnt_done; // Capture RXD at center of Bit
// (* MARK_DEBUG="true" *)
reg bit_cnt_done; // Count the end of Bits  
// (* MARK_DEBUG="true" *)
reg [3:0] CNT_Sampling; // 16 Over-sampling per 1-bit 
// (* MARK_DEBUG="true" *)
reg [2:0] CNT_RX_bit; // Count Received Data bit
// (* MARK_DEBUG="true" *)
reg [7:0] RX_DATA; // Received Data Reposit
// reg Parity;

// always @(posedge CLK)
always @(posedge baud_x16_en)
begin
    if ( (RST == 1'b1) || (current_state == IDLE) ) begin
        RX_start <= 1'b0; RX_RDY <= 1'b0; Parity_done <= 1'b0;
        over_sample_cnt_done <= 1'b0; bit_cnt_done <= 1'b0; 
        CNT_Sampling <= 4'b0; CNT_RX_bit <= 4'b0; RX_DATA <= 8'b0;                
    end
    //
    else // (RST == 1'b0) && (current_state != IDLE)
    begin   
        // START state : During Start-bit 
        if ( current_state == START )
        // if ( (current_state == START) && (baud_x16_en == 1'b1) )
        begin
            CNT_Sampling <= (CNT_Sampling == 15) ? 4'b0 : CNT_Sampling + 1'b1;
            RX_start <= (CNT_Sampling == 15);         
        end // if ( current_state == START )    
           
        // RX state : During Data-bit (Data Receive)
        else if ( current_state == RX ) 
        // else if ( (current_state == RX) && (baud_x16_en == 1'b1) )
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
           
        // STOP state : Parity Error Check
        else if ( current_state == STOP )
        // else if ( (current_state == STOP) && (baud_x16_en == 1'b1) ) // Parity Error Check       
        begin
            RX_RDY <= 1'b0; bit_cnt_done <= 1'b0; // After State Transition, Reset   
            
            CNT_Sampling <= (CNT_Sampling == 15) ? 4'b0 : CNT_Sampling + 1'b1;
            Error <= (CNT_Sampling == 7) ? ( ^(RX_DATA) != RXD ) : Error;
            Parity_done <= (CNT_Sampling == 15);
        end // else if ( current_state == STOP )                
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
always @(current_state, RXD, RX_start, RX_RDY, Parity_done, baud_x16_en)
begin 
    //
    case ( current_state )
    IDLE : begin
        if ( (RXD == 1'b0) && (baud_x16_en == 1'b1) )    next_state = START; // Start bit : '0'      
        // && (baud_x16_en == 1'b1) : for Sync.           
        else                    next_state = IDLE; // Default : RXD = 1'b1         
        end                            
    START : begin       
        if ( RX_start == 1'b1 ) next_state = RX; //                  
        else                    next_state = START;  
        end 
    RX : begin
        if ( RX_RDY == 1'b1 )   next_state = STOP; //                  
        else                    next_state = RX;  
        end         
    STOP : begin
        if ( Parity_done == 1'b1 )  next_state = IDLE; //                  
        else                        next_state = STOP;  
        end
    default : next_state = IDLE;                                     
    endcase 
end
// *** FSM *** //


// *** Data Representation by 7-Segment *** //  
reg [31:0] CNT_Seg;
wire [3:0] Dig2Seg; 
// (* MARK_DEBUG="true" *)
reg [3:0] Digit_10s, Digit_1s; 
reg tick; 
reg Pos_Sel; // 10 ms Toggle
    
assign CA = Pos_Sel;
assign Dig2Seg = Pos_Sel ? Digit_10s : Digit_1s; // 
my_disp U0 ( .SW( Dig2Seg ), .AN(AN) ); // Input : Dig2Seg (4-bit; 0~9), Output : AN (7-bit; A~G) 

// Generate 7-Segment Position Select Signal 
// Pos_Sel : 10 ms Toggle && tick : 10 ms Posedge
always @(posedge CLK)
begin
    if ( RST == 1'b1 ) begin
        CNT_Seg <= 32'b0; Pos_Sel <= 1'b0; tick <= 1'b0;  
    end 
    else // RST == 1'b0 
    begin
        CNT_Seg <= (CNT_Seg == ((CLK_FREQ/100) - 1)) ? 32'b0 : CNT_Seg + 1'b1;
        Pos_Sel <= (CNT_Seg == ((CLK_FREQ/100) - 1)) ? ~Pos_Sel : Pos_Sel;
        tick <= (CNT_Seg == ((CLK_FREQ/100) - 1));
        /*	   
        if ( CNT_Seg == ( (CLK_FREQ/100) - 1 ) ) begin // 10ms Toggle            
                CNT_Seg <= 32'b0; Pos_Sel <= ~Pos_Sel; tick <= 1'b1;
        end
        else begin
            CNT_Seg <= CNT_Seg + 1'b1; tick <= 1'b0; 
        end
        */
    end           
end   
//

// Digit Separation - [Digit_10s][Digit_1s]
always @(posedge CLK)
begin
    if ( RST == 1'b1 ) begin
        Digit_10s <= 4'b0; Digit_1s <= 4'b0;
    end 
    else // RST == 1'b0   
    begin
        if ( RX_RDY == 1'b1 ) begin        
            /*
            Digit_10s <= RX_DATA / 10; Digit_1s <= RX_DATA % 10;            
            // ex) 'A' > RX_DATA = 0100_0001 (65) > [Digit_10s = 6][Digit_1s = 5]
            */
            Digit_10s <= RX_DATA[7:4]; Digit_1s <= RX_DATA[3:0];                       
            // ex) 'A' > RX_DATA = 0100_0001 (8'h41) > [Digit_10s = 4][Digit_1s = 1]
        end        
    end // else // RST == 1'b0  
end
// *** Data Representation by 7-Segment *** //  
      
endmodule