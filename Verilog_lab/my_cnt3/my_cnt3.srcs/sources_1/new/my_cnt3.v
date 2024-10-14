`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/08 09:39:19
// Design Name: 
// Module Name: my_cnt3
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

module dff(input d, clk, rst, 
            output reg q);
    always @(posedge clk or posedge rst) // always @(posedge clk)
    begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end       
endmodule // dff     

module my_cnt3(
    input RST,
    input CLK,
    output [2:0] Q
    );

// Declaration
 wire n1, n2;

assign n1 = (Q[0] ^ Q[1]);
assign n2 = (Q[2] ^ ( Q[0] & Q[1] ) ); 
 
 // Instantiation
dff dff0 (.d( ~Q[0] ), .clk(CLK), .rst(RST), .q( Q[0] ) ); // dff dff0 (~Q[0], CLK, RST, Q[0]);
dff dff1 (.d( n1 ), .clk(CLK), .rst(RST), .q( Q[1] ) );
dff dff2 (.d( n2 ), .clk(CLK), .rst(RST), .q( Q[2] ) );    
        
endmodule // my_cnt3
