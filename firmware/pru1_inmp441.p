.origin 0
.entrypoint START

// ---------------------------------------------------------------------
// BBB-DMIC-INMP441-00A0 Device Tree Overlay
//
// ---- Inputs ----
// On the P8 header pins 39-46 are for digital microphone input.
// Each pin represents a stereo line with left and right channels allowing
// up to 16 microphones to be connected.
// Pin-Name    Header-Pin  Purpose  Register-Bit
// ---------   ----------  -------  ------------
// LCD_DATA0      P8.45     SD0     PRU1_R31_0  // Line 0
// LCD_DATA1      P8.46     SD1     PRU1_R31_1  // Line 1
// LCD_DATA2      P8.43     SD2     PRU1_R31_2  // Line 2
// LCD_DATA3      P8.44     SD3     PRU1_R31_3  // Line 3
// LCD_DATA4      P8.41     SD4     PRU1_R31_4  // Line 4
// LCD_DATA5      P8.42     SD5     PRU1_R31_5  // Line 5
// LCD_DATA6      P8.39     SD6     PRU1_R31_6  // Line 6
// LCD_DATA7      P8.40     SD7     PRU1_R31_7  // Line 7
//
// ---- Outputs ----
// On the P8 header pins 29-30 are for digital mic control signals.
// Pin-Name    Header-Pin  Purpose  Register-Bit
// ---------   ----------  -------  ------------
// LCD_HSYNC      P8.29     WS      PRU1_R30_9     // Channel Select
// LCD_PCLK       P8.28     SCK     PRU1_R30_10    // Microphone Clock
// LCD_DE         P8.30     UNUSED  PRU1_R30_11    // Chip Enable
//----------------------------------------------------------------------




// Includes
#include "am335x.hp"  // addresses, offsets, and interrupts
#include "util.hp"  // spinner



// PRU1 interface with the digital microphones in real time on a fixed
// timing schedule. For this reason only deterministic operations are
// permitted.
// The SCK will be driven an a rate of MCK/64.
// MCK: 200MHz
// SCK: 3.125 MHz
// The WS will be driven at a rate of SCK/64
// WS: 48.828125 kHz
//
// The INMP441 sends 24 bit samples starting on the 2nd bit of a 32 bit word.
// The data arrives in MSb order.
//
// Registers R10-R17 are reserved for gathering the bits back into samples.
// line-0 R10
// line-1 R11
// line-2 R12
// line-3 R13
// line-4 R14
// line-5 R15
// line-6 R16
// line-7 R17

#define SCK 10
#define WS 9

START:
  // Do initializations here.
  
  // Reset bit collection registers.
  // Using the zero() command completes in a single clock cycle.
  zero &r10, 32  // sets 8 registers to zero starting at r10
  
  // Set up the mask for SCK and WS
  fill r9, 4  // set r9 to 0xffffffff
  and r9, r9, ~((1<<SCK)|(1<<WS))
  // clr r9, SCK
  // clr r9, WS
  
CAPTURE:
  and r30, r30, r9  // Toggle SCK and WS
  zero &r10, 32  // reset bit collection registers
  spinner 14, r0  // spins 29 clock cycles
  spin1
  
  set r30, SCK
  spinner 15, r0  // spins 31 clock cycles
  
  // The first clock cycle is now complete.
  // The MSb of the sample will be available
  // on the next rising edge.
  clr r30, SCK  // drive SCK low
  ldi r8, #24  // r8 will track which bit is being collected
  spinner 14, r0  // waste 29 clock cycles
  spin1  // waste 1 clock cycle
  
GATHER_BITS:
  set r30, SCK  // drive SCK high
  mov r7, r31  // capture bits on all microphone lines
  

CAPTURE_LEFT:
  // Drive SCK and WS low
  and r30.b1, r30.b1, ~0x06  // sets bits 9 & 10 in r30 to zero
  
  
CAPTURE_RIGHT:
  // Drive SCK LOW and WS high
  and r30.b1, ~0x04
  
  



