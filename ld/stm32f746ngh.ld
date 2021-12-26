/***********************************************************************************************//**
 * Copyright 2021 Mario Kodba
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************************************
 * @file    stm32f746ngh.ld
 * @author  mario.kodba
 * @brief   STM32F746NGH-DISCO board linker script.
 **************************************************************************************************/

/* STACK size - can be changed */
STACK_SIZE = 0x2000; /* 8 kB */

/* entry point of the program, should be first ISR vector in vector table (after top of stack address) */
ENTRY(RESET_handler)

/***************************************************************************
*                   MEMORY LAYOUT

            0x0 +---------------------+ 0x08000000
                |                     |
                |     Bootloader      |
                |                     |
        0x4000  +---------------------+
                |                     |
                |                     |
                |     Application     |
                |                     |
                |                     |
                +---------------------+ 0x20000000
                |                     |
                |                     |
                |       RAM           |
                |                     |
                |                     |
                |                     |
                |                     |
                |                     |
                |                     |
                +---------------------+

***************************************************************************/
MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 1024K
    RAM (xrw) : ORIGIN = 0x20000000, LENGTH = 320K
}

_flash_start__ = ORIGIN(FLASH);
_flash_size__ = LENGTH(FLASH);
_ram_start__ = ORIGIN(RAM);
_ram_size__ = LENGTH(RAM);

/***************************************************************************
*               MEMORY SECTIONS
***************************************************************************/
SECTIONS
{
    .text :
    {
        /* <input filename>(section) */
        KEEP(*(.vectors))       /* keep .vectors section in each file even if not referenced */
        KEEP(*(.vectors.*))
        KEEP(*(.text))
        . = ALIGN(4);
        *(.text*)               /* place all .text* sections of all input files here */
        *(.rodata*)
        . = ALIGN(4);
        _etext = .;             /* end of .text output section */
    } > FLASH

    /* ARM magic sections - it is needed when compiled with exceptions enabled (left here for now) */
    .ARM.extab : ALIGN(4)
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > FLASH
   	
    . = ALIGN(4);
    __exidx_start = .;   	
    .ARM.exidx : ALIGN(4)
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > FLASH
    __exidx_end = .;
       
    .preinit_array ALIGN(4) :
    {
        PROVIDE_HIDDEN(_preinit_array_start = .);
        KEEP(*(.preinit_array*))
        PROVIDE_HIDDEN(_preinit_array_end = .);
    } > FLASH

    .init_array ALIGN(4) : {
        _init_array_start = .;
        KEEP(*(.init_array))
        _init_array_end = .;
    } > FLASH

    .fini_array ALIGN(4) : {
        _fini_array_start = .;
        KEEP(*(.fini_array))
        _fini_array_end = .;
    } > FLASH

    .gnu_build_id ALIGN(4) :
    {
        KEEP(*(.note.gnu.build-id))
        *(.note.gnu.build-id)
    } > FLASH

    .bss (NOLOAD) :             /* no need to load .bss section in final build since it will be zeroed on startup */
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss*)
        *(.bss.*)
        *(COMMON)               /* global variables (not static ones) */
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data*);
        *(.data.*);
        . = ALIGN(4);
        _edata = .;
    } > RAM AT > FLASH           /* needs to be relocated to RAM on startup */

    .stack (NOLOAD) :
    {
        . = ALIGN(8);           /* per AAPCS, stack should be double word aligned */
        _sstack = .;
        . = . + STACK_SIZE;
        . = ALIGN(8);
        _estack = .;
    } > RAM

    . = ALIGN(4);
    _end = . ;
}

 
