# @summary Setup certificate authority for Kubernetes
#
# A description of what this class does
#
# @example
#   include kube_hard_way::certificate_authority
class kube_hard_way::certificate_authority (
  Optional[Stdlib::Unixpath] $path = undef,
) {
  include tlsinfo
  include kubeinstall::params

  $cert_dir = $path ? {
    Stdlib::Unixpath => $path,
    default          => $kubeinstall::params::cert_dir,
  }

  tlsinfo::cfssl::ca_config { 'ca-config':
    path             => $cert_dir,
    signing_profiles => {
      'kubernetes' => {
        usages => ['signing', 'key encipherment', 'server auth', 'client auth'],
        expiry => '43824h',
      },
    }
  }

  tlsinfo::cfssl::crt_req { 'ca-csr':
    path                   => $cert_dir,
    common_name            => 'Kubernetes',
    name_organisation      => 'Kubernetes',
    name_organisation_unit => 'CA',
  }

  tlsinfo::cfssl::gencert { 'ca':
    path    => $cert_dir,
    initca  => true,
    require => [
      Tlsinfo::Cfssl::Crt_req['ca-csr'],
    ]
  }
}
