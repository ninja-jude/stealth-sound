/*
* example_pru_to_pru_interrupt.c
* 
* Compile like so:
* gcc -c -o example_pru_to_pru_interrupt.o example_pru_to_pru_interrupt.c
* gcc example_pru_to_pru_interrupt.o -L. -lpthread -lprussdrv -o example_pru_to_pru_interrupt_app
*/



// Standard header files
#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

// Driver header file
#include "prussdrv.h"
#include "pruss_intc_mapping.h"


int main(void)
{
  unsigned int ret;
  
  tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
 
  printf("Running example %s.\n", "example_pru_to_pru_interrupt");
  
  // Initialize the PRU
  prussdrv_init ();		

  // Open PRU Interrupt
  ret = prussdrv_open(PRU_EVTOUT_0);
  if (ret) {
      printf("prussdrv_open open failed\n");
      return ret;
  }
  
  // Open PRU Interrupt
  ret = prussdrv_open(PRU_EVTOUT_1);
  if (ret) {
      printf("prussdrv_open open failed\n");
      return ret;
  }
  
  // Get the interrupt initialized
  prussdrv_pruintc_init(&pruss_intc_initdata);
  
  // Run the PRU code
  printf("Running PRU0\n");
  prussdrv_exec_program (0, "./pru0_receive_interrupt.bin");
  printf("Running PRU1\n");
  prussdrv_exec_program (1, "./pru1_send_interrupt.bin");
 

  // Wait until PRU0 has finished execution
  printf("Waiting for PRU1 to halt...");
  prussdrv_pru_wait_event(PRU_EVTOUT_1);
  printf("DONE.\n");
  prussdrv_pru_clear_event(PRU1_ARM_INTERRUPT);

  // Wait until PRU0 has finished execution
  printf("Waiting for PRU0 to halt...");
  prussdrv_pru_wait_event(PRU_EVTOUT_0);
  printf("DONE.\n");
  prussdrv_pru_clear_event(PRU0_ARM_INTERRUPT);

  // Disable PRU and exit
  prussdrv_pru_disable(0);
  prussdrv_pru_disable(1);
  prussdrv_exit();

  return 0;
}

