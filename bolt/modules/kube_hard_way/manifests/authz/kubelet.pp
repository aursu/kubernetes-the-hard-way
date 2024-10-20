# @summary Authorize access the Kubelet API
#
# Create ClusterRole with permissions to access the Kubelet API
#
# @param object_name
#   ClusterRole name (after `system:` prefix)
#
# @param metadata
#   Ability to add additional annotations, labels and namespace.
#
# @example
#   include kube_hard_way::authz::kubelet
class kube_hard_way::authz::kubelet (
  Kubeinstall::DNSName $object_name = 'kube-apiserver-to-kubelet',
  Kubeinstall::Metadata $metadata = {},
  Boolean $apply = true,
  Stdlib::Unixpath $cert_dir = $kube_hard_way::params::cert_dir,
  Optional[Stdlib::Unixpath] $kubeconfig = "${cert_dir}/admin.kubeconfig",
) inherits kube_hard_way::params {
  include kubeinstall::params
  include kube_hard_way::params
  include kubeinstall
  include kubeinstall::directory_structure

  $annotations = $metadata['annotations'] ? {
    Hash    => $metadata['annotations'],
    default => {},
  }

  $labels = $metadata['labels'] ? {
    Hash    => $metadata['labels'],
    default => {},
  }

  $object_header  = {
    'apiVersion' => 'rbac.authorization.k8s.io/v1',
    'kind'       => 'ClusterRole',
  }

  # it is  possible to supply 'namespace' via $metadata variable
  # also additionally to specified here annotations and labels it is possible to add
  # them via $metadata variable as well
  $metadata_content = {
    'metadata' => $metadata + {
      'name' => "system:${object_name}",
      'annotations' => $annotations + {
        'rbac.authorization.kubernetes.io/autoupdate' => 'true',
      },
      'labels' => $labels + {
        'kubernetes.io/bootstrapping' => 'rbac-defaults',
      },
    },
  }

  # kubectl exec -ti busybox -- nslookup kubernetes
  # error: unable to upgrade connection: Forbidden (user=kubernetes, verb=create, resource=nodes, subresource=proxy)

  $object_content = {
    'rules' => [
      {
        'apiGroups' => [''],
        'resources' => [
          'nodes/proxy',
          'nodes/stats',
          'nodes/log',
          'nodes/spec',
          'nodes/metrics',
        ],
        'verbs'     => ['*'],
      }
    ],
  }

  $object = to_yaml($object_header + $metadata_content + $object_content)

  file { "clusterroles/${object_name}.yaml":
    ensure  => file,
    path    => "${kubeinstall::manifests_directory}/manifests/clusterroles/${object_name}.yaml",
    content => $object,
    mode    => '0600',
    require => Class['kubeinstall::directory_structure'],
  }

  if $apply {
    include kubeinstall::component::kubectl

    kubeinstall::kubectl::apply { "clusterroles/${object_name}.yaml":
      kind       => 'ClusterRole',
      resource   => $object_name,
      kubeconfig => $kubeconfig,
      subscribe  => File["clusterroles/${object_name}.yaml"],
      require    => Class['kubeinstall::component::kubectl'],
    }
  }
}
