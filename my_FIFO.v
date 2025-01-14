`timescale 1ns / 1ps

module my_FIFO(
    input RST,
    input CLK,
    input [DATA_BIT-1:0] DIN, // 8-bit Data
    input WEN, // Write Enable
    input REN, // Read Enable
    output [DATA_BIT-1:0] DOUT, // 8-bit Data
    output reg EMPTY,
    output reg FULL
);

parameter DATA_BIT = 8;
parameter ADDR_BIT = 7;
parameter ROW = 2 ** (ADDR_BIT); // 2^(ADDR_BIT)

// Memory Definition  
reg [DATA_BIT-1:0] ram [0:ROW-1]; // ram [0:127] for Test
// reg [7:0] ram [127:0]; // 8-bit Data & 7-bit Address (128 Rows)

// FIFO Address Definition
reg [ADDR_BIT-1:0] WR_ADDR, RD_ADDR; // 7-bit Address 
// reg [ADDR_BIT:0] WR_ADDR, RD_ADDR; // Extra 1-bit (MSB) for Control 

/*
reg WEN_SYNC, REN_SYNC;
wire W_CLK, R_CLK;
always @(posedge CLK)
begin
    WEN_SYNC <= ( WEN ) ? 1'b1 : 1'b0;
    REN_SYNC <= ( REN ) ? 1'b1 : 1'b0;
end

assign W_CLK = WEN_SYNC & CLK & ~FULL;
assign R_CLK = REN_SYNC & CLK & ~EMPTY;
*/

// *** FIFO Address Update *** // 
always @(posedge CLK)
begin
    if ( RST ) begin
        WR_ADDR <= ADDR_BIT*{1'b0}; RD_ADDR <= ADDR_BIT*{1'b0};
    end
    else begin
        // Write Address
        if ( WEN & !FULL )              WR_ADDR <= WR_ADDR + 1'b1;
        // Read Address   
        else if ( REN & !EMPTY )    RD_ADDR <= RD_ADDR + 1'b1;
    end  // else      
end
// *** FIFO Address Update *** //


// *** FIFO Address Decoding *** //
/*
reg [ROW-1:0] WL;
always @ (posedge CLK)
begin
    WL <= ROW*{1'b0};
    
    if  (WEN)           WL[ WR_ADDR ] <= 1'b1;
    else if  (REN)     WL[ RD_ADDR ] <= 1'b1;
end    
*/
// *** FIFO Address Decoding *** //


// *** FIFO Memory Reset & Data Write *** // 
/*
integer i;
always @ (posedge CLK)
begin
    // FIFO Memory Reset
    if ( RST ) begin        
        for (i = 0; i < ROW; i = i + 1) 
            ram[i] <= DATA_BIT*{1'bx};  // ram[i] <= 8'b0;
    end 
    
    // FIFO Data Write
    else if ( WEN & !FULL ) ram [ WR_ADDR ] <= DIN;
end
*/
// *** FIFO Memory Reset & Data Write *** // 


// *** FIFO Data Read *** //
assign DOUT = ( REN & !EMPTY ) ? ram [ RD_ADDR ] : DATA_BIT*{1'bx};
// *** FIFO Data Read *** //


// *** Control Signal Gen. *** // 
/*
wire ADDR_EQU, ADDR_POS;

assign ADDR_EQU = ( WR_ADDR[ADDR_BIT-1:0] == RD_ADDR[ADDR_BIT-1:0] );
assign ADDR_POS = ( WR_ADDR[ADDR_BIT] ^ RD_ADDR[ADDR_BIT] );

// assign FULL = ADDR_EQU & ADDR_POS;
// assign EMPTY = ADDR_EQU & ~ADDR_POS;
*/

wire FULL_EN, EMPTY_EN;
assign FULL_EN = (RD_ADDR == WR_ADDR + 1'b1);
assign EMPTY_EN = (WR_ADDR == RD_ADDR + 1'b1);

always @ (posedge CLK)
begin
    if ( RST == 1'b1 ) begin
        FULL <= 1'b0; EMPTY <= 1'b1;
    end
    else begin // RST == 1'b0    
        if ( FULL_EN & WEN ) FULL <= 1'b1;
        else if  ( WR_ADDR != RD_ADDR ) FULL <= 1'b0;
        
        if ( EMPTY_EN & REN ) EMPTY <= 1'b1;
        else if  (WR_ADDR != RD_ADDR ) EMPTY <= 1'b0;     
    end          
end
// *** Control Signal Gen. *** // 

endmodule