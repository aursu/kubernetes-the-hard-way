# @summary Add appropriate Kubernetes labels
#
# Add appropriate Kubernetes labels
# see https://github.com/kubernetes/ingress-gce/tree/master/docs/deploy/gke/non-gcp#set-locality-labels-on-nodes
# also https://kubernetes.io/docs/reference/labels-annotations-taints/#node-kubernetes-io-exclude-from-external-load-balancers
#
# @param exclude_from_external_load_balancers
#   Where to set label node.kubernetes.io/exclude-from-external-load-balancers for node or not
#
# @param gcp_region
#   If specified label topology.kubernetes.io/region will be set to
#
# @param gcp_zone
#   If specified label topology.kubernetes.io/zone will be set to
#
# @param instance
#   Node name
#
# @param kubeconfig
#   Kubernetes auth config to pass as KUBECONFIG env variable name for kubectl command
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
}
