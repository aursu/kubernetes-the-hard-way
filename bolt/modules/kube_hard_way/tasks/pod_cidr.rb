#!/opt/puppetlabs/puppet/bin/ruby
require 'json'

require_relative '../../ruby_task_helper/files/task_helper'
require_relative 'google/metadatainternal'

# task to retrieve hostname from internal metadata
class KubeHardWayPodCIDR < TaskHelper
  def task(**_kwargs)
    pod_cidr = Google::MetadataInternal.new.pod_cidr

    if pod_cidr.nil?
      raise TaskHelper::Error.new('Unable to retrieve pod-cidr instance attribute from internal metadata',
                                'aursu-kube_hard_way/pod_cidr',
                                { 'exitcode': 1 })
    end

    pod_cidr
  end
end

KubeHardWayPodCIDR.run if __FILE__ == $PROGRAM_NAME
