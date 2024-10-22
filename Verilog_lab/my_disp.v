`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/22 15:09:50
// Design Name: 
// Module Name: my_disp
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


module my_disp(
    input [3:0] SW,
    output [6:0] AN
    //output CA
    );
    
    reg [7:0] LED;
    
    assign AN = LED[6:0]; // AN[6] = LED[6], ... , AN[0] = LED[0]
   // assign CA = LED[7];
    
    always @(SW)   
    begin
        LED = 8'h00;
        case (SW) // LED[7] = '0' 
            4'h0 : LED = 8'h3F;  // 4'h0 : LED = 8'h3F;
            4'h1 : LED = 8'h06;
            4'h2 : LED = 8'h5B;
            4'h3 : LED = 8'h4F;
            4'h4 : LED = 8'h66;
            4'h5 : LED = 8'h6D;
            4'h6 : LED = 8'h7D;
            4'h7 : LED = 8'h27;
            4'h8 : LED = 8'h7F;
            4'h9 : LED = 8'h6F; // 4'h9 : LED = 8'h67;                  
            default : LED = 8'hxx; 
        endcase            
     end // always       
    /*    
    always @(SW)   
    begin
        if (BTN == 1'b0) // 1의 자리
        begin
            case (SW) // LED[7] = '0' 
                4'b0000 : LED = 8'h3F; // 00 // LED1 = 8'hBF;
                4'b0001 : LED = 8'h06; // 01 // LED1 = 8'hBF;
                4'b0010 : LED = 8'h5B; // 02 // LED1 = 8'hBF;
                4'b0011 : LED = 8'h4F; // 03 // LED1 = 8'hBF;
                4'b0100 : LED = 8'h66; // 04 // LED1 = 8'hBF;
                4'b0101 : LED = 8'h6D; // 05 // LED1 = 8'hBF;
                4'b0110 : LED = 8'h7D; // 06 // LED1 = 8'hBF;
                4'b0111 : LED = 8'h27; // 07 // LED1 = 8'hBF;
                4'b1000 : LED = 8'h7F; // 08 // LED1 = 8'hBF;
                4'b1001 : LED = 8'h6F; // 09 // LED1 = 8'hBF;                
                4'b1010 : LED = 8'h3F; // 10 // LED1 = 8'hBF;
                4'b1011 : LED = 8'h06; // 11 // LED1 = 8'h86;
                4'b1100 : LED = 8'h5B; // 12 // LED1 = 8'hDB;
                4'b1101 : LED = 8'h4F; // 13 // LED1 = 8'hCF;
                4'b1110 : LED = 8'h66; // 14 // LED1 = 8'hE6;
                4'b1111 : LED = 8'h6D; // 15 // LED1 = 8'hED;                
                default : LED = 8'hxx; 
            endcase            
        end
        else // BTN == 1'b1 (10의 자리)
        begin
            case (SW) // LED[7] = '0' 
                4'b0000 : LED = 8'hBF;
                4'b0001 : LED = 8'hBF;
                4'b0010 : LED = 8'hBF;
                4'b0011 : LED = 8'hBF;
                4'b0100 : LED = 8'hBF;
                4'b0101 : LED = 8'hBF;
                4'b0110 : LED = 8'hBF;
                4'b0111 : LED = 8'hBF;
                4'b1000 : LED = 8'hBF;
                4'b1001 : LED = 8'hBF; // 09              
                4'b1010 : LED = 8'h86; // 10 // LED1 = 8'hBF;
                4'b1011 : LED = 8'h86; // 11 // LED1 = 8'h86;
                4'b1100 : LED = 8'h86; // 12 // LED1 = 8'hDB;
                4'b1101 : LED = 8'h86; // 13 // LED1 = 8'hCF;
                4'b1110 : LED = 8'h86; // 14 // LED1 = 8'hE6;
                4'b1111 : LED = 8'h86; // 15 // LED1 = 8'hED;                
                default : LED = 8'hxx; 
            endcase                  
        end    
    end
    */        
endmodule
//
//
module disp_mod(
    input [3:0] SW,
    input BTN,
    output [6:0] AN,
    output CA
    );
    
my_disp U0 ( .SW(disp_data), .AN(AN) );


wire [3:0] disp_data;
wire [3:0] digit0, digit1;
wire Carry;

assign Carry = ( SW[3] & SW[1] ) |  ( SW[3] & SW[2] );
assign digit0 = Carry ? (SW - 4'b1010) : SW;
// assign digit0 = Carry ? { (~SW[3], ( SW[2:1] - 1'b1 ) , SW[0] } : SW; 
assign digit1 = Carry ? 4'b0001 :4'b0000;   

assign disp_data = BTN ? digit1 : digit0;

assign CA = BTN;

endmodule
