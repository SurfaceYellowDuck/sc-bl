/**
*  Syntacore SCR* infra
*
*  @copyright (C) Syntacore 2015-2017. All rights reserved.
*  @author mn-sc
*
*  @brief Bare metal linker script
**/

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
  RAM (rwx) : ORIGIN = 0xFFFFF000, LENGTH = 4K
  ROM (rx) : ORIGIN = 0xFFEF0000, LENGTH = 32K
}

SEC_ALIGN = 32;

STACK_SIZE = 2K;

SECTIONS {

  __start_of_ram : {
    _end = .;
  } > RAM

  .stack : {
    __STACK_START__ = .;
      LONG(0);
    . += STACK_SIZE - 4;
    __C_STACK_TOP__ = .;
    __STACK_END__ = .;
  } >RAM

  .bss : {
    . = ALIGN(SEC_ALIGN);
    __BSS_START__ = .;
    *(.dynbss) *(.bss .bss.* .gnu.linkonce.b.*) *(COMMON)
  } >RAM

  .sbss : {
    . = ALIGN(SEC_ALIGN);
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
    . = ALIGN(0x10);
    __BSS_END__ = .;
  } >RAM

  .sdata : {
    . = ALIGN(SEC_ALIGN);
    *(.sdata .sdata.* .gnu.linkonce.s.*)
   __global_pointer$ = . + 0x800;
  } >RAM

  .data : {
    . = ALIGN(SEC_ALIGN);
    *(.data .data.*)
  } >RAM

  /* thread-local data segments */
  .tdata : {
    . = ALIGN(SEC_ALIGN);
    _tls_data = .;
    _tdata_begin = .;
    KEEP(*(.tdata .tdata.*));
    _tdata_end = .;
    . = ALIGN(0x10);
  } >RAM

  .tbss : {
    . = ALIGN(SEC_ALIGN);
    _tbss_begin = .;
    KEEP(*(.tbss .tbss.*));
    . = ALIGN(SEC_ALIGN);
    _tbss_end = .;
  } >RAM

  __TLS_SIZE__ = _tbss_end - _tdata_begin;

  __TLS0_BASE__ = __C_STACK_TOP__ - __TLS_SIZE__;

  .srodata ALIGN(SEC_ALIGN) : {
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata.*)
  } >RAM

  .rodata : {
    . = ALIGN(SEC_ALIGN);
    *(.rodata) *(.rodata.*) *(.gnu.linkonce.r.*)
  }

  .text : {
    . = ALIGN(SEC_ALIGN);  
    __TEXT_START__ = .;
    *(.text .text*)
    KEEP(*(.init.text));
    __TEXT_END__ = .;
  } >ROM

  .startup ORIGIN(ROM) + 0x2000 : {
    KEEP(*(.startup));
  } >ROM

  .vectors ORIGIN(ROM) + 0x2800 : {
    KEEP(*(.vectors));
  } >ROM

  /DISCARD/ : {
    *(.eh_frame .eh_frame.*)
  }
}