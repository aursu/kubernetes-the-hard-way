# @summary kube-proxy configuration
#
# kube-proxy configuration
# https://kubernetes.io/docs/reference/config-api/kube-proxy-config.v1alpha1/
#
# @param kubeconfig
#   kubeconfig is the path to a KubeConfig file. clientConnection specifies the kubeconfig file and
#   client connection settings for the proxy server to use when communicating with the apiserver.
#
# @param proxy_mode
#   specifies which proxy mode to use. ProxyMode represents modes used by the Kubernetes proxy server.
#   Currently, two modes of proxy are available on Linux platforms: `iptables` and `ipvs`.
#   https://kubernetes.io/docs/reference/config-api/kube-proxy-config.v1alpha1/#kubeproxy-config-k8s-io-v1alpha1-ProxyMode
#
# @param cluster_cidr
#   clusterCIDR is the CIDR range of the pods in the cluster. It is used to bridge traffic coming
#   from outside of the cluster. If not provided, no off-cluster bridging will be performed.
#
# @example
#   include kube_hard_way::config::kube_proxy
class kube_hard_way::config::kube_proxy (
  Stdlib::Unixpath $cert_dir = $kube_hard_way::params::cert_dir,
  Enum['iptables', 'ipvs'] $proxy_mode = 'iptables',
  Stdlib::IP::Address $cluster_cidr = $kube_hard_way::params::cluster_cidr,
) inherits kube_hard_way::params {
  include kubeinstall
  include kubeinstall::directory_structure

  $object_header  = {
    'apiVersion' => 'kubeproxy.config.k8s.io/v1alpha1',
    'kind'       => 'KubeProxyConfiguration',
  }

  $object_content = {
    'clientConnection' => {
      'kubeconfig' => "${cert_dir}/kube-proxy.kubeconfig",
    },
    'mode' => $proxy_mode,
    'clusterCIDR' => $cluster_cidr,
  }

  $object = to_yaml($object_header + $object_content)

  file { '/var/lib/kube-proxy/kube-proxy-config.yaml':
    ensure  => file,
    content => $object,
    mode    => '0600',
  }
}
