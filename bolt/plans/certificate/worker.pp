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
    run_plan(facts, $target)

    if $target.facts['gce'] {
      $gce_instance       = $target.facts['gce']['instance']
      $network_interfaces = $gce_instance['networkInterfaces']
      $access_configs     = $network_interfaces[0]['accessConfigs']
      $gce_external_ip    = $access_configs[0]['externalIp']
    }
    else {
      $gce_external_ip = undef
    }

    # directory structure for Kubernetes must be set up before upload
    apply($target) {
      include kubeinstall
      include kubeinstall::directory_structure
    }

    apply($main_controller) {
      kube_hard_way::certificates::kubelet { $target.name:
        path        => $cert_dir,
        hostname    => $target.facts['networking']['hostname'],
        internal_ip => $target.facts['networking']['ip'],
        external_ip => $gce_external_ip,
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
