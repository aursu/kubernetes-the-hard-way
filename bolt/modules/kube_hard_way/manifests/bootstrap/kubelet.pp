# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::bootstrap::kubelet
class kube_hard_way::bootstrap::kubelet (
  Kubeinstall::VersionPrefix $kubernetes_version,
  Stdlib::Unixpath $runtime_socket = '/var/run/containerd/containerd.sock',
  Stdlib::Unixpath $cert_dir = $kube_hard_way::params::cert_dir,
  Stdlib::Host $instance = $facts['networking']['hostname'],
  Stdlib::IP::Address $pod_subnet = $kube_hard_way::global::pod_subnet,
) inherits kube_hard_way::global {
  include bsys::systemctl::daemon_reload
  include kubeinstall

  $container_runtime_endpoint = "unix://${runtime_socket}"
  $kubeconfig = "${cert_dir}/${instance}.kubeconfig"

  class { 'kube_hard_way::config::kubelet':
    pod_subnet => $pod_subnet,
  }

  class { 'kubeinstall::component::kubelet':
    kubernetes_version => $kubernetes_version,
  }

  file { '/etc/systemd/system/kubelet.service':
    ensure  => file,
    content => template('kube_hard_way/kubelet.service.erb'),
    notify  => Class['bsys::systemctl::daemon_reload'],
  }

  service { 'kubelet':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/kubelet.service'],
  }

  Class['kubeinstall::component::kubelet'] -> Service['kubelet']
  Class['kube_hard_way::config::kubelet'] ~> Service['kubelet']
}
