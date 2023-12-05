plan kube_hard_way::bootstrap::ingress_gce (
  TargetSpec $control_plain = 'controller-0',
  TargetSpec $targets = 'kubernetes',
  Boolean $exclude_from_external_load_balancers = false,
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  unless get_targets($control_plain).size == 1 {
    fail("Must specify a single control plane, not ${control_plain}")
  }

  $main_controller = get_targets($control_plain)[0]
  run_plan(facts, $main_controller)

  get_targets($targets).each |$target| {
    run_plan(facts, $target)

    $hostname_info = run_task('kube_hard_way::hostname', $target)
    if $hostname_info.ok {
      $gcp_region = $hostname_info.first.value['region']
      $gcp_zone   = $hostname_info.first.value['zone']
    }
    else {
      fail_plan("Unable to retrieve hostname information from the host's GCP metadata.")
    }

    apply($main_controller) {
      class { 'kube_hard_way::bootstrap::ingress_gce':
        gcp_region                           => $gcp_region,
        gcp_zone                             => $gcp_zone,
        instance                             => $target.name,
        exclude_from_external_load_balancers => $exclude_from_external_load_balancers,
        kubeconfig                           => $kubeconfig,
      }
    }
  }
}
