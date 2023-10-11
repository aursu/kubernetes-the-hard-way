plan kubernetes::bootstrap::etcd (
  String $version = '3.5.9',
  TargetSpec $targets = 'controllers',
) {
  run_plan(etcd::install, $targets, version => $version)
  return run_plan(kube_hard_way::etcd::service, $targets)
}
