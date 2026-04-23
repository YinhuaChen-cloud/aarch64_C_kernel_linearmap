.section .text.exception, "ax"
.global exception_init
.extern exception_panic

exception_init:
    ldr x0, =exception_vectors
    msr vbar_el1, x0
    isb
    ret

.macro exception_entry label, vector_id
\label:
    mov x0, #\vector_id
    mrs x1, esr_el1
    mrs x2, elr_el1
    mrs x3, far_el1
    mrs x4, spsr_el1
    bl exception_panic

1:
    wfe
    b 1b
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
