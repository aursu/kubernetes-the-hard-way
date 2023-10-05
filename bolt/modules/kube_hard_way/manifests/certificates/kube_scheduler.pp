# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::certificates::kube_scheduler
class kube_hard_way::certificates::kube_scheduler {
  include tlsinfo
  include kubeinstall::params
  include kube_hard_way::certificate_authority

  tlsinfo::cfssl::crt_req { 'kube-scheduler-csr':
    path => $kubeinstall::params::cert_dir,
    common_name => 'system:kube-scheduler',
    name_organisation => 'system:kube-scheduler',
    name_organisation_unit => 'Kubernetes',
  }

  tlsinfo::cfssl::gencert { 'kube-scheduler':
    config => 'ca-config.json',
    profile => 'kubernetes',
    require => [
      Tlsinfo::Cfssl::Crt_req['kube-scheduler-csr'],
      Tlsinfo::Cfssl::Ca_config['ca-config'],
    ]
  }
}
