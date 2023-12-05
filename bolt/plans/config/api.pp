plan kubernetes::config::api (
  TargetSpec $control_plain = 'controller-0',
  TargetSpec $controllers = 'controllers',
  TargetSpec $workers = 'workers',
  String $gce_public_address = 'kubernetes-the-hard-way',
  Boolean $enable_kubelet = true,
) {
  unless get_targets($control_plain).size == 1 {
    fail("Must specify a single control plane, not ${control_plain}")
  }

  $main_controller = get_targets($control_plain)[0]
  $rest_controllers = get_targets($controllers).filter |$target| { $target.name != $main_controller.name }
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
  apply($main_controller) {
    kube_hard_way::kubeconfig {
      default:
        server_name  => $public_address,
        cert_dir     => $cert_dir,
        cluster_name => 'kubernetes-the-hard-way',
        ;
      'kube-proxy':
        auth_user => 'system:kube-proxy',
        ;
      'kube-controller-manager':
        auth_user => 'system:kube-controller-manager',
        ;
      'kube-scheduler':
        auth_user => 'system:kube-scheduler',
        ;
      'admin':
        auth_user => 'admin',
        ;
    }
  }

  if $enable_kubelet {
    run_plan( 'kubernetes::config::worker',
      control_plain  => $main_controller.name,
      targets        => $controllers,
    )
  }

  $downloaded = download_file($cert_dir, 'pki', $main_controller)
  $downloaded.each |$file| {
    $down_path = $file['path']

    upload_file("${down_path}/kube-proxy.kubeconfig", "${cert_dir}/kube-proxy.kubeconfig", $workers)
    upload_file("${down_path}/kube-proxy.kubeconfig", "${cert_dir}/kube-proxy.kubeconfig", $rest_controllers)
    upload_file("${down_path}/kube-controller-manager.kubeconfig", "${cert_dir}/kube-controller-manager.kubeconfig", $rest_controllers)
    upload_file("${down_path}/kube-scheduler.kubeconfig", "${cert_dir}/kube-scheduler.kubeconfig", $rest_controllers)
    upload_file("${down_path}/admin.kubeconfig", "${cert_dir}/admin.kubeconfig", $rest_controllers)
  }
}
