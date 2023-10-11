# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   kube_hard_way::kubeconfig { 'namevar': }
define kube_hard_way::kubeconfig (
  String $auth_user,
  Stdlib::Host $server_name,
  String $cluster_name = 'kubernetes-the-hard-way',
  String $config_name="${name}.kubeconfig",
  String $certificate_authority = 'ca.pem',
  String $client_certificate = "${name}.pem",
  String $client_key = "${name}-key.pem",
  Optional[Stdlib::Unixpath] $path = undef,
) {
  include kubeinstall
  include kubeinstall::params
  include kube_hard_way::tools::yq
  include kubeinstall::kubectl::binary

  $cert_dir = $path ? {
    Stdlib::Unixpath => $path,
    default          => $kubeinstall::params::cert_dir,
  }

  $ca_option = "--certificate-authority=${certificate_authority}"
  $server_option = "--server=https://${server_name}:6443"
  $cert_option = "--client-certificate=${client_certificate}"
  $key_option = "--client-key=${client_key}"
  $user_option = "--user=${auth_user}"
  $config_option = "--kubeconfig=${config_name}"
  $cluster_option = "--cluster=${cluster_name}"

  exec {
    default:
      path    => '/usr/local/bin:/usr/bin:/bin',
      cwd     => $cert_dir,
      require => Class['kubeinstall::kubectl::binary'],
      ;
    "kubectl config set-cluster ${cluster_name} ${config_option}":
      command => "kubectl config set-cluster ${cluster_name} ${ca_option} --embed-certs=true  ${server_option} ${config_option}",
      unless  => "yq -e '.clusters[] | select(.name == \"${cluster_name}\")' ${config_name}",
      ;
    "kubectl config set-credentials ${auth_user} ${config_option}":
      command => "kubectl config set-credentials ${auth_user} ${cert_option} ${key_option} --embed-certs=true  ${server_option} ${config_option}",
      unless  => "yq -e '.users[] | select(.name == \"${auth_user}\")' ${config_name}",
      require => Exec["kubectl config set-cluster ${cluster_name} ${config_option}"],
      ;
    "kubectl config set-context default ${config_option}":
      command => "kubectl config set-context default ${cluster_option} ${user_option} ${config_option}",
      unless  => "yq -e '.contexts[] | select(.name == \"default\")' ${config_name}",
      require => Exec["kubectl config set-credentials ${auth_user} ${config_option}"],
      ;
    "kubectl config use-context default ${config_option}":
      unless  => "yq -e 'select(.current-context == \"default\")' ${config_name}",
      require => Exec["kubectl config set-context default ${config_option}"],
      ;
  }
}
