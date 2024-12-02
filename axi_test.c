#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"


int main()
{
    int *ptr;
    int data;
    int i;
    ptr = (int *) 0x40000000;

    printf("start axi test \r\n");
    printf("AXI Write \r\n");
    
    for(i = 0; i < 4; i++) {
        *(ptr + i) = i;
        printf("write address: %x data : %d \r\n",ptr+i,i);
    }
    
    printf("\r\n AXI Read test \r\n");
    for(i=0; i < 4; i++) {
        data = *(ptr + i);
        printf(" Read address: %x data : %d \r\n",ptr+i,data);
    }

}