ifeq ($(shell command -v aarch64-none-elf-gcc 2>/dev/null),)
CROSS_COMPILE ?= aarch64-linux-gnu-
else
CROSS_COMPILE ?= aarch64-none-elf-
endif

CC      := $(CROSS_COMPILE)gcc
OBJCOPY := $(CROSS_COMPILE)objcopy
QEMU    ?= qemu-system-aarch64

BUILD_DIR   := build
KERNEL_ELF  := $(BUILD_DIR)/kernel.elf
KERNEL_IMG  := $(BUILD_DIR)/kernel8.img

CFLAGS  := -Wall -Wextra -O2 -ffreestanding -fno-stack-protector -fno-pic -fno-pie \
           -nostdlib -nostartfiles -mgeneral-regs-only -mcpu=cortex-a53
ASFLAGS := $(CFLAGS)
LDFLAGS := -T linker.ld -nostdlib -Wl,--build-id=none -Wl,-n

QEMU_FLAGS := -machine virt -cpu cortex-a53 -nographic -serial mon:stdio -kernel $(KERNEL_IMG)

.PHONY: all run clean check-toolchain

all: $(KERNEL_IMG)

check-toolchain:
	@command -v $(CC) >/dev/null 2>&1 || { \
		echo "error: missing $(CC)"; \
		echo "hint: install gcc-aarch64-linux-gnu or provide CROSS_COMPILE=<tool-prefix>"; \
		exit 1; \
	}
	@command -v $(OBJCOPY) >/dev/null 2>&1 || { \
		echo "error: missing $(OBJCOPY)"; \
		exit 1; \
	}

$(BUILD_DIR):
	@mkdir -p $@

$(KERNEL_ELF): check-toolchain $(BUILD_DIR) src/start.S src/main.c src/mmu.c src/mmu.h src/exception.c src/exception.h src/exception_vectors.S src/uart.c src/uart.h linker.ld
	$(CC) $(ASFLAGS) -c src/start.S -o $(BUILD_DIR)/start.o
	$(CC) $(CFLAGS) -c src/main.c -o $(BUILD_DIR)/main.o
	$(CC) $(CFLAGS) -c src/mmu.c -o $(BUILD_DIR)/mmu.o
	$(CC) $(CFLAGS) -c src/exception.c -o $(BUILD_DIR)/exception.o
	$(CC) $(CFLAGS) -c src/uart.c -o $(BUILD_DIR)/uart.o
	$(CC) $(ASFLAGS) -c src/exception_vectors.S -o $(BUILD_DIR)/exception_vectors.o
	$(CC) $(CFLAGS) $(LDFLAGS) $(BUILD_DIR)/start.o $(BUILD_DIR)/main.o $(BUILD_DIR)/mmu.o $(BUILD_DIR)/exception.o $(BUILD_DIR)/uart.o $(BUILD_DIR)/exception_vectors.o -o $@

$(KERNEL_IMG): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $(KERNEL_ELF) $@

run: all
	$(QEMU) $(QEMU_FLAGS)

clean:
	rm -rf $(BUILD_DIR)
