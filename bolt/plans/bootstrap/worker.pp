plan kubernetes::bootstrap::worker (
  TargetSpec $targets = 'workers',
) {
  run_plan(facts, $targets)
}
