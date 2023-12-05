plan kubernetes::certificate::api (
  TargetSpec          $control_plain      = 'controller-0',
  TargetSpec          $controllers        = 'controllers',
  Stdlib::Host        $internal_ip        = '10.32.0.1',
  Array[Stdlib::Host] $controller_nodes   = [
    '10.240.0.10',
    '10.240.0.11',
    '10.240.0.12',
  ],
  String              $gce_public_address = 'kubernetes-the-hard-way',
  Boolean             $enable_kubelet     = true,
) {
  unless get_targets($control_plain).size == 1 {
    fail("Must specify a single control plane, not ${control_plain}")
  }

  $main_controller  = get_targets($control_plain)[0]
  $rest_controllers = get_targets($controllers).filter |$target| { $target.name != $main_controller.name }
  $cert_dir         = '/etc/kubernetes/pki'

  run_plan(facts, $main_controller)

  apply($main_controller) {
    class { 'kube_hard_way::certificate_authority': cert_dir => $cert_dir, }
    class { 'kube_hard_way::certificates::admin': cert_dir => $cert_dir, }
    class { 'kube_hard_way::certificates::controller_manager': cert_dir => $cert_dir, }
    class { 'kube_hard_way::certificates::kube_proxy': cert_dir => $cert_dir, }
    class { 'kube_hard_way::certificates::kube_scheduler': cert_dir => $cert_dir, }
    class { 'kube_hard_way::certificates::service_account': cert_dir => $cert_dir, }
  }

  run_plan( 'kube_hard_way::certificates::kubernetes_api',
    control_plain      => $main_controller.name,
    internal_ip        => $internal_ip,
    controller_nodes   => $controller_nodes,
    gce_public_address => $gce_public_address,
    cert_dir           => $cert_dir,
  )

  # directory structure for Kubernetes must be set up before upload
  run_plan(facts, $rest_controllers)
  apply($rest_controllers) {
    include kubeinstall
    include kubeinstall::directory_structure
  }

  if $enable_kubelet {
    run_plan( 'kubernetes::certificate::worker',
      control_plain  => $main_controller.name,
      targets        => $controllers,
    )
  }

  $downloaded = download_file($cert_dir, 'pki', $main_controller)
  $downloaded.each |$file| {
    $down_path = $file['path']

    upload_file("${down_path}/ca-key.pem", "${cert_dir}/ca-key.pem", $rest_controllers)
    upload_file("${down_path}/ca.pem", "${cert_dir}/ca.pem", $rest_controllers)
    upload_file("${down_path}/kubernetes-key.pem", "${cert_dir}/kubernetes-key.pem", $rest_controllers)
    upload_file("${down_path}/kubernetes.pem", "${cert_dir}/kubernetes.pem", $rest_controllers)
    upload_file("${down_path}/service-account-key.pem", "${cert_dir}/service-account-key.pem", $rest_controllers)
    upload_file("${down_path}/service-account.pem", "${cert_dir}/service-account.pem", $rest_controllers)
  }
}
