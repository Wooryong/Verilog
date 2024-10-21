`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/21 15:13:18
// Design Name: 
// Module Name: my_SR
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


module my_SR(
    input RST,
    input CLK,
    input [7:0] SEED,
  //  output reg data_out,
    output Dout
    );
    
//    reg MSB; 
    reg [7:0] SR;
 
    assign bit_7 = SR[2] ^ SR[4]; //
    assign Dout = SR[0]; //
      
    always @(posedge CLK)
    begin
        if (RST == 1'b1)
            SR <= SEED;
        else // RST == 1'b0
        begin
            /*
            MSB = SR[2] ^ SR[4];
            data_out = SR[0];
            SR = SR >> 1;
            SR[7] = MSB;
            */
            SR <= { bit_7 , SR[7:1] };           
        end               
    end
  
endmodule
