`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/22 09:48:34
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


module my_serdes_tb( );
parameter CLK_PD = 8.0;

reg rst, clk, sof_in;
reg [7:0] din;
wire p2s_sof_out, p2s_sout, s2p_sof_out;
wire [7:0] dout;

 P2S uut_0 ( .RST(rst), .CLK(clk), .SOF_IN(sof_in), .DIN(din), .SOF_OUT(p2s_sof_out), .SOUT(p2s_sout));
 S2P uut_1 ( .RST(rst), .CLK(clk), .SOF_IN(p2s_sof_out), .SIN(p2s_sout), .SOF_OUT(s2p_sof_out), .DOUT(dout));

initial begin
    rst = 1'b1;
    #(CLK_PD*10);
    rst = 1'b0;
end

initial clk = 1'b0;
always #(CLK_PD/2) clk = ~clk;

initial begin
    sof_in = 1'b0;
    din = 8'd0;
    wait (rst == 1'b0);
    #(CLK_PD*10);
    @(posedge clk);
    repeat (10) 
    begin
        sof_in = 1'b1;
        @(posedge clk);
        sof_in = 1'b0;
        repeat(10) @(posedge clk);
        din = din + 1;
    end // repeat
    #1000;
    $finish;
            
end     // initial    

endmodule

