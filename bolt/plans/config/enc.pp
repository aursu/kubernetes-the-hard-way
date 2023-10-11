plan kubernetes::config::enc (
  TargetSpec $control_plain = 'controller-0',
  TargetSpec $controllers = 'controllers',
) {
  unless get_targets($control_plain).size == 1 {
    fail("Must specify a single control plane, not ${control_plain}")
  }

  $main_controller = get_targets($control_plain)[0]
  $rest_controllers = get_targets($controllers).filter |$target| { $target.name != $main_controller.name }

  # get IP address information based on its GCE name
  $key_info = run_task('kube_hard_way::encryption_key', $main_controller, 'force' => 1)
  # check if address has been got
  if $key_info.ok {
    $encryption_key = $key_info.first.value['key']
  }
  else {
    fail_plan('Unable ot read/write /var/lib/kubernetes/enc.key')
  }

  run_plan(facts, $main_controller)
  apply($main_controller) {
    class { 'kube_hard_way::config::encryption': key => $encryption_key, }
  }

  run_plan(facts, $rest_controllers)
  apply($rest_controllers) {
    class { 'kube_hard_way::setup': }
  }

  $downloaded = download_file('/var/lib/kubernetes/encryption-config.yaml', 'encryption-config.yaml', $main_controller)
  $downloaded.each |$file| {
    $down_path = $file['path']

    upload_file($down_path, '/var/lib/kubernetes/encryption-config.yaml', $rest_controllers)
  }
}
