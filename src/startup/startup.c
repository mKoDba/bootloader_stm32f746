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
 * @file    startup.c
 * @author  mario.kodba
 * @brief   Startup file used for setting up environment for executing program on Cortex-M processor
 *          and handing over control to main program.
 **************************************************************************************************/

/******************************************************************************
 *                  EXTERNAL REFERENCES
 *****************************************************************************/
// top of stack, used to initialize SP
extern unsigned int _estack;
// start of .bss section
extern unsigned int _sbss;
// end of .bss section
extern unsigned int _ebss;
// start of .data section
extern unsigned int _sdata;
// end of .data section
extern unsigned int _edata;
// .rodata that needs to relocated to RAM
extern unsigned int _etext;

extern int main(void);

/******************************************************************************
 *                  INTERNAL REFERENCES
 *****************************************************************************/
#ifdef __cplusplus
extern "C"
{
#endif
void RESET_handler(void);
void DEFAULT_handler(void);

static void clear_bss(void);
static void copy_data(void);

/******************************************************************************
 *                  INTERRUPT VECTORS
 *****************************************************************************/
// these handlers are with attribute 'weak' and can be overwritten by non-weak function, default is DEFAULT_handler() function
void NMI_handler            (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void HARDFAULT_handler      (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void MEMMANAGE_handler      (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void BUSFAULT_handler       (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void USAGEFAULT_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void SVCALL_handler         (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void DEBUGMONITOR_handler   (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void PENDSV_handler         (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void SYSTICK_handler        (void) __attribute__ ((weak, alias("DEFAULT_handler")));

void INTERRUPT0_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT1_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT2_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT3_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT4_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT5_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT6_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT7_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT8_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));
void INTERRUPT9_handler     (void) __attribute__ ((weak, alias("DEFAULT_handler")));


__attribute__((section(".vectors"))) void *_vector_table[] = {
    (void *) (&_estack),            // configure initial SP, using linker-generated symbols
    (void *) RESET_handler,
    (void *) NMI_handler,
    (void *) HARDFAULT_handler,
    (void *) MEMMANAGE_handler,
    (void *) BUSFAULT_handler,
    (void *) USAGEFAULT_handler,
    (void *) DEFAULT_handler,       // reserved
    (void *) DEFAULT_handler,       // reserved
    (void *) DEFAULT_handler,       // reserved
    (void *) DEFAULT_handler,       // reserved        
    (void *) SVCALL_handler,
    (void *) DEBUGMONITOR_handler,
    (void *) DEFAULT_handler,       // reserved
    (void *) PENDSV_handler,
    (void *) SYSTICK_handler,

    (void *) INTERRUPT0_handler,                     // interrupt 0 
    (void *) INTERRUPT1_handler,                     // interrupt 1
    (void *) INTERRUPT2_handler,                     // interrupt 2
    (void *) INTERRUPT3_handler,                     // interrupt 3
    (void *) INTERRUPT4_handler,                     // interrupt 4
    (void *) INTERRUPT5_handler,                     // interrupt 5
    (void *) INTERRUPT6_handler,                     // interrupt 6
    (void *) INTERRUPT7_handler,                     // interrupt 7
    (void *) INTERRUPT8_handler,                     // interrupt 8
    (void *) INTERRUPT9_handler                      // interrupt 9
                                                     // interrupts 10 .. 223 are left out
};


void RESET_handler(void) {

    clear_bss();
    copy_data();

    // main application starting point
    main();

    while(1);
}

void DEFAULT_handler(void) {

    while(1);
}

// copy initialization .rodata from FLASH to .data section in RAM
static void copy_data(void) {

    unsigned int *dst = &_sdata;
    unsigned int *src = &_etext;

    while(dst < &_edata) {
        *dst = *src;
        src++;
        dst++;
    }
}

// clears .bss section as required by standard
static void clear_bss(void) {

    unsigned int *addr = &_sbss;

    while(addr < &_ebss) {
        *addr = 0u;
        addr++;
    }
}

#ifdef __cplusplus
}
#endif