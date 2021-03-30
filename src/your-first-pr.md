# 第一个 Kata Containers 的 PR

终于到了该介绍如何在 Kata Containers 社区提交自己的 PR 了，可能有些人已经等不及了。读完这一章，你也可以尝试着提交个 PR 试试。

## 如何找到 issue

要想提交 PR，首先得确定要修改什么。

在 Kata Containers 社区通过 GitHub 的 issue 和 PR 来管理 bug 和合并请求。首先要有一个 issue，然后以此创建自己的开发分支，在本地开发、测试通过后，就可以提交 PR 到社区并获得项目维护者的 review，如果没有问题，就可以合并代码了。


大概有如下几种情况：

- 有人提了 issue，可以去 Kata Containers 的 issue 页面查找自己刚兴趣的去 fix
- 自己使用中发现的 bug
- 自己需要的功能
- 学习、阅读源代码时候发现的问题

对于上面在阅读源代码时候发现的问题，也不完全都是 bug，也可以是简单的 typo，不合适的变量名，各种类似 golint 等对代码质量和阅读性上有影响的代码等，都可以作为修正对象。

## 准备工作

### 配置 git

首先，需要对 git 进行简单的配置。

如果你的开源项目和工作项目需要分开，或者有多个账号要分开使用，那么推荐为不同的项目仓库配置不同的 git 用户信息（即标志一个代码贡献者）。

```
$ git config --local user.name liubin
$ git config --local user.email liubin0329@gmail.com
```

如果你已经设置了全集的用户信息（通过 `--global` 选项），并且不想单独设置不同的账号，则这一步可以省略。

## 创建 PR

要想让你的代码获得合并，必须满足如下两个条件：

- 所有必须的 CI 测试通过
- 有2个或2个以上的项目维护者的 approve 。

### CI 检查

CI 分两大类

- 使用 GitHub Action 的各种构建、静态检查和 UT 等验证
- 基于 Jenkins 的集成测试，包括基于最新代码和PR修改内容的所有组件的构建、各种环境（K8s、contaienrd、CRI-O、VFIO、QEMU、CLH、Firecracker等）的真实负载测试


