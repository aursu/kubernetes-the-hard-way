#!/opt/puppetlabs/puppet/bin/ruby
require 'json'

require_relative '../../ruby_task_helper/files/task_helper'
require_relative 'google/metadatainternal'

# task to retrieve hostname from internal metadata
class KubeHardWayHostname < TaskHelper
  def task(**_kwargs)
    dns_info = Google::MetadataInternal.new.dns_info

    if dns_info.nil?
      raise TaskHelper::Error.new('Unable to retrieve hostname from internal metadata',
                                'aursu-kube_hard_way/hostname',
                                { 'exitcode': 1 })
    end

    dns_info
  end
end

KubeHardWayHostname.run if __FILE__ == $PROGRAM_NAME
