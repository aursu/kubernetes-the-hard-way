# @summary CoreDNS installation 
#
# Deploying the DNS Cluster Add-on
#
# @param kubeconfig
#   Kubernetes admin authorization configuration
#
# @example
#   include kube_hard_way::bootstrap::coredns
class kube_hard_way::bootstrap::coredns (
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
  Stdlib::IP::Address $dns_addr = $kube_hard_way::params::dns_addr,
) inherits kube_hard_way::params {
  include kubeinstall
  include kubeinstall::install::helm_binary

  kubeinstall::helm::repo { 'coredns':
    url => 'https://coredns.github.io/helm',
  }

  kubeinstall::helm::chart { 'coredns/coredns':
    release_name      => 'coredns',
    namespace         => 'kube-system',
    default_namespace => true,
    kubeconfig        => $kubeconfig,
    set_values        => {
      'service.clusterIP' => $dns_addr,
    },
  }
}
