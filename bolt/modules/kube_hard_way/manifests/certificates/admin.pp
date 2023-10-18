# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::certificates::admin
class kube_hard_way::certificates::admin (
  Stdlib::Unixpath $cert_dir = $kube_hard_way::params::cert_dir,
) inherits kube_hard_way::params {
  include tlsinfo
  include kubeinstall::params
  include kube_hard_way::certificate_authority

  tlsinfo::cfssl::crt_req { 'admin-csr':
    path                   => $cert_dir,
    common_name            => 'admin',
    name_organisation      => 'system:masters',
    name_organisation_unit => 'Kubernetes',
  }

  tlsinfo::cfssl::gencert { 'admin':
    path    => $cert_dir,
    config  => 'ca-config.json',
    profile => 'kubernetes',
    require => [
      Tlsinfo::Cfssl::Crt_req['admin-csr'],
      Tlsinfo::Cfssl::Ca_config['ca-config'],
    ],
  }

  Class['kube_hard_way::certificate_authority'] -> Tlsinfo::Cfssl::Crt_req['admin-csr']
}
