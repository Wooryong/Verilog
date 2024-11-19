`timescale 1ns / 1ps

module my_UART_RX_tb();

parameter BAUD_RATE = 9_600; // Baud rate    
parameter Oversampling_Rate = 16;
parameter Test_Freq = 5 * BAUD_RATE * Oversampling_Rate; // 1_536_000 (1.536 MHz)
parameter CLK_PD = ( 1_000_000_000 / Test_Freq ); // ~651 ns
// 160 CLK_PD = 1-bit

reg rst, clk, rxd;
// reg ref;

wire error;
wire [6:0] an; 
wire ca;

my_UART_RX #( .CLK_FREQ(Test_Freq) ) uut ( .RST(rst), .CLK(clk), .RXD(rxd), .Error(error), .AN(an), .CA(ca) );

// Initial Reset
initial
begin
    rst = 1'b1;
    #(CLK_PD * 5) rst = 1'b0;
end

// CLK Generation
initial clk = 1'b0;
always #( CLK_PD / 2 ) clk = ~clk;

/*
// Ref. bit 
initial
begin
    ref = 1'b0;
    wait ( rst == 1'b0 );    
    always #( CLK_PD * 80 ) ref = ~ref;   
end
*/


// baud rate bit en 脚龋 积己 内靛 累己

// Check Full Operation
// if TX_Data = 'A' > RXD = '1' - '1' - ... - '1' (IDLE) - '0' (START) - '1' (Data[0]) - '0' (Data[1]) - '0' (Data[2]) - '0' (Data[3])
// '0' (Data[4]) - '0' (Data[5]) - '1' (Data[6]) - '0' (Data[7]) - '0' (Parity) - '1' (Stop) - '1' (IDLE) - '1' - ...
// RXD = 1 1 / 0 / 1 0 0 0 0 0 1 0 / 0 / 1 / 1 1 


initial 
begin
    rxd = 1'b1;
    wait ( rst == 1'b0 ); // 
    // IDLE State
    #(CLK_PD * 80); // '1' (IDLE)
    
    // Start State
    rxd = 1'b0; // Start bit
    #(CLK_PD * 80);
    
    // RX State
    rxd = 1'b1; // Data[0]
    #(CLK_PD * 80); 
    rxd = 1'b0; // Data[1]
    #(CLK_PD * 80); 
    rxd = 1'b0; // Data[2]
    #(CLK_PD * 80); 
    rxd = 1'b0; // Data[3]
    #(CLK_PD * 80); 

    rxd = 1'b0; // Data[4]
    #(CLK_PD * 80); 
    rxd = 1'b0; // Data[5]
    #(CLK_PD * 80); 
    rxd = 1'b1; // Data[6]
    #(CLK_PD * 80); 
    rxd = 1'b0; // Data[7]
    #(CLK_PD * 80); 
    
    // Stop State
    rxd = 1'b0; // Parity
    #(CLK_PD * 80); 
    
    // IDLE State
    rxd = 1'b1; // Stop bit
    #(CLK_PD * 80);    
    rxd = 1'b1; // '1' (IDLE) 
    #(CLK_PD * 80); 

    // Start State
    rxd = 1'b0; // Start bit
    #(CLK_PD * 80);
    
    // RX State
    rxd = 1'b1; // Data[0]
    #(CLK_PD * 80); 
    rxd = 1'b1; // Data[1]
    #(CLK_PD * 80); 
    rxd = 1'b1; // Data[2]
    #(CLK_PD * 80); 
    rxd = 1'b1; // Data[3]
    #(CLK_PD * 80); 

    rxd = 1'b0; // Data[4]
    #(CLK_PD * 80); 
    rxd = 1'b0; // Data[5]
    #(CLK_PD * 80); 
    rxd = 1'b1; // Data[6]
    #(CLK_PD * 80); 
    rxd = 1'b0; // Data[7]
    #(CLK_PD * 80); 
 
     // Stop State
    rxd = 1'b0; // Parity
    #(CLK_PD * 80); 
    
    // IDLE State
    rxd = 1'b1; // Stop bit
    #(CLK_PD * 80);    
    rxd = 1'b1; // '1' (IDLE) 
    #(CLK_PD * 80); 
    
    $finish;
end

endmodule
