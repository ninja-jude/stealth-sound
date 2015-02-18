
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
#define CONST_PRUCFG C4
#define CONST_PRUDRAM C24
#define CONST_PRUSHAREDRAM C28
#define CONST_L3RAM C30
#define CONST_DDR C31

// The addresses of the PRU0 and PRU1 control registers.
#define PRU0_CTRL            0x22000
#define PRU1_CTRL            0x24000

// Offset of Constant Table Programmable Pointer Registers
// from the PRUx_CTRL address.
#define CTPPR0               0x28
#define CTPPR1               0x2C
#define CTBIR0               0x20
#define CTBIR1               0x24

// The three most useful values to load into the C28 constant table
// programmable pointer register.
#define OWN_RAM              0x000  // PRU's own RAM
#define OTHER_RAM            0x020  // Other PRU's RAM
#define SHARED_RAM           0x100  // Shared RAM

// Address for the Constant table Programmable Pointer Register 0(CTPPR_0)
// Address for the Constant table Programmable Pointer Register 0(CTPPR_0)
#define CTBIR_0 0x22020  // PRU0_CTRL + CTBIR0
#define CTBIR_1 0x22024  // PRU0_CTRL + CTBIR1

// Address for the Constant table Programmable Pointer Register 0(CTPPR_0)
// Address for the Constant table Programmable Pointer Register 1(CTPPR_1) 
#define CTPPR_0 0x22028  // PRU0_CTRL + CTPPR0
#define CTPPR_1 0x2202C  // PRU0_CTRL + CTPPR1


#define GER_OFFSET        0x10
#define HIESR_OFFSET      0x34
#define SICR_OFFSET       0x24
#define EISR_OFFSET       0x28

#define INTC_CHNMAP_REGS_OFFSET       0x0400
#define INTC_HOSTMAP_REGS_OFFSET      0x0800
#define INTC_HOSTINTPRIO_REGS_OFFSET  0x0900
#define INTC_HOSTNEST_REGS_OFFSET     0x1100

// All document references are to this document:
// AM335x PRU-ICSS Reference Guide (Rev. A)
// /doc/ti/am335xPruReferenceGuide.pdf

START:
  // Enable Open Core Protocol (OCP) master port.
  // Access to the data bus that interconnects all peripherals 
  // on the SoC, including the ARM Cortex-A8, used for data transfer 
  // directly to and from the PRU in Level 3 (L3) memory space.
  // This is a required step in order to access memory outside of
  // the PRU. If you do not do this, then the PRU will stall without
  // any explanation when you attempt to access external memory.
  // So in short, Enabling the OCP master port is a must to
  // communicate with the host ARM processor.
  // CONST_PRUCFG is register C4 in the constants table.
  // Section 5.2.1, Table-9, Constants Table
  // C4 is PRU-ICSS CFG (local) @ 0x0002_6000
  // Section 10.1, Table-205, lists PRU_ICSS_CFG registers
  // At an offset of 4 is the SYSCFG register.
  // Secition 10.1.2, Table-207, shows that setting bit 4 to zero
  // enables the OCP master port.
  lbco r0, CONST_PRUCFG, 4, 4  // copy contents of PRUConfig register into r0
  clr r0, r0, 4  // clears bit 4 in the PRUConfig register thereby enabling OCP master port  // Clear SYSCFG[STANDBY_INIT] to enable OCP master port
  sbco r0, CONST_PRUCFG, 4, 4  // copy r0 back into the PRUConfig register to enable change
  
CATCH:
  // catch the interrupt from pru1
  wbs r31, 30
  
  // clear the interrupt
  ldi r0.w2, 0x0000
  ldi r0.w0, PRU1_PRU0_INTERRUPT
  sbco r0, CONST_PRUSSINTC, SICR_OFFSET, 4
  
  // Grab the transfer from scratch-pad-0
  xin 10, r10, 32
  
  // Write the values into DDR.
  sbco r10, CONST_DDR, 0x00, 32

  // Notify the host that the interrupt was received.
  // Why the +16 for AM33xx?
  mov r31.b0, PRU0_ARM_INTERRUPT+16

  // End the program
  halt


