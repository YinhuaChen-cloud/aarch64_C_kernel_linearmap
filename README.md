# AArch64 hello world kernel

这是一个最小化的 AArch64 裸机小内核，使用 C 语言通过 QEMU `virt` 机器的 PL011 UART 输出 `hello world`，并在 `init_c()` 开头开启 EL1 MMU 和安装异常向量。

## 文件说明

- `src/start.S`：启动入口，设置栈、必要时从 EL2 切换到 EL1、清零 `.bss`
- `src/init_c.c`：`init_c()`，并在其中调用 `exception_init()` 和 `mmu_init()`
- `src/exception.c`：异常打印与异常原因解析
- `src/exception.h`：异常初始化与异常处理接口声明
- `src/exception_vectors.S`：异常向量表与 `exception_init()`
- `src/mmu.c`：一级页表与 `mmu_init()`
- `src/mmu.h`：`mmu_init()` 接口声明
- `src/uart.c`：PL011 UART 输出实现
- `src/uart.h`：UART 输出接口声明
- `linker.ld`：链接脚本，镜像基地址为 `0x40080000`
- `Makefile`：编译、生成镜像并启动 QEMU

## 异常处理说明

- 已在 EL1 配置异常向量表 `VBAR_EL1`
- 当前会捕获同步异常，并打印 `ESR_EL1`、`ELR_EL1`、`FAR_EL1`、`SPSR_EL1`
- `init_c()` 中包含两次测试写访问：
	- `0x80000000`：页表未映射，预期为 translation fault
	- `0xa0000000`：页表已映射到 Normal memory，但超出当前 QEMU RAM，预期为 synchronous external abort
- `exception_panic()` 会根据 `ESR_EL1.DFSC` 打印不同异常原因

## MMU 映射说明

当前使用 4KB granule 和 TTBR0_EL1 的一级块映射，采用恒等映射（VA = PA）：

- `0x00000000` - `0x3fffffff`：设备内存，用于覆盖 UART 和其他低地址 MMIO
- `0x40000000` - `0x7fffffff`：普通可缓存内存，用于覆盖 QEMU `virt` 的 RAM 与内核镜像
- `0x80000000` - `0xbfffffff`：通过二级页表仅额外映射 `0xa0000000` 所在 2MB 区间，用于测试“页表存在但物理内存不存在”的异常

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

当前默认以 1GB 内存启动 QEMU `virt` 机器。

当前示例会依次触发两类异常，因此 QEMU 终端会打印类似：

```text
mmu on (identity map)
hello world
test 1: trigger translation fault at 0x80000000

exception: sync current EL with SPx
MMU翻译错误（页表未映射）

test 2: trigger DRAM out-of-range access at 0xa0000000

exception: sync current EL with SPx
访问越界/外部终止（物理内存不存在）
```
