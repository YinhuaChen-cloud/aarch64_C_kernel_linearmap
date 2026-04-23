.section .text.head, "ax"
.global head_jump_to_main
.extern main
.extern __high_stack_top

head_jump_to_main:
    ldr x17, =__high_stack_top
    mov sp, x17

    msr ttbr0_el1, xzr
    dsb ish
    tlbi vmalle1
    dsb ish
    isb

    ldr x16, =main
    br x16
