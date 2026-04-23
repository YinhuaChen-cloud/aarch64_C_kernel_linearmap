#include "exception.h"
#include "uart.h"

#define TEST

#define ESR_EC_SHIFT 26UL
#define ESR_EC_MASK  0x3fUL
#define ESR_DFSC_MASK 0x3fUL

#define EC_DATA_ABORT_LOWER_EL   0x24UL
#define EC_DATA_ABORT_CURRENT_EL 0x25UL

static const char *exception_vector_name(unsigned long vector_id)
{
    switch (vector_id) {
    case 0:
        return "sync current EL with SP0";
    case 1:
        return "irq current EL with SP0";
    case 2:
        return "fiq current EL with SP0";
    case 3:
        return "SError current EL with SP0";
    case 4:
        return "sync current EL with SPx";
    case 5:
        return "irq current EL with SPx";
    case 6:
        return "fiq current EL with SPx";
    case 7:
        return "SError current EL with SPx";
    case 8:
        return "sync lower EL AArch64";
    case 9:
        return "irq lower EL AArch64";
    case 10:
        return "fiq lower EL AArch64";
    case 11:
        return "SError lower EL AArch64";
    case 12:
        return "sync lower EL AArch32";
    case 13:
        return "irq lower EL AArch32";
    case 14:
        return "fiq lower EL AArch32";
    case 15:
        return "SError lower EL AArch32";
    default:
        return "unknown vector";
    }
}

static int is_out_of_bounds_abort(unsigned long esr)
{
    unsigned long ec = (esr >> ESR_EC_SHIFT) & ESR_EC_MASK;
    unsigned long dfsc = esr & ESR_DFSC_MASK;

    if (ec != EC_DATA_ABORT_LOWER_EL && ec != EC_DATA_ABORT_CURRENT_EL) {
        return 0;
    }

    return (dfsc >= 0x4UL && dfsc <= 0x7UL);
}

void exception_panic(unsigned long vector_id,
                     unsigned long esr,
                     unsigned long elr,
                     unsigned long far,
                     unsigned long spsr)
{
    uart_puts("\nexception: ");
    uart_puts(exception_vector_name(vector_id));
    uart_putc('\n');

    if (is_out_of_bounds_abort(esr)) {
        uart_puts("内存访问越界异常\n");
    } else {
        uart_puts("未处理异常\n");
    }

    uart_puts("ESR_EL1 = ");
    uart_put_hex(esr);
    uart_putc('\n');
    uart_puts("ELR_EL1 = ");
    uart_put_hex(elr);
    uart_putc('\n');
    uart_puts("FAR_EL1 = ");
    uart_put_hex(far);
    uart_putc('\n');
    uart_puts("SPSR_EL1 = ");
    uart_put_hex(spsr);
    uart_putc('\n');

#ifdef TEST
    return;
#else
    for (;;) {
        __asm__ volatile ("wfe");
    }
#endif
}
