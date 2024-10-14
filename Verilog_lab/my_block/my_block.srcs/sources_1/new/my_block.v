`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/08 14:19:52
// Design Name: 
// Module Name: my_block
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


module my_block(input clk, b, output reg a, c);

always @(posedge clk)
    a <= b; // a = b;
    
always @(posedge clk)
    c <= a; // c = a;

//reg [7:0] my_bus;
//reg a = 1'b1;
//reg b = 1'b1;

// Blocking 
//initial
//begin  
//    rst = 1'b1;
//    #20 rst = 1'b0; ce = 1'b1;
//    #5 my_bus = 8'b1111_0000;
//    #10 clk = 1'b1;
//    #15 and1 = (a & b);
//end

// Non-Blocking 
//initial
//begin  
//    rst <= 1'b1;
//    rst <= #20 1'b0; 
//    ce <= 1'b1;
//    my_bus <= #5 8'b1111_0000;
//    clk <= #10 1'b1;
//    and1 <= #15 (a & b);
//end

// fork-join
//initial
//begin
//    fork
//    rst = 1'b1;
//    #20 rst = 1'b0;
//    ce <= 1'b1;
//    #5 my_bus = 8'b1111_0000;
//    #10 clk <= 1'b1;
//    #15 and1 <= (a & b);
//    join
//    $finish; // 
//end   
  
endmodule
