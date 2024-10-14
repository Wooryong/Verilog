`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/14 11:16:49
// Design Name: 
// Module Name: my_mult
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


module my_mult(
    input A, B,
    input [1:0] Sel,
    output reg Z
    );
     
   always @(A, B, Sel)
   begin
//        Z = 1'bx; 
        case (Sel)
            2'b00 : Z = ~A;
            2'b01 : Z = ~(A & B);
            2'b10 : Z = ~( A & (~B) );
            2'b11 : Z = A ^ B;
            default : Z = 1'bx;//
        endcase
   end
       
endmodule
