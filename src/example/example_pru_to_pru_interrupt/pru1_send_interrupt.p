
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
#define CONST_PRUCFG    C4
#define CONST_PRUDRAM   C24
#define CONST_L3RAM     C30
#define CONST_DDR       C31

// Address for the Constant table Programmable Pointer Register 0(CTPPR_0)
#define CTBIR_0         0x22020
// Address for the Constant table Programmable Pointer Register 0(CTPPR_0)
#define CTBIR_1         0x22024

// Address for the Constant table Programmable Pointer Register 0(CTPPR_0)      
#define CTPPR_0         0x22028
// Address for the Constant table Programmable Pointer Register 1(CTPPR_1)      
#define CTPPR_1         0x2202C


#define GER_OFFSET        0x10
#define HIESR_OFFSET      0x34
#define SICR_OFFSET       0x24
#define EISR_OFFSET       0x28

#define INTC_CHNMAP_REGS_OFFSET       0x0400
#define INTC_HOSTMAP_REGS_OFFSET      0x0800
#define INTC_HOSTINTPRIO_REGS_OFFSET  0x0900
#define INTC_HOSTNEST_REGS_OFFSET     0x1100


START:
  // Send an interrupt to pru0.
  mov r31.b0, PRU1_PRU0_INTERRUPT+16

  // Notify the host that the interrupt was sent.
  mov r31.b0, PRU1_ARM_INTERRUPT+16

  // End the program
  halt


