# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::tools::yq
class kube_hard_way::tools::yq  (
  String $version = '4.35.2',
) {
  $download_url = "https://github.com/mikefarah/yq/releases/download/v${version}/yq_linux_amd64"

  exec { 'install-yq':
    command => "curl -L ${download_url} -o yq_linux_amd64-${version}",
    creates => "/usr/local/bin/yq_linux_amd64-${version}",
    path    => '/bin:/usr/bin',
    cwd     => '/usr/local/bin',
  }

  file { '/usr/local/bin/yq':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => "file:///usr/local/bin/yq_linux_amd64-${version}",
    require => Exec['install-yq'],
  }
}
