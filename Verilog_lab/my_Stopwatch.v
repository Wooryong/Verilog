`timescale 1ns / 1ps

module my_Stopwatch(
    (* MARK_DEBUG="true" *)
    input CLK, 
    (* MARK_DEBUG="true" *)
    input RST, 
    (* MARK_DEBUG="true" *)
    input BTN0, 
    (* MARK_DEBUG="true" *)
    input BTN1, // BTN0 for START & STOP / BTN1 for CLEAR
    (* MARK_DEBUG="true" *)
    output [6:0] AN,
    (* MARK_DEBUG="true" *)
    output CA
    );
 
    parameter CLK_FREQ = 125_000_000; // Use 125 MHz SYSCLK    
  	
  	// De-bounce Code for BTNs
  	reg BTN0_chk1, BTN0_chk2;
  	(* MARK_DEBUG="true" *)
  	wire BTN0_press;
  	
  	reg BTN1_chk1, BTN1_chk2;
  	(* MARK_DEBUG="true" *)
  	wire BTN1_press;
  	  	  	
  	always @(posedge CLK)
  	begin
        BTN0_chk1 <= BTN0;
        BTN0_chk2 <= BTN0_chk1;   
        
        BTN1_chk1 <= BTN1;
        BTN1_chk2 <= BTN1_chk1;              	
  	end 
  	
  	assign BTN0_press = BTN0_chk1 & ~BTN0_chk2;
  	assign BTN1_press = BTN1_chk1 & ~BTN1_chk2;
  	//
  	
	// Time Representation by 7-Segment  
	reg [31:0] CNT_Seg;
	(* MARK_DEBUG="true" *)
	wire [3:0] Dig2Seg; 
	(* MARK_DEBUG="true" *)
	reg [3:0] Digit_10s, Digit_1s; 
	(* MARK_DEBUG="true" *)
	reg tick; 
	(* MARK_DEBUG="true" *)
	reg Pos_Sel; // 10 ms Toggle
    
	assign CA = Pos_Sel;
	assign Dig2Seg = Pos_Sel ? Digit_10s : Digit_1s; // 
	my_disp U0 ( .SW( Dig2Seg ), .AN(AN) ); // Input : Dig2Seg (4-bit; 0~9), Output : AN (7-bit; A~G) 
    //

	// Generate 7-Segment Position Select Signal 
	// Pos_Sel : 10 ms Toggle 
	// tick : 10 ms Posedge
	always @(posedge CLK)
	begin
        if ( RST == 1'b1 ) 
        begin
            CNT_Seg <= 32'b0; Pos_Sel <= 1'b0; tick <= 1'b0;  
        end 
        else // RST == 1'b0 
        begin	   
            if ( CNT_Seg == ( (CLK_FREQ-1)/100 ) ) // 10ms Toggle
            begin
                CNT_Seg <= 32'b0; Pos_Sel <= ~Pos_Sel; tick <= 1'b1;
            end
            else 
            begin
                CNT_Seg <= CNT_Seg + 1'b1; tick <= 1'b0; 
            end
        end           
    end   
	//
    
    // State Definition by using Localparam 
    localparam [1:0] // #State : 4 > 2-bit
        CLEAR   = 2'b00, // CLR 신호 발생 시
        START   = 2'b01,
        STOP    = 2'b10,    
        LOAD    = 2'b11; // load 신호 발생 시 
        
    // FSM Current & Next State
    (* MARK_DEBUG="true" *)
    reg [1:0] current_state; 
    (* MARK_DEBUG="true" *)
    reg [1:0] next_state; 
    
    (* MARK_DEBUG="true" *)
    reg time_start;  
    (* MARK_DEBUG="true" *)  
    reg [31:0] CNT_1s; 
    (* MARK_DEBUG="true" *)  
    reg [5:0] Time_sec; // 00-59
    (* MARK_DEBUG="true" *)
    reg [29:0] Time_save; // 6-bit * 5
    (* MARK_DEBUG="true" *)
    reg [2:0] Save_flag; // 5 Lab-times (#1 : '001', #2 : '010' , #3 : '011', #4 : '100', #5 : '101')
    
    (* MARK_DEBUG="true" *)
    reg wait_clear, wait_load;
    (* MARK_DEBUG="true" *)
    reg [31:0] CNT_CLR;
    (* MARK_DEBUG="true" *)
    reg [31:0] CNT_LOAD;
    (* MARK_DEBUG="true" *)
    reg CLR;
    (* MARK_DEBUG="true" *) 
    reg load;

// START, STOP : CLEAR 가능하도록 (BTN1 오래 누를 시)
// STOP : 그대로 유지 (Latch) & Lab-time 저장 
// CLEAR : 모두 0으로 초기화     
   
    // Time Update by tick signal
    always @(posedge CLK)
    begin
        if ( ( RST == 1'b1 ) || ( CLR == 1'b1 ) )
        begin
            CNT_1s <= 32'b0; Time_sec <= 6'b0;  
            Time_save <= 30'b0; Save_flag <= 3'b0;
        end          
        else if ( ( time_start == 1'b1 ) && ( tick == 1'b1 ) ) // ( RST == 1'b0 ) && ( CLR == 1'b0 )
        begin
            if ( CNT_1s == 99 ) // 1 s = 100 * (10 ms)
            begin
                CNT_1s <= 32'b0; 
           
                if (Time_sec == 59) Time_sec <= 6'b0;  
                else                Time_sec <= Time_sec + 1'b1;                                                      
            end
            else CNT_1s <= CNT_1s + 1'b1;    
        end
        else if ( ( wait_load == 1'b1 ) && ( BTN1_press == 1'b1 ) ) // ( RST == 1'b0 ) && ( CLR == 1'b0 ) 
        // else if ( ( wait_load == 1'b1 ) && ( BTN1 == 1'b1 ) ) // ( RST == 1'b0 ) && ( CLR == 1'b0 ) 
        // START & STOP state - Lab-time Save
        begin
            Time_save <= { Time_save[23:0] , Time_sec };
          
            /*
            if ( Save_flag < 5 )    Save_flag <= Save_flag + 1'b1;    
            else                    Save_flag <= 3'b101;
            */                        
        end   
        else if ( ( wait_load == 1'b0 ) && ( BTN1_press == 1'b1 ) )            
        // else if ( ( wait_load == 1'b0 ) && ( BTN1 == 1'b1 ) )
        // LOAD state - Lab-time Load
        begin   
            Time_sec <= Time_save[29:24];
            Time_save <= { Time_save[23:0], Time_save[29:24] };
            /*
            if ( Save_flag < 1 ) 
            else
            Save_flag <= Save_flag - 1'b1; 
            */   
        end
    end
    // 
    
    // Digit Separation - [Digit_10s][Digit_1s]
    // ex) Time_sec = 29 > [Digit_10s = 2][Digit_1s = 9]
    always @(Time_sec)
    begin
        Digit_10s = Time_sec / 10;
        Digit_1s = Time_sec % 10;
    end         
    //
        
    // Generate CLR by tick signal 
    always @(posedge CLK)
    begin    
        if ( ( wait_clear == 1'b1 ) && ( BTN1_press == 1'b1 ) && ( tick == 1'b1 ) ) // START & STOP state   
        // if ( ( wait_clear == 1'b1 ) && ( BTN1 == 1'b1 ) && ( tick == 1'b1 ) ) // START & STOP state
        begin
            if ( CNT_CLR == 299 ) // 3 s = 300 * (10 ms)
            begin
                CLR <= 1'b1; CNT_CLR <= 32'b0;
            end
            else CNT_CLR <= CNT_CLR + 1'b1;  
        end    
        else if ( ( wait_clear == 1'b0 ) || ( BTN1 == 1'b0 ) )        
        // else if ( ( wait_clear == 1'b0 ) || ( BTN1 == 1'b0 ) )
        begin 
            CLR <= 1'b0; CNT_CLR <= 32'b0;    
        end               
    end        
    //   
     
    // Generate load by tick signal
    always @(posedge CLK)
    begin 
        if ( ( wait_load == 1'b1 ) && ( BTN0_press == 1'b1  ) && ( tick == 1'b1 ) ) // START & STOP state      
        // if ( ( wait_load == 1'b1 ) && ( BTN0 == 1'b1 ) && ( tick == 1'b1 ) ) // START & STOP state
        begin
            if ( CNT_LOAD == 299 ) // 3 s = 300 * (10 ms)
            begin
                load <= 1'b1; CNT_LOAD <= 32'b0;
            end
            else CNT_LOAD <= CNT_LOAD + 1'b1;  
        end            
        else if ( ( wait_load == 1'b0 ) || ( BTN0 == 1'b0 ) )
        begin
            load <= 1'b0; CNT_LOAD <= 32'b0;    
        end               
    end    
                 
    // Initialization - Start State 
    always @(posedge CLK)
    begin
        if ( RST == 1'b1 )  current_state <= CLEAR;
        else                current_state <= next_state;                
    end // always @(posedge CLK)    

     // 각 Current_state에서 외부 Input(BUT)에 따른 State Transition 조건 및 Output
    always @(current_state, BTN0_press, CLR)
    begin
        // wait_clear : BTN1 3초 이상 > CLR = 1 >> CLEAR state
        // wait_load : BTN0 3초 이상 > load = 1 >> LOAD state   
        case (current_state)
        CLEAR : // 2'b00
            // State Transition 조건
            begin
                if ( BTN0_press == 1'b1 ) next_state = START;
                // if ( BTN0 == 1'b1 ) next_state = START;  
                else                next_state = CLEAR;  
                // State Output (Event)
                // 시간 출력 - 00초                 
                wait_clear = 1'b0; time_start = 1'b0; wait_load = 1'b1;
            end
        START : // 2'b01
            begin
                if ( load == 1'b1 )     next_state = LOAD;
                else if ( BTN0_press == 1'b1) next_state = STOP;
                // else if ( BTN0 == 1'b1) next_state = STOP; 
                else if ( CLR == 1'b1 ) next_state = CLEAR;              
                else                    next_state = START;
                // State Output (Event)
                // 시간 출력 - 변화하는 시간   
                wait_clear = 1'b1; time_start = 1'b1; wait_load = 1'b1;                     
            end 
        STOP : // 2'b10     
            begin
                if ( load == 1'b1 )     next_state = LOAD;
                else if (BTN0_press == 1'b1)  next_state = START;
                // else if (BTN0 == 1'b1)  next_state = START; 
                else if ( CLR == 1'b1 ) next_state = CLEAR;               
                else                    next_state = STOP;
                // State Output (Event)
                // 시간 출력 - 멈춘 시간      
                wait_clear = 1'b1; time_start = 1'b0; wait_load = 1'b1;                             
            end 
        LOAD : // 2'b11     
            begin
                if ( CLR == 1'b1 )      next_state = CLEAR;
                else                    next_state = LOAD;
                // State Output (Event)
                // 시간 출력 - 저장된 시간     
                wait_clear = 1'b1; time_start = 1'b0; wait_load = 1'b0;                              
            end                                                      
        default : next_state = CLEAR;    
        endcase              
    end 
    
endmodule

    /* Time Update 
    always @(posedge CLK)
    begin
        if ( ( RST == 1'b1 ) || ( CLR == 1'b1 ) )
        begin
            CNT_1s <= 32'b0; Time_sec <= 6'b0;  
        end          
        else if ( time_start == 1'b1 ) // ( RST == 1'b0 ) && ( CLR == 1'b0 )
        begin
            if ( CNT_1s == (CLK_FREQ - 1) ) 
            begin
                CNT_1s <= 32'b0; 
           
                if (Time_sec == 59) Time_sec <= 6'b0;
                else                Time_sec <= Time_sec + 1'b1;                                                  
            end
            else CNT_1s <= CNT_1s + 1'b1;    
        end
    end
    */
    
    /* Generate CLR 
    always @(posedge CLK)
    begin       
        if ( ( wait_clear == 1'b1 ) && ( BTN1 == 1'b1 ) ) // START & STOP state
        begin
            CNT_CLR <= CNT_CLR + 1'b1;  
 
            if ( CNT_CLR == (3 * CLK_FREQ - 1 ) ) // 3 sec 이상 유지
           begin
                CLR <= 1'b1; CNT_CLR <= 32'b0;
            end            
        end            
        else
        begin
            CLR <= 1'b0; CNT_CLR <= 32'b0;    
        end               
    end        
    */

