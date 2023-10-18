plan kubernetes::config::worker (
  Stdlib::Host $control_plain = 'controller-0',
  TargetSpec $workers = 'workers',
  String $gce_public_address = 'kubernetes-the-hard-way',
) {
  unless get_targets($control_plain).size == 1 {
    fail("Must specify a single control plane, not ${control_plain}")
  }

  $main_controller = get_targets($control_plain)[0]
  $cert_dir = '/etc/kubernetes/pki'

  # get IP address information based on its GCE name
  $addr_info = run_task('kube_hard_way::address', $main_controller, 'address' => $gce_public_address)
  # check if address has been got
  if $addr_info.ok {
    $public_address = $addr_info.first.value['address']
  }
  else {
    fail_plan('Unable ot retrieve Kubernetes cluster address')
  }

  run_plan(facts, $main_controller)

  get_targets($workers).each |$target| {
    $instance = $target.name
    apply($main_controller) {
      kube_hard_way::kubeconfig { $instance:
        auth_user    => "system:node:${instance}",
        server_name  => $public_address,
        cert_dir     => $cert_dir,
        cluster_name => 'kubernetes-the-hard-way',
      }
    }
  }

  $downloaded = download_file($cert_dir, 'pki', $main_controller)
  $downloaded.each |$file| {
    $down_path = $file['path']

    get_targets($workers).each |$target| {
      $instance = $target.name

      upload_file("${down_path}/${instance}.kubeconfig", "${cert_dir}/${instance}.kubeconfig", $target)
    }
  }
}
