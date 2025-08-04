/* linker.ld */
ENTRY(_start)

MEMORY {
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 64K
  RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 20K
}

SECTIONS {
  .text : {
    *(.text*)
  } > FLASH

  .data : {
    *(.data*)
  } > RAM

  .bss : {
    *(.bss*)
  } > RAM
}
