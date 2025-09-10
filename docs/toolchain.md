# ARM Cortex-M Bare-Metal Toolchain

This document explains the complete toolchain used to build, link, flash, and debug firmware for the STM32F103RB — fully manual, without STM32CubeIDE or HAL.

---

## 1. Toolchain Overview

The toolchain transforms **C source code** into a binary image that runs on bare-metal hardware:

C Source → Preprocessor → Compiler → Assembler → Object Files → Linker → ELF → Binary → Flash → Execution


Key components:
- **arm-none-eabi-gcc** → compiler & assembler  
- **arm-none-eabi-ld** → linker  
- **arm-none-eabi-objcopy** → binary extraction  
- **OpenOCD** → flashing + GDB server  
- **arm-none-eabi-gdb** → debugging  

---

## 2. Build Stages

### 2.1 Preprocessing
Expands macros, includes, conditional compilation.
```bash
arm-none-eabi-gcc -E main.c -o main.i
```
### 2.2 Compilation
Convert preprocessed C into assembly.

```bash
arm-none-eabi-gcc -S main.i -o main.s
```
### 2.3 Assembly
Assemble .s into object code.

```bash
arm-none-eabi-gcc -c main.s -o main.o
```
### 2.4 Linking
Combine objects + startup code + linker script → ELF executable.

```bash
arm-none-eabi-ld -T linker.ld startup.o main.o -o firmware.elf
```
### 2.5 Binary Extraction
ELF contains debug symbols; flash requires raw binary.

```bash
arm-none-eabi-objcopy -O binary firmware.elf firmware.bin
````
## 3. Linker Script
Critical for bare-metal: places code/data into the STM32 memory map.

Example regions for STM32F103RB:

```ld
MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 128K
  SRAM  (rwx): ORIGIN = 0x20000000, LENGTH = 20K
}
```
Sections mapped:

`.text` → FLASH

`.data` → SRAM (init from FLASH)

`.bss` → SRAM (zero-initialized)

`Vector table `→ FLASH start (0x08000000)

## 4. Flashing with OpenOCD
OpenOCD interfaces with the on-board ST-LINK debugger.

Example command:

```bash
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg
```
Then in OpenOCD console:

```tcl
program firmware.elf verify reset exit
```
## 5. Debugging with GDB
Start GDB:

```bash
arm-none-eabi-gdb firmware.elf
```
Connect to OpenOCD server:

```gdb
target remote localhost:3333
```
Useful commands:

`monitor reset halt` → reset MCU

`load` → flash from GDB

`break main` → set breakpoint

`stepi `→ single-step instructions

`x/4wx 0x40021018` → inspect RCC register

## 6. Makefile Automation
All steps wrapped into a GNU Makefile:

```make
all: firmware.bin

%.o: %.c
	arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -c $< -o $@

firmware.elf: startup.o main.o
	arm-none-eabi-ld -T linker.ld $^ -o $@

firmware.bin: firmware.elf
	arm-none-eabi-objcopy -O binary $< $@

flash: firmware.elf
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
	        -c "program $< verify reset exit"

clean:
	rm -f *.o *.elf *.bin
```

One-liner builds:

```
make flash
```
## 7. Why This Matters
Shows first-principles control: not dependent on IDE.

Demonstrates understanding of ARM Cortex-M memory layout.

Highlights ability to debug at register + instruction level.

Provides a reusable template toolchain for any bare-metal ARM project.

## 8. Key Takeaways
Every line of C becomes deterministic ARM Thumb assembly.

Linker script defines how firmware maps onto real silicon.

OpenOCD bridges host ↔ MCU, exposing debug over GDB.

The Makefile captures the entire build system in ~20 lines.