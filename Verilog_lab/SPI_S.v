`timescale 1ns / 1ps

module SPI_S(
    input CSN,
    input SCLK,    
    
    input MOSI,
    output MISO,
    
    input CLK,    
    output WEN,
    output [6:0] ADDR,
    output [7:0] DIN,
    input [7:0] DOUT
    );
    
reg [15:0] SPI_S_reg;
assign MISO = SPI_S_reg[15]; // SPI_S Register MSB > SPI_M Register LSB

reg [3:0] CNT; // 4-bit Counter 
wire Mode;
// assign Mode = 
reg [7:0] Ctrl;
always @ (posedge SCLK)
begin
    if ( CSN == 1'b0 )
    begin
        SPI_S_reg <= { SPI_S_reg[14:0], MOSI }; // bit-shift
        CNT <= ( CNT == 4'b1111 ) ? 4'b0 : CNT + 1'b1;
         
        if ( CNT == 4'b0111 ) Ctrl <= SPI_S_reg[7:0];
    end
end

always @ (posedge CLK)
begin


end
  
endmodule
