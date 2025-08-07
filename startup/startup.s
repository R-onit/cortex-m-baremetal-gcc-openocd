/* startup.s */

.syntax unified
.cpu cortex-m3
.thumb

.section .isr_vector, "a", %progbits
.type _isr_vector, %object
.size _isr_vector, .- _isr_vector
.global _isr_vector

_isr_vector:
  .word  _estack         /* Initial stack pointer */
  .word  Reset_Handler   /* Reset vector */

.section .text.Reset_Handler
.global Reset_Handler
.type Reset_Handler, %function

Reset_Handler:
  /* Copy .data section (RAM ← Flash) */
  ldr r0, =_sdata
  ldr r1, =_edata
  ldr r2, =_etext
1:
  cmp r0, r1         /* r0 < r1 ? */
  ittt lt
  ldrlt r3, [r2], #4 /* r3 = *r2; r2 += 4 */
  strlt r3, [r0], #4 /* *r0 = r3; r0 += 4 */
  blt 1b             /* if r0 < r1, loop */

  /* Zero .bss section */
  ldr r0, =_sbss
  ldr r1, =_ebss
2:
  cmp r0, r1
  it lt
  movlt r2, #0
  strlt r2, [r0], #4
  blt 2b

  /* Call main() */
  bl main

  /* If main() returns, loop forever */
.Lhang:
  b .Lhang
