# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   kube_hard_way::certificates::kubelet { 'namevar': }
define kube_hard_way::certificates::kubelet (
  Stdlib::Host $instance = $name,
) {
  $hostname     = $facts['networking']['hostname']
  $internal_ip  = $facts['networking']['ip']

  if $facts['gce'] {
    $gce_instance       = $facts['gce']['instance']
    # $hostname           = $gce_instance['name']
    $network_interfaces = $gce_instance['networkInterfaces']
    # $internal_ip        = $network_interfaces[0]['ip']
    $access_configs     = $network_interfaces[0]['accessConfigs']
    $extenal_ip         = $access_configs[0]['externalIp']
  }
  else {
    $extenal_ip   = undef
  }

  include tlsinfo
  include kubeinstall::params
  include kube_hard_way::certificate_authority

  $instance_option = $instance ? {
    $hostname => [],
    default => [$instance],
  }

  $extenal_ip_option = $extenal_ip ? {
    Stdlib::Host => [$extenal_ip],
    default => [],
  }

  tlsinfo::cfssl::crt_req { "${instance}-csr":
    path => $kubeinstall::params::cert_dir,
    common_name => "system:node:${hostname}",
    name_organisation => 'system:nodes',
    name_organisation_unit => 'Kubernetes',
  }

  tlsinfo::cfssl::gencert { $instance:
    config => 'ca-config.json',
    profile => 'kubernetes',
    hostname => $instance_option + [$hostname, $internal_ip] + $extenal_ip_option,
    require => [
      Tlsinfo::Cfssl::Crt_req["${instance}-csr"],
      Tlsinfo::Cfssl::Ca_config['ca-config'],
    ]
  }
}
