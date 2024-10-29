`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/29 10:29:20
// Design Name: 
// Module Name: my_security_tb
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


module my_security_tb( );
parameter CLK_PD = 8.0;
reg rst, clk, door;
reg [1:0] key;
wire ca, alarm_siren;
wire [6:0] an;

my_security #(.CLK_FREQ(100))
    uut (    .RST(rst), .CLK(clk), .KEY(key), .DOOR(door), .WINDOW(1'b0),
            .ALARM_SIREN(alarm_siren), .CA(ca), .AN(an));
initial begin
    rst = 1'b1;
    #(CLK_PD*10);
    rst = 1'b0;
end           

initial clk = 1'b0;
always #(CLK_PD/2) clk = ~clk;

initial begin
    key = 2'b00;
    door = 0;
    wait (rst == 1'b0);
    #(CLK_PD*10);
    key = 2'b11;
    #(CLK_PD*10);
    key = 2'b00;
    #(CLK_PD*10);
    key = 2'b11;
    #(CLK_PD*10);
    door = 1'b1;
    @(posedge clk);
    door = 1'b0;
    wait (alarm_siren);
    #(CLK_PD*10);
    key = 2'b00;
    #(CLK_PD*10);
    $finish;
end        
                    
endmodule