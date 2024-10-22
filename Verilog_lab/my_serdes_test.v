`timescale 1ns / 1ps
/*
module P2S_my(
    input RST, CLK, SOF_in,
    input [7:0] SIN,
    output SOF_out,// output SOF_out
    output SOUT
    );
   
    // 3-bit CNT
    reg [2:0] CNT;
    reg temp_SOUT, temp_SOF_out;
    
    reg Enable;
    
    assign SOUT = temp_SOUT;
    assign SOF_out = temp_SOF_out;
   
    initial temp_SOUT = 1'b0;
    initial temp_SOF_out = 1'b0;
    initial Enable = 1'b0;    
    // Reset OFF & SOF_in Active - Enable ON 
    always @(posedge CLK) // always @(negedge CLK)
    begin
        if (RST == 1'b1)
        begin
            CNT <= 3'b0;
            temp_SOUT <= 1'b0;
            Enable <= 1'b0; //
        end
        else if (SOF_in == 1'b1) // RST == 1'b0
           Enable <= 1'b1;
    end
    
    // Reset OFF & Enable ON - Data Transfer Start
    always @(posedge CLK)
    begin
        if (Enable == 1'b1)
        begin
            temp_SOUT <= SIN[CNT]; // SIN[0] - SIN[1] - ... - SIN[6] - SIN[7]
            CNT <= CNT + 1'b1; // CNT : 1 - ... - 7 - 8          
           
            if( CNT > 3'b111 ) 
            begin
                CNT <= 3'b0; // CNT : 8 -> 0
                Enable <= 1'b0;       
            end
        end
    end 
        
    // Data LSB - SOF_out Active
    always @(posedge CLK)
    begin
        if (CNT == 3'b0)    temp_SOF_out <= 1'b1;
        else                temp_SOF_out <= 1'b0;
    end 

endmodule
*/
/*
module S2P_my(
    input RST, CLK, SOF_in, // SOF_in = SOF_out from P2S
    input Data, // Data = SOUT from P2S
    output SOF_out,
    output [7:0] DOUT
    );

    reg [7:0] temp_Data, temp_DOUT;
    reg temp_SOF_out;
    
    reg [2:0] CNT;
    reg Enable;
    
    assign DOUT = temp_DOUT;
    assign SOF_out = temp_SOF_out;
 
//    initial temp_Data =  8'b0;
//    initial temp_DOUT = 8'b0;
//    initial temp_SOF_out = 1'b0;
    initial Enable = 1'b0;    
    initial CNT = 3'b0;   
 
    // Reset OFF & SOF_in Active - Enable ON   
    always @(posedge CLK)
    begin
        if (RST == 1'b1)
        begin
            temp_DOUT <= 8'b0;
            temp_Data <= 8'b0;
            temp_SOF_out <= 1'b0;
        end    
        else if (SOF_in == 1'b1) // RST == 1'b0
        begin //
            Enable <= 1'b1;  
            temp_SOF_out <= 1'b1; //
        end    
        else // SOF_in == 1'b0
            temp_SOF_out <= 1'b0; //
    end
   
    // Reset OFF & Enable ON - Data Transfer Start
    always @(posedge CLK)
    begin
        if (Enable == 1'b1)
        begin
            temp_Data <= { temp_Data[6:0], Data }; // temp_Data << 1
            // First Data = MSB 
            CNT <= CNT + 1'b1; // CNT : 1 - ... - 7 - 8          
              
            if( CNT > 3'b111 ) 
            begin
                CNT <= 3'b0; // CNT : 8 -> 0
 
                Enable <= 1'b0;
            end                    
        end
    end 
        
    // Data LSB - SOF_out Active
    always @(posedge CLK)
 //   begin
        if ( CNT == 3'b0 ) //   if ( CNT == 3'b111 )
 //       begin
 //           temp_SOF_out <= 1'b1;
            temp_DOUT <= temp_Data;
 //       end
 //       else                
 //           temp_SOF_out <= 1'b0;
 //   end 
        
endmodule
*/