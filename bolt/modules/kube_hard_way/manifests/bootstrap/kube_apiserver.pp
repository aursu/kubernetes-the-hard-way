# @summary Bootstrap of Kubernetes API server
#
# Bootstrap of Kubernetes API server
#
# @param server_name
#   Kubernetes Cluster address or IP which is accessible on port 6443
#
# @param advertise_address
#   The IP address on which to advertise the apiserver to members of the cluster. This address
#   must be reachable by the rest of the cluster. If blank, the --bind-address will be used.
#   If --bind-address is unspecified, the host's default interface will be used.
#
# @param allow_privileged
#   If true, allow privileged containers. [default=false]
#
# @param bind_address
#   The IP address on which to listen for the --secure-port port. The associated interface(s) must
#   be reachable by the rest of the cluster, and by CLI/web clients. If blank or an unspecified
#   address (0.0.0.0 or ::), all interfaces and IP address families will be used.
#   (Default: 0.0.0.0)
#
# @param client_ca_file
#   If set, any request presenting a client certificate signed by one of the authorities in the
#   client-ca-file is authenticated with an identity corresponding to the CommonName of the client
#   certificate.
#
# @param etcd_cafile
#   SSL Certificate Authority file used to secure etcd communication.
#
# @param etcd_certfile
#   SSL certification file used to secure etcd communication.
#
# @param etcd_keyfile
#   SSL key file used to secure etcd communication.
#
# @param kubelet_certificate_authority
#   Path to a cert file for the certificate authority.
#
# @param kubelet_client_certificate
#   Path to a client cert file for TLS.
#
# @param kubelet_client_key
#   Path to a client key file for TLS.
#
# @param service_account_key_file
#   File containing PEM-encoded x509 RSA or ECDSA private or public keys, used to verify
#   ServiceAccount tokens. The specified file can contain multiple keys, and the flag can be
#   specified multiple times with different files. If unspecified, --tls-private-key-file is used.
#   Must be specified when --service-account-signing-key-file is provided
#
# @param service_account_signing_key_file
#   Path to the file that contains the current private key of the service account token issuer. The
#   issuer will sign issued ID tokens with this private key.
#
# @param service_cluster_ip_range
#   A CIDR notation IP range from which to assign service cluster IPs. This must not overlap with
#   any IP ranges assigned to nodes or pods. Max of two dual-stack CIDRs is allowed.
#
# @param tls_cert_file
#   File containing the default x509 Certificate for HTTPS. (CA cert, if any, concatenated after
#   server cert). If HTTPS serving is enabled, and --tls-cert-file and --tls-private-key-file are
#   not provided, a self-signed certificate and key are generated for the public address and saved
#   to the directory specified by --cert-dir (default is /var/run/kubernetes).
#
# @param tls_private_key_file
#   File containing the default x509 private key matching --tls-cert-file.
#
# @example
#   include kube_hard_way::bootstrap::controller
class kube_hard_way::bootstrap::kube_apiserver (
  Stdlib::Host $server_name,
  Kubeinstall::VersionPrefix $kubernetes_version,
  Stdlib::IP::Address $advertise_address = $facts['networking']['ip'],
  Boolean $allow_privileged = true,
  Stdlib::IP::Address $bind_address = '0.0.0.0',
  Stdlib::Unixpath $client_ca_file = '/etc/kubernetes/pki/ca.pem',
  Stdlib::Unixpath $etcd_cafile = '/etc/kubernetes/pki/etcd/ca.crt',
  Stdlib::Unixpath $etcd_certfile = '/etc/kubernetes/pki/etcd/server.crt',
  Stdlib::Unixpath $etcd_keyfile = '/etc/kubernetes/pki/etcd/server.key',
  Array[Stdlib::IP::Address] $etcd_servers = [
    '10.240.0.10',
    '10.240.0.11',
    '10.240.0.12',
  ],
  Stdlib::Unixpath $encryption_provider_config = $kube_hard_way::params::encryption_provider_config,
  Stdlib::Unixpath $kubelet_certificate_authority = '/etc/kubernetes/pki/ca.pem',
  Stdlib::Unixpath $kubelet_client_certificate = '/etc/kubernetes/pki/kubernetes.pem',
  Stdlib::Unixpath $kubelet_client_key = '/etc/kubernetes/pki/kubernetes-key.pem',
  Stdlib::Unixpath $service_account_key_file = '/etc/kubernetes/pki/service-account.pem',
  Stdlib::Unixpath $service_account_signing_key_file = '/etc/kubernetes/pki/service-account-key.pem',
  Stdlib::IP::Address $service_cluster_ip_range = $kube_hard_way::global::cluster_ip_range,
  Stdlib::Unixpath $tls_cert_file = '/etc/kubernetes/pki/kubernetes.pem',
  Stdlib::Unixpath $tls_private_key_file = '/etc/kubernetes/pki/kubernetes-key.pem',
) inherits kube_hard_way::global {
  include bsys::systemctl::daemon_reload

  include kube_hard_way::setup
  include kubeinstall

  class { 'kubeinstall::component::kube_apiserver':
    kubernetes_version => $kubernetes_version,
  }

  $etcd_servers_string = $etcd_servers.reduce([]) |$memo, $server| {
    $memo + ["https://${server}:2379"]
  }.join(',')

  # Identifier of the service account token issuer. The issuer will assert this identifier in "iss"
  # claim of issued tokens. This value is a string or URI. If this option is not a valid URI per
  # the OpenID Discovery 1.0 spec, the ServiceAccountIssuerDiscovery feature will remain disabled,
  # even if the feature gate is set to true. It is highly recommended that this value comply with
  # the OpenID spec: https://openid.net/specs/openid-connect-discovery-1_0.html. In practice, this
  # means that service-account-issuer must be an https URL. It is also highly recommended that this
  # URL be capable of serving OpenID discovery documents at
  # {service-account-issuer}/.well-known/openid-configuration. When this flag is specified multiple
  # times, the first is used to generate tokens and all are used to determine which issuers are
  # accepted.
  $service_account_issuer = "https://${server_name}:6443"

  file { '/etc/systemd/system/kube-apiserver.service':
    ensure  => file,
    content => template('kube_hard_way/kube-apiserver.service.erb'),
    notify  => Class['bsys::systemctl::daemon_reload'],
  }

  service { 'kube-apiserver':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/kube-apiserver.service'],
  }

  Class['kubeinstall::component::kube_apiserver'] -> Service['kube-apiserver']
}
