`timescale 1ns / 1ps

module SPI_IO(
		input RSTN, CLK,				
		input WR_START, RD_START, // Trigger Signal		
		output [1:0] CMD, // {WR_EN, RD_EN}
		output [ADDR_BIT - 1:0] ADDR, // WR_ADDR or RD_ADDR		
		input WR_DONE, RD_DONE, // from SPI Master		
		input [DATA_BIT - 1:0] DIN,
		output [DATA_BIT - 1:0] WR_DATA,		
		input [DATA_BIT - 1:0] RD_DATA,
		output reg [DATA_BIT - 1:0] DOUT
    );
 
parameter DATA_BIT = 4;
parameter ADDR_BIT = 3;

wire RST;  assign RST = ~RSTN;

//
assign CMD = {WR_EN, RD_EN};
assign WR_DATA = ( WR_EN ) ? DIN : DATA_BIT * {1'bx}; 
assign ADDR = ( WR_EN ) ? WR_ADDR[ADDR_BIT - 1:0] : 
                        ( RD_EN ) ? RD_ADDR[ADDR_BIT - 1:0] : ADDR_BIT * {1'bx};
//

 // *** Address Counter *** //
reg [ADDR_BIT:0] WR_ADDR, RD_ADDR; // 7-bit Address + Extra 1-bit (MSB) for Control 
always @(posedge CLK) begin
    if ( RST ) begin
        WR_ADDR <= ADDR_BIT * {1'b0}; 
        RD_ADDR <= ADDR_BIT * {1'b0};
    end
    else begin // RST == 1'b0
        // After Write, Read Process, ADDR Update in Advance 
        if ( WR_DONE ) WR_ADDR <= WR_ADDR + 1'b1;    
        else if ( RD_DONE ) RD_ADDR <= RD_ADDR + 1'b1;   
    end // else begin // RST == 1'b0
end 
 // *** Address Counter *** //

// *** Address Logic *** //
wire FULL, EMPTY;
assign FULL = (WR_ADDR[ADDR_BIT-1:0] == RD_ADDR[ADDR_BIT-1:0]) && (WR_ADDR[ADDR_BIT] != RD_ADDR[ADDR_BIT]);
assign EMPTY = (WR_ADDR == RD_ADDR); 
// *** Address Logic *** // 

// *** Check RAM Status *** //
 reg WR_RDY, RD_RDY;
always @(posedge CLK) begin
    if ( FULL ) WR_RDY <= 1'b0; // Inhibit Write Process from ADDR Logic
    else if ( WR_EN ) WR_RDY <= 1'b0; // Inhibit Another Write Process during Previous Write Process
    else WR_RDY <= 1'b1;  
    
    if ( EMPTY ) RD_RDY <= 1'b0; // Inhibit Read Process from ADDR Logic
    else if ( RD_EN ) RD_RDY <= 1'b0; // Inhibit Another Read Process during Previous Read Process
    else RD_RDY <= 1'b1;               
end   
// *** Check RAM Status *** //
 
// *** Command Signal Gen. *** //  
reg WR_EN, RD_EN;
always @(posedge CLK) begin
    if ( RST ) begin
        WR_EN <= 1'b0; RD_EN <= 1'b0; 
    end // RST == 1'b1
    else begin // RST == 1'b0
        if ( WR_START & WR_RDY ) WR_EN <= 1'b1;
        else if ( WR_DONE ) WR_EN <= 1'b0;
        
        if ( RD_START & RD_RDY ) RD_EN <= 1'b1;
        else if ( RD_DONE ) RD_EN <= 1'b0;
    end // else begin // RST == 1'b0
end
// *** Command Signal Gen. *** //
 
// *** Read-out RAM DATA *** //  
always @(posedge CLK) begin
    if ( RST ) DOUT <= DATA_BIT * {1'bx};
    else if ( RD_DONE ) DOUT <= RD_DATA;
end           
// *** Read-out RAM DATA *** //  
              
endmodule
