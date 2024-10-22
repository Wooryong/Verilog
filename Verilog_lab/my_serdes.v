`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/22 09:29:33
// Design Name: 
// Module Name: my_serdes
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


module P2S(
    input RST, CLK, SOF_in,
    input [7:0] DIN,
    output SOF_out,// output SOF_out
    output SOUT
    );

    reg [7:0] DIN_REG;
    reg temp_SOF_out;
    
    assign SOUT = DIN_REG[0]; // Assign LSB
    assign SOF_out = temp_SOF_out;
    
    always @(posedge CLK)
    begin
        if (RST == 1'b1)
        begin
            DIN_REG <= 8'b0;
            temp_SOF_out <= 1'b0;
        end    
        else // RST == 1'b0    
        begin
            if( SOF_in == 1'b1)
            begin
                DIN_REG <= DIN;
                temp_SOF_out <= SOF_in;
            end    
            else // (RST == 1'b0) && (SOF_in == 1'b0)
            begin
                DIN_REG <= (DIN_REG >> 1); 
                temp_SOF_out <= 1'b0;
            end        
        end
    end
           
endmodule
//
//
module S2P(
    input RST, CLK, SOF_in, // SOF_in = SOF_out from P2S
    input Data, // Data = SOUT from P2S
    output SOF_out,
    output [7:0] DOUT
    );

    reg [7:0] temp_Data, temp_DOUT;
    reg temp_SOF_out;
    
    reg [2:0] CNT;
    reg Enable;
    
    assign DOUT = temp_DOUT;
    assign SOF_out = temp_SOF_out;
 
//    initial temp_Data =  8'b0;
//    initial temp_DOUT = 8'b0;
//    initial temp_SOF_out = 1'b0;
    initial Enable = 1'b0;    
    initial CNT = 3'b0;   
 
    // Reset OFF & SOF_in Active - Enable ON   
    always @(posedge CLK)
    begin
        if (RST == 1'b1)
        begin
            temp_DOUT <= 8'b0;
            temp_Data <= 8'b0;
            temp_SOF_out <= 1'b0;
        end    
        else if (SOF_in == 1'b1) // RST == 1'b0
        begin //
            Enable <= 1'b1;  
            temp_SOF_out <= SOF_in; //
        end    
        else // SOF_in == 1'b0
            temp_SOF_out <= 1'b0; //
    end
   
    // Reset OFF & Enable ON - Data Transfer Start
    always @(posedge CLK)
    begin
        if (Enable == 1'b1)
        begin
            temp_Data[CNT] <= Data; // temp_Data << 1
            
            if ( CNT == 3'b111 ) 
            begin
                CNT <= 3'b0;
                Enable <= 1'b0;
                temp_DOUT <= temp_Data;
            end    
            else
                CNT <= CNT + 1'b1; // CNT : 1 - ... - 7 - 8   
        end
    end 
       
endmodule