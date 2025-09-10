# ARM Cortex-M3 Architecture Notes (STM32F103RB)

This document summarizes key architectural aspects of the ARM Cortex-M3 core (ARMv7-M). It connects theory from the ARM Architecture Reference Manual (TRM) to practical usage in this repository.

---

## 1. Core Overview

- **Architecture:** ARMv7-M  
- **ISA:** Thumb-2 only (no ARM state)  
- **Registers:** 16 general-purpose + special registers  
- **Modes:**  
  - **Thread mode** → normal program execution  
  - **Handler mode** → exception/interrupt service  
- **Privilege levels:**  
  - Privileged (default after reset)  
  - Unprivileged (requires OS or MPU)  

---

## 2. Register File

### General-Purpose (R0–R12)
- Used for computation and parameter passing.  
- R0–R3: argument/result registers.  
- R4–R11: callee-saved.  
- R12 (IP): intra-procedure scratch.

### Special Registers
- **R13 (SP):** Stack Pointer  
  - MSP (Main SP, default)  
  - PSP (Process SP, OS use)  

- **R14 (LR):** Link Register  
  - Holds return address after `BL`.  
  - Special exception return codes (`0xFFFFFFxx`) restore state from stack.  

- **R15 (PC):** Program Counter  
  - Always bit[0]=1 (Thumb state).  

- **xPSR (Program Status Register):**  
  - Combines APSR (flags), IPSR (exception number), EPSR (execution state).  
  - Key bits: N, Z, C, V flags, Thumb bit, current ISR number.

---

## 3. Exception Model

- **Vector table** at base of memory (STM32 remaps Flash at `0x08000000`).  
- First entry = initial SP, second = Reset, then exception/IRQ handlers.  
- Each exception has priority (0–255, lower = higher priority).  
- NVIC (Nested Vectored Interrupt Controller) handles dispatch.  
- On entry: CPU pushes stack frame automatically:
R0, R1, R2, R3, R12, LR, PC, xPSR


- On exit: `BX LR` with special EXC_RETURN value unwinds.

---

## 4. Memory Map (ARMv7-M Defined)

Cortex-M cores use a fixed, unified memory map:
```
| Address Range          | Region                 | STM32F103 Mapping       |
|------------------------|------------------------|-------------------------|
| 0x0000_0000 – 0x1FFF_FFFF | Code (Flash/ROM)      | 0x0800_0000 Flash       |
| 0x2000_0000 – 0x3FFF_FFFF | SRAM                  | 0x2000_0000 (20 KB)     |
| 0x4000_0000 – 0x5FFF_FFFF | Peripheral space      | RCC/GPIO etc.           |
| 0xE000_0000 – 0xE00F_FFFF | System control space  | NVIC, SysTick, SCB      |
```
This allows load/store instructions to address peripherals as memory.

---

## 5. Instruction Set (Thumb-2)

- **Thumb-2** blends 16-bit and 32-bit encodings for dense + powerful instructions.  
- Key instructions in this project:
- `LDR`, `STR` → memory access.  
- `CMP`, `IT` → conditional execution.  
- `BL` → branch with link (`main()` call).  
- `B` → infinite loop hang.  
- `IT` (If-Then) block allows predication of up to 4 instructions — unique to Thumb-2.

---

## 6. Stack & Calling Convention (AAPCS)

- Stack grows downward (high → low).  
- On function call:
- Arguments: R0–R3, rest on stack.  
- Return: R0.  
- Callee must preserve R4–R11, SP.  
- LR holds return address or EXC_RETURN code.  
- Reset handler sets SP from vector table before first C function executes.

---

## 7. System Control Space (SCS)

At `0xE000E000` region. Key components:

- **NVIC:** Interrupt enable/priority.  
- **SysTick:** 24-bit timer for OS tick or delays.  
- **SCB (System Control Block):** Controls vector table offset, system reset, fault handlers.  

For minimal bare-metal projects, only NVIC/SysTick/SCB are relevant.

---

## 8. Exception Entry/Exit (Cycle Level)

On IRQ/exception entry:
1. PC, xPSR, LR, R12, R3, R2, R1, R0 automatically pushed to current SP.  
2. Vector fetched from table, PC updated.  
3. Execution begins in Handler mode, privileged.  

On exit:
- `BX LR` with EXC_RETURN (`0xFFFFFFFx`) restores context and returns to Thread mode.

---

## 9. Debugging Architecture

- SWD (Serial Wire Debug) provides memory/register access.  
- GDB via OpenOCD can halt/resume, set breakpoints, inspect core registers.  
- Useful commands:
- `info registers` → dump R0–R15, xPSR.  
- `x/10i $pc` → disassemble instructions.  
- `monitor reset halt` → reset core via OpenOCD.

---

## 10. Key Takeaways

- Cortex-M3 is **designed for deterministic embedded execution**.  
- **Vector table + Reset Handler** are the minimal boot contract.  
- Privileged Thread mode + MSP is the initial state.  
- **Linker symbols and startup code** bridge architecture → C environment.  
- Understanding registers, stack, and exceptions is essential for building RTOS or drivers later.
