`timescale 1ns / 1ps

// *** RAM Module *** //
module RAM(
    input CLK,
    input [ADDR_BIT - 1:0] RAM_ADDR, 
    input [DATA_BIT - 1:0] DIN, 
    input WEN, REN, 
    output [DATA_BIT - 1:0] DOUT
);

parameter DATA_BIT = 4;
parameter ADDR_BIT = 3;
parameter ROW = 2 ** (ADDR_BIT); // 2^(ADDR_BIT)

// Memory Definition  
reg [DATA_BIT - 1:0] ram [ROW - 1:0]; 

// initial ram [ 3'b101 ] = 4'b0101;

// Data Read
always @ (posedge CLK)   
    if ( WEN )  ram [ RAM_ADDR ] <= DIN; // WEN == 1'b1 : Data Write

// Data Read  
assign DOUT = ( REN ) ? ram [ RAM_ADDR ] : DATA_BIT * {1'bx};    
    
endmodule    

