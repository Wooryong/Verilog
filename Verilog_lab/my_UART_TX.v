`timescale 1ns / 1ps

module my_UART_TX(
    input RST, CLK, // RST - BTN0, CLK - SYSCLK
    input BTN1, // for Send (Idel > Start)
    // input Parity_Sel,
    input [3:0] SW, // Din = 0100_XXXX
    output Dout, // Dout
    output LED_IDLE, LED_START, LED_TX, // LED Colors by State 
    output reg Busy // LED
    );
    
    // State Representation by LED 
    assign LED_IDLE = ( current_state == IDLE ); // LED0_R
    assign LED_START = ( current_state == START ); // LED0_G
    assign LED_TX = ( current_state == TX ); // LED0_B
      
    // Parameters
    parameter CLK_FREQ = 125_000_000; // Use 125 MHz SYSCLK    
    parameter BAUD_RATE = 115_200; // Baud rate     
    
    wire [7:0] Din;
    assign Din = { 4'b0100, SW }; // (64 + SW)
    // ASCII Code : 'A' (65) 

    // Generate Parity-bit (Even Parity)
    wire Parity;     
    // wire [1:0] Parity_sel;
    // assign Parity_sel = 2'b10; // '00' : No Parity, '01' : Odd Parity, '10' : Even Parity                 
    assign Parity = (^Din); // 짝수개면 1'b0, 홀수개면 1'b1 
    
  	// Generate Ready, Send Signal 
  	reg BTN1_chk1, BTN1_chk2; 
  	reg BTN1_CNT;
  	wire BTN1_press;
  	wire Ready, Send;
  	  	  	  	
  	always @(posedge CLK) // always @(posedge CLK)
  	begin  
        if ( RST == 1'b1 ) BTN1_CNT <= 1'b0; 
        else // RST == 1'b0
        begin
            BTN1_chk1 <= BTN1;
            BTN1_chk2 <= BTN1_chk1;       
            
            if ( (current_state == START) && (BTN1_press == 1'b1) )
            begin
                BTN1_CNT <= ~BTN1_CNT;
            end
            else if ( current_state != START )
                BTN1_CNT <= 1'b0;                  
        end               	
  	end 
 
  	assign BTN1_press = BTN1_chk1 & ~BTN1_chk2; 
  	assign Ready = (current_state == IDLE) & BTN1_press;	
  	assign Send = Bit_CLK & (BTN1_CNT == 1'b1) ;
  	
  	// assign Send = (current_state == START) & Bit_CLK & ~BTN1_press;
  	//    
           
    // Generate Busy
    // Send Active > Busy Active
    // Data Transfer End > Busy In-active
    
 	// Generate Bit_CLK 
 	// 125_000_000 / 115_200 ~ 1085
	reg [10:0] CNT_BAUD; // 11-bit CNT
	
	reg Bit_CLK; // 1 Posedge 
	always @(posedge CLK)
	begin
        if ( RST == 1'b1 ) begin
            CNT_BAUD <= 11'b0; Bit_CLK <= 1'b0;   
        end 
        else // RST == 1'b0 
        begin	   
            if ( CNT_BAUD == ( ( CLK_FREQ /  BAUD_RATE ) - 1 ) ) begin // 10ms Toggle            
                CNT_BAUD <= 11'b0; Bit_CLK <= 1'b1;
            end
            else begin
                CNT_BAUD <= CNT_BAUD + 1'b1; Bit_CLK <= 1'b0; 
            end
        end           
    end   
	//
	
    // State Definition by using Localparam 
    localparam [1:0] // #State : 4 > 2-bit
        IDLE    = 2'b00,  
        START   = 2'b01,
        TX      = 2'b10;    
    //    STOP    = 2'b11;  
    //        
        
    // FSM Current & Next State
    // (* MARK_DEBUG="true" *)
    reg [1:0] current_state, next_state; 
    // 
    
    // 1 Frame (11-bit) : Stop - Parity - Bit7 - ... - Bit0 - Start >> '1' - Parity - Din - '0'   
    reg [10:0] SR; // Shift Register for 11-bit 
    reg [10:0] TX_data; // Temp. 
    assign Dout = TX_data[0]; // Dout = LSB of SR
     
    reg [3:0] CNT_TX;
    reg TX_end;          
    always @(posedge CLK)
    begin
        if ( current_state == IDLE )
        begin
            SR <= 11'b0; TX_data <= 11'b111_1111_1111;  
            CNT_TX <= 4'b0; TX_end = 1'b0; Busy = 1'b0; 
        end    
        // Update Shift Register      
        else if ( current_state == START )
        begin	
            SR[0] <= 1'b0; // Start Bit      
            SR[8:1] <= Din; // [8] MSB of Din - [1] LSB of Din
            SR[9] <= Parity; // Parity Bit
            SR[10] <= 1'b1; // Stop Bit
            
            Busy = 1'b1;
            if ( Send == 1'b1 ) TX_data <= SR; // State Transition : START > TX 
        end
        
        else if ( (current_state == TX) && (Bit_CLK == 1'b1) )
        begin
            TX_data <= { 1'b1, TX_data[10:1] }; 
            
            if ( CNT_TX == 10 ) 
            begin
                CNT_TX <= 4'b0; Busy <= 1'b0; TX_end = 1'b1;
            end        
            else CNT_TX <= CNT_TX + 1'b1;
        end
    end
       
    // Initialization - Start State 
    always @(posedge CLK)
    begin
        if ( RST == 1'b1 )  current_state <= IDLE;
        else                current_state <= next_state;                
    end // always @(posedge CLK)   
    // 
    
    // 각 Current_state에서 State Transition 조건 및 Output
    always @(current_state, Ready, Send, TX_end)
    begin           
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
                if ( Send == 1'b1 ) next_state = TX; // if ( BTN1 == 1'b1 ) next_state = TX;                 
                else                next_state = START;  
                // State Output (Event)  
                  
            end                       	
        TX : // 2'b10
            // State Transition 조건    
            begin
                if ( TX_end == 1'b1 )   next_state = IDLE; // if ( BTN1 == 1'b1 ) next_state = START;    
                // else if ( STOP )        next_state = STOP;             
                else                    next_state = TX; 
                            
                // State Output (Event)    
                
            end                            
        default : next_state = IDLE;    
        endcase            
    end            
               	
endmodule    