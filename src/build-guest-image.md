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

## 脚本说明

这里以使用了 Docker(`USE_DOCKER=true`) 的场景进行说明。

### 构建 rootfs

主要文件在 `rootfs.sh` ，入口函数为 `main()`，这个函数主要有两个函数组成：

 - `build_rootfs_distro`
 - `setup_rootfs`


#### `build_rootfs_distro`

首先会创建 Dockerfile，这使用了 scripts/lib.sh 中的 `generate_dockerfile` 函数，构建命令如下（省略部分参数）：

```
docker build -t ubuntu-rootfs-osbuilder ./rootfs-builder/ubuntu
```

镜像构建之后，会基于这个镜像，启动一个容器来构建 agent 和 rootfs。这时候启动的命令如下（省略部分参数，节选自社区 CI job 日志）：

```bash
docker run --env https_proxy= --env http_proxy= --env AGENT_VERSION= --env ROOTFS_DIR=/rootfs --env AGENT_BIN=kata-agent --env AGENT_INIT=no --env KERNEL_MODULES_DIR= --env EXTRA_PKGS= --env OSBUILDER_VERSION=2.2.0-alpha0-81ae07081da935ab010a9719f38074df8af20c20 --env INSIDE_CONTAINER=1 --env SECCOMP= --env DEBUG=true --env HOME=/root -v /tmp/jenkins/workspace/kata-containers-2.0-fedora-PR/go/src/github.com/kata-containers/kata-containers/tools/osbuilder/rootfs-builder/../../../:/kata-containers -v /tmp/jenkins/workspace/kata-containers-2.0-fedora-PR/go/src/github.com/kata-containers/kata-containers/tools/osbuilder/ubuntu_rootfs:/rootfs -v /tmp/jenkins/workspace/kata-containers-2.0-fedora-PR/go/src/github.com/kata-containers/kata-containers/tools/osbuilder/rootfs-builder/../scripts:/scripts -v /tmp/jenkins/workspace/kata-containers-2.0-fedora-PR/go/src/github.com/kata-containers/kata-containers/tools/osbuilder/ubuntu_rootfs:/tmp/jenkins/workspace/kata-containers-2.0-fedora-PR/go/src/github.com/kata-containers/kata-containers/tools/osbuilder/ubuntu_rootfs --rm --runtime runc -v /tmp/jenkins/workspace/kata-containers-2.0-fedora-PR/go:/tmp/jenkins/workspace/kata-containers-2.0-fedora-PR/go --env GOPATH=/tmp/jenkins/workspace/kata-containers-2.0-fedora-PR/go --cap-add SYS_ADMIN --cap-add SYS_CHROOT --cap-add MKNOD \
--env STAGE_PREPARE_ROOTFS=1 \
ubuntu-rootfs-osbuilder \
bash /kata-containers/tools/osbuilder/rootfs-builder/rootfs.sh ubuntu
```

我们可以看到，在容器中执行的是 `bash /kata-containers/tools/osbuilder/rootfs-builder/rootfs.sh ubuntu` 命令。

这相当于在容器里又运行了 `rootfs.sh` 但是没有使用 `USE_DOCKER` 参数，所以这时候会执行到这里：

```bash
if [ -z "${USE_DOCKER}" ] && [ -z "${USE_PODMAN}" ]; then
	info "build directly"
	build_rootfs ${ROOTFS_DIR}
else
	...
fi
```

即执行 `build_rootfs` 函数。这个函数默认实现在 `scripts/lib.sh` 中，各个 distro 也可以覆盖，可以参考 `rootfs/` 下各 distro 下面中的内容。

默认实现中只是安装了各种需要的 package。

#### `setup_rootfs`


`setup_rootfs` 主要是编译和安装 agent。

这个函数在 main 中通过环境变量来控制是否执行：

```bash
if [ "$STAGE_PREPARE_ROOTFS" == "" ]; then
	init="${ROOTFS_DIR}/sbin/init"
	setup_rootfs
fi
```

主入口，即从 host 执行的时候，这个变量是空的；再通过 docker run 启动容器的时候，设置了 `STAGE_PREPARE_ROOTFS=1` 这个环境变量，所以容器中不会执行 `setup_rootfs` 。

