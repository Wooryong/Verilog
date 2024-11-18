`timescale 1ns / 1ps

module my_UART_RX(
    input RST, CLK,
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

// *** UART_Baud_gen Block *** //
// Generate Oversampling CLK : baud_x16_en
// SYSCLK : 125 MHz & Baud_rate = 9,600 bps 
// Oversamling rate = 16
// 125_000_000 / 9_600 / 16 = 813
reg [9:0] CNT_OVER_CLK; // 10-bit CNT
reg baud_x16_en; // Baud Rate Over-sampling(x16) CLK
always @(posedge CLK)
begin
    if ( RST == 1'b1 ) begin
        CNT_OVER_CLK <= 10'b0; baud_x16_en <= 1'b0;   
    end 
    else // RST == 1'b0 
    begin	   
        if ( CNT_OVER_CLK == ( ( CLK_FREQ / BAUD_RATE / 16 ) - 1 ) ) begin // Oversampling x16            
            CNT_OVER_CLK <= 10'b0; baud_x16_en <= 1'b1;
        end
        else begin
            CNT_OVER_CLK <= CNT_OVER_CLK + 1'b1; baud_x16_en <= 1'b0; 
        end
    end // else // RST == 1'b0           
end   
// *** UART_Baud_gen Block *** //  


// *** UART_RX_CTL Block *** //
// 입력신호 : rst, clk, rxd, baud_x16_en
// 출력신호 : rx_rdy, rx_data[7:0]
// FSM 
// State Definition by using Localparam 
localparam [1:0] // #State : 4 > 2-bit
    IDLE    = 2'b00,  
    START   = 2'b01,
    RX      = 2'b10,    
    STOP    = 2'b11;  
          
// FSM Current & Next State
reg [1:0] current_state, next_state; 


reg RX_start, RX_RDY, Parity_done; // State Transition Signal
reg over_sample_cnt_done; // 16 Oversample 중 Center Point
reg bit_cnt_done; // At the end of each data bit, posedge
reg [3:0] CNT_Sampling; // 16 Divisions per 1-bit 
reg [2:0] CNT_RX_bit; // 8 data bit 
reg [7:0] RX_DATA; // Received Data Reposit
// reg Parity;

always @(posedge baud_x16_en)
begin
    if ( (RST == 1'b1) || (current_state == IDLE) ) begin
        RX_start <= 1'b0; RX_RDY <= 1'b0; Parity_done <= 1'b0;
        over_sample_cnt_done <= 1'b0; bit_cnt_done <= 1'b0; 
        CNT_Sampling <= 4'b0; CNT_RX_bit <= 4'b0; 
        RX_DATA <= 8'b0;
        // Parity <= 1'b0;                   
    end
    //
    else // (RST == 1'b0) && (current_state != IDLE)
    begin   
        // START state : During Start-bit 
        if ( current_state == START )
        begin
            if ( CNT_Sampling == 15 ) begin         
                CNT_Sampling <= 4'b0; RX_start <= 1'b1;
            end        
            else begin  
                CNT_Sampling <= CNT_Sampling + 1'b1; RX_start <= 1'b0;   
            end         
        end // if ( current_state == START )       
        // RX state : During Data-bit (Data Receive)
        else if ( current_state == RX ) 
        begin
            RX_start <= 1'b0;
            
            if ( CNT_Sampling == 7 ) // Center Position > Bit Capture 
            begin
                CNT_Sampling <= CNT_Sampling + 1'b1;
                over_sample_cnt_done <= 1'b1; 
                RX_DATA <= { RXD , RX_DATA[7:1] }; // MSB & Right Shift 
            end              
            else if ( CNT_Sampling == 15 ) begin // End Position > Count #bit             
                CNT_Sampling <= 4'b0; bit_cnt_done <= 1'b1; 
                //
                if ( CNT_RX_bit == 7 ) begin  
                    CNT_RX_bit <= 3'b0; RX_RDY <= 1'b1;
                end    
                else begin                   
                CNT_RX_bit <= CNT_RX_bit + 1'b1; RX_RDY <= 1'b0;
                end                 
                //               
            end                
            else begin   
                CNT_Sampling <= CNT_Sampling + 1'b1;     
                over_sample_cnt_done <= 1'b0; bit_cnt_done <= 1'b0; 
            end                                                                  
        end // else if ( current_state == RX )     
        // STOP state : Parity Error Check
        else if ( current_state == STOP ) // Parity Error Check       
        begin
            RX_RDY <= 1'b0; bit_cnt_done <= 1'b0;   
             
            if ( CNT_Sampling == 7 ) begin
                // Parity <= RXD; 
                CNT_Sampling <= CNT_Sampling + 1'b1;
                Error <= ( (^RX_DATA) != RXD );
            end    
            else if ( CNT_Sampling == 15 ) begin             
                CNT_Sampling <= 4'b0; Parity_done <= 1'b1;  
            end      
            else begin                 
                CNT_Sampling <= CNT_Sampling + 1'b1; Parity_done <= 1'b0;
            end    
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
    IDLE : // 2'b00
    // State Transition 조건
        begin
            if ( (RXD == 1'b0) && (baud_x16_en == 1'b1) )   next_state = START; // Start-bit = '0'                 
            else                                            next_state = IDLE; // Default : RXD = 1'b1 
        // State Output (Event) 
           
        end                            
    START : // 2'b01
    // State Transition 조건
        begin
            if ( RX_start == 1'b1 ) next_state = RX; //                  
            else                    next_state = START;  
        // State Output (Event)       
                                     
        end 
    RX : // 2'b10
    // State Transition 조건
        begin
            if ( RX_RDY == 1'b1 )   next_state = STOP; //                  
            else                    next_state = RX;  
        // State Output (Event) 
         
        end         
    STOP : // 2'b11
    // State Transition 조건
        begin
            if ( Parity_done == 1'b1 )  next_state = IDLE; //                  
            else                        next_state = STOP;  
        // State Output (Event) 
                 
        end
    default : next_state = IDLE;                                     
    endcase 
end
// *** FSM *** //


// *** Data Representation by 7-Segment *** //  
reg [31:0] CNT_Seg;
wire [3:0] Dig2Seg; 
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
        if ( CNT_Seg == ( (CLK_FREQ/100) - 1 ) ) begin // 10ms Toggle            
                CNT_Seg <= 32'b0; Pos_Sel <= ~Pos_Sel; tick <= 1'b1;
        end
        else begin
            CNT_Seg <= CNT_Seg + 1'b1; tick <= 1'b0; 
        end
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
        if ( RX_RDY == 1'b1 )
        begin
            /*
            Digit_10s <= RX_DATA / 10;
            Digit_1s <= RX_DATA % 10;
            // ex) 'A' > RX_DATA = 0100_0001 (65) > [Digit_10s = 6][Digit_1s = 5]
            */
            Digit_10s <= RX_DATA[7:4];
            Digit_1s <= RX_DATA[3:0];            
            // ex) 'A' > RX_DATA = 0100_0001 (8'h41) > [Digit_10s = 4][Digit_1s = 1]
        end        
    end // else // RST == 1'b0  
end
// *** Data Representation by 7-Segment *** //  
      
endmodule

            /*
            if ( over_sample_cnt_done == 1'b1 );
                RX_DATA <= { RXD , RX_DATA[7:1] }; // MSB & Right Shift                
            */
            /*
            if ( bit_cnt_done == 1'b1 )
            begin
                if ( CNT_RX_bit == 7 ) begin  
                    CNT_RX_bit <= 3'b0; RX_RDY <= 1'b1;
                end    
                else begin                   
                CNT_RX_bit <= CNT_RX_bit + 1'b1; RX_RDY <= 1'b0;
                end 
            end  
            */  