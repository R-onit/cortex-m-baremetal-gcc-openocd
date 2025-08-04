// startup.s
.section .text
.global _start
.global Reset_Handler

_start:
    b Reset_Handler

Reset_Handler:
    bl main
    b .
