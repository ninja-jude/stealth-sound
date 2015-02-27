
.origin 0
.entrypoint START

// Refer to this mapping in the file - \prussdrv\include\pruss_intc_mapping.h
#define PRU0_PRU1_INTERRUPT     17
#define PRU1_PRU0_INTERRUPT     18
#define PRU0_ARM_INTERRUPT      19
#define PRU1_ARM_INTERRUPT      20
#define ARM_PRU0_INTERRUPT      21
#define ARM_PRU1_INTERRUPT      22

START:
  // Send an interrupt to pru0.
  mov r31.b0, PRU1_PRU0_INTERRUPT+16

  // Notify the host that the interrupt was sent.
  mov r31.b0, PRU1_ARM_INTERRUPT+16

  // End the program
  halt


