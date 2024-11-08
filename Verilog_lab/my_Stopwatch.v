`timescale 1ns / 1ps

module my_Stopwatch(
    (* MARK_DEBUG="true" *)
    input CLK, RST, 
    (* MARK_DEBUG="true" *)
    input BTN0, BTN1, // BTN0 for START & STOP / BTN1 for Lab-time & CLEAR
    (* MARK_DEBUG="true" *)
    output [6:0] AN,
    (* MARK_DEBUG="true" *)
    output CA,
    output LED_START, LED_STOP, LED_LOAD // LED Colors by State 
    );
    
    // Parameters
    parameter CLK_FREQ = 125_000_000; // Use 125 MHz SYSCLK    
  	
  	// De-bounce Code for BTNs
  	reg BTN0_chk1, BTN0_chk2, BTN1_chk1, BTN1_chk2;
  	(* MARK_DEBUG="true" *)
  	wire BTN0_press, BTN1_press;
  	  	  	
  	always @(posedge CLK) // always @(posedge CLK)
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
	// Pos_Sel : 10 ms Toggle && tick : 10 ms Posedge
	always @(posedge CLK)
	begin
        if ( RST == 1'b1 ) begin
            CNT_Seg <= 32'b0; Pos_Sel <= 1'b0; tick <= 1'b0;  
        end 
        else // RST == 1'b0 
        begin	   
            if ( CNT_Seg == ( (CLK_FREQ-1)/100 ) ) begin // 10ms Toggle            
                CNT_Seg <= 32'b0; Pos_Sel <= ~Pos_Sel; tick <= 1'b1;
            end
            else begin
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
    //        
        
    // FSM Current & Next State
    (* MARK_DEBUG="true" *)
    reg [1:0] current_state, next_state; 
    //
    
    (* MARK_DEBUG="true" *)
    reg time_start, wait_clear, wait_load;;  
    (* MARK_DEBUG="true" *)  
    reg [31:0] CNT_1s, CNT_CLR, CNT_LOAD; 
    (* MARK_DEBUG="true" *)
    reg CLR, load;
    (* MARK_DEBUG="true" *)  
    reg [5:0] Time_sec; // 00-59
    
    (* MARK_DEBUG="true" *)
    reg [29:0] Time_save; // 6-bit * 5
    (* MARK_DEBUG="true" *)
    reg [2:0] Save_flag; // Possible 5 Lab-times (#1 : '001', #2 : '010' , #3 : '011', #4 : '100', #5 : '101')
    (* MARK_DEBUG="true" *)
    reg [2:0] Max_Save_flag; // #Time-data
    
    // Time Update by tick signal && Lab-time Save & Load
    always @(posedge CLK)
	begin	   
        if ( ( RST == 1'b1 ) || ( CLR == 1'b1 ) )
        begin
            CNT_1s <= 32'b0; Time_sec <= 6'b0;  
            Time_save <= 30'b0; Save_flag <= 3'b0;
        end 
        
        // Time Update        
        else if ( ( time_start == 1'b1 ) && ( tick == 1'b1 ) ) // ( RST == 1'b0 ) && ( CLR == 1'b0 )
        begin
            if ( CNT_1s == 99 ) // 1 s = 100 * (10 ms)
            begin
                CNT_1s <= 32'b0; 
           
                if (Time_sec == 59)	Time_sec <= 6'b0;  
                else                Time_sec <= Time_sec + 1'b1;                                                      
            end // if
            else CNT_1s <= CNT_1s + 1'b1;    
        end // else if 
        //
        
        // Lab-time Save
        else if ( ( wait_load == 1'b1 ) && ( BTN1_press == 1'b1 ) ) // in START & STOP state - Lab-time Save
        // if ( ( wait_load == 1'b1 ) && ( BTN1 == 1'b1 ) )
        begin
            Time_save <= { Time_save[23:0] , Time_sec }; // Time_save : Save #5 Lab-time           
            // Save_flag : Time-date Index 
            if ( Save_flag < 3'b101 )   Save_flag <= Save_flag + 1'b1; // 0 (Empty) - 5 (Full Save)    
            else                        Save_flag <= 3'b101;                       
        end 
        //
        
        // Lab-time Load
        else if ( ( wait_load == 1'b0 ) && ( BTN1_press == 1'b1 ) ) // in LOAD state - Lab-time Load
        // if ( ( wait_load == 1'b0 ) && ( BTN1 == 1'b1 ) )
        begin
            case ( Save_flag )
            3'b101 : begin // #1                
                    Time_sec <= Time_save[29:24]; Save_flag <= Save_flag - 1'b1;
                end
            3'b100 : begin // #2                                     
                    Time_sec <= Time_save[23:18]; Save_flag <= Save_flag - 1'b1;
                end                    
            3'b011 : begin // #3                                     
                    Time_sec <= Time_save[17:12]; Save_flag <= Save_flag - 1'b1;
                end   
            3'b010 : begin // #4                                   
                    Time_sec <= Time_save[11:6]; Save_flag <= Save_flag - 1'b1;
                end                                       
            3'b001 : begin // #5                                    
                Time_sec <= Time_save[5:0]; Save_flag <= Max_Save_flag;
                end   
            default : Time_sec <= 6'b0; // No Lab-time      
            endcase // case ( Save_flag )
        end                   
        //          
    end        
    
    // Digit Separation - [Digit_10s][Digit_1s]
    always @(Time_sec)
    begin
        Digit_10s = Time_sec / 10;
        Digit_1s = Time_sec % 10;
        // ex) Time_sec = 29 > [Digit_10s = 2][Digit_1s = 9]
    end         
    //
        
    // Generate CLR by tick signal 
    always @(posedge CLK)
    begin    
        if ( ( wait_clear == 1'b1 ) && ( BTN1 == 1'b1 ) && ( tick == 1'b1 ) ) // START & STOP state   
        begin
            if ( CNT_CLR == 299 ) begin // 3 s = 300 * (10 ms)            
                CLR <= 1'b1; CNT_CLR <= 32'b0;
            end
            else CNT_CLR <= CNT_CLR + 1'b1;  
        end    
        else if ( ( wait_clear == 1'b0 ) || ( BTN1 == 1'b0 ) ) begin           
            CLR <= 1'b0; CNT_CLR <= 32'b0;    
        end               
    end        
    //   
     
    // Generate load by tick signal
    always @(posedge CLK)
    begin 
        if ( ( wait_load == 1'b1 ) && ( BTN0 == 1'b1 ) && ( tick == 1'b1 ) ) // START & STOP state      
        begin
            if ( CNT_LOAD == 299 ) begin // 3 s = 300 * (10 ms)            
                load <= 1'b1; CNT_LOAD <= 32'b0; 
                Max_Save_flag <= Save_flag; // Load State 변화 시 저장된 Lab-time 횟수   
            end
            else CNT_LOAD <= CNT_LOAD + 1'b1;  
        end            
        else if ( ( wait_load == 1'b0 ) || ( BTN0 == 1'b0 ) ) begin        
            load <= 1'b0; CNT_LOAD <= 32'b0;    
        end               
    end    
    //

    // State Representation by LED 
    assign LED_START = ( current_state == START ); // LED0_R
    assign LED_STOP = ( current_state == STOP ); // LED0_G
    assign LED_LOAD = ( current_state == LOAD ); // LED0_B
                 
    // Initialization - Start State 
    always @(posedge CLK)
    begin
        if ( RST == 1'b1 )  current_state <= CLEAR;
        else                current_state <= next_state;                
    end // always @(posedge CLK)   
    // 

     // 각 Current_state에서 State Transition 조건 및 Output
    always @(current_state, BTN0_press, CLR, load)
    begin
        // BTN0 Short Press : CLEAR > START > STOP > START > STOP > ...
        // BTN0 Long (> 3 sec) Press (load = 1) : START or STOP > LOAD 
        // BTN1 Short Press : (START or STOP) Lab-time Save & (Load) Lab-time Load
        // BTN1 Long (> 3 sec) Press (CLR = 1) : START or STOP or LOAD > CLEAR       
        case (current_state)
        CLEAR : // 2'b00
            // State Transition 조건
            begin
                if ( BTN0_press == 1'b1 )   next_state = START; // if ( BTN0 == 1'b1 ) next_state = START;                 
                else                        next_state = CLEAR;  
                // State Output (Event)                
                wait_clear = 1'b0; time_start = 1'b0; wait_load = 1'b1;
            end
        START : // 2'b01
            begin
                if ( load == 1'b1 )             next_state = LOAD;
                else if ( BTN0_press == 1'b1 )  next_state = STOP; // else if ( BTN0 == 1'b1 ) next_state = STOP;
                else if ( CLR == 1'b1 )         next_state = CLEAR;              
                else                            next_state = START;
                // State Output (Event)
                wait_clear = 1'b1; time_start = 1'b1; wait_load = 1'b1;                  
            end 
        STOP : // 2'b10     
            begin
                if ( load == 1'b1 )             next_state = LOAD;
                else if ( BTN0_press == 1'b1 )  next_state = START; // else if ( BTN0 == 1'b1 )  next_state = START;                 
                else if ( CLR == 1'b1 )         next_state = CLEAR;               
                else                            next_state = STOP;
                // State Output (Event)    
                wait_clear = 1'b1; time_start = 1'b0; wait_load = 1'b1;                                             
            end 
        LOAD : // 2'b11     
            begin
                if ( CLR == 1'b1 )      next_state = CLEAR;
                else                    next_state = LOAD;
                // State Output (Event)   
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

