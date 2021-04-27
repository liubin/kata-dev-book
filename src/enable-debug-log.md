# 开启 debug log

开启 debug log 可以帮助我们获得更详细的 log，除了 runtime 的 log，而且还能看到 agent 的 log，以及 guest OS 中 kernel 的 log（dmesg命令的输出）。

开启 debug log，需要修改两个配置文件：

- containerd/CRI-O
- Kata Containers

## containerd

### containerd

`containerd` 配置文件按如下修改即可：

```
[debug]
        level = "debug"

```

### CRI-O

`CRI-O` 配置文件按如下修改即可：

```
# Changes the verbosity of the logs based on the level it is set to. Options
# are fatal, panic, error, warn, info, debug and trace. This option supports
# live configuration reload.
log_level = "info"
```

## Kata Containers

在 Kata Containers 中需要开启 runtime 和 agent 的 debug log。

### runtime

修改 runtime 的配置文件，打开里面的 `enable_debug` 选项：

```
$ sudo sed -i -e 's/^# *\(enable_debug\).*=.*$/\1 = true/g' /etc/kata-containers/configuration.toml
```

### agent

需要通过 kernel 启动参数来配置 agent，启用 debug log。

```
$ sudo sed -i -e 's/^kernel_params = "\(.*\)"/kernel_params = "\1 agent.log=debug"/g' /etc/kata-containers/configuration.toml
```
