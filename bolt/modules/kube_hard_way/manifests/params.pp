# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::params
class kube_hard_way::params {
  $lib_dir = '/var/lib/kubernetes'
  $encription_key = "${lib_dir}/enc.key"
}
