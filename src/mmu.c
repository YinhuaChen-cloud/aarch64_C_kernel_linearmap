#include "mmu.h"

#define SCTLR_EL1_M   (1UL << 0)
#define SCTLR_EL1_C   (1UL << 2)
#define SCTLR_EL1_I   (1UL << 12)

#define MAIR_ATTR_DEVICE_nGnRnE 0x00UL
#define MAIR_ATTR_NORMAL_WB     0xffUL

#define TCR_T0SZ_4GB     32UL
#define TCR_IRGN0_WBWA   (1UL << 8)
#define TCR_ORGN0_WBWA   (1UL << 10)
#define TCR_SH0_INNER    (3UL << 12)
#define TCR_EPD1_DISABLE (1UL << 23)
#define TCR_IPS_36BIT    (1UL << 32)

#define PTE_VALID        (1UL << 0)
#define PTE_TABLE        (1UL << 1)
#define PTE_ATTRINDX(x)  ((unsigned long)(x) << 2)
#define PTE_SH_INNER     (3UL << 8)
#define PTE_AF           (1UL << 10)
#define PTE_UXN          (1UL << 54)
#define PTE_PXN          (1UL << 53)

static unsigned long l1_xlat_table[512] __attribute__((aligned(4096)));
static unsigned long l2_xlat_table_2[512] __attribute__((aligned(4096)));

static inline void dsb_ishst(void)
{
    __asm__ volatile ("dsb ishst" ::: "memory");
}

static inline void dsb_ish(void)
{
    __asm__ volatile ("dsb ish" ::: "memory");
}

static inline void isb(void)
{
    __asm__ volatile ("isb" ::: "memory");
}

static inline void tlbi_vmalle1(void)
{
    __asm__ volatile ("tlbi vmalle1" ::: "memory");
}

void mmu_init(void)
{
    unsigned long mair;
    unsigned long tcr;
    unsigned long sctlr;

    l1_xlat_table[0] = 0x00000000UL |
                       PTE_VALID |
                       PTE_ATTRINDX(0) |
                       PTE_AF |
                       PTE_UXN |
                       PTE_PXN;

    l1_xlat_table[1] = 0x40000000UL |
                       PTE_VALID |
                       PTE_ATTRINDX(1) |
                       PTE_SH_INNER |
                       PTE_AF;

    l1_xlat_table[2] = ((unsigned long)l2_xlat_table_2) |
                       PTE_VALID |
                       PTE_TABLE;

    l2_xlat_table_2[256] = 0xa0000000UL |
                           PTE_VALID |
                           PTE_ATTRINDX(1) |
                           PTE_SH_INNER |
                           PTE_AF;

    dsb_ishst();

    mair = (MAIR_ATTR_DEVICE_nGnRnE << 0) |
           (MAIR_ATTR_NORMAL_WB << 8);
    tcr = TCR_IPS_36BIT |
          TCR_EPD1_DISABLE |
          TCR_SH0_INNER |
          TCR_ORGN0_WBWA |
          TCR_IRGN0_WBWA |
          TCR_T0SZ_4GB;

    __asm__ volatile ("msr mair_el1, %0" :: "r" (mair) : "memory");
    __asm__ volatile ("msr tcr_el1, %0" :: "r" (tcr) : "memory");
    __asm__ volatile ("msr ttbr0_el1, %0" :: "r" (l1_xlat_table) : "memory");

    isb();
    tlbi_vmalle1();
    dsb_ish();
    isb();

    __asm__ volatile ("mrs %0, sctlr_el1" : "=r" (sctlr));
    sctlr |= SCTLR_EL1_M | SCTLR_EL1_C | SCTLR_EL1_I;
    __asm__ volatile ("msr sctlr_el1, %0" :: "r" (sctlr) : "memory");
    isb();
}
