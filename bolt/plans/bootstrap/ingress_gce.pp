plan kubernetes::bootstrap::ingress_gce (
  TargetSpec $main_controller = 'controller-0',
  TargetSpec $targets = 'kubernetes',
  Boolean $exclude_from_external_load_balancers = false,
) {
  $cert_dir = '/etc/kubernetes/pki'
  $admin_config = "${cert_dir}/admin.kubeconfig"

  run_plan( 'kube_hard_way::bootstrap::ingress_gce',
    control_plain => $main_controller,
    targets       => $targets,
    kubeconfig    => $admin_config,
    exclude_from_external_load_balancers => $exclude_from_external_load_balancers,
  )
}
