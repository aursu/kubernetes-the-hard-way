plan kubernetes::bootstrap::components (
  TargetSpec $main_controller = 'controller-0',
) {
  run_plan(facts, $main_controller)

  $cert_dir = '/etc/kubernetes/pki'
  $admin_config = "${cert_dir}/admin.kubeconfig"

  apply($main_controller) {
    include kube_hard_way::global

    class { 'kube_hard_way::bootstrap::components':
      kubeconfig => $admin_config,
    }
  }
}
