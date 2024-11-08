//`timescale 1ms / 1us // Check State Change 
`timescale 1us / 1ns // Check Full Operation

module my_Stopwatch_tb();

// Check State Change  - Use 10 Hz CLK
// parameter CLK_PD = 100; // CLK_FREQ = 10 Hz >> CLK_PD = 100 ms

// Check Full Operation - Use 10 Hz CLK
parameter CLK_PD = 8; // CLK_FREQ = 125 kHz >> CLK_PD = 8 us
parameter Time_1s = 125_000; // CLK_PD * Time_1s = 8 us * (125_000) = 1 s

reg clk, rst;
reg btn0, btn1;
// BTN0 for START & STOP / BTN1 for CLEAR

wire [6:0] an;
wire ca;

// Check State Change - Use 10 Hz CLK
// my_Stopwatch #( .CLK_FREQ(10) ) uut (.CLK(clk), .RST(rst), .BTN0(btn0), .BTN1(btn1), .AN(an), .CA(ca) );
// module my_Stopwatch(input CLK, BTN0, BTN1, output [6:0] AN, output CA );

// Check Full Operation - Use 125 MHz CLK
my_Stopwatch #( .CLK_FREQ(125_000) ) uut (.CLK(clk), .RST(rst), .BTN0(btn0), .BTN1(btn1), .AN(an), .CA(ca) );
// module my_Stopwatch(input CLK, BTN0, BTN1, output [6:0] AN, output CA );

// CLK Generation
initial clk = 1'b1;
always #( CLK_PD / 2 ) clk = ~clk;

// Initial Reset
initial
begin
    rst = 1'b1;
    #(CLK_PD * 5) rst = 1'b0;
end

// Check State Change
/*
initial 
begin
    btn0 = 1'b0; btn1 = 1'b0;
    wait ( rst == 1'b0 ); // -500 ms : Reset
    #(CLK_PD * 5); // 500-1000 ms : CLEAR state
    btn0 = 1'b1; // State Change : CLEAR > START
    #(CLK_PD * 0.1); btn0 = 1'b0; #(CLK_PD * 0.9); // for 10 ms, BTN0 'H'   
    #(CLK_PD * 104); // 1000-10500 ms : START state (Time Start)
    btn0 = 1'b1; // State Change : START > STOP 
    #(CLK_PD * 0.1); btn0 = 1'b0; #(CLK_PD * 0.9); // for 10 ms, BTN0 'H'
    #(CLK_PD * 9); // 10500-11500 ms : STOP state (Time Stop)
    btn1 = 1'b1; // BTN1 for CLEAR 
    #(CLK_PD * 50); // 11500-16500 ms
    btn0 = 1'b0; btn1 = 1'b0;
    #(CLK_PD * 5); // 16500-17000 ms : CLEAR state
    btn0 = 1'b1; // State Change : CLEAR > START
    #(CLK_PD * 0.1); btn0 = 1'b0; #(CLK_PD * 0.9); // for 10 ms, BTN0 'H' 
    #(CLK_PD * 699); // 17000-97000 ms
    btn0 = 1'b1; // State Change : START > STOP 
    #(CLK_PD * 0.1); btn0 = 1'b0; #(CLK_PD * 0.9); // for 10 ms, BTN0 'H'
    #(CLK_PD * 9); // 97000-98000 ms : STOP state (Time Stop)
    $finish;
end
*/

// Check Full Operation
initial 
begin
    btn0 = 1'b0; btn1 = 1'b0;
    wait ( rst == 1'b0 ); // -40 us : Reset
    #(CLK_PD * 5); // 40-80 us : CLEAR state
    btn0 = 1'b1; // State Change : CLEAR > START
    #(CLK_PD * 10); btn0 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN0 'H'   
    #(20 * CLK_PD * Time_1s); // -20 s : START state (Time Start)
    btn1 = 1'b1; // Lab-time #1 (20s?) Save 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'   
    #(15 * CLK_PD * Time_1s); // -35 s : START state (Time Start)
    btn1 = 1'b1; // Lab-time #2 (35s?) Save 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us),BTN1 'H'       
    #(30 * CLK_PD * Time_1s); // -65 s : START state (Time Start)
    // Check 59 > 00
    btn0 = 1'b1; // State Change : START > STOP 
    #(CLK_PD * 10); btn0 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN0 'H'
    #(5 * CLK_PD * Time_1s); // -70 s : STOP state (Time Stop)
    btn1 = 1'b1; // BTN1 for CLEAR 
    #(5 * CLK_PD * Time_1s); // - 75 s : State Change : STOP > CLEAR (At 73 s?)
    // Check All Clear
    btn0 = 1'b0; btn1 = 1'b0;
    #(5 * CLK_PD * Time_1s); // -80 s : CLEAR state 
    btn0 = 1'b1; // State Change : CLEAR > START
    #(CLK_PD * 10); btn0 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us),, BTN0 'H'  
    // 
    #(5 * CLK_PD * Time_1s); // -85 s : START state (Time Start) 
    btn1 = 1'b1; // Lab-time #1 (5s?) Save 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'       
    #(15 * CLK_PD * Time_1s); // -100 s : START state (Time Start)    
    btn1 = 1'b1; // Lab-time #2 (20s?) Save 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'       
    #(5 * CLK_PD * Time_1s); // -105 s : START state (Time Start)        
    btn1 = 1'b1; // Lab-time #3 (25s?) Save 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'       
    #(5 * CLK_PD * Time_1s); // -110 s : START state (Time Start)        
    btn1 = 1'b1; // Lab-time #4 (30s?) Save 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'       
    #(5 * CLK_PD * Time_1s); // -115 s : START state (Time Start)        
    btn1 = 1'b1; // Lab-time #5 (35s?) Save 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'        
    #(5 * CLK_PD * Time_1s); // -120 s : START state (Time Start)        
    btn1 = 1'b1; // Lab-time #6 (40s?) Save - Lab-time #1 (5s?) Discard
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'  
    #(5 * CLK_PD * Time_1s); // -125 s : START state (Time Start) 
    
    // At 125 s, BTN0 5 sec for LOAD
    btn0 = 1'b1; // // State Change : START > STOP
    #(5 * CLK_PD * Time_1s); // -130 s : State Change : STOP > LOAD (At 128 s?)
    btn0 = 1'b0;

    btn1 = 1'b1; // Lab-time Load #2 (20s?) Load 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'     
    #(5 * CLK_PD * Time_1s); // -135 s : Load state (Lab-time Load)
    
    btn1 = 1'b1; // Lab-time Load #3 (25s?) Load 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'     
    #(5 * CLK_PD * Time_1s); // -140 s : Load state (Lab-time Load)   
     
    btn1 = 1'b1; // Lab-time Load #4 (30s?) Load 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'     
    #(5 * CLK_PD * Time_1s); // -145 s : Load state (Lab-time Load)    
      
    btn1 = 1'b1; // Lab-time Load #5 (35s?) Load 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'     
    #(5 * CLK_PD * Time_1s); // -150 s : Load state (Lab-time Load) 
       
    btn1 = 1'b1; // Lab-time Load #6 (40s?) Load 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'     
    #(5 * CLK_PD * Time_1s); // -155 s : Load state (Lab-time Load)    
    
    btn1 = 1'b1; // Lab-time Load #2 (20s?) Load 
    #(CLK_PD * 10); btn1 = 1'b0; #(CLK_PD * 10); // for 10 CLK (80 us), BTN1 'H'     
    #(5 * CLK_PD * Time_1s); // -160 s : Load state (Lab-time Load)    
    
    btn1 = 1'b1; // Lab-time Load #3 (25s?) Load 
    #(5 * CLK_PD * Time_1s); // -165 s : State Change : LOAD > CLEAR (At 163 s?) 
    // Check All Clear
    #(5 * CLK_PD * Time_1s); // - 170 s : CLEAR state               
    $finish;
end

endmodule

