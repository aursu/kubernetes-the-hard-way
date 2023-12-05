plan kubernetes::bootstrap::argocd (
  TargetSpec $main_controller = 'controller-0',
) {
  run_plan(facts, $main_controller)

  $cert_dir = '/etc/kubernetes/pki'
  $admin_config = "${cert_dir}/admin.kubeconfig"

  apply($main_controller) {
    include kubeinstall
    class { 'kubeinstall::install::argocd':
      kubeconfig => $admin_config,
    }
  }
}
