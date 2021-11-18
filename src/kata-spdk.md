# 在 Kata Containers 中使用 SPDK

关于如何在 Kata Containers 中使用 SPDK，官方有一个[使用说明](https://github.com/kata-containers/kata-containers/blob/main/docs/use-cases/using-SPDK-vhostuser-and-kata.md)，只是之前是基于 Docker 的，由于 Kata Containers 已经不直接支持 Docker（或者说反过来 Docker 不支持 Kata Containers），所以原来的文档需要更新，比如使用 ctr 来演示如何在 Kata Containers 中使用 SPDK 设备。

趁这次更新文档的机会，顺便记录了一些中间的具体过程，但是全部放到 [原文档](https://github.com/kata-containers/kata-containers/pull/3055) 中又有些冗余，所以在这里记录一下。

演示示例主要在于 ctr 需要自己准备 rootfs 和 OCI spec （`config.json`）文档，这里我直接给出了相关脚本，直接使用即可。

首先确保你已经按照官方 [使用说明](https://github.com/kata-containers/kata-containers/blob/main/docs/use-cases/using-SPDK-vhostuser-and-kata.md) 准备好了 SPDK 设备。

## 创建 rootfs

使用这个脚本即可，这会使用一个 busybox 镜像作为 rootfs。

```bash
ctr i pull quay.io/prometheus/busybox:latest 
ctr i export rootfs.tar quay.io/prometheus/busybox:latest 

rootfs_tar=rootfs.tar
bundle_dir="./bundle"
mkdir -p "${bundle_dir}"

# extract busybox rootfs
rootfs_dir="${bundle_dir}/rootfs"
mkdir -p "${rootfs_dir}"
layers_dir="$(mktemp -d)"
tar -C "${layers_dir}" -pxf "${rootfs_tar}"
for ((i=0;i<$(cat ${layers_dir}/manifest.json | jq -r ".[].Layers | length");i++)); do
    tar -C ${rootfs_dir} -xf ${layers_dir}/$(cat ${layers_dir}/manifest.json | jq -r ".[].Layers[${i}]")
done
```

该脚本会使用 ctr 下载镜像，将镜像导出为 tar 文件，这时候 export 出来的还是 blob 格式，不能直接当做 rootfs 使用，需要再将每层解压缩，才能作为 rootfs 使用。

上面的脚本执行后，就可以在本地看到 rootfs 了：

```bash
# ./create_rootfs.sh 
quay.io/prometheus/busybox:latest:                                                resolved       |++++++++++++++++++++++++++++++++++++++| 
index-sha256:a56e11cce1c09f50a71290d65733ebe976adc8654395091d5379c7f294cc891e:    done           |++++++++++++++++++++++++++++++++++++++| 
manifest-sha256:de4af55df1f648a334e16437c550a2907e0aed4f0b0edf454b0b215a9349bdbb: done           |++++++++++++++++++++++++++++++++++++++| 
layer-sha256:b45d31ee2d7f9f452678a85b0c837c29e12089f31ee8dbac6c8c24dfa4054a30:    done           |++++++++++++++++++++++++++++++++++++++| 
layer-sha256:aa2a8d90b84cb2a9c422e7005cd166a008ccf22ef5d7d4f07128478585ce35ea:    done           |++++++++++++++++++++++++++++++++++++++| 
config-sha256:765c5b099deb79705ac7f947580453504f7c5d81d38e1e661b397e2648383815:   done           |++++++++++++++++++++++++++++++++++++++| 
elapsed: 1.1 s                                                                    total:   0.0 B (0.0 B/s)                                         
unpacking linux/amd64 sha256:a56e11cce1c09f50a71290d65733ebe976adc8654395091d5379c7f294cc891e...
done
root@kant:/tmp/rootfs
# ls 
bundle  create_rootfs.sh  rootfs.tar
root@kant:/tmp/rootfs# ls bundle/
rootfs
root@kant:/tmp/rootfs# ls bundle/rootfs/
bin  dev  etc  home  lib  root  tmp  usr  var

```

## 准备 config.json 文件

将下面的 `config.json` 文件拷贝到 bundle 下即可，注意其中的 rootfs 要根据自己的实际情况修改。

将 SPDK 设备传递给 Kata Containers 是通过指定 `devices` 属性实现的。其中 `major: 241` 是 Kata Containers 约定的 vhost-user-blk 设备的编号，文件模式 420 即 8 进制的 644。 


```json
    "linux": {
        "devices": [{
            "path": "/dev/vda",
            "type": "b",
            "major": 241,
            "minor": 0,
            "fileMode": 420,
            "uid": 0,
            "gid": 0
        }]
    }
```

然后就可以启动 Kata Containers 容器了。

```bash
$ sudo ctr run -d --runtime io.containerd.run.kata.v2 --config bundle/config.json spdk_container
$ sudo ctr t exec --exec-id 1 -t spdk_container sh
/ # ls -l /dev/vda
brw-r--r--    1 root     root      254,   0 Jan 20 03:54 /dev/vda
/ # dd if=/dev/vda of=/tmp/ddtest bs=4k count=20
20+0 records in
20+0 records out
81920 bytes (80.0KB) copied, 0.002996 seconds, 26.1MB/s
```


完整的 `config.json` 如下：

```json
{
    "ociVersion": "1.0.0-rc2-dev",
    "platform": {
        "os": "linux",
        "arch": "amd64"
    },
    "process": {
        "terminal": false,
        "consoleSize": {
            "height": 0,
            "width": 0
        },
        "user": {
            "uid": 0,
            "gid": 0
        },
        "args": [ "/bin/tail", "-f", "/dev/null" ],
        "env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "TERM=xterm"
        ],
        "cwd": "/",
        "rlimits": [{
            "type": "RLIMIT_NOFILE",
            "hard": 1024,
            "soft": 1024
        }],
        "noNewPrivileges": true
    },
    "root": {
        "path": "/tmp/rootfs/bundle/rootfs",
        "readonly": false
    },
    "hostname": "spdk-test",
    "mounts": [{
            "destination": "/proc",
            "type": "proc",
            "source": "proc"
        },
        {
            "destination": "/dev",
            "type": "tmpfs",
            "source": "tmpfs",
            "options": [
                "nosuid",
                "strictatime",
                "mode=755",
                "size=65536k"
            ]
        },
        {
            "destination": "/dev/pts",
            "type": "devpts",
            "source": "devpts",
            "options": [
                "nosuid",
                "noexec",
                "newinstance",
                "ptmxmode=0666",
                "mode=0620",
                "gid=5"
            ]
        },
        {
            "destination": "/dev/shm",
            "type": "tmpfs",
            "source": "shm",
            "options": [
                "nosuid",
                "noexec",
                "nodev",
                "mode=1777",
                "size=65536k"
            ]
        },
        {
            "destination": "/dev/mqueue",
            "type": "mqueue",
            "source": "mqueue",
            "options": [
                "nosuid",
                "noexec",
                "nodev"
            ]
        },
        {
            "destination": "/sys",
            "type": "sysfs",
            "source": "sysfs",
            "options": [
                "nosuid",
                "noexec",
                "nodev",
                "ro"
            ]
        },
        {
            "destination": "/sys/fs/cgroup",
            "type": "cgroup",
            "source": "cgroup",
            "options": [
                "nosuid",
                "noexec",
                "nodev",
                "relatime",
                "ro"
            ]
        }
    ],
    "hooks": {},
    "linux": {
        "devices": [{
            "path": "/dev/vda",
            "type": "b",
            "major": 241,
            "minor": 0,
            "fileMode": 420,
            "uid": 0,
            "gid": 0
        }],
        "cgroupsPath": "kata/spdktest",
        "resources": {
            "devices": [
            ]
        },
        "namespaces": [{
                "type": "pid"
            },
            {
                "type": "network"
            },
            {
                "type": "ipc"
            },
            {
                "type": "uts"
            },
            {
                "type": "mount"
            }
        ],
        "maskedPaths": [
            "/proc/kcore",
            "/proc/latency_stats",
            "/proc/timer_list",
            "/proc/timer_stats",
            "/proc/sched_debug",
            "/sys/firmware"
        ],
        "readonlyPaths": [
            "/proc/asound",
            "/proc/bus",
            "/proc/fs",
            "/proc/irq",
            "/proc/sys",
            "/proc/sysrq-trigger"
        ]
    }
}
```