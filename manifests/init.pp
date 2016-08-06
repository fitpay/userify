# Puppet module which installs userify shim
class userify(
    $api_id,
    $api_key,
    $static_host = 'static.userify.com',
    $shim_host = 'configure.userify.com',
    $self_signed = 0
) {

  if $self_signed == 1 {
    $insecure = '-k'     # skip root CA verify, accept self-signed certs
  } else {
    $insecure = ''
  }

  # This is used in case userify is laid down already and the configuration
  # changes for whatever reason, the idea is this file will then change and
  # the notify will cause a re-install/setup of userify below
  file { '/etc/userify-config':
    ensure  => present,
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
    command => "curl -sS1 ${insecure} \"https://${static_host}/installer.sh\" | \
      static_host=\"${static_host}\" \
      shim_host=\"${shim_host}\" \
      self_signed=${self_signed} \
      api_id=\"${api_id}\" \
      api_key=\"${api_key}\" \
      /bin/sh",
    creates => '/opt/userify/shim.sh',
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin']
  }
}
