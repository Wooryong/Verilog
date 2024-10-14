`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/07 14:45:32
// Design Name: 
// Module Name: my_module
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


module my_module(
    input [3:0] A,
    input [3:0] B,
    input C,
    output [3:0] out
    );
     
   assign #3 out = C ? A : B; // assign #3 out = C ? A : B;
        
endmodule
