# @summary Global paramters for module
#
# Global paramters for module Kube Hard Way
#
# @param pod_subnet
#   podCIDR is the CIDR to use for pod IP addresses, only used in standalone mode. In cluster mode,
#   this is obtained from the control plane.
#
# @param cluster_ip_range
#   A CIDR notation IP range from which to assign service cluster IPs. This must not overlap with
#   any IP ranges assigned to nodes or pods. Max of two dual-stack CIDRs is allowed.
#   https://kubernetes.io/docs/concepts/services-networking/cluster-ip-allocation/
#
# @example
#   include kube_hard_way::global
class kube_hard_way::global (
  Kubeinstall::VersionPrefix $kubernetes_version = '1.28.4',
  String                     $containerd_version = '1.7.9',
  String                     $coredns_version    = '1.11.1',

  # default cluster CIDR
  Stdlib::IP::Address        $cluster_cidr       = '10.200.0.0/16',
  Stdlib::IP::Address        $cluster_ip_range   = '10.32.0.0/24',
  Stdlib::IP::Address        $dns_addr           = '10.32.0.10',

  # default Pod CIDR
  Stdlib::IP::Address        $pod_subnet         = $cluster_cidr,
) inherits kube_hard_way::params {}
