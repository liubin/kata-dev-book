# 成为 Kata Containers 开发者

本文档在线阅读地址： http://liubin.org/kata-dev-book/

本文档原文件代码地址：https://github.com/liubin/kata-dev-book

**Version:** BUILD_VERSION

**Build At:** BUILD_DATE

如果发现文档中有错误，或者有不足，欢迎指出或者帮忙完善，可以直接在该电子书[项目主页](https://github.com/liubin/kata-dev-book)发送 PR 即可。

## 面向用户对象

本书主要针对 Kata Containers 使用者、容器技术相关的兴趣者，想从事安全容器开发的开发者。

如果只想阅读本文档，可以忽略该页面下面的内容，这部分内容主要是介绍如何在本地编译 gitbook 的说明。

## 分支说明

本 repo 有两个分支：

- main：源代码分支，所有 PR 都需要向这个分支合并
- website：gitbook 在线阅读分支，这个分支不能直接修改，必须通过 Makefile 来更新。

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

## 本地 preview

本地修改文档可以使用如下命令验证：

```bash
$ gitbook serve
```

默认监听 `4000` 端口，你可以在浏览器中访问 `http://localhost:4000/` 查看修改效果。

如果想修改监听端口，可以使用如下方式：

```bash
$ gitbook --port 8080 serve
```

## 如何修改本文档

直接修改 `src/` 下的内容，然后发送 PR 即可。

**不需要**修改 docs 下面的内容，这部分会统一发布。

## 更新在线阅读分支

执行 `make deploy` 即可。

**注意：** 需要确保当前分支（main）不能包含未提交内容。

## 生成 pdf 文件

生成 pdf 文件需要 [calibre](https://calibre-ebook.com) 的支持。

在 macOS 下，如果安装了 clibre ，可能还是会出错，类似这样。

```
InstallRequiredError: "ebook-convert" is not installed.
Install it from Calibre: https://calibre-ebook.com
```

如果确认已经安装了 calibre ，那么很可能是因为 `ebook-convert` 命令没有在 `$PATH` 环境变量中，执行下面的命令即可：


```
$ sudo ln -s /Applications/calibre.app/Contents/MacOS/ebook-convert /usr/local/bin
```

然后通过 `make` 命令即可生成 pdf 文件：

```
$ make pdf
```

成功的话，就会在当前文件夹下生成 `book.pdf`，这也就是电子书的 pdf 格式。
