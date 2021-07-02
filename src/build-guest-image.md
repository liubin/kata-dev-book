# 构建 guest image


## 构建 rootfs

```
# cd tools/osbuilder
# make USE_DOCKER=true rootfs-fedora
```

其中 `rootfs-fedora` 表示构建 fedora 的镜像，也可以直接使用 `make rootfs`，这将构建默认的 distro 镜像。

创建好的 rootfs 在 `fedora_rootfs` 下，文件夹名中的 `fedora` 即所指定的操作系统类型。

## 构建镜像


```
# cd tools/osbuilder
# make USE_DOCKER=true image-fedora
```

创建好的 image 文件为 `kata-containers-image-fedora.img` ，文件名中的 `fedora` 即所指定的操作系统类型。

