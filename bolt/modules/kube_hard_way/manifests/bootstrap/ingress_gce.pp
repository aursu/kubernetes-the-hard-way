# @summary Add appropriate Kubernetes labels
#
# Adds appropriate Kubernetes labels. 
# See https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#set-locality-labels-on-nodes
# and https://kubernetes.io/docs/reference/labels-annotations-taints/#node-kubernetes-io-exclude-from-external-load-balancers for more information.
#
# @param exclude_from_external_load_balancers
#   Determines whether to set the label node.kubernetes.io/exclude-from-external-load-balancers
#   for a node.
#
# @param gcp_region
#   If specified, the label topology.kubernetes.io/region will be set accordingly.
#
# @param gcp_zone
#   If specified, the label topology.kubernetes.io/zone will be set accordingly.
#
# @param instance
#   Name of the node.
#
# @param kubeconfig
#   Kubernetes authentication configuration to be passed as the KUBECONFIG environment variable
#   for the kubectl command.
#
# @example
#   include kube_hard_way::bootstrap::ingress_gce
class kube_hard_way::bootstrap::ingress_gce (
  Boolean $exclude_from_external_load_balancers = false,
  Optional[String] $gcp_region = undef,
  Optional[String] $gcp_zone = undef,
  Stdlib::Host $instance = $facts['networking']['hostname'],
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  if $exclude_from_external_load_balancers {
    kubeinstall::node::label { 'node.kubernetes.io/exclude-from-external-load-balancers':
      value      => 'true',
      node_name  => $instance,
      kubeconfig => $kubeconfig,
    }
  }

  if $gcp_region {
    kubeinstall::node::label { 'topology.kubernetes.io/region':
      value      => $gcp_region,
      node_name  => $instance,
      kubeconfig => $kubeconfig,
    }
  }

  if $gcp_zone {
    kubeinstall::node::label { 'topology.kubernetes.io/zone':
      value      => $gcp_zone,
      node_name  => $instance,
      kubeconfig => $kubeconfig,
    }
  }
}
