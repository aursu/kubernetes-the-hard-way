plan kubernetes::bootstrap::components (
  TargetSpec $main_controller = 'controller-0',
) {
  run_plan(facts, $main_controller)
  $cert_dir = '/etc/kubernetes/pki'
  $admin_config = "${cert_dir}/admin.kubeconfig"

  apply($main_controller) {
    class { 'kube_hard_way::bootstrap::coredns':
      kubeconfig => $admin_config,
    }

    class { 'kubeinstall::kubectl::config':
      kubeconfig => $admin_config,
    }
  }
}
