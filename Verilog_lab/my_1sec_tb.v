`timescale 1ms / 1us // 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/21 11:42:32
// Design Name: 
// Module Name: my_1sec_tb
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


module my_1sec_tb();

parameter CLK_PER = 100; // 주기 100 ms

reg rst, clk;
wire led;

my_1sec #(.CLK_FREQ(10)) uut ( .RST(rst), .CLK(clk), .LED(led) );
// CLK_FREQ = 10 Hz >> 주기 100 ms 

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
