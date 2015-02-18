/*
* example_sck.c
* 
* Compile like so:
* gcc -c -o example_sck.o example_sck.c
* gcc example_sck.o -L. -lpthread -lprussdrv -o example_sck_app
*/

// Standard header files
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

// Driver header file
#include "prussdrv.h"
#include "pruss_intc_mapping.h"


// PRU selection
#define PRU_NUM 1


int main(void)
{
  unsigned int ret;
  
  tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
 
  printf("\nRunning example %s.\n", "example_sck");
  
  // Initialize the PRU
  prussdrv_init ();		

  // Open PRU Interrupt
  ret = prussdrv_open(PRU_EVTOUT_0);
  if (ret) {
      printf("prussdrv_open open failed\n");
      return ret;
  }
  
  // Get the interrupt initialized
  prussdrv_pruintc_init(&pruss_intc_initdata);
  
  // Run the PRU code
  prussdrv_exec_program (PRU_NUM, "./example_sck.bin");
  
  printf("To stop the PRU you must reset the board.\n");

  // prussdrv_pru_wait_event(PRU_EVTOUT_1);
  // prussdrv_pru_clear_event(PRU1_ARM_INTERRUPT);
  
  // // Disable PRU and close memory mapping
  // prussdrv_pru_disable(PRU_NUM); 
  // prussdrv_exit();

  return 0;
}
