# 成为 Kata Containers 开发者

本文档在线阅读地址： http://liubin.org/kata-dev-book/

本文档原文件代码地址：https://github.com/liubin/kata-dev-book

## 分支说明

本 repo 有两个分支：

- main：源代码分支，所有 PR 都需要向这个分支合并
- website：gitbook在线阅读分支，这个分支不能直接修改，必须通过 Makefile 来更新。

## 环境设置

可参看网上的关于 gitbook 的教程，但是如果是在 macOS 上，最新的 npm 可能不兼容 gitbook ，只能使用 nvm 等软件安装老版本的 npm。

如果你看到如下错误，大概率是这个原因。

```
TypeError [ERR_INVALID_ARG_TYPE]: The "data" argument must be of type string or an instance of Buffer, TypedArray, or DataView. Received an instance of Promise
```

使用 nvm 可以切换 npm 版本。

```
$ nvm use v10.24.0
```

本文档开发所用 gitbook 版本：

```
$ gitbook -V
CLI version: 2.3.2
GitBook version: 3.2.3
```

## 如何修改本文档

直接修改 `src/` 下的内容，然后发送 PR 即可。

**不需要**修改 docs 下面的内容，这部分会统一发布。

## 更新在线阅读分支

执行 `make deploy` 即可。

