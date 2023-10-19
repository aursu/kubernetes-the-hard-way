plan kube_hard_way::etcd::service (
  TargetSpec $targets = 'controllers',
  Stdlib::Unixpath $server_crt = '/etc/kubernetes/pki/kubernetes.pem',
  Stdlib::Unixpath $server_key = '/etc/kubernetes/pki/kubernetes-key.pem',
  Stdlib::Unixpath $peer_crt = '/etc/kubernetes/pki/kubernetes.pem',
  Stdlib::Unixpath $peer_key = '/etc/kubernetes/pki/kubernetes-key.pem',
  Stdlib::Unixpath $ca_crt = '/etc/kubernetes/pki/ca.pem',
  Optional[String] $initial_cluster_token = 'etcd-cluster-0',
  Optional[String] $initial_cluster = undef,
) {
  run_plan('etcd::service', $targets,
    server_crt => $server_crt,
    server_key => $server_key,
    peer_crt => $peer_crt,
    peer_key => $peer_key,
    ca_crt => $ca_crt,
  initial_cluster_token => $initial_cluster_token)

  apply($targets) {
    include etcd::service

    file { '/etc/etcd': ensure => directory }
    file { '/etc/etcd/ca.pem': source => "file://${ca_crt}" }
    file { '/etc/etcd/kubernetes.pem': source => "file://${server_crt}" }
    file { '/etc/etcd/kubernetes-key.pem': source => "file://${server_key}" }
  }
}
