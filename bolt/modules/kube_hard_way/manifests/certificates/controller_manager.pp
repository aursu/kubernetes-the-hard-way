# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::certificates::controller_manager
class kube_hard_way::certificates::controller_manager {
  include tlsinfo
  include kubeinstall::params
  include kube_hard_way::certificate_authority

  tlsinfo::cfssl::crt_req { 'kube-controller-manager-csr':
    path => $kubeinstall::params::cert_dir,
    common_name => 'system:kube-controller-manager',
    name_organisation => 'system:kube-controller-manager',
    name_organisation_unit => 'Kubernetes',
  }

  tlsinfo::cfssl::gencert { 'kube-controller-manager':
    path    => $kubeinstall::params::cert_dir,
    config  => 'ca-config.json',
    profile => 'kubernetes',
    require => [
      Tlsinfo::Cfssl::Crt_req['kube-controller-manager-csr'],
      Tlsinfo::Cfssl::Ca_config['ca-config'],
    ]
  }
}
