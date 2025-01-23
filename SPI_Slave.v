`timescale 1ns / 1ps

module SPI_Slave(
   input RSTN, CLK,
    input CSN, SCLK,    
    
    input MOSI, // SPI_M Register MSB > SPI_S Register LSB
    output MISO, // SPI_S Register MSB > SPI_M Register LSB
    
    output reg WEN, REN,
    output reg [ADDR_BIT - 1:0] RAM_ADDR,
    output reg [DATA_BIT - 1:0] DIN,
    input [DATA_BIT - 1:0] DOUT
    );
    
parameter DATA_BIT = 4;
parameter ADDR_BIT = 3;
parameter SPI_BIT = 2 + ADDR_BIT + DATA_BIT; // 2 : Write, Read
parameter DIV_RATIO = 10; 

wire RST; assign RST = ~RSTN; 

reg [SPI_BIT - 1:0] SPI_S_reg;
assign MISO = ( MISO_EN ) ? SPI_S_reg[SPI_BIT - 1] : 1'bx; // SPI_S Register MSB > SPI_M Register LSB

// *** Bit-shift & Bit-sampling Signal *** //   
reg [3:0] DIV_CNT; // 4-bit CNT
wire BIT_SHIFT, BIT_SP; 
assign BIT_SHIFT = ( DIV_CNT == (DIV_RATIO - 1) ); // SLCK negedge
assign BIT_SP = ( DIV_CNT == (DIV_RATIO/2 - 1) ); // SCLK posedge
always @ (posedge CLK)
begin
    if ( RST ) DIV_CNT <= 4'b0; 
    else if ( !CSN ) DIV_CNT <= (DIV_CNT == (DIV_RATIO - 1) ) ? 4'b0 : DIV_CNT + 1'b1;
    else if ( CSN ) DIV_CNT <= 4'b0;
 end     
// *** Bit-shift & Bit-sampling Signal *** //   

// *** Check Mode (Write or Read) *** //
reg [1:0] Mode; // 
always @ (posedge CLK)
begin
    if ( RST ) Mode <= 2'b0;
    else if ( BIT_CNT == 5'd2 ) Mode <= SPI_S_reg[1:0];
    else if ( CSN ) Mode <= 2'b0;
end
// *** Check Mode (Write or Read) *** //


// ***  *** // 
reg [4:0] BIT_CNT; // 5-bit CNT 
wire ADDR_DONE;
assign ADDR_DONE = ( BIT_SP && (BIT_CNT == ADDR_BIT + 1) ); // CMD + ADDR 
wire WR_DONE, RD_DONE;
assign WR_DONE = (Mode == 2'b10) && (BIT_CNT == SPI_BIT) && ( DIV_CNT == SPI_BIT );
assign RD_DONE = (Mode == 2'b01) && BIT_SHIFT && (BIT_CNT == SPI_BIT - 1);
reg MISO_EN;
always @ (posedge CLK)
begin
    if ( RST ) begin
        SPI_S_reg <= SPI_BIT * {1'b0}; BIT_CNT <= 5'b0; MISO_EN <= 1'b0;    
    end
    else begin // RST == 1'b0   
        if ( current_state == IDLE ) begin
            BIT_CNT <= 5'b0; MISO_EN <= 1'b0;
        end                
        else if ( current_state == ADDR ) begin          
             if ( BIT_SP ) begin
                SPI_S_reg <= { SPI_S_reg[SPI_BIT - 2:0], MOSI }; // Bit-shift & MOSI Shift-in                  
                BIT_CNT <= BIT_CNT + 1'b1;       
            end // if ( BIT_SP )                                 
        end // else if ( current_state == ADDR )
       
        else if ( current_state == WRITE ) begin         
            // if ( BIT_SHIFT ) begin
            if ( BIT_SP ) begin
                SPI_S_reg <= { SPI_S_reg[SPI_BIT - 2:0], MOSI }; // Bit-shift : MSB (MOSI) TX                
                BIT_CNT <= ( BIT_CNT == SPI_BIT ) ? 5'b0 : BIT_CNT + 1'b1;                
            end // if ( BIT_SHIFT )
        end // else if ( current_state == WRITE )
  
        else if ( current_state == READ ) begin         
            if ( BIT_SHIFT ) begin
                if( (BIT_CNT == ADDR_BIT + 2) && (!MISO_EN) ) begin
                    SPI_S_reg[SPI_BIT - 1:ADDR_BIT + 2] <= DOUT;
                    MISO_EN <= 1'b1;
                end   
                else begin
                    SPI_S_reg <= { SPI_S_reg[SPI_BIT - 2:0], 1'bx }; // Bit-shift                
                    BIT_CNT <= ( BIT_CNT == SPI_BIT ) ? 5'b0 : BIT_CNT + 1'b1;           
                end                        
            end // if ( BIT_SHIFT )                               
        end // else if ( current_state == READ )     
    
        else if ( current_state == DONE ) MISO_EN <= 1'b0;
                  
    end // else begin // RST == 1'b0
end


always @ (posedge CLK)
begin
    if ( RST || (current_state == IDLE) ) begin
        WEN <= 1'b0; REN <= 1'b0; RAM_ADDR <= ADDR_BIT * {1'bx}; DIN <= DATA_BIT * {1'bx};     
    end    
    else if ( current_state == READ ) begin
        if ( BIT_CNT == ADDR_BIT + 2 ) begin
            REN <= 1'b1; RAM_ADDR <= SPI_S_reg[ADDR_BIT - 1:0];
        end           
        else begin
            REN <= 1'b0; RAM_ADDR <= ADDR_BIT * {1'bx};                    
        end
    end // else if ( current_state == READ )       

    else if ( Mode == 2'b10 ) begin    
        if ( BIT_CNT == SPI_BIT ) begin
            WEN <= 1'b1; 
            RAM_ADDR <= SPI_S_reg[SPI_BIT - 3:DATA_BIT]; 
            DIN <= SPI_S_reg[DATA_BIT - 1:0];     
        end           
        else begin
            WEN <= 1'b0; RAM_ADDR <= ADDR_BIT * {1'bx}; DIN <= DATA_BIT * {1'bx};                   
        end
    end // else if ( Mode == 2'b10 )       
end


/*
// *** SPI Slave - RAM *** //
always @ (posedge CLK)
begin
    if ( RST ) begin
        WEN <= 1'b0; REN <= 1'b0; ADDR <= 7'bx; DIN <= 8'bx;
   end // if ( RST == 1'b1 )
   else begin // RST == 1'b0
        // Write Process
        if ( Mode == 2'b10 ) begin 
            if ( BIT_CNT == 5'b0 ) begin
                WEN <= 1'b1; 
                ADDR <= SPI_S_reg[SPI_BIT - 3:DATA_BIT]; 
                DIN <= SPI_S_reg[DATA_BIT - 1:0];                 
            end //  if ( BIT_CNT == 5'b0 )     
        end // if ( Mode == 2'b10 ) 
       
        // Read Process
        else if ( Mode == 2'b01 ) begin
            if ( BIT_CNT == ADDR_BIT + 2 ) begin            
                REN <= 1'b1; ADDR <= SPI_S_reg[ADDR_BIT - 1:0]; // 7-bit Address
            end // if ( BIT_CNT == ADDR_BIT + 2 )                      
        end // else if ( Mode == 2'b01 )     
        
        else begin // Mode == 2'b0        
            WEN <= 1'b0; REN <= 1'b0; ADDR <= 7'bx; DIN <= 8'bx;          
        end // else // Mode == 1'bx     
    end // else begin // RST == 1'b0   
end 
*/

 // State Definition by using Localparam 
localparam [2:0] // #State : 5 > 3-bit
    IDLE = 3'b000, ADDR = 3'b001, WRITE = 3'b010, READ = 3'b011, DONE = 3'b100; 
    
reg [2:0] current_state, next_state;  

// Initialization - Start State 
always @(posedge CLK)
    current_state <= ( RST ) ? IDLE : next_state;
 
// *** FSM *** //
always @(current_state, CSN, ADDR_DONE, Mode, WR_DONE, RD_DONE)
begin 
    case ( current_state )
    IDLE : // 3'b000
        next_state = ( !CSN ) ? ADDR : IDLE;           
    ADDR : begin // 3'b001        
        next_state = ( ADDR_DONE && (Mode == 2'b10 ) ) ? WRITE : 
                              ( ADDR_DONE && (Mode == 2'b01) ) ? READ : ADDR;         
        end    
    WRITE : // 3'b010 
        next_state = ( WR_DONE ) ? DONE : WRITE;
    READ : // 3'b011 
        next_state = ( RD_DONE ) ? DONE : READ;       
    DONE : // 3'b100 
        next_state = ( CSN ) ? IDLE : DONE;               
    default : next_state = IDLE;    
    endcase            
end 
// *** FSM *** //
  
endmodule