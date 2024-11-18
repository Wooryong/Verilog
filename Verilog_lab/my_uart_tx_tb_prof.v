`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/12 12:23:37
// Design Name: 
// Module Name: my_uart_tx_tb
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


module my_uart_tx_tb();
parameter CLK_PD = 8.0;
parameter BAUD_RATE = 1200;
parameter CLK_FREQ = BAUD_RATE*10;

reg rst, clk, btn1;
reg [3:0] sw;
wire        uart_tx, busy;
 
//------ uut instantiation 
my_uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) 
    uut (
    .RST    (rst),
    .CLK    (clk),
    .BTN1   (btn1),
    .SW     (sw),
    .UART_TX (uart_tx),
    .BUSY       (busy)
    );
//---------- rst, clk gen
initial begin
    rst = 1'b1;
    #(CLK_PD*10);
    rst = 1'b0;
end
initial clk = 1'b0;
always #(CLK_PD/2) clk = ~clk;

// ------ btn1, sw gen
initial begin
    sw = 4'd0;
    btn1 = 1'b0;
    wait (busy == 1'b0);
    #(CLK_PD*20);
    btn1 = 1'b1;
    sw = 4'd1;
    #(CLK_PD*20);
    btn1 = 1'b0;
    sw = 4'd3;
    wait (busy == 1'b0);
    #(CLK_PD*20);
    btn1 = 1'b1;
    #(CLK_PD*20);
    btn1 = 1'b0;
    #(CLK_PD*50);
    $finish;
end     
    
    
    
       
    
    



endmodule
