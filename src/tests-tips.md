# tests 仓库

这里介绍一下 [tests](https://github.com/kata-containers/tests) 仓库相关的用法。

## 跨仓库修改

如果因为 kata-containers 仓库某一比较大的变动，导致现有 tests 仓库的测试直接执行会失败，这时就需要同时修改两个仓库，在 GitHub 的 CI 中，也需要使用这两个仓库的不同分支来进行测试。

而默认的情况下，两个仓库都默认使用 main 分支，即在 tests 仓库中新建一个 pr ，会使用 kata-containers 仓库的 main 来进行测试。

tests 仓库中的 CI 代码提供了一个功能，就是通过在 commit message 中使用 `Depends-on:` 语法，来指定依赖仓库的非默认分支。

我们可以看一个[实际的例子](https://github.com/kata-containers/tests/pull/3173/commits/20d7ca3cb5a00d78f11df6b2f75f89d64be1c022)。

```
ci: Create stable VIRTIOFS job

Create a job definition to run stable virtiofs.

The new job explicitly define what kernel, qemu
and test will be run for virtiofs.

Depends-on: github.com/kata-containers/runtime#3122
Depends-on: github.com/kata-containers/packaging#1190

... ... ... ... ... ...
... ... ... ... ... ...
```

这个 tests 仓库的 pr 依赖了两个其他仓库的 pr ，因此在执行该 pr 时，不会去使用 kata-containers/runtime 和 kata-containers/packaging 两个仓库的默认分支（master），而是使用这两个仓库中的两个 pr 。

这种方式在同时修改几个关联的仓库的时候非常有用。
