`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/14 16:05:17
// Design Name: 
// Module Name: my_cnt32
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


module my_cnt32(
    input RST,
    input DIR,
    input CLK,
    output [7:0] LED
    );
    
    // CLK : 125 MHz SYSCLK �̿�
    // RST : SW1
    // DIR : SW2
    
    // ���� 32-bit �������
    reg [31:0] CNT;    
    assign LED = CNT[31:24]; // ���� 8-bit�� 
   
    initial
        CNT <= 32'b0;
            
    always @(posedge CLK)
    begin
        if (RST == 1)   CNT <= 32'b0;
        
        else // RST == 0
        begin
            if (DIR == 1)   CNT <= CNT + 1;
            else            CNT <= CNT - 1;   
        end   
    end
      
endmodule
