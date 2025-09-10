# Linker Script Deep Dive (Cortex-M3 STM32F103RB)

This document explains the **linker script** used in this repository and how it controls memory placement on Cortex-M3.

---

## 1. Memory Map (STM32F103RB)

The STM32F103RB has:

- **Flash:** `0x0800_0000` – `0x0801_FFFF` (128 KB)  
- **SRAM:** `0x2000_0000` – `0x20004FFF` (20 KB)  
- **Peripheral space:** starts at `0x4000_0000`  

Our script defines only Flash + SRAM:

```ld
MEMORY
{
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 128K
}
```
## 2. Entry Point
```ld
ENTRY(Reset_Handler)
```
Tells the linker the program entry is Reset_Handler.

Ensures symbol is included in final image even if unused by reference.

Matches the second word in vector table.

## 3. Stack Pointer
```ld
_estack = ORIGIN(RAM) + LENGTH(RAM);
```
Symbol placed at end of RAM.

Used in vector table as initial SP.

Cortex-M stacks grow downward, so stack starts at high address and decrements.

## 4. Sections Breakdown
```
.isr_vector
ld
Copy code
.isr_vector :
{
    KEEP(*(.isr_vector))
} > FLASH
```
Fixed at Flash base (0x08000000).

Contains vector table (SP + Reset + IRQs).

KEEP() ensures linker does not discard it even if unused.

Must be first section in Flash image.
```.text
.text :
{
    *(.text*)
    *(.rodata*)
    _etext = .;
} > FLASH
```
Holds all code (.text) and read-only data (.rodata).

`_etext` = address right after .text in Flash.

`_etext` also used as source for copying .data into RAM.

```.data
.data : AT(_etext)
{
    _sdata = .;
    *(.data*)
    _edata = .;
} > RAM
```
Contains initialized variables.

Two addresses:

Load address = `_etext` in Flash (ROM image).

Execution address = in RAM.

At reset, startup code copies from load → exec.

`_sdata` /`_edata` used as copy bounds.

```.bss
.bss :
{
    _sbss = .;
    *(.bss*)
    *(COMMON)
    _ebss = .;
} > RAM
```
Contains uninitialized globals (default = 0).

Zeroed by startup code at reset.

COMMON ensures legacy uninitialized symbols are also included.

`_sbss` / `_ebss` used as zeroing bounds.

## 5. Linking Flow
When GCC/LD links object files:

Compiler outputs .o with `.text`, `.data`, `.bss`.

Linker script maps each section into physical memory.

Produces firmware.elf with:

Flash contents: vector + text + rodata + data image.

RAM layout: data + bss + stack.

objcopy extracts binary (firmware.bin) to flash.

## 6. Visual Layout
```
Flash (0x08000000):
[0x08000000]  Vector table
[0x08000040]  .text (code + rodata)
[0x0800xxxx]  .data (load image)
[0x0801FFFF]  End of Flash
```
```
RAM (0x20000000):
[0x20000000]  .data (exec)
[0x2000xxxx]  .bss
[0x20005000]  _estack (initial SP)
```
## 7. Debugging Symbols
`info address _etext` → Flash end of .text.

`info address _sdata` → RAM start of .data.

`info address _sbss` → RAM start of .bss.

Inspect memory regions:

`x/16wx &_sdata `→ verify .data contents.

`x/16wx &_sbss `→ check .bss cleared.

## 8. Key Takeaways
Linker script defines physical placement of code/data.

`.data` requires copy from Flash → RAM.

`.bss` requires zeroing at startup.

Stack symbol _estack ensures predictable SP initialization.

Without a correct script, firmware will compile but not run.