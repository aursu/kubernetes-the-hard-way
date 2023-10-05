#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'

require_relative '../../ruby_task_helper/files/task_helper'
require_relative 'google/metadatainternal'

# TaskHelper for address information description
class KubeHardWayAddress < TaskHelper
  def task(address: nil, **_kwargs)
    dns_info = Google::MetadataInternal.new.dns_info

    unless dns_info && dns_info['region']
      raise TaskHelper::Error.new('Unable to retrieve region from internal metadata',
                                'aursu-kube_hard_way/address',
                                { 'exitcode': 1 })
    end

    cmd = ['gcloud', 'compute', 'addresses', 'describe', address, "--region=#{dns_info['region']}", '--format=json']

    output, status = Open3.capture2(*cmd)

    raise TaskHelper::Error.new('gcloud did not exited normally', 'aursu-kube_hard_way/address', output) unless status.exited?
    raise TaskHelper::Error.new("gcloud exited with error code #{status.exitstatus}", 'aursu-kube_hard_way/address', output) if status != 0

    JSON.parse(output)
  end
end

KubeHardWayAddress.run if __FILE__ == $PROGRAM_NAME
