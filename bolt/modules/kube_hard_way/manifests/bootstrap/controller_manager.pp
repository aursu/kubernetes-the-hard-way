# @summary Kubernetes controller manager bootstrap
#
# Kubernetes controller manager bootstrap
#
# @param bind_address
#   The IP address on which to listen for the --secure-port port. The associated interface(s) must
#   be reachable by the rest of the cluster, and by CLI/web clients. If blank or an unspecified
#   address (0.0.0.0 or ::), all interfaces and IP address families will be used.
#   (Default: 0.0.0.0)
#
# @param service_account_signing_key_file
#   Path to the file that contains the current private key of the service account token issuer. The
#   issuer will sign issued ID tokens with this private key.
#
# @param service_cluster_ip_range
#   A CIDR notation IP range from which to assign service cluster IPs. This must not overlap with
#   any IP ranges assigned to nodes or pods. Max of two dual-stack CIDRs is allowed.
#
# @param cluster_cidr
#   CIDR Range for Pods in cluster. Requires --allocate-node-cidrs to be true
#   (for kube-controller-manager)
#
# @param cluster_name
#   The instance prefix for the cluster.
#
# @param cluster_signing_cert_file
#   Filename containing a PEM-encoded X509 CA certificate used to issue cluster-scoped
#   certificates. If specified, no more specific --cluster-signing-* flag may be specified.
#
# @param cluster_signing_key_file
#   Filename containing a PEM-encoded RSA or ECDSA private key used to sign cluster-scoped
#   certificates. If specified, no more specific --cluster-signing-* flag may be specified.
#
# @param kubeconfig
#   Path to kubeconfig file with authorization and master location information (the master location
#   can be overridden by the master flag).
#
# @param root_ca_file
#   If set, this root certificate authority will be included in service account's token secret.
#   This must be a valid PEM-encoded CA bundle.
#
# @param service_account_private_key_file
#   Filename containing a PEM-encoded private RSA or ECDSA key used to sign service account tokens.
#
# @example
#   include kube_hard_way::bootstrap::controller_manager
class kube_hard_way::bootstrap::controller_manager (
  Stdlib::IP::Address $bind_address = '0.0.0.0',
  String $cluster_name = 'kubernetes',
  Stdlib::Unixpath $cluster_signing_cert_file = '/etc/kubernetes/pki/ca.pem',
  Stdlib::Unixpath $cluster_signing_key_file = '/etc/kubernetes/pki/ca-key.pem',
  String $kubeconfig = '/etc/kubernetes/pki/kube-controller-manager.kubeconfig',
  Stdlib::Unixpath $root_ca_file = '/etc/kubernetes/pki/ca.pem',
  Stdlib::Unixpath $service_account_signing_key_file = '/etc/kubernetes/pki/service-account-key.pem',
  Stdlib::Unixpath $service_account_private_key_file = $service_account_signing_key_file,
  Stdlib::IP::Address $service_cluster_ip_range = '10.32.0.0/24',
  Stdlib::IP::Address $cluster_cidr = $kube_hard_way::params::cluster_cidr,
) inherits kube_hard_way::params {
  include bsys::systemctl::daemon_reload

  include kube_hard_way::setup
  include kubeinstall
  include kubeinstall::component::kube_controller_manager

  file { '/etc/systemd/system/kube-controller-manager.service':
    ensure  => file,
    content => template('kube_hard_way/kube-controller-manager.service.erb'),
    notify  => Class['bsys::systemctl::daemon_reload'],
  }

  service { 'kube-controller-manager':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/kube-controller-manager.service'],
  }

  Class['kubeinstall::component::kube_controller_manager'] -> Service['kube-controller-manager']
}
