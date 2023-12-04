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

  $cert_dir = '/etc/kubernetes/pki'
  $admin_config = "${cert_dir}/admin.kubeconfig"

  get_targets($targets).each |$target| {
    apply($target) {
      include kube_hard_way::bootstrap::health_checks
      class { 'kube_hard_way::bootstrap::controller':
        server_name    => $server_name,
        instance       => $target.name,
        enable_kubelet => true,
        kubeconfig     => $admin_config,
      }
    }
  }

  apply($main_controller) {
    class { 'kube_hard_way::authz::kubelet': }
    class { 'kube_hard_way::authz::kube_apiserver_kubelet': }
  }
}
