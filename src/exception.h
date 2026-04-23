#ifndef EXCEPTION_H
#define EXCEPTION_H

void exception_init(void);
void exception_panic(unsigned long vector_id,
                     unsigned long esr,
                     unsigned long elr,
                     unsigned long far,
                     unsigned long spsr);

#endif
