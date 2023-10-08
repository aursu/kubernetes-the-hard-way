# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::setup
class kube_hard_way::setup {
  include kube_hard_way::params

  file { $kube_hard_way::params::lib_dir:
    ensure => directory,
  }
}
