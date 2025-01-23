`timescale 1ns / 1ps

module SPI_tb();

parameter CLK_PD = 10.0; // 10 ns CLK (100 MHz)

parameter DATA_BIT = 4;
parameter ADDR_BIT = 3;
// parameter ROW = 2 ** (ADDR_BIT);

SPI_Master #( .DATA_BIT(DATA_BIT), .ADDR_BIT(ADDR_BIT) )
    uut0(
    .RSTN(rstn), .CLK(clk), 
    .CMD(cmd), .RAM_ADDR(addr), .WR_DATA(wr_data), .RD_DATA(rd_data),
    .CSN(csn), .SCLK(sclk), 
    .MISO(miso), .MOSI(mosi), 
    .WR_DONE(wr_done), .RD_DONE(rd_done) 
    );
    
SPI_Slave #( .DATA_BIT(DATA_BIT), .ADDR_BIT(ADDR_BIT) )
    uut1(
    .RSTN(rstn), .CLK(clk),
    .CSN(csn), .SCLK(sclk),      
    .MISO(miso), .MOSI(mosi),
    .WEN(WEN), .REN(REN), 
    .RAM_ADDR(RAM_ADDR), .DIN(DIN), .DOUT(DOUT)
    );

RAM #( .DATA_BIT(DATA_BIT), .ADDR_BIT(ADDR_BIT) )
    uut2(
    .CLK(clk), 
    .WEN(WEN), .REN(REN),
    .RAM_ADDR(RAM_ADDR), .DIN(DIN), .DOUT(DOUT)
    );

reg rstn, clk;
reg [1:0] cmd;
reg [ADDR_BIT - 1:0] addr;
reg [DATA_BIT - 1:0] wr_data;
wire [DATA_BIT - 1:0] rd_data;
wire csn, sclk;

wire mosi, miso;
wire WEN, REN;

wire [ADDR_BIT - 1:0] RAM_ADDR;
wire [DATA_BIT - 1:0] DIN;
wire [DATA_BIT - 1:0] DOUT;

// *** CLK Gen. *** //
initial clk = 1'b1;
always #(CLK_PD/2) clk = ~clk;  
// *** CLK Gen. *** //


// *** Reset Stage *** // 
initial begin
    rstn = 1'b0; #(CLK_PD * 3); rstn = 1'b1; // -15 ns
end
// *** Reset Stage *** // 


initial begin    
    cmd = 2'b00; #(CLK_PD * 5); 
    cmd = 2'b10; addr = 3'b000; wr_data = 4'b0000; wait(wr_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 50);
    cmd = 2'b10; addr = 3'b001; wr_data = 4'b0001; wait(wr_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 50);
    cmd = 2'b10; addr = 3'b010; wr_data = 4'b0010; wait(wr_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 50);
    cmd = 2'b10; addr = 3'b011; wr_data = 4'b0011; wait(wr_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 50);
    
    cmd = 2'b01; addr = 3'b000; wait(rd_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 50);
    cmd = 2'b01; addr = 3'b001; wait(rd_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 50);
    cmd = 2'b01; addr = 3'b010; wait(rd_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 50);
    cmd = 2'b01; addr = 3'b011; wait(rd_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 50);
end
   
endmodule
