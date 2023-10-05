# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::certificates::kubernetes_api
class kube_hard_way::certificates::kubernetes_api (
  Stdlib::Host $internal_ip = '10.32.0.1',
  Array[Stdlib::Host] $controller_nodes = [
    '10.240.0.10',
    '10.240.0.11',
    '10.240.0.12',
  ],
  Optional[Stdlib::Host] $public_address = undef,
) {
  include tlsinfo
  include kubeinstall::params
  include kube_hard_way::certificate_authority

  $public_address_option = $public_address ? {
    Stdlib::Host => [$public_address],
    default => [],
  }

  $hostname_option = [$internal_ip] + $controller_nodes + $public_address_option + [
    '127.0.0.1',
    'kubernetes', 'kubernetes.default', 'kubernetes.default.svc',
    'kubernetes.default.svc.cluster', 'kubernetes.default.svc.cluster.local',
  ]

  tlsinfo::cfssl::crt_req { 'kubernetes-csr':
    path => $kubeinstall::params::cert_dir,
    common_name => 'kubernetes',
    name_organisation => 'Kubernetes',
    name_organisation_unit => 'Kubernetes',
  }

  tlsinfo::cfssl::gencert { 'kubernetes':
    path     => $kubeinstall::params::cert_dir,
    config   => 'ca-config.json',
    profile  => 'kubernetes',
    hostname => $hostname_option,
    require  => [
      Tlsinfo::Cfssl::Crt_req['kubernetes-csr'],
      Tlsinfo::Cfssl::Ca_config['ca-config'],
    ]
  }
}
