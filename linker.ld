/* linker.ld */

ENTRY(Reset_Handler)  /* Entry point after reset */

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 128K /*defines the memory area and adresses,flash is read/execute, ram is read write and execute*/
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

SECTIONS    /*this section where each section of text/data/bss should go into memory (>FLASH,>RAM)*/

{
  /* Vector table must be at the start of FLASH */
  .isr_vector :
  {
    KEEP(*(.isr_vector))
  } > FLASH

  /* Code + const data */
  .text :      /*text section all the functions that gets compiles , hence they are kept in flash as they dont change  */

  {
    *(.text*)
    *(.rodata*)
    _etext = .; /* Marks end of .text for .data init copy */
  } > FLASH

  /* Initialized data section (load from Flash → run from RAM) */
  .data : AT(_etext)     /*global/static (int x=3) variables are placed inside the RAM , and initial values of them are stored inside the FLASH*/

  {
    _sdata = .;        /* Start of .data in RAM */
    *(.data*)
    _edata = .;        /* End of .data in RAM */
  } > RAM

  /* Uninitialized data (zeroed in startup) */
  .bss :  /* uninitialized variables(int x) are stored inside RAM*/
  {
    _sbss = .;
    *(.bss*)
    *(COMMON)
    _ebss = .;
  } > RAM

  /* Stack pointer: reserve stack at end of RAM */
  . = ORIGIN(RAM) + LENGTH(RAM);
  _estack = .;
}


/*linker script is used to define memory regions of flash and sram
  - used by linker to know which section of code/bss/data goes where in the memory
  *structure of the linker script
    ENTRY
    MEMORY
    SECTIONS
  
  all these regions are automatically made by compiler when converting c and assembly files to .o files 
  we are just deciding which section is going to which part of the memory 
   */

   /*when we compile the .s and .c files they get converted into .o files which are somewhat classified
    types inside it (means the code is structurised according to .text ,.data ,.bss) right . then the
    text contains functions , the data contains the variables present , the bss contains just initialised
    variables and dont have values . text stored into flash as its fixed , data initial value stored inside 
    flash but when code runninf=g it comes in ram , and bss also on ram
    */

