# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   kube_hard_way::certificates::kubelet { 'namevar': }
define kube_hard_way::certificates::kubelet (
  Stdlib::Host                  $instance    = $name,
  Optional[Stdlib::Unixpath]    $cert_dir    = undef,
  Stdlib::Host                  $hostname    = $facts['networking']['hostname'],
  Stdlib::IP::Address           $internal_ip = $facts['networking']['ip'],
  Optional[Stdlib::IP::Address] $external_ip = undef,
) {
  if $facts['gce'] {
    $gce_instance       = $facts['gce']['instance']
    $network_interfaces = $gce_instance['networkInterfaces']
    $access_configs     = $network_interfaces[0]['accessConfigs']
    $gce_external_ip    = $access_configs[0]['externalIp']
  }
  else {
    $gce_external_ip    = undef
  }

  include tlsinfo
  include kubeinstall::params
  include kube_hard_way::certificate_authority

  $cert_dir_defined = $cert_dir ? {
    Stdlib::Unixpath => $cert_dir,
    default          => $kubeinstall::params::cert_dir,
  }

  $instance_option = $instance ? {
    $hostname => [],
    default   => [$instance],
  }

  $external_ip_option = $external_ip ? {
    Stdlib::IP::Address => [$external_ip],
    default             => $gce_external_ip ? {
      Stdlib::IP::Address => [$gce_external_ip],
      default             => [],
    },
  }

  tlsinfo::cfssl::crt_req { "${instance}-csr":
    path                   => $cert_dir_defined,
    common_name            => "system:node:${hostname}",
    name_organisation      => 'system:nodes',
    name_organisation_unit => 'Kubernetes',
  }

  tlsinfo::cfssl::gencert { $instance:
    path     => $cert_dir_defined,
    config   => 'ca-config.json',
    profile  => 'kubernetes',
    hostname => $instance_option + [$hostname, $internal_ip] + $external_ip_option,
    require  => [
      Tlsinfo::Cfssl::Crt_req["${instance}-csr"],
      Tlsinfo::Cfssl::Ca_config['ca-config'],
    ],
  }

  Class['kube_hard_way::certificate_authority'] -> Tlsinfo::Cfssl::Crt_req["${instance}-csr"]
}
