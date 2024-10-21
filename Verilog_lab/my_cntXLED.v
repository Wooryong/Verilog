`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/15 11:59:11
// Design Name: 
// Module Name: my_cntXLED
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


module my_cntXLED(
    input RST,
    input DIR,
    input CLK,
    output reg [7:0] LED
    );
    
    // CLK : 125 MHz SYSCLK 이용
    // RST : SW1 
    // DIR : SW2 ('1' : Up_count, '0' : Down_count)
    
    // 내부 32-bit 저장공간
    reg [31:0] CNT;  

    wire [3:0] SW; // 빼면 숫자 0, 1만 나옴 
    assign SW = CNT[31:28]; // 상위 4-bit만
   
    initial
        CNT <= 32'b0;
 
    always @(posedge CLK) // always @(posedge CLK or posedge RST)
    begin
        if (RST == 1'b1)   CNT <= 32'b0; // if (RST == 1)   CNT <= 32'b0;
        
        else // RST == 0
        begin
            if (DIR == 1'b1) // if (DIR == 1) 
                CNT <= CNT + 1'b1; // CNT <= CNT + 1;
            else // DIR == 0
                CNT <= CNT - 1'b1; // CNT <= CNT - 1;
        end // else  
    end // always

    always @(SW) // @ (posedge CLK) > CNT Update > SW Update > Non-blocking 
    begin
        // LED = 8'h00;
        case (SW) // LED[7] = '0' 
            4'b0000 : LED <= 8'h3F;  // 4'h0 : LED = 8'h3F;
            4'b0001 : LED <= 8'h06;
            4'b0010 : LED <= 8'h5B;
            4'b0011 : LED <= 8'h4F;
            4'b0100 : LED <= 8'h66;
            4'b0101 : LED <= 8'h6D;
            4'b0110 : LED <= 8'h7D;
            4'b0111 : LED <= 8'h27;
            4'b1000 : LED <= 8'h7F;
            4'b1001 : LED <= 8'h6F; // 4'h9 : LED = 8'h67;    
            4'b1010 : LED <= 8'h77; //
            4'b1011 : LED <= 8'h7C; //
            4'b1100 : LED <= 8'h39; //
            4'b1101 : LED <= 8'h5E; // 4'hD : LED = 8'h3F;
            4'b1110 : LED <= 8'h79; //
            4'b1111 : LED <= 8'h71; //                  
            default : LED <= 8'h00; 
        endcase            
     end // always   
    
endmodule
