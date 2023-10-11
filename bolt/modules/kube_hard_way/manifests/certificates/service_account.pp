# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::certificates::service_account
class kube_hard_way::certificates::service_account (
  Optional[Stdlib::Unixpath] $path = undef,
) {
  include tlsinfo
  include kubeinstall::params
  include kube_hard_way::certificate_authority

  $cert_dir = $path ? {
    Stdlib::Unixpath => $path,
    default          => $kubeinstall::params::cert_dir,
  }

  tlsinfo::cfssl::crt_req { 'service-account-csr':
    path                   => $cert_dir,
    common_name            => 'service-accounts',
    name_organisation      => 'Kubernetes',
    name_organisation_unit => 'Kubernetes',
  }

  tlsinfo::cfssl::gencert { 'service-account':
    path    => $cert_dir,
    config  => 'ca-config.json',
    profile => 'kubernetes',
    require => [
      Tlsinfo::Cfssl::Crt_req['service-account-csr'],
      Tlsinfo::Cfssl::Ca_config['ca-config'],
    ],
  }

  Class['kube_hard_way::certificate_authority'] -> Tlsinfo::Cfssl::Crt_req['service-account-csr']
}
