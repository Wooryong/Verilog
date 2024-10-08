`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/07 11:17:55
// Design Name: 
// Module Name: my_adder
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


module my_adder(
    input [1:0] A,
    input [1:0] B,
    output [1:0] S,
    output Co
    );
    
     // Wire Declaration
    wire ca0, ca1; // Full-adder의 Carry
    // wire [1:0] ca;
    
    // Instantiation 밑에 적어도 결과는 같다.
    assign Co = ca1;
    // assign Co = ca[1];
    
    // *** Instantiation ***
    // [참조할 Module명] [식별 Name] ( 참조할 Module의 포트와 신호 연결 )
    my_fadder fa0(
    .A(A[0]),
    .B(B[0]),
    .Ci(1'b0), // 첫 Full-adder의 Carry-in = 0
    .S(S[0]),
    .Co(ca0) // .Co(ca[0])
    );
    // my_fadder fa0( .A(A[0]), .B(B[0]), .Ci(1'b0), .S(S[0]), .Co(ca0) );
       
    my_fadder fa1(
    .A(A[1]),
    .B(B[1]),
    .Ci(ca0), // 첫 Full-adder의 Carry-in = 0
    .S(S[1]),
    .Co(ca1) // .Co(ca[1])
    );    
    // my_fadder fa1( .A(A[1]), .B(B[2]), .Ci(ca0), .S(S[1]), .Co(ca1) );
    
endmodule
