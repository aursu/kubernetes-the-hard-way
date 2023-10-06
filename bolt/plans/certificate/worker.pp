plan kubernetes::certificate::worker (
  TargetSpec $control_plain = 'controller-0',
  TargetSpec $targets = 'workers',
) {
  unless get_targets($control_plain).size == 1 {
    fail("Must specify a single control plane, not ${control_plain}")
  }
  $main_controller = get_targets($control_plain)[0]

  $cert_dir = '/etc/kubernetes/pki'

  run_plan(facts, $main_controller)
  get_targets($targets).each |$target| {
    apply($main_controller) {
      kube_hard_way::certificates::kubelet { $target.name:
        path => $cert_dir,
      }
    }
  }

  $downloaded = download_file($cert_dir, 'pki', $main_controller)
  $downloaded.each |$file| {
    $down_path = $file['path']

    get_targets($targets).each |$target| {
      $instance = $target.name

      upload_file("${down_path}/ca.pem", "${cert_dir}/ca.pem", $target)
      upload_file("${down_path}/${instance}-key.pem", "${cert_dir}/${instance}-key.pem", $target)
      upload_file("${down_path}/${instance}.pem", "${cert_dir}/${instance}.pem", $target)
    }
  }
}
