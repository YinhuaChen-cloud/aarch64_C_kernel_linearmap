.section .text.boot
.global _start
.extern kernel_main
.extern __bss_start
.extern __bss_end
.extern __stack_top

_start:
    ldr x0, =__stack_top
    mov sp, x0

    bl switch_to_el1
    bl zero_bss
    bl kernel_main

1:
    wfe
    b 1b

switch_to_el1:
    mrs x0, CurrentEL
    cmp x0, #0x8
    b.ne 1f

    ldr x0, =__stack_top
    msr sp_el1, x0

    mov x0, #(1 << 31)
    msr hcr_el2, x0

    mov x0, #0x3c5
    msr spsr_el2, x0

    adr x0, 1f
    msr elr_el2, x0
    eret

1:
    ret

zero_bss:
    ldr x0, =__bss_start
    ldr x1, =__bss_end
    mov x2, #0

1:
    cmp x0, x1
    b.hs 2f
    str x2, [x0], #8
    b 1b

2:
    ret
