`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/22 10:36:02
// Design Name: 
// Module Name: my_serdes_tb
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


module my_serdes_tb();

//parameter CLK_PER = 10; // 주기 10 ns

reg rst, clk, sof_in;
// reg [7:0] din;

wire p2s_sof_out, p2s_sout, s2p_sof_out;
wire [7:0] dout;

P2S uut_0 ( .RST(rst), .CLK(clk), .SOF_in(sof_in), .DIN(8'h9B), .SOF_out(p2s_sof_out), .SOUT(p2s_sout) ); // DIN = 1001_1011
S2P uut_1 ( .RST(rst), .CLK(clk), .SOF_in(p2s_sof_out), .Data(p2s_sout), .SOF_out(s2p_sof_out), .DOUT(dout) );

// Initial Reset
initial
begin
    rst = 1'b1;
    #20 rst = 1'b0;
end 

// CLK Setting 
initial clk = 1'b0;
always #5 clk = ~clk; // CLK 주기 100 ms  
// forever #(clk_Period / 2) clk = ~clk;

// SOF_in Setting
initial 
begin
    sof_in = 1'b0;
    #30 sof_in = 1'b1;
    #10 sof_in = 1'b0;
    #70 sof_in = 1'b1;
    #10 sof_in = 1'b0;
    #70 sof_in = 1'b1;
    #10 sof_in = 1'b0;
    #70 sof_in = 1'b1;
end

endmodule
