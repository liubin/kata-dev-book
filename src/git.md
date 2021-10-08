# 常用 git 命令

## 同步 upstream

确保 remote 中包括 upstream （kata-containers）和 origin （自己用户下）两个。

```bash
$ git fetch upstream
$ git co main
$ git merge upstream/main
$ git push
```

这样就可以将 upstream 的 main 分支合并到自己的 main 分支。

## 添加别人的分支

有时候可能需要验证别人的分支，这时候可以：

```bash
$ git remote add someone https://github.com/someone/kata-containers
$ git fetch someone
$ git checkout -b some-branch someone/some-branch
```

这样就可以将 `someone` 用户下的 `some-branch` checkout 出来。

## 修改 commit 顺序

假设当前 PR 分支有多个 commit ，如果想修改其中一个 commit 的内容，可以使用 rebase 功能。

```bash
$ git rebase -i HEAD~3
```

这里假设有 3 个 commit，想调整顺序或者修改其中的某些，或者删掉某些 commit，都可以用上面的 `git rebase` 命令。

执行上面命令会进入编辑界面，一般来说我们常用的就是：

- `pick`： 将这个 commit 原封不动的保留
- `reword`：编辑 commit message
- `edit`：修改这个 commit ，之后需要 `git commit --amend` 。
- `squash`：将这个 commit 合并到前面的 commit ，这可以减少 commit 数量。

另外，每一 commit 都占据一行，也可以调整行之间的顺序。

