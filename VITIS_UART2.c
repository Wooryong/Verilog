/********************************************************************
*   Copyright (C) 2024 WeDu Solution Co., Ltd. All Right Reserved
*   SPDX-License-Identifier: MIT
********************************************************************/

/*******************************************************************/
/**
*
* @file      uart_test.app
*   this test the uart 
* @note
* MODIFICATION HISTORY:
* <pre>
* 1.00a  lebits 12/30/2024  First Release
* <pre>
********************************************************************/

/************************** Include Files **************************/
#include "xparameters.h"
#include "xil_types.h"
#include "xuartps.h"
#include "xil_printf.h"

/*********************** Constant Definitions ***********************/
#define	XUARTPS_BASEADDRESS	XPAR_XUARTPS_0_BASEADDR
// #define AXI_BASEADDRESS     XPAR_AXI_SLVE_BASEADDR
#define Reg_Addr 0x40000000 // Check Address

#define TEST_BUFFER_SIZE    10
/*************************** Type Definitions ***********************/

/************** Macros (Inline Functions) Definitions ***************/

/********************* Function Prototypes **************************/

/********************* Variable Definitions *************************/

XUartPs Uart_PS;		/* Instance of the UART Device */


//static u8 SendBuffer[TEST_BUFFER_SIZE];     //buffer for transmitting data
//static u8 RecvBuffer[TEST_BUFFER_SIZE];
/*****************************************************************************/
/**
*
* Main function.
*
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE
*
* @note		None
*
******************************************************************************/

int main(void) 
{

 	int Status;
	XUartPs_Config *Config;
	unsigned int ReceivedCount;
	char PS_UART_DATA;
	int UART_DATA;
	int *ptr;
	int uart_tx_status;   
   	int uart_rx_status;    

	/*
	 * Initialize the UART driver so that it's ready to use.
	 * Look up the configuration in the config table, then initialize it.
	 */
	Config = XUartPs_LookupConfig(XUARTPS_BASEADDRESS);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPs_CfgInitialize(&Uart_PS, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    xil_printf("\n\r==== UART Test started ===\n\r");

    ReceivedCount = 0; // 
    ptr = (int *) Reg_Addr; // Reg_Addr = slv_reg0

while(1) 
{
    xil_printf( "Wait for UART RX Data or Enter Data through PS UART \n\r" );

	while(1) // Loop for IDLE 
	{
		uart_rx_status = 0; 
		uart_rx_status = *(ptr); // Read slv_reg0 (Control)
        // xil_printf( "UART Status : %x \n\r", uart_rx_status);        
        uart_rx_status = (uart_rx_status << 1);
        // xil_printf( "UART Status : %x \n\r", uart_rx_status);
        // uart_rx_status & (0x7FFFFFFF);       
        // uart_rx_status = (uart_rx_status << 1); // Bit Shift for Removal of TX_READY 
		ReceivedCount = 0; 
		ReceivedCount = XUartPs_Recv(&Uart_PS, &PS_UART_DATA,1); // PS UART Data

		if ( (uart_rx_status != 0) || (ReceivedCount != 0) )
			break;
	}

    // xil_printf( "UART Status : %x \n\r", uart_rx_status); 

	if (uart_rx_status != 0) // UART RX Data exist
	{
		xil_printf( "UART RX Status : %x \n\r", uart_rx_status);
        UART_DATA = *(ptr + 1); // Read UART RX Data in slv_reg1 (Data)
        // UART RX Clear 
		*(ptr) = 0x00; // RX_CLEAR 
        xil_printf( "UART RX Status : %x \n\r", *(ptr));
		// *(ptr) = *(ptr) & (0x00000000);
		xil_printf( "UART RX > PS UART - Hexa : %x Dec : %d \n\r" , UART_DATA, UART_DATA);
        // can be ommitted
        *(ptr + 1) = UART_DATA; // Write UART RX Data to slv_reg1 (UART TX Data)
        xil_printf( "UART RX > UART TX - Hexa : %x Dec : %d \n\r" , UART_DATA,  UART_DATA);
	} // if (uart_rx_status != 0)

	if (ReceivedCount != 0) // PS UART Data
	{
        if(PS_UART_DATA == 0x0d)	
        {
            xil_printf( "You pressed Enter Key, so UART Test ends \n\r" ); 
            break; // Escape Main while(1) Loop
        }			
        *(ptr + 1) = PS_UART_DATA; // Write PS UART Data to slv_reg1 (UART TX Data)
        xil_printf( "PS UART > UART TX - Hexa : %x Dec : %d \n\r" , PS_UART_DATA,  PS_UART_DATA);
	} // if (ReceivedCount != 1)

    // UART TX
    
    uart_tx_status = 0;		
    while(1)               
    {
        uart_tx_status = *(ptr); // Read slv_reg0 (Control)
        uart_tx_status = (uart_tx_status >> 1); // Bit Shift for Removal of RX_DONE         
        if (uart_tx_status != 0)    break;
    } 
    
    *(ptr) = 0x00010000; // TX_START = slv_reg0[16]
    xil_printf( "TX Start Once!! \n\r" ); 
    *(ptr) = 0x00000000;
    
    //

    xil_printf( "1 Cycle End \n\r" );
    xil_printf( "========================================= \n\r" ); 
    xil_printf( "\n\r" ); 
} // while(1) 

xil_printf("==== UART Test Fnished ===\n\r");
return XST_SUCCESS;
}