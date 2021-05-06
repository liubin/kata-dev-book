# 下载并编译 Kata Containers 代码

上一篇文章中介绍了如何使用VirtualBox + Vagrant 构建一台基于 Ubuntu 的虚拟机，并在里面安装了 containerd + Kata Containers 2.0，同时安装好了开发环境，包括 Golang 和 Rust 。不过我们还没有进行过任何开发活动，这也是我们从这篇文章开始将要接触到的内容。

在本篇文章中，我们将会主要讲述如下一些内容：

- Kata Containers 仓库介绍
- 如何编译 runtime 和 agent 两个组件

## Kata Containers 仓库介绍

Kata Containers 代码托管在 GitHub 上，这是它的主页： https://github.com/kata-containers 。

目前 Kata Containers 有两个版本：1.x 和 2.0 ，1.x 基本处于维护阶段，新功能都在 2.0 上开发。

根据 Kata Containers 版本的不同，代码仓库也有些不一样。

### Kata Containers 1.x

**Note：**本系列文章以 Kata Containers 2.0 为对象进行说明，对 1.x 的说明仅供了解。

在 Kata Containers 1.x 中，涉及到的组件比较多，主要有以下几个：

|组件|语言|说明|
|---|---|---|
|[runtime](https://github.com/kata-containers/runtime)|Golang|runtime/shimv2|
|[kata-agent](https://github.com/kata-containers/agent)|Golang|运行在 guest 中的 agent，和 runtime 通过 gRPC 协议通信，负责 guest 内容器的管理|
|[kata-proxy](https://github.com/kata-containers/proxy)|Golang|运行在 host 中的代理，负责路由kata-shim和kata-runtime到kata-agent之间的I/O和信号|
|[kata-shim](https://github.com/kata-containers/shim)|Golang|运行在 host 中，负责 guest 中进程的 I/O 拷贝和信号处理|
|[documentation](https://github.com/kata-containers/documentation)|文档|开发、使用文档|
|[packaging](https://github.com/kata-containers/packaging)|文档、脚本|构建内核、安装包、发布新版本|
|[osbuilder](https://github.com/kata-containers/osbuilder)|文档、脚本|构建 guest OS 镜像|

### Kata Containers 2.0

从上面的仓库介绍来说，2.0 在开发上主要有以下几个重大的变更点：

- agent 使用 Rust 重写
- 只支持 shimv2，因此少了 proxy 和 shim 组件

在 Kata Containers 2.0 中，核心组件只剩下两个：runtime 和 agent ，且都在[kata-containers](https://github.com/kata-containers/kata-containers) 这个 repo 下。

这个 repo 的目录和文件有如下几个可以拿出来先提前说明一下的（开发中经常会修改或参考的）：

 - versions.yaml：记录了测试、构建所需要的软件版本信息
 - ci：CI 测试脚本（主要依赖的其实是 [tests](https://github.com/kata-containers/tests) 仓库）。
 - docs：文档信息，对应 1.x 的 documentation 仓库。
 - tools：原来的 packaging 和 osbuilder 挪到了这里。
 - src：核心组件的源代码。

#### src 目录介绍

kata-containers/src 下有如下几个项目的代码：

- agent： agent 代码
- runtime： runtime（shimv2）代码
- trace-forwarder：可选，一个用于将 guest 内的 trace 通过 vsock 转发出来的组件。
- kata-monitor：可选，运行在主机中，运行一些 shimv2 协议之外的管理接口。


### 其他仓库

除了上面的主要代码仓库之外，作为一个颇具规模的开源软件，Kata Containers 还有一些其他的仓库需要了解下。

#### community

[community](https://github.com/kata-containers/community) 里面记录的是如何进行项目管理，包括治理委员会的组成和选举，以及开发者和贡献者的管理等内容。

#### tests

[tests](https://github.com/kata-containers/tests) 是非常重要的一个仓库，所有关于测试的代码都在这里，我们提交的每个 PR ，都会通过 CI 进行测试，而测试的主体代码都在这个仓库里。

## Kata Containers 开发流程

Kata Containers 社区通过 PR 的方式来修改软件，也就是任何提交，都需要通过创建 PR、review 后，合并到主分支。 

在提交代码之前，你还需要先 [创建一个 issue](https://github.com/kata-containers/kata-containers/issues/new/choose)， 来介绍你为什么要做这次提交。基本来说 issue 有两种类型： bug 和 feature（enhancement）。不管是哪种类型，都需要描述问题的背景，以及如何解决，这样可以方便其他开发人员理解该问题，提高 review 代码的速度，这也是 PR 能今早合并的一个前提条件。

Issue 有了后，就可以在本地修改代码、测试，如果测试通过，就可以提交代码了。

提交代码的时候，对 commit message 的要求比较严格，一般来说是需要按照这样的格式来填写的：

```
subsystem: One line change summary

More detailed explanation of your changes (why and how)
that spans as many lines as required.

Fixes: #1234

Signed-off-by: Contributors Name <contributor@foo.com>
```

即，commit message 包含 4 部分：

- title： 由 subsystem: title 组成
- body： 具体的说明，比如为了解决什么问题，如何处理，注意事项，参考资料等
- Fixes：需要指明这个 PR 是为了解决哪个 issue
- Signed-off-by：这个可以通过 git commit -s 来自动生成。

关于 commit message，我们会在后面的实例中再次进行说明。

代码提交、push 到 GitHub 后，就可以到 GitHub 上创建 PR 了，这部分可以参考 GitHub 的官方文档，这里不做说明，假设你了解该如何去做。如果你有 gitlab 的使用经验，应该可以很快入手。

这里列出的只是 Kata Containers 开发中比较重要的点，具体的一些注意事项，比如 git config 的配置，代码格式的检查等，我们都会在后面的系列文章中逐步进行详细的说明。

## 编译 Kata Containers 组件

### Fork Kata Containers 仓库

首先，你需要在 GitHub 上 fork Kata Containers 的代码仓库，然后把自己 fork 的仓库下载到本地。

```
$ git clone git@github.com:{your-github-username}/kata-containers.git $GOPATH/src/github.com/kata-containers/kata-containers
```

### 编译 runtime 组件

```
$ cd $GOPATH/src/github.com/kata-containers/kata-containers/src/runtime
$ make
```

第一次 make 的时候大概率会需要安装 yq 命令：

```
INFO: yq was not found, installing it
```

如果安装失败，则可能需要配置下网络代理。

如果一切正常，构建会比较快，你可以在当前文件夹下看到如下的一些二进制文件：

- containerd-shim-kata-v2
- kata-monitor
- kata-netmon
- kata-runtime

我们的大部分开发工作，基本都会围绕着 containerd-shim-kata-v2 进行。

如果想使用自己编译的 containerd-shim-kata-v2 代替系统的 containerd-shim-kata-v2， 可以做一个符号链接即可：

```
# ln -s $GOPATH/src/github.com/kata-containers/kata-containers/src/runtime/containerd-shim-kata-v2 /usr/local/bin/containerd-shim-kata-v2
```

### 编译 agent 组件

和 runtime 组件不同，agent 采用 Rust 编写，所有依赖的库都没有被以 vendor 的形式放到代码仓库里，在构建的时候，需要从网络上下载，所以初次构建 agent 会比较慢，所耗时间，还和宿主机的配置有关。


在编译 agent 之前，需要先安装 x86_64-unknown-linux-musl 用于静态链接（默认链接方式）。

```
$ rustup target add x86_64-unknown-linux-musl
```

之后就可以编译 agent 了。

```
$ cd $GOPATH/src/github.com/kata-containers/kata-containers/src/agent
$ make
```

在我的 2C4G 虚拟机中，这个构建过程花费了近 6 分钟的时间。不过这只是第一次构建的耗时而已，只要你不执行 make clean ，如果只是简单修改代码后再构建，耗时应该会比这个低一些。

编译后的 kata-agent 文件在 target/x86_64-unknown-linux-musl/release/ 下面，这个文件需要在 guest OS 中运行，所以我们编译完了之后还不能直接使用，而必须要把它放到 guest OS 的镜像之中，不过这里我们暂时还不打算立刻介绍如何去做，等到后面有机会的时候，再做具体的详细说明。

## 小结

这篇文章给大家介绍了要想参与 Kata Containers 的开发，都会需要解除哪些代码仓库，大致的开发流程，也介绍了如何编译 runtime 和 agent 组件。在下一章，我们将会看到如何做一些具体的修改，并进行测试。
