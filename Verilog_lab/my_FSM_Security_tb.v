`timescale 1ms / 1us // Check wait_delay 
// `timescale 1ns / 1ps // Check 7-Segment
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/29 09:27:14
// Design Name: 
// Module Name: my_FSM_Security_tb
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


module my_FSM_Security_tb();

// Check wait_delay - Use 10 Hz CLK
parameter CLK_PD = 100; // [Check wait_delay] CLK_FREQ = 10 Hz >> CLK_PD = 100 ms

// Check 7-Segment - Use 125 MHz CLK
// parameter CLK_PD = 8; // [Check 7-Segment] CLK_FREQ = 125 MHz >> CLK_PD = 8 ns
// parameter Rep_ms = 125_000; // [Check 7-Segment] 

reg [1:0] key;
reg door, window;
reg clk, rst;

wire alarm;
wire [6:0] an;
wire ca;

// Check wait_delay - Use 10 Hz CLK
my_FSM_Security #( .CLK_FREQ(10) ) uut (.KEY(key), .DOOR(door), .WINDOW(window), .CLK(clk), .RST(rst), .ALARM(alarm), .AN(an), .CA(ca) );

// Check 7-Segment - Use 125 MHz CLK
// my_FSM_Security uut (.KEY(key), .DOOR(door), .WINDOW(window), .CLK(clk), .RST(rst), .ALARM(alarm), .AN(an), .CA(ca) );
// module my_FSM_Security(input [1:0] KEY, input DOOR, WINDOW, input CLK, RST, output reg ALARM, output [6:0] AN, output CA);

// CLK Generation
initial clk = 1'b0;
always #( CLK_PD / 2 ) clk = ~clk;

// Initial Reset
initial
begin
    rst = 1'b1;
    #(CLK_PD * 5) rst = 1'b0;
end


// Check wait_delay
initial 
begin
    key = 2'b00; door = 1'b0; window = 1'b0;
    wait ( rst == 1'b0 ); // -500 ms : Reset 
    #(CLK_PD * 10); // 500-1500 ms : disarmed
    key = 2'b11; // state Change : disarmed > armed
    #(CLK_PD * 10); // 1500-2500 ms : armed
    key = 2'b00; // state Change : armed > disarmed 
    #(CLK_PD * 10); // 2500-3500 ms : disarmed
    key = 2'b11; // state Change : disarmed > armed   
    #(CLK_PD * 10); // 3500-4500 ms : armed
    door = 1'b1; // state Change : armed > wait_delay
    // in wait_delay state, 5초(50 * CLK주기) 이상 유지되면 count_done Active     
    #(CLK_PD * 2); // 4500-4700 ms : wait_delay (Count Condition X > count_done == 1'b0 유지)
    key = 2'b00; door = 1'b0; // state Change : wait_delay > disarmed
    #(CLK_PD * 3); // 4700-5000 ms : disarmed
    key = 2'b11; // state Change : disarmed > armed    
    #(CLK_PD * 10); // 5000-6000 ms : armed
    door = 1'b1; // state Change : armed > wait_delay   
    #(CLK_PD * 55); // 6000-11500 ms : wait_delay (Count Condition O > count_done == 1'b1)
    // state Change : wait_delay > alarm ( At 11000 ms? ) >> count_done == 1'b0 유지
    #(CLK_PD * 5); // 11500-12000 ms : alarm
    key = 2'b00; door = 1'b0; // state Change : alarm > disarmed
    #(CLK_PD * 10); // 12000-13000 ms    
    $finish;
end


// 1 ms = 10_000_000 ns = 125_000 * 8 ns = Rep_ms * CLK_PD
// 5 sec = Rep_ms * CLK_PD * 5000
//  Check 7-Segment
/*
initial 
begin
    key = 2'b00; door = 1'b0; window = 1'b0;
    wait ( rst == 1'b0 ); // -40 ns : Reset 
    #(Rep_ms * CLK_PD * 20); // -20 ms : disarmed
    key = 2'b11; // state Change : disarmed > armed
    #(Rep_ms * CLK_PD * 20); // 20-40 ms : armed
    key = 2'b00; // state Change : armed > disarmed 
    #(Rep_ms * CLK_PD * 20); // 40-60 ms : disarmed
    key = 2'b11; // state Change : disarmed > armed   
    #(Rep_ms * CLK_PD * 20); // 60-80 ms : armed
    door = 1'b1; // state Change : armed > wait_delay
    // in wait_delay state, 5초 이상 유지되면 count_done Active     
    #(Rep_ms * CLK_PD * 2020); // 80-2100 ms : wait_delay (Count Condition X > count_done == 1'b0 유지)
    key = 2'b00; door = 1'b0; // state Change : wait_delay > disarmed
    #(Rep_ms * CLK_PD * 20); // 2100-2120 ms : disarmed  
    key = 2'b11; // state Change : disarmed > armed    
    #(Rep_ms * CLK_PD * 20); // 2120-2140 ms : armed
    door = 1'b1; // state Change : armed > wait_delay   
    #(Rep_ms * CLK_PD * 10860); // 2140-13000 ms : wait_delay (Count Condition O > count_done == 1'b1)
    // state Change : wait_delay > alarm ( At 7140 ms? ) >> count_done == 1'b0 유지
    #(Rep_ms * CLK_PD * 10); // 13000-13010 ms : alarm
    key = 2'b00; door = 1'b0; // state Change : alarm > disarmed
    #(CLK_PD * 20); // 13010-13030 ms       
    $finish;
end
*/

endmodule
