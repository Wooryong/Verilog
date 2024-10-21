`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/21 15:32:59
// Design Name: 
// Module Name: my_SR_tb
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


module my_SR_tb();

parameter CLK_PER = 10; // 주기 100 ms

reg rst, clk;
wire out;

my_SR uut ( .RST(rst), .CLK(clk), .SEED(8'h47), .Dout(out) );

// Initial Reset
initial
begin
    rst = 1'b1;
    #(CLK_PER * 5) rst = 1'b0;
end 

// CLK Setting 
initial clk = 1'b0;
always #(CLK_PER / 2) clk = ~clk; // CLK 주기 100 ms  
// forever #(clk_Period / 2) clk = ~clk;


endmodule
