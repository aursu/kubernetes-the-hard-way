# @summary Generate certificate for Kubernetes API
#
# Generate certificate for Kubernetes API
#
# @param control_plain
#
# @param internal_ip
#
# @param controller_nodes
#
# @param gce_public_address
#
plan kube_hard_way::certificates::kubernetes_api (
  Stdlib::Host $control_plain = 'controller-0',
  Stdlib::Host $internal_ip = '10.32.0.1',
  Array[Stdlib::Host] $controller_nodes = [
    '10.240.0.10',
    '10.240.0.11',
    '10.240.0.12',
  ],
  String $gce_public_address = 'kubernetes-the-hard-way',
) {
  # convert host name into TargetSpec
  $targets = get_target($control_plain)
  run_plan(facts, $targets)

  # get IP address information based on its GCE name
  $addr_info = run_task('kube_hard_way::address', $targets, 'address' => $gce_public_address)

  # check if address has been got
  if $addr_info.ok {
    $public_address = $addr_info.first.value['address']
  }
  else {
    # we do  not fail plan if address is not here
    $public_address = undef
  }

  return apply($targets) {
    class { 'kube_hard_way::certificates::kubernetes_api':
      internal_ip      => $internal_ip,
      controller_nodes => $controller_nodes,
      public_address   => $public_address,
    }
  }
}
