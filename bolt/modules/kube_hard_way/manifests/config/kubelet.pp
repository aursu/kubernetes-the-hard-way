# @summary kubelet configuration
#
# kubelet configuration
# https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/
# https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
#
# @param client_ca_file
#   clientCAFile is the path to a PEM-encoded certificate bundle. If set, any request presenting a
#   client certificate signed by one of the authorities in the bundle is authenticated with a
#   username corresponding to the CommonName, and groups corresponding to the Organization in the
#   client certificate.
#
# @param cluster_domain
#   clusterDomain is the DNS domain for this cluster. If set, kubelet will configure all containers
#   to search this domain in addition to the host's search domains.
#
# @param cluster_dns
#   clusterDNS is a list of IP addresses for the cluster DNS server. If set, kubelet will configure
#   all containers to use this for DNS resolution instead of the host's DNS servers.
#
# @param pod_subnet
#   podCIDR is the CIDR to use for pod IP addresses, only used in standalone mode. In cluster mode,
#   this is obtained from the control plane
#
# @param resolv_conf
#   resolvConf is the resolver configuration file used as the basis for the container DNS
#   resolution configuration. If set to the empty string, will override the default and effectively
#   disable DNS lookups. `/run/systemd/resolve/resolv.conf` is used to avoid loops when using CoreDNS
#   for service discovery on systems running `systemd-resolved`.
#
# @param runtime_request_timeout
#   runtimeRequestTimeout is the timeout for all runtime requests except long running requests -
#   pull, logs, exec and attach.
#
# @param instance
#   Kubernetes worker name (hostname)
#
# @param tls_cert_file
#   tlsCertFile is the file containing x509 Certificate for HTTPS. (CA cert, if any, concatenated
#   after server cert). If tlsCertFile and tlsPrivateKeyFile are not provided, a self-signed
#   certificate and key are generated for the public address and saved to the directory passed to
#   the Kubelet's --cert-dir flag.
#
# @param tls_private_keyfile
#   tlsPrivateKeyFile is the file containing x509 private key matching tlsCertFile.
#
# @param cgroup_driver
#   cgroupDriver is the driver kubelet uses to manipulate CGroups on the host (cgroupfs or systemd). 
#
# @example
#   include kube_hard_way::config::kubelet
class kube_hard_way::config::kubelet (
  Stdlib::Unixpath $cert_dir = $kube_hard_way::params::cert_dir,
  Stdlib::Unixpath $client_ca_file = "${cert_dir}/ca.pem",
  Stdlib::Host $cluster_domain = 'cluster.local',
  Stdlib::IP::Address $dns_addr = $kube_hard_way::global::dns_addr,
  Array[Stdlib::Host] $cluster_dns = [$dns_addr],
  Stdlib::IP::Address $pod_subnet = $kube_hard_way::global::pod_subnet,
  Stdlib::Unixpath $resolv_conf = '/run/systemd/resolve/resolv.conf',
  String $runtime_request_timeout = '15m',
  Stdlib::Host $instance = $facts['networking']['hostname'],
  Stdlib::Unixpath $tls_cert_file = "${cert_dir}/${instance}.pem",
  Stdlib::Unixpath $tls_private_keyfile = "${cert_dir}/${instance}-key.pem",
  Enum['cgroupfs', 'systemd'] $cgroup_driver = 'systemd',
) inherits kube_hard_way::global {
  include kubeinstall
  include kubeinstall::directory_structure

  $object_header  = {
    'apiVersion' => 'kubelet.config.k8s.io/v1beta1',
    'kind'       => 'KubeletConfiguration',
  }

  $object_content = {
    'authentication'        => {
      'anonymous' => {
        'enabled' => false,
      },
      'webhook' => {
        'enabled' => true,
      },
      'x509' => {
        # x509 client certificate authentication.
        'clientCAFile' => $client_ca_file,
      },
    },
    'authorization'         => {
      'mode' => 'Webhook',
    },
    'clusterDomain'         => $cluster_domain,
    'clusterDNS'            => $cluster_dns,
    # podCIDR is the CIDR to use for pod IP addresses, only used in standalone mode. In cluster
    # mode, this is obtained from the control plane.
    # 'podCIDR'              => $pod_subnet,
    'resolvConf'            => $resolv_conf,
    'runtimeRequestTimeout' => $runtime_request_timeout,
    'tlsCertFile'           => $tls_cert_file,
    'tlsPrivateKeyFile'     => $tls_private_keyfile,
    'registerNode'          => true,
    'cgroupDriver'          => $cgroup_driver,
  }

  $object = to_yaml($object_header + $object_content)

  file { '/var/lib/kubelet/kubelet-config.yaml':
    ensure  => file,
    content => $object,
    mode    => '0600',
  }
}
