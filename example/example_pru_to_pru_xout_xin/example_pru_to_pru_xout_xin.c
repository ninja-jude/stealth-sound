/*
* example_pru_to_pru_interrupt.c
* 
* Compile like so:
* gcc -c -o example_pru_to_pru_xout_xin.o example_pru_to_pru_xout_xin.c
* gcc example_pru_to_pru_xout_xin.o -L. -lpthread -lprussdrv -o example_pru_to_pru_xout_xin_app
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


#define DDR_BASEADDR 0x80000000


// Globals
static int mem_fd;
static void *ddr_mem;

/**
* @brief Opens a file handle into memory and maps a pointer to it.
* 
* If mem_fd cannot open /dev/mem or ddr_mem fails to map then
* a negative value is returned otherwise 0 is returned.
* 
* @return operation status
*/
static int map_memory() {
  void *DDR_regaddr;   
 
  /* open the device */
  mem_fd = open("/dev/mem", O_RDWR);
  if (mem_fd < 0) {
    printf("Failed to open /dev/mem (%s)\n", strerror(errno));
    return -1;
  }   

  /* map the memory */
  ddr_mem = mmap(0, 0x0FFFFFFF, PROT_WRITE | PROT_READ, MAP_SHARED, mem_fd, DDR_BASEADDR);
  if (ddr_mem == NULL) {
    printf("Failed to map the device (%s)\n", strerror(errno));
    close(mem_fd);
    return -1;
  }

  return(0);
}  // map_memory

/**
* @brief Unmaps memory.
* Unmaps ddr_mem and closes mem_fd.
*/
static void cleanup() {
  munmap(ddr_mem, 0x0FFFFFFF);
  close(mem_fd);
}


/**
* @brief Verifies that the memory transfer worked.
* 
* In this example PRU1 transfers 32 bytes to PRU0 using
* XOUT/XIN transfer through the scratchpad.
* PRU0 then writes these bytes into memory.
* The result should be 8 uint32 from 0 to 7.
* 
* Returns 0 if transfer was successful.
* Returns -1 if transfer failed.
* 
* @return operation status
*/
static int verify() {
  unsigned int* data = (unsigned int*) ddr_mem;
  unsigned int kk;
  int ret = 0;
  
  for (kk = 0; kk < 8; ++kk) {
    printf("%u\n", data[kk]);
    if (data[kk] != kk) {
      ret = -1;
    }
  }
  
  return ret;
}


/**
* @brief Runs the example code.
* 
*/
int main(void)
{
  unsigned int ret;
  
  tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
 
  printf("Running example %s.\n", "example_pru_to_pru_xout_xin");
  
  // Initialize the PRU
  prussdrv_init();		

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
  
  ret = map_memory();
  if (ret) {
    printf("map_memory failed\n");
    return ret;
  }
  
  // Run the PRU code
  printf("Running PRU0\n");
  prussdrv_exec_program (0, "./pru0_xin.bin");
  printf("Running PRU1\n");
  prussdrv_exec_program (1, "./pru1_xout.bin");
 

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
  
  if (verify()) {
    printf("\n\t!!! FAIL !!!\n\n");
  } else {
    printf("\n\tPASS\n\n");
  }
  
  // Frees memory map
  cleanup();

  return 0;
}

