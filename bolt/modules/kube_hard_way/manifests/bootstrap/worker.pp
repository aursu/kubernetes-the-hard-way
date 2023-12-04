# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::bootstrap::worker
class kube_hard_way::bootstrap::worker (
  Stdlib::IP::Address $pod_subnet = $kube_hard_way::global::pod_subnet,
) inherits kube_hard_way::global {
  # https://github.com/containerd/containerd/blob/main/docs/getting-started.md
  # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
  # https://github.com/aursu/kubernetes-the-hard-way/blob/master/docs/09-bootstrapping-kubernetes-workers.md#provisioning-a-kubernetes-worker-node

  $kubernetes_version = $kube_hard_way::global::kubernetes_version
  $containerd_version = $kube_hard_way::global::containerd_version

  # dependencies
  include kube_hard_way::bootstrap::dependencies

  # disable swap
  include kubeinstall::system::swap

  class { 'kube_hard_way::bootstrap::kubelet':
    kubernetes_version => $kubernetes_version,
  }

  class { 'kube_hard_way::bootstrap::kube_proxy':
    kubernetes_version => $kubernetes_version,
  }

  # containerd CRI
  class { 'kubeinstall::runtime::containerd':
    version    => $containerd_version,
    pod_subnet => $pod_subnet,
    set_config => true,
  }

  Class['kubeinstall::runtime::containerd'] -> Class['kube_hard_way::bootstrap::kubelet']
  Class['kubeinstall::runtime::containerd'] -> Class['kube_hard_way::bootstrap::kube_proxy']
}
