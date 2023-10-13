# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @param path
#   Path to directory with certificates for Kubernetes
#
# @example
#   include kube_hard_way::bootstrap::health_checks
class kube_hard_way::bootstrap::health_checks (
  Optional[Stdlib::Unixpath] $path = undef,
) {
  include lsys_nginx
  include kubeinstall::params

  $cert_dir = $path ? {
    Stdlib::Unixpath => $path,
    default          => $kubeinstall::params::cert_dir,
  }

  nginx::resource::server { 'kubernetes.default.svc.cluster.local':
    listen_port => 80,
    server_name => ['kubernetes.default.svc.cluster.local'],

    locations   => {
      '/healthz' => {
        location                      => '/healthz',
        proxy                         => 'https://127.0.0.1:6443/healthz',
        proxy_ssl_trusted_certificate => "${cert_dir}/ca.pem",
      },
    },
  }
}
