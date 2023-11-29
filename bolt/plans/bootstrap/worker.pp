plan kubernetes::bootstrap::worker (
  TargetSpec $targets = 'workers',
) {
  get_targets($targets).each |$target| {
    run_plan(facts, $target)

    apply($target) {
      class { 'kube_hard_way::bootstrap::worker': }
    }
  }
}
