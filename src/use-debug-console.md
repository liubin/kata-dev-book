# 使用 debug console

有时候我们需要登录到 guest OS 中进行一些调试工作，Kata Containers 支持两种方式的 debug console ：

- 传统 console 设备
- 基于 vsock 的连接

## 基于 vsock 的连接

这种方式是 agent 在 guest 中启动一个 bash/sh 进程，等待客户端通过 vsock 连接到 1026 端口，然后进行 I/O/Signal 的转发。

要想启用 vsock 的 debug console ，可以在 `configuration.toml` 文件中使用下面的配置：

```
[agent.kata]
debug_console_enabled = true
```

agent 启动参数（`kernel_params` 参数）设置 `agent.debug_console agent.debug_console_vport=1026` 两个参数也可以起到相同的效果。

`kata-runtime` 提供了一个 `exec` 子命令来连接 guest 中的 console bash 进程：

```
$ kata-runtime exec 1a9ab65be63b8b03dfd0c75036d27f0ed09eab38abb45337fea83acd3cd7bacd
bash-4.2# id
uid=0(root) gid=0(root) groups=0(root)
```

其中 `1a9ab65be63b8b03dfd0c75036d27f0ed09eab38abb45337fea83acd3cd7bacd` 为要登录的 Pod 的 ID。

## 传统 console 设备

TODO