`timescale 1ns / 1ps

module SPI_M_tb();

parameter CLK_PD = 10.0; // 10 ns CLK (100 MHz)

parameter DATA_BIT = 4;
parameter ADDR_BIT = 3;
// parameter ROW = 2 ** (ADDR_BIT);

SPI_Master #( .DATA_BIT(DATA_BIT), .ADDR_BIT(ADDR_BIT) )
    uut(
    .RSTN(rstn), .CLK(clk), 
    .CMD(cmd), .RAM_ADDR(addr), .WR_DATA(wr_data),
    .CSN(csn), .SCLK(sclk), 
    .MISO(miso), .MOSI(mosi), 
    .WR_DONE(wr_done), .RD_DONE(rd_done) 
    );

reg rstn, clk;
reg [1:0] cmd;
reg [ADDR_BIT - 1:0] addr;
reg [DATA_BIT - 1:0] wr_data;
wire csn, sclk;

reg miso;
wire mosi;

wire wr_done, rd_done;

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
    cmd = 2'b00; #(CLK_PD * 5); cmd = 2'b10;
    // cmd = 2'b10; wait(wr_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 10);
    cmd = 2'b01; wait(rd_done == 1'b1); #(CLK_PD * 1); cmd = 2'b00; #(CLK_PD * 10);
end

initial begin
    // miso = 1'b1;
    miso = 1'bx; wait(csn == 1'b0); miso = 1'b1;    
    forever #(CLK_PD * 10) miso = ~miso;
end
    // wait(csn == 1'b0); #(CLK_PD); 
    // always #(CLK_PD*10) miso = ~miso;  


initial begin
    addr = ADDR_BIT * {1'bx}; wait(cmd != 2'b00);
    addr = 7'b101_0101;
end

initial begin
    wr_data = DATA_BIT * {1'bx}; wait(cmd != 2'b00);
    wr_data = 8'b0101_0101;
    end

endmodule
