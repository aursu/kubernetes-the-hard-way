# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::params
class kube_hard_way::params {
  include kubeinstall::params

  $cert_dir = $kubeinstall::params::cert_dir
  $lib_dir = '/var/lib/kubernetes'
  $config_dir = '/etc/kubernetes/config'
  $encription_key = "${lib_dir}/enc.key"
  $encryption_provider_config = '/var/lib/kubernetes/encryption-config.yaml'

  # default Pod CIDR
  $pod_subnet = '10.85.0.0/16'

  # default cluster CIDR
  $cluster_cidr = '10.200.0.0/16'
}
