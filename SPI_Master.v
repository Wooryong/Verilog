`timescale 1ns / 1ps

module SPI_Master(
    input RSTN, CLK,   
    input [1:0] CMD, // {WR_EN, RD_EN}
    input [ADDR_BIT - 1:0] RAM_ADDR, // WR_ADDR or RD_ADDR 
    input [DATA_BIT - 1:0] WR_DATA,
    output reg [DATA_BIT - 1:0] RD_DATA,        
    output reg CSN, SCLK,
    output MOSI,  
    input MISO, // from SPI Slave
    output WR_DONE, RD_DONE 
    );
 
parameter DATA_BIT = 4;
parameter ADDR_BIT = 3;
parameter SPI_BIT = 2 + ADDR_BIT + DATA_BIT; // 2 : Write, Read
parameter DIV_RATIO = 10; // [Freq.] CLK : SCLK = 10 : 1
    
wire RST; assign RST = ~RSTN;
 
assign WR_DONE = (current_state == WRITE) && (BIT_CNT == 5'b0);  
assign RD_DONE = BIT_SHIFT && (current_state == READ) && (BIT_CNT == SPI_BIT);  
 
always @ (posedge CLK) begin
    if ( RST || current_state == IDLE ) RD_DATA <= DATA_BIT * {1'bx};   
    else if ( RD_DONE ) RD_DATA <= SPI_M_reg[DATA_BIT - 1:0];      
end
// assign RD_DATA = (current_state == DONE) ? SPI_M_reg[DATA_BIT - 1:0] : DATA_BIT * {1'bx};

reg [SPI_BIT - 1:0] SPI_M_reg;
assign MOSI = ( (current_state == ADDR) || (current_state == WRITE) ) ? SPI_M_reg[SPI_BIT - 1] : 1'bx; // SPI_M Register MSB > SPI_S Register LSB                             
 
 // *** CSN Signal Generation *** // 
always @ (posedge CLK) begin
    if ( RST ) CSN <= 1'b1;    
    else if ( CMD != 2'b00 ) CSN <= 1'b0;
    else if ( SPI_DONE ) CSN <= 1'b1;
end   
 // *** CSN Signal Generation *** // 

// *** SCLK Gen. *** //   
reg [3:0] DIV_CNT; // 4-bit CNT
wire BIT_SHIFT, BIT_SP, SPI_DONE;
assign BIT_SHIFT = ( DIV_CNT == (DIV_RATIO - 1) ); // SLCK negedge
assign BIT_SP = ( DIV_CNT == (DIV_RATIO/2 - 1) ); // SLCK posedge
assign SPI_DONE = ( BIT_SHIFT & (current_state == DONE) );
always @ (posedge CLK)
begin
    if ( RST ) begin   
        DIV_CNT <= 4'b0; SCLK <= 1'b0;
        // SCLK_CNT <= 3'b0; SCLK <= 1'b0; CNT <= 4'b0; 
    end // if ( RST == 1'b1 )

    else if ( !CSN ) begin
        DIV_CNT <= (DIV_CNT == (DIV_RATIO - 1) ) ? 4'b0 : DIV_CNT + 1'b1;
        
        if ( current_state == DONE ) SCLK <= 1'b0;
        else
            SCLK <= ( (DIV_CNT == (DIV_RATIO/2 - 1)) | (DIV_CNT == (DIV_RATIO - 1)) ) ? ~SCLK : SCLK;
    end // else if ( !CSN ) begin
 end     
// *** SCLK Gen. *** //      
  
// *** SPI Master Register *** // 
reg [4:0] BIT_CNT; // 5-bit Counter 
wire ADDR_DONE;
assign ADDR_DONE = ( BIT_SHIFT && (BIT_CNT == ADDR_BIT + 1) ); // CMD + ADDR 
always @ (posedge CLK)   
begin
    if ( RST ) begin
        SPI_M_reg <= SPI_BIT*{1'b0}; BIT_CNT <= 5'b0;
        // WR_DONE <= 1'b0; RD_DONE <= 1'b0; 
    end 
    else begin // RST == 1'b0   
        if ( current_state == IDLE ) begin
            BIT_CNT <= 5'b0;          
            if ( !CSN ) SPI_M_reg <= { CMD,  RAM_ADDR , WR_DATA };                 
        end // if (current_state == IDLE)  

        else if ( current_state == ADDR ) begin
            if ( BIT_SHIFT ) begin
                // SPI_M_reg <= { SPI_M_reg[SPI_BIT - 2:0], MISO }; // Bit-shift & MISO In (for Test)        
                SPI_M_reg <= { SPI_M_reg[SPI_BIT - 2:0], 1'bx }; // Bit-shift        
                BIT_CNT <= BIT_CNT + 1'b1;         
            end // else if ( current_state == ADDR )
        end // else if ( current_state == ADDR )

        else if ( current_state == WRITE ) begin         
            if ( BIT_SHIFT ) begin
                SPI_M_reg <= { SPI_M_reg[SPI_BIT - 2:0], 1'bx }; // Bit-shift : MSB (MOSI) TX                
                BIT_CNT <= ( BIT_CNT == (SPI_BIT - 1) ) ? 5'b0 : BIT_CNT + 1'b1;                
                // WR_DONE <= ( BIT_CNT == (SPI_BIT - 1) );
            end // if ( BIT_SHIFT )
        end // else if ( current_state == WRITE )
                
         else if ( current_state == READ ) begin         
            // if ( BIT_SHIFT ) begin
            if ( BIT_SP ) begin
                SPI_M_reg <= { SPI_M_reg[SPI_BIT - 2:0], MISO }; // Bit-shift : MSB (MISO) RX                
                BIT_CNT <= ( BIT_CNT == SPI_BIT ) ? 5'b0 : BIT_CNT + 1'b1;                                
                // RD_DONE <= ( BIT_CNT == (SPI_BIT - 1) );
            end // if ( BIT_SHIFT )
        end // else if ( current_state == Read )
        /*
        else if ( current_state == DONE ) begin
            WR_DONE <= 1'b0; RD_DONE <= 1'b0;    
        end // else if ( current_state == DONE )        
        */
    end // else begin // RST == 1'b0    
end   
// *** SPI Master Register *** //  

 // State Definition by using Localparam 
localparam [2:0] // #State : 5 > 3-bit
    IDLE = 3'b000, ADDR = 3'b001, WRITE = 3'b010, READ = 3'b011, DONE = 3'b100; 
    
reg [2:0] current_state, next_state;  

// Initialization - Start State 
always @(posedge CLK)
    current_state <= ( RST ) ? IDLE : next_state;
 
// *** FSM *** //
always @(current_state, CSN, CMD, ADDR_DONE, WR_DONE, RD_DONE, SPI_DONE)
begin 
    case ( current_state )
    IDLE : // 3'b000
        next_state = ( !CSN ) ? ADDR : IDLE;           
    ADDR : begin // 3'b001        
        next_state = ( ADDR_DONE && (CMD == 2'b10 ) ) ? WRITE : 
                              ( ADDR_DONE && (CMD == 2'b01) ) ? READ : ADDR;         
    end    
    WRITE : // 3'b010 
        next_state = ( WR_DONE ) ? DONE : WRITE;
    READ : // 3'b010 
        next_state = ( RD_DONE ) ? DONE : READ;       
    DONE : // 3'b100             
        next_state = ( SPI_DONE ) ? IDLE : DONE;       
    default : next_state = IDLE;    
    endcase            
end 
// *** FSM *** //
    
endmodule
