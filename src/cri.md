# Container Runtime Interface (CRI)

CRI 是目前 K8s 和容器运行时之间的通信接口。该接口从 [K8s 1.5](https://kubernetes.io/blog/2016/12/container-runtime-interface-cri-in-kubernetes/) 开始引入，目前是 K8s 唯一支持的容器运行时相关接口，当前版本为 v1alpha1。

具体来说 containerd 、 CRI-O 是最流行的两种实现。一般我们将运行时分为高级运行时和低级运行时，前者直接和 kubelet 交互，containerd 即属于此类；低级运行时才真正的管理容器，比如 runc 或 Kata Containers 都属于这一类。

## CRI 概述

Kubelet 通过 Unix socket 和 CRI 通信，通信使用 gRPC 协议。

![](images/cri.png)

CRI API 定义了两类服务： ImageService 和 RuntimeService。

从名字也可以看出，这两个服务分别负责镜像和容器。ImageService 用于拉取镜像，获取镜像信息，RuntimeService 负责管理 pod 和容器的生命周期，也包括容器的exec/attach和端口转发等。

通常来说一个运行时可以同时提供这两种类型的接口，这样只需要设置一个运行时地址，如果两种接口分别由不同的服务实现，Kubelet 也提供了 `--container-runtime-endpoint` 和 `--image-service-endpoint` 两个参数类设置不同的运行时服务。

CRI 接口的完整定义在 [https://github.com/kubernetes/kubernetes/blob/release-1.5/pkg/kubelet/api/v1alpha1/runtime/api.proto](https://github.com/kubernetes/kubernetes/blob/release-1.5/pkg/kubelet/api/v1alpha1/runtime/api.proto) 。

### ImageService

镜像接口不多，主要包括镜像的下载、删除、查看。

```
// ImageService defines the public APIs for managing images.
service ImageService {
    // ListImages lists existing images.
    rpc ListImages(ListImagesRequest) returns (ListImagesResponse) {}
    // ImageStatus returns the status of the image. If the image is not
    // present, returns nil.
    rpc ImageStatus(ImageStatusRequest) returns (ImageStatusResponse) {}
    // PullImage pulls an image with authentication config.
    rpc PullImage(PullImageRequest) returns (PullImageResponse) {}
    // RemoveImage removes the image.
    // This call is idempotent, and must not return an error if the image has
    // already been removed.
    rpc RemoveImage(RemoveImageRequest) returns (RemoveImageResponse) {}
}
```

### RuntimeService

在 CRI/K8s 中， PodSandbox 是一个不同于容器的概念，主要用于表示一个隔离的、带有资源限制的运行环境，所有的容器都会在 Pod 的 cgroup 中创建。

在创建容器之前，必须先通过 `RunPodSandbox` API 创建运行环境（对 Kata Containers 来说是一个虚拟机，对 runc 来说是一系列namespace）。

PodSandbox 创建好之后，才可以进行容器相关的操作（创建、启动、停止和删除等）。

运行时相关接口很多，主要是围绕容器的操作。

```
// Runtime service defines the public APIs for remote container runtimes
service RuntimeService {
    // Version returns the runtime name, runtime version, and runtime API version.
    rpc Version(VersionRequest) returns (VersionResponse) {}

    // RunPodSandbox creates and starts a pod-level sandbox. Runtimes must ensure
    // the sandbox is in the ready state on success.
    rpc RunPodSandbox(RunPodSandboxRequest) returns (RunPodSandboxResponse) {}
    // StopPodSandbox stops any running process that is part of the sandbox and
    // reclaims network resources (e.g., IP addresses) allocated to the sandbox.
    // If there are any running containers in the sandbox, they must be forcibly
    // terminated.
    // This call is idempotent, and must not return an error if all relevant
    // resources have already been reclaimed. kubelet will call StopPodSandbox
    // at least once before calling RemovePodSandbox. It will also attempt to
    // reclaim resources eagerly, as soon as a sandbox is not needed. Hence,
    // multiple StopPodSandbox calls are expected.
    rpc StopPodSandbox(StopPodSandboxRequest) returns (StopPodSandboxResponse) {}
    // RemovePodSandbox removes the sandbox. If there are any running containers
    // in the sandbox, they must be forcibly terminated and removed.
    // This call is idempotent, and must not return an error if the sandbox has
    // already been removed.
    rpc RemovePodSandbox(RemovePodSandboxRequest) returns (RemovePodSandboxResponse) {}
    // PodSandboxStatus returns the status of the PodSandbox.
    rpc PodSandboxStatus(PodSandboxStatusRequest) returns (PodSandboxStatusResponse) {}
    // ListPodSandbox returns a list of PodSandboxes.
    rpc ListPodSandbox(ListPodSandboxRequest) returns (ListPodSandboxResponse) {}

    // CreateContainer creates a new container in specified PodSandbox
    rpc CreateContainer(CreateContainerRequest) returns (CreateContainerResponse) {}
    // StartContainer starts the container.
    rpc StartContainer(StartContainerRequest) returns (StartContainerResponse) {}
    // StopContainer stops a running container with a grace period (i.e., timeout).
    // This call is idempotent, and must not return an error if the container has
    // already been stopped.
    // TODO: what must the runtime do after the grace period is reached?
    rpc StopContainer(StopContainerRequest) returns (StopContainerResponse) {}
    // RemoveContainer removes the container. If the container is running, the
    // container must be forcibly removed.
    // This call is idempotent, and must not return an error if the container has
    // already been removed.
    rpc RemoveContainer(RemoveContainerRequest) returns (RemoveContainerResponse) {}
    // ListContainers lists all containers by filters.
    rpc ListContainers(ListContainersRequest) returns (ListContainersResponse) {}
    // ContainerStatus returns status of the container.
    rpc ContainerStatus(ContainerStatusRequest) returns (ContainerStatusResponse) {}

    // ExecSync runs a command in a container synchronously.
    rpc ExecSync(ExecSyncRequest) returns (ExecSyncResponse) {}
    // Exec prepares a streaming endpoint to execute a command in the container.
    rpc Exec(ExecRequest) returns (ExecResponse) {}
    // Attach prepares a streaming endpoint to attach to a running container.
    rpc Attach(AttachRequest) returns (AttachResponse) {}
    // PortForward prepares a streaming endpoint to forward ports from a PodSandbox.
    rpc PortForward(PortForwardRequest) returns (PortForwardResponse) {}

    // UpdateRuntimeConfig updates the runtime configuration based on the given request.
    rpc UpdateRuntimeConfig(UpdateRuntimeConfigRequest) returns (UpdateRuntimeConfigResponse) {}

    // Status returns the status of the runtime.
    rpc Status(StatusRequest) returns (StatusResponse) {}
}
```

## cri-api

[cri-api](https://github.com/kubernetes/cri-api) 是一套 golang 的库，包括 CRI API 定义，我们可以使用这个库手动编码使用 CRI 接口。


