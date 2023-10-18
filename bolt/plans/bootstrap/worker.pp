plan kubernetes::bootstrap::worker (
  TargetSpec $targets = 'workers',
) {
  get_targets($targets).each |$target| {
    run_plan(facts, $target)

    $pod_cidr_result = run_task('kube_hard_way::pod_cidr', $target)

    # check if pod_cidr has been got
    if $pod_cidr_result.ok {
      $pod_cidr = $pod_cidr_result.first.value['pod_cidr']
    }
    else {
      fail_plan('Unable ot retrieve Pod CIDR from instance metadata')
    }

    apply($target) {
      class { 'kube_hard_way::bootstrap::worker':
        pod_subnet => $pod_cidr,
      }
    }
  }
}
