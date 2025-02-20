
`timescale 1 ns / 1 ps

	module myip_slave_lite_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
		(* MARK_DEBUG="true" *)	
		input wire RX_VALID,          // RX_DONE (RX_RDY in UART_RX)
		(* MARK_DEBUG="true" *)
		input wire [7:0] RX_DATA,     // UART RX DATA 8-bit
		(* MARK_DEBUG="true" *)	
		input wire TX_READY,          //
		(* MARK_DEBUG="true" *)
		output wire TX_START,         //
		(* MARK_DEBUG="true" *)
		output wire [7:0] TX_DATA,     //
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		input wire  S_AXI_ARESETN,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		input wire [2 : 0] S_AXI_AWPROT,
		input wire  S_AXI_AWVALID,
		output wire  S_AXI_AWREADY,
		(* MARK_DEBUG="true" *)
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input wire  S_AXI_WVALID,
		output wire  S_AXI_WREADY,
		output wire [1 : 0] S_AXI_BRESP,
		output wire  S_AXI_BVALID,
		input wire  S_AXI_BREADY,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		input wire [2 : 0] S_AXI_ARPROT,
		input wire  S_AXI_ARVALID,
		output wire  S_AXI_ARREADY,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		output wire [1 : 0] S_AXI_RRESP,
		output wire  S_AXI_RVALID,
		input wire  S_AXI_RREADY	
	);

	// AXI4LITE signals
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	// (* MARK_DEBUG="true" *)
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_wdata;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr; //

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	(* MARK_DEBUG="true" *)
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	(* MARK_DEBUG="true" *)
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	(* MARK_DEBUG="true" *)
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	(* MARK_DEBUG="true" *)
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	integer	 byte_index;
	   
	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;

	 //state machine varibles 
	 reg [1:0] state_write;
	 reg [1:0] state_read;

	 //State machine local parameters
	 localparam Idle = 2'b00,Raddr = 2'b10,Rdata = 2'b11 ,Waddr = 2'b10,Wdata = 2'b11;

// Implement Write state machine
// Outstanding write transactions are not supported by the slave 
// i.e., master should assert bready to receive response on or before it starts sending the new transaction
always @(posedge S_AXI_ACLK)                                 
begin                                 
	if (S_AXI_ARESETN == 1'b0)                                 
	begin                                 
		axi_awready <= 0; axi_wready <= 0;                                 
		axi_bvalid <= 0; axi_bresp <= 0;                                 
		state_write <= Idle;                                 
	end 
                                
	else // S_AXI_ARESETN == 1'b1                               
	begin                                 
		case (state_write)                                 
		Idle:                                      
		begin                                 
			if (S_AXI_ARESETN == 1'b1)                                  
            begin                                 
                axi_awready <= 1'b1;                                 
                axi_wready <= 1'b0; //                               
                state_write <= Waddr; //cb
			end                                 
			else // S_AXI_ARESETN == 1'b0
				state_write <= state_write;                                 
		end // Idle:                                 
	             
		Waddr:        
		//At this state, slave is ready to receive address 
		// along with corresponding control signals and first data packet. 
		// Response valid is also handled at this state     
        begin            
			if (S_AXI_AWVALID && S_AXI_AWREADY)
			begin
                axi_awready <= 1'b0; axi_wready <= 1'b1;
				axi_awaddr <= S_AXI_AWADDR;			
				state_write <= Wdata;   	                
            end
            else	
			     state_write <= Waddr; 	 
		end // Waddr:  

		Wdata:        
		//At this state, slave is ready to receive the data packets 
		// until the number of transfers is equal to burst length                                 
		begin              
			axi_wdata <= S_AXI_WDATA; 
                  
			if (S_AXI_WVALID)                                 
	        begin                                 
				axi_wready <= 1'b0; axi_awready <= 1'b1; axi_bvalid <= 1'b1;	                                	                   	   				   
				state_write <= Waddr;                          
			end   
			                              
            else // S_AXI_WVALID = 1'b0                                 
            begin                                 
                state_write <= Wdata;     
                            
				if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;                                 
            end                                              
		end // Wdata:       
		                         
		endcase                                 
	end // else // S_AXI_ARESETN == 1'b1                                 
end                                 

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	 
always @( posedge S_AXI_ACLK )
begin
    if ( S_AXI_ARESETN == 1'b0 )
    begin
        slv_reg0 <= 0; slv_reg1 <= 0; 
        slv_reg2 <= 0; slv_reg3 <= 0;
    end 
    else // S_AXI_ARESETN == 1'b1
    begin
        if (S_AXI_WVALID)
        begin
            case ( axi_awaddr[ ADDR_LSB+OPT_MEM_ADDR_BITS : ADDR_LSB ] )
                2'h0: slv_reg0 <= axi_wdata;
                2'h1: slv_reg1 <= axi_wdata;
                2'h2: slv_reg2 <= axi_wdata;
                2'h3: slv_reg3 <= axi_wdata;
                default : 
                begin
                    slv_reg0 <= slv_reg0; slv_reg1 <= slv_reg1;
                    slv_reg2 <= slv_reg2; slv_reg3 <= slv_reg3;
                end
            endcase
        end // if (S_AXI_WVALID)
        
        else // S_AXI_WVALID == 1'b0
        begin  
            // UART RX             
            if ( RX_VALID == 1'b1 ) slv_reg3 <= { 24'b0 , RX_DATA }; // Save RX_DATA to slv_reg3 
        
            // Check UART_RX Status 
            if ( RX_VALID == 1'b1 )             slv_reg2[31] = 1'b1; // RX Data Ready
            else if ( UART_RX_CLEAR == 1'b1 )   slv_reg2[31] = 1'b0; // RX Data Used (already printed at Tera Term)        
            
            // UART TX  
            slv_reg0 <= { TX_READY, 31'b0 }; // Check UART TX Status  
                                           
        end // else // S_AXI_AWVALID == 1'b0
                                          
    end // else // S_AXI_ARESETN == 1'b1
end // always @( posedge S_AXI_ACLK ) begin    

(* MARK_DEBUG="true" *)
wire UART_RX_CLEAR; // UART RX DATA printed > Clear 
assign UART_RX_CLEAR = slv_reg2[0]; 
      
assign TX_DATA = slv_reg1[7:0];
assign TX_START = slv_reg0[0];   

	// Implement read state machine
	  always @(posedge S_AXI_ACLK)                                       
	    begin                                       
	      if (S_AXI_ARESETN == 1'b0)                                       
	        begin                                       
	         //asserting initial values to all 0's during reset                                       
	         axi_arready <= 1'b0;                                       
	         axi_rvalid <= 1'b0;                                       
	         axi_rresp <= 1'b0;                                       
	         state_read <= Idle;                                       
	        end                                       
	      else                                       
	        begin                                       
	          case(state_read)                                       
	            Idle:     //Initial state inidicating reset is done and ready to receive read/write transactions                                       
	              begin                                                
	                if (S_AXI_ARESETN == 1'b1)                                        
	                  begin                                       
	                    state_read <= Raddr;                                       
	                    axi_arready <= 1'b1;                                       
	                  end                                       
	                else state_read <= state_read;                                       
	              end                                       
	            Raddr:        //At this state, slave is ready to receive address along with corresponding control signals                                       
	              begin                                       
	                if (S_AXI_ARVALID && S_AXI_ARREADY)                                       
	                  begin                                       
	                    state_read <= Rdata;                                       
	                    axi_araddr <= S_AXI_ARADDR;                                       
	                    axi_rvalid <= 1'b1;                                       
	                    axi_arready <= 1'b0;                                       
	                  end                                       
	                else state_read <= state_read;                                       
	              end                                       
	            Rdata:        //At this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                       
	              begin                                           
	                if (S_AXI_RVALID && S_AXI_RREADY)                                       
	                  begin                                       
	                    axi_rvalid <= 1'b0;                                       
	                    axi_arready <= 1'b1;                                       
	                    state_read <= Raddr;                                       
	                  end                                       
	                else state_read <= state_read;                                       
	              end                                       
	           endcase                                       
	          end                                       
	        end                                         
	// Implement memory mapped register select and read logic generation
	  assign S_AXI_RDATA = (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0) ? slv_reg0 : (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h1) ? slv_reg1 : (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h2) ? slv_reg2 : (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h3) ? slv_reg3 :0;  
	// Add user logic here

	// User logic ends

	endmodule
