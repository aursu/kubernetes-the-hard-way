plan kubernetes::bootstrap::control_plain (
  TargetSpec $main_controller = 'controller-0',
  TargetSpec $targets = 'controllers',
  String $gce_public_address = 'kubernetes-the-hard-way',
) {
  run_plan(facts, $targets)

  # get IP address information based on its GCE name
  $addr_info = run_task('kube_hard_way::address', $main_controller, 'address' => $gce_public_address)
  # check if address has been got
  if $addr_info.ok {
    $server_name = $addr_info.first.value['address']
  }
  else {
    fail_plan('Unable ot retrieve Kubernetes cluster address')
  }

  apply($targets) {
    include kube_hard_way::bootstrap::health_checks
    class { 'kube_hard_way::bootstrap::controller': server_name => $server_name, }
  }

  apply($main_controller) {
    class { 'kube_hard_way::authz::kubelet': }
    class { 'kube_hard_way::authz::kube_apiserver_kubelet': }
  }
}
