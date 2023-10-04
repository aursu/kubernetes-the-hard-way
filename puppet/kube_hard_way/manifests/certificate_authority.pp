# @summary Setup certificate authority for Kubernetes
#
# A description of what this class does
#
# @example
#   include kube_hard_way::certificate_authority
class kube_hard_way::certificate_authority (
) {
  include kubeinstall::params

  tlsinfo::cfssl::ca_config { 'ca-config':
    path => $kubeinstall::params::cert_dir,
    signing_profiles => {
      'kubernetes' => {
        usages => ['signing', 'key encipherment', 'server auth', 'client auth'],
        expiry => '43824h',
      },
    }
  }

  tlsinfo::cfssl::crt_req { 'ca-csr':
    path => $kubeinstall::params::cert_dir,
    common_name => 'Kubernetes',
    name_organisation => 'Kubernetes',
    name_organisation_unit => 'CA',
  }

  tlsinfo::cfssl::gencert { 'ca':
    initca => true,
    require => [
      Tlsinfo::Cfssl::Crt_req['ca-csr'],
    ]
  }
}
