OUTPUT_ARCH(aarch64)
ENTRY(_start)

__phys_base = 0x40080000;
__ttbr1_virt_offset = 0xffffffff00000000;

SECTIONS
{
    . = __phys_base;

    .init : ALIGN(16) {
        KEEP(build/start.o(.text.boot))
        build/start.o(.text* .rodata* .data*)
        build/init_c.o(.text* .rodata* .data*)
        build/mmu.o(.text* .rodata* .data*)
        build/exception.o(.text* .rodata* .data*)
        build/exception_vectors.o(.text* .rodata* .data*)
        build/early_uart.o(.text* .rodata* .data*)
    }

    .init.bss (NOLOAD) : ALIGN(16) {
        __bss_start = .;
        build/start.o(.bss* COMMON)
        build/init_c.o(.bss* COMMON)
        build/mmu.o(.bss* COMMON)
        build/exception.o(.bss* COMMON)
        build/exception_vectors.o(.bss* COMMON)
        build/early_uart.o(.bss* COMMON)
        . = ALIGN(16);
        __bss_end = .;
    }

    . = ALIGN(16);
    . += 0x10000;
    __stack_top = .;
    __high_stack_top = __ttbr1_virt_offset + __stack_top;

    __high_text_lma = ALIGN(., 16);
    . = __ttbr1_virt_offset + __high_text_lma;
    .text : AT(__high_text_lma) ALIGN(16) {
        build/head.o(.text*)
        build/main.o(.text*)
        build/uart.o(.text*)
    }

    __high_rodata_lma = ALIGN(LOADADDR(.text) + SIZEOF(.text), 16);
    . = __ttbr1_virt_offset + __high_rodata_lma;
    .rodata : AT(__high_rodata_lma) ALIGN(16) {
        build/head.o(.rodata*)
        build/main.o(.rodata*)
        build/uart.o(.rodata*)
    }

    __high_data_lma = ALIGN(LOADADDR(.rodata) + SIZEOF(.rodata), 16);
    . = __ttbr1_virt_offset + __high_data_lma;
    .data : AT(__high_data_lma) ALIGN(16) {
        build/head.o(.data*)
        build/main.o(.data*)
        build/uart.o(.data*)
    }

    __high_bss_lma = ALIGN(LOADADDR(.data) + SIZEOF(.data), 16);
    . = __ttbr1_virt_offset + __high_bss_lma;
    .bss (NOLOAD) : ALIGN(16) {
        build/head.o(.bss* COMMON)
        build/main.o(.bss* COMMON)
        build/uart.o(.bss* COMMON)
    }

    /DISCARD/ : {
        *(.comment*)
        *(.gnu*)
        *(.note*)
        *(.eh_frame*)
    }
}
