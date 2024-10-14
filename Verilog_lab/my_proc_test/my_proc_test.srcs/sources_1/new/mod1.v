`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/08 12:15:12
// Design Name: 
// Module Name: mod1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mod1(
//    input a,
//    input b,
//    output reg out // output out
    );

reg a, b, out;
 
    initial 
    begin
        a = 1'b0; b = 1'b0;
        #30; a = 1'b1;
        #30; b = 1'b1;
        #30; b = 1'b0;
    end 
 // -----------------------------   
    always @ (a)
    begin
        out = a | b; //
        out = a & b;
    end // always
         
endmodule
