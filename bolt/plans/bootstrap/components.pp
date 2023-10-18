plan kubernetes::bootstrap::components (
  TargetSpec $main_controller = 'controller-0',
) {
  run_plan(facts, $main_controller)
  apply($main_controller) {
    class { 'kube_hard_way::bootstrap::coredns':
      kubeconfig => '/etc/kubernetes/pki/admin.kubeconfig',
    }
  }
}
