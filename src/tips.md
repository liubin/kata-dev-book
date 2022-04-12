# 常用操作


## 查找 pod 对应的 sandbox ID

这里以 `kata-1` 为 pod 名，来展示如何找到该 pod 对应的 sandbox ID。因为在 CRI 下面的 runtime 中，使用的是这个 sandbox ID，这个并不是 pod UUID。


### 使用 ctr

```bash
$ kubectl get pod kata-1 -o jsonpath='{$.status.containerStatuses[0].containerID}' | tr -d '"' | sed -e 's#containerd://##' | xargs ctr -n k8s.io c info | jq '.Spec.annotations."io.kubernetes.cri.sandbox-id"' | tr -d '"'
```

### 使用 crictl

```bash
$ kubectl get pod kata-1 -o jsonpath='{$.status.containerStatuses[0].containerID}' | tr -d '"' | sed -e 's#containerd://##'  | xargs crictl inspect | jq '.info.runtimeSpec.annotations."io.kubernetes.cri.sandbox-id"' | tr -d '"'
```

或

```bash
$ kubectl get pod kata-1 -o jsonpath='{$.status.containerStatuses[0].containerID}' | tr -d '"' | sed -e 's#containerd://##'  | xargs crictl inspect | jq .info.sandboxID | tr -d '"'
```
