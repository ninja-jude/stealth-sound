

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
  // Load registers r10:r17 with values 0:7
  ldi r10, 0
  ldi r11, 1
  ldi r12, 2
  ldi r13, 3
  ldi r14, 4
  ldi r15, 5
  ldi r16, 6
  ldi r17, 7
  
  // NOTE: There are 3 scratchpads that each contain 30 registers.
  // Device id of scratchpad 0 is 10
  // Device id of scratchpad 1 is 11
  // Device id of scratchpad 2 is 12
  // Transfer 8 registers to scratch-pad-0.
  xout 10, r10, 32
  
  // Send an interrupt to pru0.
  mov r31.b0, PRU1_PRU0_INTERRUPT+16

  // Notify the host that the interrupt was sent.
  mov r31.b0, PRU1_ARM_INTERRUPT+16

  // End the program
  halt


