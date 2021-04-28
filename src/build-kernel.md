# 构建 Kernel

## 安装必须软件

```
apt install -y flex bison libelf-dev
```

## build kernel

```
$ tools/packaging/kernel
$ ./build-kernel.sh setup
$ ./build-kernel.sh build
```

最后编译后的结果在 `kata-linux-5.10.25-84/`（这里 kernel 版本为 5.10.25）下，内核文件分别为 `arch/x86/boot/bzImage` 和 `vmlinux` 。

