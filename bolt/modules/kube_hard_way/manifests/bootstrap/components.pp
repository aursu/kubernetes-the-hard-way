# @summary Control Plain components
#
# DNS and CNI installation on control plain
#
# @example
#   include kube_hard_way::bootstrap::components
class kube_hard_way::bootstrap::components (
  Stdlib::Unixpath           $cert_dir   = $kube_hard_way::params::cert_dir,
  Optional[Stdlib::Unixpath] $kubeconfig = "${cert_dir}/admin.kubeconfig",
) inherits kube_hard_way::global {
  class { 'kube_hard_way::bootstrap::coredns':
    kubeconfig => $kubeconfig,
  }

  class { 'kubeinstall::kubectl::config':
    kubeconfig => $kubeconfig,
  }

  class { 'kubeinstall::install::calico':
    cidr       => $kube_hard_way::global::pod_subnet,
    operator   => true,
    calicoctl  => true,
    kubeconfig => $kubeconfig,
  }

  Class['kubeinstall::install::calico'] -> Class['kube_hard_way::bootstrap::coredns']
}
