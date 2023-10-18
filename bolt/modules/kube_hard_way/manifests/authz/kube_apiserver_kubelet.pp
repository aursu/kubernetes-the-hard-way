# @summary Authorize access to Kubelet for Kube API server
#
# Authorize access the Kubelet API for Kube API server
#
# @example
#   include kube_hard_way::authz::kube_apiserver_kubelet
class kube_hard_way::authz::kube_apiserver_kubelet (
  Kubeinstall::DNSName $object_name = 'kube-apiserver',
  Kubeinstall::Metadata $metadata = {},
  Boolean $apply = true,
  Stdlib::Unixpath $cert_dir = $kube_hard_way::params::cert_dir,
  Optional[Stdlib::Unixpath] $kubeconfig = "${cert_dir}/admin.kubeconfig",
) inherits kube_hard_way::params {
  include kubeinstall::params
  include kube_hard_way::params
  include kube_hard_way::authz::kubelet

  $authz_kubelet_object_name = $kube_hard_way::authz::kubelet::object_name

  $object_header  = {
    'apiVersion' => 'rbac.authorization.k8s.io/v1',
    'kind'       => 'ClusterRoleBinding',
  }

  # it is  possible to supply 'namespace' via $metadata variable
  # also additionally to specified here annotations and labels it is possible to add
  # them via $metadata variable as well
  $metadata_content = {
    'metadata' => $metadata + {
      'name' => "system:${object_name}",
      'namespace' => '',
    },
  }

  $object_content = {
    'roleRef' => {
      'apiGroup' => 'rbac.authorization.k8s.io',
      'kind'     => 'ClusterRole',
      'name'     => "system:${authz_kubelet_object_name}"
    },
    'subjects' => [
      {
        'apiGroup' => 'rbac.authorization.k8s.io',
        'kind'     => 'User',
        'name'     => 'kubernetes',
      },
    ],
  }

  $object = to_yaml($object_header + $metadata_content + $object_content)

  file { "clusterrolebindings/${object_name}.yaml":
    ensure  => file,
    path    => "${kubeinstall::params::manifests_directory}/manifests/clusterrolebindings/${object_name}.yaml",
    content => $object,
    mode    => '0600',
    require => Class['kube_hard_way::authz::kubelet'],
  }

  if $apply {
    include kubeinstall::kubectl::binary

    kubeinstall::kubectl::apply { "clusterrolebindings/${object_name}.yaml":
      kind       => 'ClusterRoleBinding',
      resource   => $object_name,
      kubeconfig => $kubeconfig,
      subscribe  => File["clusterrolebindings/${object_name}.yaml"],
      require    => Class['kubeinstall::kubectl::binary'],
    }
  }
}
