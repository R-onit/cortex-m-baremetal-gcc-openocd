# cortex-m-baremetal-gcc-openocd

A minimal, fully manual bare-metal STM32 project using Makefiles, linker scripts, and OpenOCD — no IDEs, no HALs.

## Features

- ✅ Manual startup file
- ✅ Custom linker script
- ✅ GNU Make-based build system
- ✅ Header auto-dependency generation
- ✅ Flashing with ST-Link + OpenOCD
- ✅ Blinks LED on PA5 using direct register access

## Memory Layout

📷 [Insert memory diagram here or link to docs/memory-map.svg]

## Getting Started

```bash
make
make flash
make size
