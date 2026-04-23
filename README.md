# AArch64 hello world kernel

这是一个最小化的 AArch64 裸机小内核，使用 C 语言通过 QEMU `virt` 机器的 PL011 UART 输出 `hello world`，并在进入 `kernel_main()` 前开启 EL1 MMU。

## 文件说明

- `src/start.S`：启动入口，设置栈、必要时从 EL2 切换到 EL1、清零 `.bss`、调用 MMU 初始化
- `src/main.c`：UART 驱动与 `kernel_main()`
- `src/mmu.c`：一级页表与 `mmu_init()`
- `src/mmu.h`：`mmu_init()` 接口声明
- `linker.ld`：链接脚本，镜像基地址为 `0x40080000`
- `Makefile`：编译、生成镜像并启动 QEMU

## MMU 映射说明

当前使用 4KB granule 和 TTBR0_EL1 的一级块映射，采用恒等映射（VA = PA）：

- `0x00000000` - `0x3fffffff`：设备内存，用于覆盖 UART 和其他低地址 MMIO
- `0x40000000` - `0x7fffffff`：普通可缓存内存，用于覆盖 QEMU `virt` 的 RAM 与内核镜像

## 依赖

需要以下工具之一：

- `aarch64-none-elf-gcc`
- `aarch64-linux-gnu-gcc`

当前 `Makefile` 会优先使用 `aarch64-none-elf-` 前缀，否则回退到 `aarch64-linux-gnu-`。

在 Debian/Ubuntu 上可安装：

```bash
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu qemu-system-arm make
```

## 使用方法

构建：

```bash
make
```

运行：

```bash
make run
```

正常情况下，QEMU 终端会打印：

```text
hello world
```
