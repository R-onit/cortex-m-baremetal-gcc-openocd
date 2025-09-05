.syntax unified
.cpu cortex-m3
.thumb

/* Vector table */
.section .isr_vector, "a", %progbits
.global _isr_vector
.type _isr_vector, %object
.size _isr_vector, .-_isr_vector

_isr_vector:
    .word _estack         /* Initial stack pointer */
    .word Reset_Handler   /* Reset vector */
    /* Optional: other interrupts can be added here */

.section .text.Reset_Handler
.global Reset_Handler
.type Reset_Handler, %function

Reset_Handler:
    /* --- Copy .data from flash to RAM --- */
    ldr r0, =_sdata      /* RAM start */
    ldr r1, =_edata      /* RAM end */
    ldr r2, =_etext      /* FLASH start of .data */
1:
    cmp r0, r1
    it lt
    ldrlt r3, [r2], #4
    it lt
    strlt r3, [r0], #4
    blt 1b

    /* --- Zero .bss section --- */
    ldr r0, =_sbss
    ldr r1, =_ebss
2:
    cmp r0, r1
    it lt
    movlt r2, #0
    it lt
    strlt r2, [r0], #4
    blt 2b

    /* --- Call main() --- */
    bl main

/* --- Infinite loop if main() returns --- */
.Lhang:
    b .Lhang
