# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::certificates::admin
class kube_hard_way::certificates::admin {
  include tlsinfo
  include kubeinstall::params
  include kube_hard_way::certificate_authority

  tlsinfo::cfssl::crt_req { 'admin-csr':
    path => $kubeinstall::params::cert_dir,
    common_name => 'admin',
    name_organisation => 'system:masters',
    name_organisation_unit => 'Kubernetes',
  }

  tlsinfo::cfssl::gencert { 'admin':
    config => 'ca-config.json',
    profile => 'kubernetes',
    require => [
      Tlsinfo::Cfssl::Crt_req['admin-csr'],
      Tlsinfo::Cfssl::Ca_config['ca-config'],
    ]
  }
}
