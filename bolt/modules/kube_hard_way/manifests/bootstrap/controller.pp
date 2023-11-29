# @summary Kubernetes controller bootstrap
#
# Kubernetes controller bootstrap
#
# @example
#   include kube_hard_way::bootstrap::controller
class kube_hard_way::bootstrap::controller (
  Stdlib::Host $server_name,
  Array[Stdlib::IP::Address] $etcd_servers = [
    '10.240.0.10',
    '10.240.0.11',
    '10.240.0.12',
  ],
) inherits kube_hard_way::global {
  include kubeinstall
  include kubeinstall::component::kubectl

  # dependencies
  package { ['socat', 'conntrack', 'ipset', 'ipvsadm']:
    ensure => 'present',
  }

  $kubernetes_version = $kube_hard_way::global::kubernetes_version

  class { 'kube_hard_way::bootstrap::kube_apiserver':
    kubernetes_version => $kubernetes_version,
    server_name        => $server_name,
    etcd_servers       => $etcd_servers,
  }

  class { 'kube_hard_way::bootstrap::controller_manager':
    kubernetes_version => $kubernetes_version,
  }

  class { 'kube_hard_way::bootstrap::kube_scheduler':
    kubernetes_version => $kubernetes_version,
  }
}
