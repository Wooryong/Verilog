`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/07 09:38:55
// Design Name: 
// Module Name: my_fadder
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


module my_fadder(
    input A,
    input B,
    input Ci,
    output S,
    output Co
    );
    
    // S = (A ^ B) ^ Ci
    // Co = (A & B) | (Ci & (A ^ B) )
    
    // Wire Declaration
    wire ha0_s, ha0_c; // Half-adder 0�� Sum, Carry
    wire ha1_s, ha1_c; // Half-adder 1�� Sum, Carry
    
    // Instantiation �ؿ� ��� ����� ����. 
    assign S = ha1_s;
    assign Co = ha0_c | ha1_c;
    
    // *** Instantiation ***
    // [������ Module��] [�ĺ� Name] ( ������ Module�� ��Ʈ�� ��ȣ ���� )
    my_hadder ha0 (
        .A(A), 
        .B(B), 
        .S(ha0_s), 
        .C(ha0_c) 
        );

    my_hadder ha1 (
        .A(ha0_s), 
        .B(Ci), 
        .S(ha1_s), 
        .C(ha1_c) 
        );
        
endmodule
