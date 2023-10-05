#!/opt/puppetlabs/puppet/bin/ruby

require_relative 'httpclient'

# class to request Google Cloud internal metadata
class Google::MetadataInternal < HTTPClient
  def initialize
    super
    @hostname = nil
  end

  def api_get(path)
    code, _headers, body = url_get("http://metadata.google.internal/computeMetadata/v1/#{path}", { 'Metadata-Flavor' => 'Google' })

    return nil unless code == '200'

    body.strip
  end

  def hostname
    @hostname ||= api_get('instance/hostname')
  end

  def dns_info
    return nil if hostname.nil?

    dns = hostname.split('.')

    project_id = dns[-2]
    vm_name = dns[0]
    zone = (dns[1] == 'c') ? nil : dns[1]
    region = zone.nil? ? nil : zone.split('-')[0...2].join('-')

    { 'hostname' => hostname,
      'project_id' => project_id,
      'vm_name' => vm_name,
      'zone' => zone,
      'region' => region }
  end
end
