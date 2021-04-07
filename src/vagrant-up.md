# 使用 VirtualBox 安装虚拟机开发环境

在平时闲聊或者吃饭的时候，隔壁同学谈到对 Kata Containers 也很感兴趣，问如何才能参与下或者学习下呢？确实现在 Kata Containers 社区版基本都是英文资料，而且也缺乏比较基础的入门资料，这也成为了这一系列文章的契机。

这一系列文章主要是介绍如何开始参与到 Kata Containers 的开发，这是其中第一部分，主要是看如何来安装开发环境。在这系列教程中，主要是以在 macOS 为宿主机，使用 VirtualBox + Vagrant + Ubuntu 为例来进行说明。

## 安装虚拟机

### 安装 VirtualBox

到[官网](https://www.virtualbox.org/wiki/Downloads)下载安装。

### 安装 Vagrant

到[官网](https://www.vagrantup.com/downloads.html)下载安装。

这时候需要确保命令行中可以使用 `vagrant` 命令。

```
$ vagrant  version
==> vagrant: A new version of Vagrant is available: 2.2.14 (installed version: 2.2.7)!
==> vagrant: To upgrade visit: https://www.vagrantup.com/downloads.html
```

顺带安装下vagrant的vagrant-disksize插件，否则启动虚拟机会报错。

```
$vagrant plugin install vagrant-disksize
Installing the 'vagrant-disksize' plugin. This can take a few minutes...
Fetching vagrant-disksize-0.1.3.gem
Installed the plugin 'vagrant-disksize (0.1.3)'!
```

### 创建虚拟机

首先创建一个工作目录：

```
$ mkdir kata-box
$ cd kata-box
```

创建 Vagrant 配置文件：

```bash

$ cat <<EOF > Vagrantfile
Vagrant.configure("2") do |config|
  # 磁盘大小，30 GB比较保守
  config.disksize.size = '30GB'
  config.vm.box = "bento/ubuntu-20.04"
  # 主机名，选择自己喜欢的
  config.vm.hostname="kata-box"
  config.vm.network "private_network", ip: "192.168.33.19"
  config.vm.provider "virtualbox" do |vb|
    # 虚拟机的资源，当然是越大越好。
    vb.cpus = 2
    vb.memory = "4096"
    # 开启嵌套虚拟化，即在虚拟机中再运行虚拟机（QEMU等）。
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
  end
end
EOF
```

配置文件编辑完之后，就可以启动虚拟机了。

```bash
$ vagrant up
```

第一次启动会比较慢，完全依赖于你的网速，因为初次启动需要从网络下载虚拟机镜像，即上面的 `bento/ubuntu-20.04` ，还会安装 GuestAdditions（ Vagrant 用于管理虚拟机的 guest OS ） ，这也是很耗时的一步。

如果启动没有问题，就可以通过 ssh 登录到虚拟机了。

```bash
$ vagrant ssh
```

以后，我们每次进到 kata-box 目录，都可以直接通过 vagrant 命令来管理虚拟机。

在 guest OS 中，通过检查内核模块看是否启用了kvm：

```bash
$ lsmod | grep kvm
kvm_intel             282624  0
kvm                   663552  1 kvm_intel
```

## 安装开发环境

Kata Containers 使用了 Golang 和 Rust 两种开发语言，分别对应 `runtime` 和 `agent` 两个子模块。`runtime` 主要和 `contaienrd` 等交互，实现了 `shimv2` 协议，负责 sandbox/containers 的管理。`agent` 运行在虚拟机（guest）内，通过 [`ttrpc`](https://github.com/containerd/ttrpc-rust) 协议和runtime交互。


以下操作均在虚拟机中进行。

最好提前设置好代理，如果想在线安装的话。

```bash
export http_proxy=http://xxx
export https_proxy=http://yyy
```

### 安装 Golang

安装最新版即可，这里都是用的 root 用户。

```bash
# wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
# rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.2.linux-amd64.tar.gz
# export PATH=$PATH:/usr/local/go/bin
# go version
go version go1.16.2 linux/amd64
```

注意要把上面的 PATH 更新到 `$HOME/.profile` 或相应文件里。

### 安装 Rust

```bash
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

如果安装失败或者很慢，可能是需要设置代理。这条命令会安装 cargo 等 Rust 所需要的各种工具，也需要一定耗时。

确认 cargo 是否安装成功：

```bash
# source $HOME/.cargo/env
# cargo -V
cargo 1.50.0 (f04e7fab7 2021-02-04)
```

## 安装 Kata Containers 2.0

### 安装 Kata Containers 2.0

这里使用直接从 GitHub 下载最新压缩包的方式安装。别问我为什么，貌似 Ubuntu 上还没有 2.0 的安装包，即通过 apt 来安装。

下载并解压缩：

```
# wget https://github.com/kata-containers/kata-containers/releases/download/2.0.1/kata-static-2.0.1-x86_64.tar.xz
# tar -C / -Jxvf kata-static-2.0.1-x86_64.tar.xz 
```

Kata 相关文件都会被解压到 /opt/kata/ 下面。Kata 的配置文件在 /opt/kata/share/defaults/kata-containers/ 下面，每种 hypervisor 都有一个对应的文件，默认使用 QEMU 。

```
$ ls -tl /opt/kata/share/defaults/kata-containers/
total 60
-rw-r--r-- 1 1001 lpadmin  9686 Jan 19 20:07 configuration-acrn.toml
-rw-r--r-- 1 1001 lpadmin  9315 Jan 19 20:07 configuration-clh.toml
-rw-r--r-- 1 1001 lpadmin 14948 Jan 19 20:07 configuration-fc.toml
-rw-r--r-- 1 1001 lpadmin 19703 Jan 19 20:07 configuration-qemu.toml
lrwxrwxrwx 1 1001 lpadmin    23 Jan 19 20:07 configuration.toml -> configuration-qemu.toml
```

### 安装 containerd

只有 Kata Containers 还不能单独工作，必须要有高层的 runtime 配合才行，比如 containerd 或者 CRI-O 。

这里使用传统方法来安装 containerd 。

```
$ apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
$ add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
$ apt-get update && apt-get install -y containerd.io
```

最后生成默认的配置文件，并重启 containerd：

```
$ containerd config default > /etc/containerd/config.toml
$ systemctl daemon-reload
$ systemctl restart containerd
```

### 安装 CNI

#### 安装 CNI

没办法，一切都是为 K8s 服务。

```
$ mkdir /go
$ export GOPATH=/go
$ git clone https://github.com/containernetworking/plugins.git $GOPATH/src/github.com/containernetworking/plugins
```

build：

```
$ cd $GOPATH/src/github.com/containernetworking/plugins
$ ./build_linux.sh 
```

部署：

```
$ mkdir -p /opt/cni/bin
$ cp bin/* /opt/cni/bin/
```

#### 配置 CNI


```
$ mkdir -p /etc/cni/net.d

$ cat > /etc/cni/net.d/10-mynet.conf <<EOF
{
  "cniVersion": "0.2.0",
  "name": "mynet",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "subnet": "172.19.0.0/24",
    "routes": [
      { "dst": "0.0.0.0/0" }
    ]
  }
}
EOF
```

### 配置 containerd

为 containerd 添加 Kata 运行时。这需要编辑 `/etc/containerd/config.toml` 文件，在合适的位置添加下面的内容（注意配置项目的嵌套关系）。

```
# diff /etc/containerd/config.toml /etc/containerd/config.toml.orig 
90,93d89
<         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata]
<           runtime_type = "io.containerd.kata.v2"
<           pod_annotations = ["io.katacontainers.*"]
<           privileged_without_host_devices = true
```

然后重启 containerd：

```
$ systemctl restart containerd
```

### 验证 Kata Containers + containerd 是否正常工作


可以使用 containerd 自带的 ctr 命令来创建容器，这个命令类似 Docker 的客户端命令。

下载镜像：

```
$ ctr image pull docker.io/library/busybox:latest
```

启动容器：

```
$ ctr run --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/busybox:latest hello sh
ctr: runtime "io.containerd.run.kata.v2" binary not installed "containerd-shim-kata-v2": file does not exist: unknown
```

莫慌，因为我们的 Kata containers 不是标准安装，所以 containerd 没有找到我们的 runtime binary 文件。

链接一下即可。

```
$ ln -s /opt/kata/bin/containerd-shim-kata-v2 /usr/local/bin/containerd-shim-kata-v2
```

之后就可以启动使用了 Kata Containres 的容器了。

```
ctr run --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/busybox:latest hello sh
/ # 
```

新开一个窗口，通过 ps 命令就可以看到 qemu 虚拟机在运行了。


## 安装 crictl 工具

### 安装 crictl 二进制文件

[crictl](https://github.com/kubernetes-sigs/cri-tools) 是支持 CRI 协议的命令行工具，可以进行Pod、Container的管理。

安装也很简单：

```
$ VERSION="v1.20.0"
$ wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
$ sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
$ rm -f crictl-$VERSION-linux-amd64.tar.gz
```

### 配置 crictl

为了能正常使用 crictl 命令，需要创建 crictl 命令用的配置文件：

```
# cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: false
EOF
```

### 验证 crictl

使用 crictl 需要手工先下载 2 个镜像。

- crictl pull k8s.gcr.io/pause:3.1
- crictl pull busybox:latest

上面的 k8s.gcr.io/pause:3.1 是 Pod 中 的 pause 容器的镜像，创建 Pod 的时候需要。busybox:latest 是容器运行的镜像。crictl 不会在运行创建或容器的时候自动下载镜像，所以需要提前手工下载。

镜像下载之后就可以创建 Pod 和容器，并启动容器。

创建 pod：

```
# pod=`crictl runp -r kata sandbox.yaml`
```

查看 pod：

```
# crictl pods
POD ID              CREATED             STATE               NAME                NAMESPACE           ATTEMPT             RUNTIME
d3e1a1567602e       24 seconds ago      Ready               busybox-sandbox     default             1                   kata
```

创建容器：

```
# cnt=`crictl create $pod container.yaml sandbox.yaml`
```

启动容器：

```
# crictl start $cnt
25222afa5327a5c4f11aee9c615df019fc39d9134700135606cdc3f49f113d7d
```

查看运行中的容器：

```
# crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID
25222afa5327a       busybox:latest      15 seconds ago      Running             busybox             0                   d3e1a1567602e
```

停止并删除 pod：

```
# crictl stopp $pod
Stopped sandbox d3e1a1567602e12335dc0f772774f96f4ef66736c0a98d9dd0ab14164292c4e9

# crictl rmp $pod
Removed sandbox d3e1a1567602e12335dc0f772774f96f4ef66736c0a98d9dd0ab14164292c4e9
```

## 常用 vagrant 命令

- vagrant up： 启动虚拟机
- vagrant halt：关机
- vagrant reload：重启
- vagrant ssh：登录虚拟机，用户都是vagrant来管理，不用自己操心
- vagrant destroy：删除虚拟机，危险操作。

## 小结

这一章，介绍了如何使用 Vagrant + VirtualBox 创建虚拟机，在虚拟机中安装 Kata Containers 2.0，并通过 crictl 工具来创建兼容 K8s 的 Pod。
