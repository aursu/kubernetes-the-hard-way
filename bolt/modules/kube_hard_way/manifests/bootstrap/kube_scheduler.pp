# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::bootstrap::kube_scheduler
class kube_hard_way::bootstrap::kube_scheduler (
  Stdlib::Unixpath $config = "${kube_hard_way::params::config_dir}/kube-scheduler.yaml",
) inherits kube_hard_way::params {
  include bsys::systemctl::daemon_reload

  include kube_hard_way::setup
  include kubeinstall
  include kubeinstall::component::kube_scheduler
  include kube_hard_way::config::kube_scheduler

  file { '/etc/systemd/system/kube-scheduler.service':
    ensure  => file,
    content => template('kube_hard_way/kube-scheduler.service.erb'),
    notify  => Class['bsys::systemctl::daemon_reload'],
  }

  service { 'kube-scheduler':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/kube-scheduler.service'],
  }

  Class['kubeinstall::component::kube_scheduler'] -> Service['kube-scheduler']
  Class['kube_hard_way::config::kube_scheduler'] -> Service['kube-scheduler']
}
