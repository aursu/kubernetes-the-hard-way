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
) {
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
  }
}
