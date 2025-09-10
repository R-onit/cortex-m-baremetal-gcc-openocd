# Startup & Reset Flow (Cortex-M3)

This document explains the **startup sequence** for an STM32F103RB (ARM Cortex-M3, ARMv7-M). It maps the architecture-level boot process to the startup assembly in this repository.

---

## 1. Reset Sequence (Architectural View)

On reset, a Cortex-M3 core performs the following in hardware:
1. **Fetch Initial Stack Pointer (SP):**  
   - At address `0x00000000` (aliased to Flash `0x08000000` in STM32F1).  
   - First word in the vector table is loaded into `SP`.

2. **Fetch Reset Vector (PC):**  
   - Second word in vector table is loaded into `PC`.  
   - Execution begins at that address (our `Reset_Handler`).

3. **Processor Mode:**  
   - Enter **Thread Mode**.  
   - **Privileged execution**.  
   - Main stack pointer (MSP) in use.

4. **Interrupt System:**  
   - Vector table is active at `0x08000000`.  
   - All interrupts masked until explicitly enabled.

---

## 2. Vector Table Layout

Located at Flash base (`0x08000000`):  
```
| Offset | Content                  | Source in Code       |
|--------|--------------------------|----------------------|
| 0x00   | Initial SP value         | `_estack` (linker)   |
| 0x04   | Reset vector (entry PC)  | `Reset_Handler`      |
| 0x08+  | Optional IRQ handlers    | (not used here)      |
```
Assembly implementation:
```asm
.section .isr_vector, "a", %progbits
_isr_vector:
    .word _estack         /* Initial stack pointer */
    .word Reset_Handler   /* Reset vector */
```

## 3. Reset Handler Responsibilities
The Reset_Handler is responsible for preparing C runtime environment before calling main():

Copy .data from Flash → RAM

Initialized globals reside in Flash (ROM image).

Must be copied to SRAM for runtime modification.

Zero .bss in RAM

Uninitialized globals default to zero.

Cleared explicitly at startup.

Branch to main()

Once memory is initialized, hand over control.

Hang if main returns

MCU has no OS; returning to nowhere would fault.

Infinite loop used as fallback.

## 4. Implementation Notes
IT block usage:
Code uses conditional execution (it lt) to avoid branches for each instruction — Cortex-M3 supports Thumb-2 IT blocks.

Memory symbols:
Defined in linker script:

`_sdata`, `_edata`: RAM boundaries for .data.

`_etext`: Flash end of .text, start of .data image.

`_sbss`, `_ebss`: RAM boundaries for .bss.

`_estack`: End of RAM (stack base).

Example: .data copy loop

```asm
ldr r0, =_sdata
ldr r1, =_edata
ldr r2, =_etext
1:
cmp r0, r1
it lt
ldrlt r3, [r2], #4
it lt
strlt r3, [r0], #4
blt 1b
```
- **End State before `main`:**
- SP initialized.  
- `.data` valid in RAM.  
- `.bss` zeroed.  
- Peripherals still in reset state (no clocks enabled yet).  

---

## 5. Debugging Reset Flow

Useful GDB breakpoints:
- `break Reset_Handler` → verify entry.  
- `break main` → check memory initialized.  
- `x/16wx &_sdata` → inspect `.data` after copy.  
- `x/16wx &_sbss` → confirm `.bss` zeroed.  

---

## 6. Key Takeaways
- Vector table = boot ROM contract with CPU.  
- Reset handler = C runtime initialization.  
- Linker symbols tie Flash ↔ RAM layout.  
- Without this sequence, `main()` would run with invalid memory.  
