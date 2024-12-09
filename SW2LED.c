#include <stdio.h>
#include "xparameters.h"

#define Reg_Addr 0x40000000

int main(void) 
{   
    int *ptr;
    ptr = (int *) Reg_Addr; // Reg_Addr = slv_reg0
	int SW;
    int Old_data = 0;
    int LED;

    while(1)
    {
        // Read SW Value        
        SW = *(ptr); // *(ptr) = slv_reg0

        if( SW != Old_data )
        {
            printf("[Read] Address : %p - SW : %d\r\n", ptr , SW);

            // Conversion
            switch (SW) 
            {
                case 1 : LED = 0X00000006; break;
                case 2 : LED = 0X0000005B; break;
                case 3 : LED = 0X0000004F; break;
                case 4 : LED = 0X00000066; break;
                case 5 : LED = 0X0000006D; break;
                case 6 : LED = 0X0000007D; break;
                case 7 : LED = 0X00000027; break;
                case 8 : LED = 0X0000007F; break;
                case 9 : LED = 0X0000006F; break;
                case 10 : LED = 0X00000077; break;
                case 11 : LED = 0X0000007C; break;
                case 12 : LED = 0X00000039; break;
                case 13 : LED = 0X0000005E; break;
                case 14 : LED = 0X00000079; break;
                case 15 : LED = 0X00000071; break;
                default : LED = 0X00000000;
            }
            Old_data = SW;
            
            // Write 
            printf("[Write] Address : %p - SW : %d -> LED_Code : 0X%08X  \r\n", ptr + 1, SW, LED);
	        *(ptr + 1) = LED; // (int *) : 4-byte
        }
    }
}

