# @summary Kubernetes controller bootstrap
#
# Kubernetes controller bootstrap
#
# @example
#   include kube_hard_way::bootstrap::controller
class kube_hard_way::bootstrap::controller (
  Stdlib::Host $server_name,
  Stdlib::Host $instance = $facts['networking']['hostname'],
  Array[Stdlib::IP::Address] $etcd_servers = [
    '10.240.0.10',
    '10.240.0.11',
    '10.240.0.12',
  ],
  Boolean $enable_kubelet = false,
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) inherits kube_hard_way::global {
  include kubeinstall
  include kubeinstall::component::kubectl

  # dependencies
  class { 'kube_hard_way::bootstrap::dependencies': install_ipvsadm => true }

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

  # ability to run static pods on control plain
  if $enable_kubelet {
    include kube_hard_way::bootstrap::worker
    kubeinstall::node::label { 'node-role.kubernetes.io/control-plane':
      value      => '',
      node_name  => $instance,
      kubeconfig => $kubeconfig,
    }
  }
}
