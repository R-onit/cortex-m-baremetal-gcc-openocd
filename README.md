# Cortex-M Bare-Metal Toolchain Demo

A minimal bare-metal STM32F103RB project demonstrating understanding of ARM Cortex-M architecture, linker scripts, startup files, and low-level flashing/debugging using OpenOCD and GDB — **no IDE, no HALs**.

---

## Features

- Fully manual **Makefile-based build system**.
- **Linker script** (`linker.ld`) mapping `.text`, `.data`, `.bss`, and vector table to correct memory regions.
- **Startup assembly file** (`startup/startup.s`) initializing the stack, copying `.data` to RAM, zeroing `.bss`, and calling `main()`.
- Toolchain demonstrates:
  - Compilation with `arm-none-eabi-gcc`
  - Linking object files with custom memory layout
  - Generating `.elf` and `.bin`
- **OpenOCD integration** for flashing and debugging on Nucleo-F103RB.
- **GDB support** for live debugging and inspecting registers.

---

## Folder Structure
src/ # C source files
startup/ # Startup assembly file
linker.ld # Custom linker script
Makefile # Build, flash, and debug targets
README.md



---

## Build & Flash

```bash
# Build all
make all

# Flash to the board using OpenOCD
make flash

# Debug using GDB
make debug

