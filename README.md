# Cortex-M Bare-Metal STM32 (No IDEs, No HALs)

A **from-scratch bare-metal firmware project** for the STM32F103RB (ARM Cortex-M3) Nucleo board.  
This repo shows how to build embedded systems without vendor IDEs or auto-generated HAL code : using only **Makefiles, linker scripts, and OpenOCD**.

---

## Why This Project?
Most STM32 tutorials start with CubeIDE or HAL libraries. Here, everything is done manually:
- Custom **startup code** (vector table + Reset_Handler).
- Hand-written **linker script**.
- Minimal **Makefile toolchain**.
- Direct register access (no HAL, no CMSIS).
- Flash + debug using **OpenOCD + GDB**.

This repo proves end-to-end understanding of **ARM Cortex-M architecture** and the **firmware build pipeline**.

---

## Project Overview
- **Target MCU:** STM32F103RB (Cortex-M3, ARMv7-M)
- **Board:** Nucleo-F103RB
- **Peripherals Used:** GPIO (LED blink on PA5)
- **Workflow:** GCC ARM toolchain + Make + OpenOCD

---

## Features Implemented
- Vector table at `0x08000000`  
- Reset handler: `.data` copy, `.bss` zero, call `main()`  
- Custom linker script with defined memory regions  
- GPIOA clock enable + PA5 LED toggle  
- Makefile build system  
- Flash/debug with OpenOCD & GDB  

---
## Repository Structure
- [src/](src/) – Application C sources (main.c)
- [startup/](startup/) – Startup assembly (startup.s)
- [include/](include/) – Optional headers
- [linker.ld](linker.ld) – Custom linker script
- [Makefile](Makefile) – Build system
- [build/](build/) – Generated build artifacts (.o, .elf, .bin)
- [docs/](docs/) – In-depth technical explanations
  - [startup.md](docs/startup.md)
  - [linker.md](docs/linker.md)
  - [gpio.md](docs/gpio.md)
  - [toolchain.md](docs/toolchain.md)
  - [architecture.md](docs/architecture.md)
- [README.md](README.md)


---
## What You’ll Learn
- How Cortex-M boots after reset.  
- Why startup code matters (stack pointer, Reset_Handler).  
- How `.text`, `.data`, `.bss`, and stack are placed in memory.  
- How to control peripherals via RCC and GPIO registers.  
- How OpenOCD + GDB interact with the MCU via SWD.  

---

## Toolchain
- `arm-none-eabi-gcc` → compile & link  
- `arm-none-eabi-objcopy` → ELF → BIN/HEX  
- `OpenOCD` → flash binary & debug bridge  
- `GDB` → live debugging  

Pipeline:  
source.c ---> gcc ---> .o ---> ld ---> firmware.elf
---> objcopy ---> firmware.bin ---> OpenOCD ---> MCU

---
---

## Build & Flash

**1. Build project**
```bash
make
```
Generates
build/firmware.elf → ELF executable
build/firmware.bin → raw binary for flashing


2. Flash to board (via ST-Link)
```bash
make flash
```
3. Run + inspect binary size
```bash
make run
```
4. Debug with GDB over OpenOCD

bash
```
make gdb
```
Opens OpenOCD GDB server.

Launches arm-none-eabi-gdb connected to :3333.

---

## Further Reading
This repo doubles as a **learning resource**.  
- [Startup & Reset Flow](docs/startup.md)  
- [Linker Script Deep Dive](docs/linker.md)  
- [GPIO & Peripheral Registers](docs/gpio.md)  
- [Toolchain Explained](docs/toolchain.md)  
- [ARM Cortex-M3 Architecture Notes](docs/architecture.md)

---

## Who Is This Repo For?
- 🔹 Beginners who want to learn Cortex-M bare metal.  
- 🔹 Engineers tired of opaque IDEs/HALs.  
- 🔹 Recruiters who want proof of **deep embedded expertise**.  

---

## Future Work
- Add SysTick timer for delay (instead of busy loops).  
- Implement UART driver (printf over USART2).  
- Explore interrupts & NVIC.  
- Extend docs into a **mini Cortex-M bare-metal handbook**.

---

## Author
Built with curiosity and first-principles thinking by **Ronit**.  
Always learning, always building.
