# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::bootstrap::kube_proxy
class kube_hard_way::bootstrap::kube_proxy {
  include bsys::systemctl::daemon_reload

  include kubeinstall
  include kubeinstall::component::kube_proxy
  include kube_hard_way::config::kube_proxy

  file { '/etc/systemd/system/kube-proxy.service':
    ensure  => file,
    content => file('kube_hard_way/kube-proxy.service'),
    notify  => Class['bsys::systemctl::daemon_reload'],
  }

  service { 'kube-proxy':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/kube-proxy.service'],
  }

  Class['kubeinstall::component::kube_proxy'] -> Service['kube-proxy']
  Class['kube_hard_way::config::kube_proxy'] ~> Service['kube-proxy']
}
