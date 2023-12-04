# @summary Package dependencies
#
# Package dependencies socat, conntrack, ipset and ipvsadm
#
# @param install_ipvsadm
#   Where to install ipvsadm tool or not
#
# @example
#   include kube_hard_way::bootstrap::dependencies
class kube_hard_way::bootstrap::dependencies (
  Boolean $install_ipvsadm = false,
) {
  # dependencies
  package { ['socat', 'conntrack', 'ipset']:
    ensure => 'present',
  }

  if $install_ipvsadm {
    package { 'ipvsadm':
      ensure => 'present',
    }
  }
}
