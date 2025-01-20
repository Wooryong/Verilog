`timescale 1ns / 1ps

module SPI_M(
    input RSTN, CLK,
    
    input [1:0] CMD, // CMD = {WR_START, RD_START};
    input [6:0] Addr, // WR_ADDR or RD_ADDR (7-bit Address)
    input [7:0] WR_DATA,
    // output [7:0] RD_Data,    
        
    output reg CSN, SCLK,
    
    output MOSI,  
    input MISO, // from SPI Slave
    
    output reg WR_DONE, RD_DONE 
    );
    
wire RST;
assign RST = ~RSTN;
 
reg [15:0] SPI_M_reg;
assign MOSI = SPI_M_reg[15]; // SPI_M Register MSB > SPI_S Register LSB
 
wire Mode; // Write or Read or Floating
assign Mode = (CMD[1] == 1'b1) ? 1'b1 :
                          (CMD[0] == 1'b1) ? 1'b0 : 1'bx;                    
  
 // *** CSN Gen. *** // 
always @ (posedge CLK)
begin
    if ( RST == 1'b1 ) CSN <= 1'b1;    
    else if ( (CMD[1] == 1'b1) || (CMD[0] == 1'b1) ) 
        CSN <= 1'b0;
    else if ( Done == 1'b1 ) CSN <= 1'b1;
        // 16-bit TX/RX -> DONE signal > CNS <= 1'b1;
end   
 // *** CSN Gen. *** //  

// assign CMD = {WR_START, RD_START};

// *** SCLK Gen. *** //   
reg [2:0] SCLK_CNT; // 0~5 Count
reg [3:0] CNT; // 4-bit Counter 
reg Done;
wire bit_tick;
assign bit_tick = (CNT == 4'b1001);
always @ (posedge CLK)
begin
    if ( (RST == 1'b1) || (current_state == IDLE) ) begin   
        SCLK_CNT <= 3'b0; SCLK <= 1'b0; 
        CNT <= 4'b0; 
        // bit_tick <= 1'b0;
        Done <= 1'b0;
    end    

    else if ( (current_state == READY) || (current_state == DATA_EX) ) 
    begin
        SCLK_CNT <= (SCLK_CNT == 3'b100) ? 3'b0 : SCLK_CNT + 1'b1;
        SCLK <= (SCLK_CNT == 3'b100) ? ~SCLK : SCLK;
        
        CNT <= (CNT == 4'b1001) ? 4'b0 : CNT + 1'b1;
        // bit_tick <= (CNT == 4'b1000);
    end // else if ( CSN == 1'b0 ) 
    
    else if ( current_state == DONE )
    begin
        SCLK <= 1'b0;      
        
        CNT <= (CNT == 4'b1001) ? 4'b0 : CNT + 1'b1;
        Done <= (CNT == 4'b1001);       
    end
    // 16-bit TX/RX -> DONE signal > SCLK <= 1'b0;            
 end     
// *** SCLK Gen. *** //      
  
// *** MOSI Register *** // 
reg [3:0] bit_CNT; // 4-bit Counter 
reg WR_DONE, RD_DONE;
always @ (posedge CLK)   
begin
    if ( (RST == 1'b1) || (current_state == IDLE) )  begin
        SPI_M_reg <= 16'hFFFF; bit_CNT <= 4'b0;
        WR_DONE <= 1'b0; RD_DONE <= 1'b0;
    end 
    
    else if ( (CSN == 1'b0) && (current_state == IDLE) ) begin
        if (Mode == 1'b1) SPI_M_reg <= { Mode, Addr, WR_DATA};        
        else if (Mode == 1'b0) SPI_M_reg <= { Mode, Addr, 8*{1'bx} };  
    end // else if ( current_state == READY )     
    /*   
    else if ( current_state == READY ) begin
        if (Mode == 1'b1) SPI_M_reg <= { Mode, Addr, WR_DATA};        
        else if (Mode == 1'b0) SPI_M_reg <= { Mode, Addr, 8*{1'bx} };  
    end // else if ( current_state == READY )
    */
    else if ( current_state == DATA_EX ) begin
        if ( bit_tick == 1'b1 ) begin
            SPI_M_reg <= { SPI_M_reg[14:0], MISO }; // 
                 
            bit_CNT <= ( bit_CNT == 4'b1111 ) ? 4'b0 : bit_CNT + 1'b1; 
            WR_DONE <= ( (bit_CNT == 4'b1111) && (Mode == 1'b1) );
            RD_DONE <= ( (bit_CNT == 4'b1111) && (Mode == 1'b0) );
        end // if ( bit_tick == 1'b1 )
    end // else if 
    
end   
// *** MOSI Register *** //   

 // State Definition by using Localparam 
localparam [1:0] // #State : 4 > 2-bit
    IDLE = 2'b00, READY = 2'b01, DATA_EX = 2'b10, DONE = 2'b11; 
    
reg [1:0] current_state, next_state;  
// Initialization - Start State 
always @(posedge CLK)
begin
    current_state <= (RST == 1'b1) ? IDLE : next_state;
end   
// 
 
 // FSM
always @(current_state, CSN, CLK, WR_DONE, RD_DONE, Done)
begin 
    case ( current_state )
    IDLE : // 2'b00
        next_state = (CSN == 1'b0) ? READY : IDLE;                                      
    READY : // 2'b01
       next_state = (CLK == 1'b1) ? DATA_EX : READY;
                      	
    DATA_EX : // 2'b10
        next_state = ( (WR_DONE == 1'b1) || (RD_DONE == 1'b1) ) ? DONE : DATA_EX;
    DONE : // 2'b11              
        next_state = (Done == 1'b1) ? IDLE : DONE;                       
    default : next_state = IDLE;    
    endcase            
end
   
endmodule
