# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kube_hard_way::encryption_config
class kube_hard_way::encryption_config (
  Optional[Stdlib::Base64] $key = undef,
) {
  include kube_hard_way::params
  include kube_hard_way::tools::yq
  include kube_hard_way::setup

  if $key {
    $encription_key = $key

    file { '/var/lib/kubernetes/enc.key':
      ensure  => file,
      content => $key,
    }
  }
  elsif $facts['kubernetes_encryption_key'] {
    $encription_key = $facts['kubernetes_encryption_key']
  }
  else {
    file { '/usr/libexec/encryption-key.sh':
      ensure  => file,
      content => file('kube_hard_way/scripts/encription_key.sh'),
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }

    exec { '/usr/libexec/encryption-key.sh':
      creates => '/var/lib/kubernetes/enc.key',
      path    => '/usr/local/bin:/usr/bin:/bin',
      require => [
        File['/usr/libexec/encryption-key.sh'],
        File["${kube_hard_way::params::lib_dir}/encryption-config.yaml"],
      ],
    }

    Class['kube_hard_way::tools::yq'] -> Exec['/usr/libexec/encryption-key.sh']
  }

  $object_header  = {
    'apiVersion' => 'v1',
    'kind'       => 'EncryptionConfig',
  }

  $object_resources = {
    'resources' => [
      {
        'resources' => ['secrets'],
        'providers' => [
          {
            'aescbc' => {
              'keys'=> [
                {
                  'name' => 'key1',
                  'secret' => $encription_key,
                },
              ],
            },
          },
          { 'identity' => {} },
        ],
      }
    ],
  }

  $object = to_yaml($object_header + $object_resources)

  file { "${kube_hard_way::params::lib_dir}/encryption-config.yaml":
    ensure  => file,
    content => $object,
    mode    => '0600',
  }
}
