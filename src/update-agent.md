
# 更新镜像里的 agent

在开发中，如果要测试 agent，最直接的还是将 agent 安装到镜像中测试。本文档介绍如何更新镜像中的 agent。

## 编译 agent

略过，请参考其他章节。

## 更新 agent

这个脚本假设：

- 镜像文件在 `/home/work/kata-containers.img`
- 编译后的 agent 文件在 `/home/work/kata-agent`

```bash
#!/bin/bash

set -e
set -x
sudo mkdir -p /mnt/disk

## 镜像文件
img_file=/home/work/kata-containers.img

sudo losetup  -f $img_file

dev=$(losetup  | grep kata-containers | awk '{ print $1}')
f=$(basename $dev)

sudo kpartx -a $dev
sudo mount /dev/mapper/${f}p1 /mnt/disk

sudo cp /home/work/kata-agent /mnt/disk/usr/bin/kata-agent

sudo umount /mnt/disk/
sudo kpartx -d $dev
sudo losetup -d $dev
sudo losetup
```


