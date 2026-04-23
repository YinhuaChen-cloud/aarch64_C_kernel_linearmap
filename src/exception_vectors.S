.section .text.exception, "ax"
#define TEST
.global exception_init
.extern exception_panic

.equ EXC_FRAME_SIZE, 272
.equ EXC_X0_OFF, 0
.equ EXC_X2_OFF, 16
.equ EXC_X4_OFF, 32
.equ EXC_X6_OFF, 48
.equ EXC_X8_OFF, 64
.equ EXC_X10_OFF, 80
.equ EXC_X12_OFF, 96
.equ EXC_X14_OFF, 112
.equ EXC_X16_OFF, 128
.equ EXC_X18_OFF, 144
.equ EXC_X20_OFF, 160
.equ EXC_X22_OFF, 176
.equ EXC_X24_OFF, 192
.equ EXC_X26_OFF, 208
.equ EXC_X28_OFF, 224
.equ EXC_X30_OFF, 240
.equ EXC_ELR_OFF, 248
.equ EXC_SPSR_OFF, 256

exception_init:
    ldr x0, =exception_vectors
    msr vbar_el1, x0
    isb
    ret

.macro exception_entry label, vector_id
\label:
    sub sp, sp, #EXC_FRAME_SIZE
    stp x0, x1, [sp, #EXC_X0_OFF]
    stp x2, x3, [sp, #EXC_X2_OFF]
    stp x4, x5, [sp, #EXC_X4_OFF]
    stp x6, x7, [sp, #EXC_X6_OFF]
    stp x8, x9, [sp, #EXC_X8_OFF]
    stp x10, x11, [sp, #EXC_X10_OFF]
    stp x12, x13, [sp, #EXC_X12_OFF]
    stp x14, x15, [sp, #EXC_X14_OFF]
    stp x16, x17, [sp, #EXC_X16_OFF]
    stp x18, x19, [sp, #EXC_X18_OFF]
    stp x20, x21, [sp, #EXC_X20_OFF]
    stp x22, x23, [sp, #EXC_X22_OFF]
    stp x24, x25, [sp, #EXC_X24_OFF]
    stp x26, x27, [sp, #EXC_X26_OFF]
    stp x28, x29, [sp, #EXC_X28_OFF]
    str x30, [sp, #EXC_X30_OFF]

    mrs x5, elr_el1
    str x5, [sp, #EXC_ELR_OFF]
    mrs x5, spsr_el1
    str x5, [sp, #EXC_SPSR_OFF]

    mov x0, #\vector_id
    mrs x1, esr_el1
    ldr x2, [sp, #EXC_ELR_OFF]
    mrs x3, far_el1
    ldr x4, [sp, #EXC_SPSR_OFF]
    bl exception_panic

#ifdef TEST
    ldr x5, [sp, #EXC_ELR_OFF]
    add x5, x5, #4
    msr elr_el1, x5
    ldr x5, [sp, #EXC_SPSR_OFF]
    msr spsr_el1, x5

    ldp x0, x1, [sp, #EXC_X0_OFF]
    ldp x2, x3, [sp, #EXC_X2_OFF]
    ldp x4, x5, [sp, #EXC_X4_OFF]
    ldp x6, x7, [sp, #EXC_X6_OFF]
    ldp x8, x9, [sp, #EXC_X8_OFF]
    ldp x10, x11, [sp, #EXC_X10_OFF]
    ldp x12, x13, [sp, #EXC_X12_OFF]
    ldp x14, x15, [sp, #EXC_X14_OFF]
    ldp x16, x17, [sp, #EXC_X16_OFF]
    ldp x18, x19, [sp, #EXC_X18_OFF]
    ldp x20, x21, [sp, #EXC_X20_OFF]
    ldp x22, x23, [sp, #EXC_X22_OFF]
    ldp x24, x25, [sp, #EXC_X24_OFF]
    ldp x26, x27, [sp, #EXC_X26_OFF]
    ldp x28, x29, [sp, #EXC_X28_OFF]
    ldr x30, [sp, #EXC_X30_OFF]
    add sp, sp, #EXC_FRAME_SIZE
    eret
#else
1:
    wfe
    b 1b
#endif
.endm

.section .text.vectors, "ax"
.align 11
exception_vectors:
    b sync_current_sp0
    .align 7
    b irq_current_sp0
    .align 7
    b fiq_current_sp0
    .align 7
    b serr_current_sp0
    .align 7

    b sync_current_spx
    .align 7
    b irq_current_spx
    .align 7
    b fiq_current_spx
    .align 7
    b serr_current_spx
    .align 7

    b sync_lower_a64
    .align 7
    b irq_lower_a64
    .align 7
    b fiq_lower_a64
    .align 7
    b serr_lower_a64
    .align 7

    b sync_lower_a32
    .align 7
    b irq_lower_a32
    .align 7
    b fiq_lower_a32
    .align 7
    b serr_lower_a32

exception_entry sync_current_sp0, 0
exception_entry irq_current_sp0, 1
exception_entry fiq_current_sp0, 2
exception_entry serr_current_sp0, 3
exception_entry sync_current_spx, 4
exception_entry irq_current_spx, 5
exception_entry fiq_current_spx, 6
exception_entry serr_current_spx, 7
exception_entry sync_lower_a64, 8
exception_entry irq_lower_a64, 9
exception_entry fiq_lower_a64, 10
exception_entry serr_lower_a64, 11
exception_entry sync_lower_a32, 12
exception_entry irq_lower_a32, 13
exception_entry fiq_lower_a32, 14
exception_entry serr_lower_a32, 15
