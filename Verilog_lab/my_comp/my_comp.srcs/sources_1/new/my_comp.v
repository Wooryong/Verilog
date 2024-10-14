`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/14 10:15:35
// Design Name: 
// Module Name: my_comp
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


module my_comp(
    input [1:0] A, B,
//    input Enable, //
    output reg Lower, Equal, Greater
    );
                 
//    always @(A, B, Enable)
//    begin
//        Lower = 1'b0;
//        Equal = 1'b0;
//        Greater = 1'b0;  
          
//        if (Enable == 1)
//        begin
//            if (A < B) Lower = 1'b1; 
//            else if (A == B) Equal = 1'b1; 
//            else if (A > B) Greater = 1'b1;
//        end          
        
//        else  
//        begin        
//            Lower = 1'b0;
//            Equal = 1'b0;
//            Greater = 1'b0;   
//        end           
//    end        

    always @(A, B)
    begin
        Lower = 1'b0;
        Equal = 1'b0;
        Greater = 1'b0; 
        
        if (A < B) Lower = 1'b1; 
        else if (A == B) Equal = 1'b1; 
        else if (A > B) Greater = 1'b1;
        
    end
    
//        else   
//        begin
//            Lower = 1'bx;   
//            Equal = 1'bx;
//            Greater = 1'bx;        
//        end
//    end
       
endmodule
