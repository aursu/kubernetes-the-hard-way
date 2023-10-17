# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::bootstrap::worker
class kube_hard_way::bootstrap::worker (
  String $containerd_version = '1.7.7',
  Stdlib::IP::Address $pod_subnet = $kube_hard_way::params::pod_subnet,
) inherits kube_hard_way::params {
  # https://github.com/containerd/containerd/blob/main/docs/getting-started.md
  # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
  # https://github.com/aursu/kubernetes-the-hard-way/blob/master/docs/09-bootstrapping-kubernetes-workers.md#provisioning-a-kubernetes-worker-node

  # dependencies
  package { ['socat', 'conntrack', 'ipset']:
    ensure => 'present',
  }

  # disable swap
  include kubeinstall::system::swap

  include kube_hard_way::bootstrap::kubelet
  include kube_hard_way::bootstrap::kube_proxy

  # containerd CRI
  class { 'kubeinstall::runtime::containerd':
    version    => $containerd_version,
    pod_subnet => $pod_subnet,
    set_config => true,
  }

  Class['kubeinstall::runtime::containerd'] -> Class['kube_hard_way::bootstrap::kubelet']
  Class['kubeinstall::runtime::containerd'] -> Class['kube_hard_way::bootstrap::kube_proxy']
}
