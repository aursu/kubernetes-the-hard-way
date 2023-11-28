# @summary Global paramters for module
#
# Global paramters for module Kube Hard Way
#
# @example
#   include kube_hard_way::global
class kube_hard_way::global (
  Kubeinstall::VersionPrefix $kubernetes_version = '1.28.4',
  String                     $containerd_version = '1.7.9',
  String                     $coredns_version    = '1.11.1',
  # default Pod CIDR
  Stdlib::IP::Address        $pod_subnet         = '10.85.0.0/16',
  # default cluster CIDR
  Stdlib::IP::Address        $cluster_cidr       = '10.200.0.0/16',
  Stdlib::IP::Address        $dns_addr           = '10.32.0.10',
) inherits kube_hard_way::params {}
