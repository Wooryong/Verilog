`timescale 1ns / 1ps

module my_UART_TX_tb();

parameter BAUD_RATE = 115_200; // Baud rate    
parameter Test_Freq = 10 * BAUD_RATE;
parameter CLK_PD = ( 1_000_000_000 / Test_Freq ); // ~868 ns

reg clk, rst;
reg btn1;
reg [3:0] sw;
wire dout, busy;

// parameter BAUD_RATE = 115_200; // Baud rate
my_UART_TX #( .CLK_FREQ(1_152_000) ) uut ( .RST(rst), .CLK(clk), .BTN1(btn1), .SW(sw), .Dout(dout), .Busy(busy) );
// module my_UART_TX(input RST, CLK, input BTN1, input [3:0] SW, output Dout, output reg Busy);

// Initial Reset
initial
begin
    rst = 1'b1;
    #(CLK_PD * 5) rst = 1'b0;
end

// CLK Generation
initial clk = 1'b0;
always #( CLK_PD / 2 ) clk = ~clk;


// Check Full Operation
initial 
begin
    btn1 = 1'b0; sw = 4'b0001;
    wait ( rst == 1'b0 ); // 
    #(CLK_PD * 5); // 
    
    // State Change : IDLE > START
    btn1 = 1'b1; 
    #(CLK_PD * 5); btn1 = 1'b0; #(CLK_PD * 5); 
    #(CLK_PD * 5); // 
    
    // State Change : START > TX > IDLE
    btn1 = 1'b1; 
    #(CLK_PD * 5); btn1 = 1'b0; #(CLK_PD * 5); 
    #(CLK_PD * 100);
    
    
    sw = 4'b0010;  
    // State Change : IDLE > START
    btn1 = 1'b1; 
    #(CLK_PD * 5); btn1 = 1'b0; #(CLK_PD * 5); 
    #(CLK_PD * 5); // 
 
     // State Change : START > TX > IDLE
    btn1 = 1'b1; 
    #(CLK_PD * 5); btn1 = 1'b0; #(CLK_PD * 5); 
    #(CLK_PD * 100);   
  
    $finish;
end

endmodule
