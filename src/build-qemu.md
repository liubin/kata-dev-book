# 构建 QEMU

构建 QEMU 可以使用 `packaging` 下面的脚本，只需要执行如下命令即可：


```bash
$ export qemu_repo=https://github.com/qemu/qemu
$ export qemu_version=v6.1.0

$ ./tools/packaging/static-build/qemu/build-static-qemu.sh
```

中间可能缺一些软件，到时候按提示安装即可。不过可能会花些时间，尤其是第一次，该 build 是在 Docker 容器中进行的。
