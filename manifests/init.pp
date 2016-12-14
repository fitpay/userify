# Puppet module which installs userify shim
class userify(
    $api_id,
    $api_key,
    $static_host = 'static.userify.com',
    $shim_host = 'configure.userify.com',
    $self_signed = false,
) {

  if $self_signed == true {
    # skip root CA verify, accept self-signed certs
    $insecure = '-k'
    $insecure_cert = '1'
  } else {
    $insecure = ''
    $insecure_cert = '0'
  }

  # This is used in case userify is laid down already and the configuration
  # changes for whatever reason, the idea is this file will then change and
  # the notify will cause a re-install/setup of userify below
  file { '/etc/userify-config':
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('userify/userify-config.erb'),
    notify  => Exec['remove existing userify installation']
  }

  exec { 'remove existing userify installation':
    path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    command     => 'rm -rf /opt/userify',
    refreshonly => true,
    notify      => Exec['userify']
  }

  exec { 'userify':
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    command => "curl -1 -sS ${insecure} \
                  'https://${static_host}/installer.sh' | \
                  api_key='${api_key}' \
                  api_id='${api_id}' \
                  static_host='${static_host}' \
                  shim_host='${shim_host}' \
                  self_signed=${insecure_cert} \
                  /bin/sh",
    creates => '/opt/userify/shim.sh',
  }
}
