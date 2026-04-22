# AArch64 hello world kernel

这是一个最小化的 AArch64 裸机小内核，使用 C 语言通过 QEMU `virt` 机器的 PL011 UART 输出 `hello world`。

## 文件说明

- `src/start.S`：启动入口，设置栈、必要时从 EL2 切换到 EL1、清零 `.bss`
- `src/kernel.c`：UART 驱动与 `kernel_main()`
- `linker.ld`：链接脚本，镜像基地址为 `0x40080000`
- `Makefile`：编译、生成镜像并启动 QEMU

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
