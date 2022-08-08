# 生成 runtime/agent 的 Protocol buffers 协议文件


Runtime 和 agent 之间通过 Protocol buffers 编码的 ttrpc 协议通信， Protocol buffers 定义文件在 agent 代码下，位置在 `src/agent/protocols/protos/`。

这个文件夹下有几个文件，最主要也是最有可能更新的是 `agent.proto` 文件，这也是 runtime 和 agent 之间调用的接口定义文件。

## 安装环境

要编译 Protocol buffers 文件，需要安装 Protocol buffers 在各语言中所需的编译器。对 Golang 来说，需要安装 `protoc` 和 `protoc-gen-gogottrpc`。

### 安装 `protoc`

```
$ apt install -y protobuf-compiler
```

### 安装 `protoc-gen-gogottrpc`

```
$ go get github.com/containerd/ttrpc/cmd/protoc-gen-gogottrpc
```

## 编译 Protocol buffers 文件

Runtime 和 agent 都需要这份生成的 stub 文件，agent 采用 Rust 语言编写， Rust 提供了一个 [Build Script](https://doc.rust-lang.org/cargo/reference/build-scripts.html) 机制来在构建的时候自动生成 protocols 文件，因此在修改了上面的 `agent.proto` 文件的时候，agent 不需要再做额外的工作。

而 runtime 使用了 Golang，需要生成的 `*.pb.go` 文件。为了方便开发者，Kata Containers 提拱了一个脚本 `protocols/hack/update-generated-proto.sh` 来更新这个文件：

```
$ cd src/agent
$ protocols/hack/update-generated-proto.sh agent.proto
```

这就会生成 `agent.proto` 对应的 Golang 版本的 Protocol buffers 文件。

如果执行 `update-generated-proto.sh` 脚本而不指定命令行参数，则可以查看该脚本的使用方法。
