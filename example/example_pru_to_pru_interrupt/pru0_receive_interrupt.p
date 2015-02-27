
.origin 0
.entrypoint START

// Refer to this mapping in the file - \prussdrv\include\pruss_intc_mapping.h
#define PRU0_PRU1_INTERRUPT     17
#define PRU1_PRU0_INTERRUPT     18
#define PRU0_ARM_INTERRUPT      19
#define PRU1_ARM_INTERRUPT      20
#define ARM_PRU0_INTERRUPT      21
#define ARM_PRU1_INTERRUPT      22

#define CONST_PRUSSINTC C0
#define SICR_OFFSET 0x24

START:
  // catch the interrupt from pru1
  wbs r31, 30
  
  // clear the interrupt
  ldi r0.w2, 0x0000
  ldi r0.w0, PRU1_PRU0_INTERRUPT
  sbco r0, CONST_PRUSSINTC, SICR_OFFSET, 4

  // Notify the host that the interrupt was received.
  // Why the +16 for AM33xx?
  mov r31.b0, PRU0_ARM_INTERRUPT+16

  // End the program
  halt


