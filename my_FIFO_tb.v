`timescale 1ns / 1ps

module my_FIFO_tb();

parameter CLK_PD = 10.0; // 10 ns CLK (100 MHz)

parameter DATA_BIT = 8;
parameter ADDR_BIT = 3;
parameter ROW = 2 ** (ADDR_BIT);

my_FIFO #( .DATA_BIT(DATA_BIT), .ADDR_BIT(ADDR_BIT) )
    uut(
    .RST        (rst),
    .CLK        (clk),
    .DIN        (din),   
    .WEN      (wen),
    .REN        (ren),
    .DOUT       (dout),
    .EMPTY      (empty),
    .FULL          (full)  
    );

reg rst, clk;
reg [DATA_BIT-1:0] din;
reg wen, ren;
wire [DATA_BIT-1:0] dout;
wire empty, full;

// *** CLK Gen. *** //
initial clk = 1'b1;
always #(CLK_PD/2) clk = ~clk;  
// *** CLK Gen. *** //


// *** Reset Stage *** // 
initial begin
    rst = 1'b1; #(CLK_PD * 1.5); rst = 1'b0; // -15 ns
    #(CLK_PD * 1.6); // -31 ns
    #(CLK_PD * (8 * ROW) );
    rst = 1'b1; #(CLK_PD * 2); rst = 1'b0; //   
end
// *** Reset Stage *** // 


// *** Write & Read *** //
initial begin    
    wen = 1'b0; ren = 1'b0; #(CLK_PD * 3.1); // -31 ns  
    
    // 1st Write
    wen = 1'b1; #(CLK_PD * (ROW / 2) );  wen = 1'b0; #(CLK_PD * 2);   
    
    // 1st Read  
    ren = 1'b1; #(CLK_PD * ROW); ren = 1'b0; #(CLK_PD * 2);
    
    // 2nd Write
    wen = 1'b1; #(CLK_PD * (ROW - 1) );  wen = 1'b0; #(CLK_PD * 2);
    
    // 2nd Read
    ren = 1'b1;  #(CLK_PD * ROW ); ren = 1'b0; #(CLK_PD * 2);
    
    // 3rd Write
    wen = 1'b1; #(CLK_PD * (ROW + 2) ); wen = 1'b0; #(CLK_PD * 2);
    
    // 3rd Read
    ren = 1'b1; #(CLK_PD * (ROW + 2) ); ren = 1'b0; #(CLK_PD * 2);
    
    // Reset
    wait (rst == 1'b1); wait (rst == 1'b0);
    
    // 4th Write
    wen = 1'b1; #(CLK_PD * (ROW - 1) );  wen = 1'b0; #(CLK_PD * 2);
    
    // 4th Read
    ren = 1'b1;  #(CLK_PD * ROW ); ren = 1'b0; #(CLK_PD * 2);  
end
// *** Write & Read *** //


// *** Data Input Gen. *** //
initial begin    
    din = 0;
    #(CLK_PD * 5.1); // -51 ns   
    forever #(CLK_PD * 1) din = din + 1; // 
end
// *** Data Input Gen. *** //

endmodule
