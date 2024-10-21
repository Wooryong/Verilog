`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/21 11:18:46
// Design Name: 
// Module Name: my_1sec
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


module my_1sec(
    input RST,
    input CLK,
    output reg LED,
    output reg [7:0] Segment //
    );
    
    parameter CLK_FREQ = 125_000_000; // 125 MHz SYSCLK 
        
    reg [31:0] CNT; // 내부 32-bit 저장공간     
    reg enable; 
    reg [3:0] SW;
      
    always @(posedge CLK)
    begin
        if (RST == 1'b1)   
            begin
                CNT <= 32'b0;
                enable <= 1'b0;
                // LED <= 1'b0;
            end    
        else // RST == 1'b0
            begin
                if (CNT < CLK_FREQ - 1) // if (CNT < (CLK_FREQ) )  
                    begin
                        CNT <= CNT + 1'b1;
                        enable <= 1'b0;
                    end
                else // CNT == CLK_FREQ - 1                   
                    begin
                        CNT <= 32'b0;   
                        enable <= 1'b1;
                    end
            end    
    end // always begin-end
   
    initial LED = 1'b0; // V
    initial SW = 4'b0;
    always @(posedge CLK) // always @(enable) << 안됨 
    begin       
        if (enable == 1'b1) 
            begin
                LED <= ~LED; 
                SW <= SW + 1'b1;
                
                if (SW > 15)
                    SW <= 4'b0;   
           end         
    end
    
    always @(SW) // @ (posedge CLK) > CNT Update > SW Update > Non-blocking 
    begin
        case (SW) // Segment[7] = '0' 
            4'b0000 : Segment <= 8'h3F; // 0
            4'b0001 : Segment <= 8'h06; // 1
            4'b0010 : Segment <= 8'h5B; // 2
            4'b0011 : Segment <= 8'h4F; // 3
            4'b0100 : Segment <= 8'h66; // 4
            4'b0101 : Segment <= 8'h6D; // 5
            4'b0110 : Segment <= 8'h7D; // 6
            4'b0111 : Segment <= 8'h27; // 7
            4'b1000 : Segment <= 8'h7F; // 8
            4'b1001 : Segment <= 8'h6F; // 9  
            4'b1010 : Segment <= 8'h77; // A
            4'b1011 : Segment <= 8'h7C; // b
            4'b1100 : Segment <= 8'h39; // C
            4'b1101 : Segment <= 8'h5E; // d
            4'b1110 : Segment <= 8'h79; // E
            4'b1111 : Segment <= 8'h71; // F                 
            default : Segment <= 8'h00; //
        endcase  
    end
                              
endmodule