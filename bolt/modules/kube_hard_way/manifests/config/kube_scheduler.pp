# @summary A short summary of the purpose of this class
#
# Kubernetes scheduler setup
#
# @example
#   include kube_hard_way::config::kube_scheduler
class kube_hard_way::config::kube_scheduler (
  Optional[Stdlib::Unixpath] $path = undef,
) {
  include kube_hard_way::params
  include kube_hard_way::setup
  include kubeinstall::params

  $cert_dir = $path ? {
    Stdlib::Unixpath => $path,
    default => $kubeinstall::params::cert_dir,
  }

  $object_header  = {
    'apiVersion' => 'kubescheduler.config.k8s.io/v1',
    'kind'       => 'KubeSchedulerConfiguration',
  }

  $object_content = {
    'clientConnection' => {
      'kubeconfig' => "${cert_dir}/kube-scheduler.kubeconfig",
    },
    'leaderElection' => {
      'leaderElect' => true,
    },
  }

  $object = to_yaml($object_header + $object_content)

  file { "${kube_hard_way::params::config_dir}/kube-scheduler.yaml":
    ensure  => file,
    content => $object,
    mode    => '0600',
  }
}
