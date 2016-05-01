# Puppet module which installs userify shim
class userify(
    $api_id,
    $api_key,
    $static_host = 'static.userify.com',
    $shim_host = 'configure.userify.com',
    $self_signed = 0
) {

  if $self_signed == 1 {
    $insecure = '-1 -k'     # skip root CA verify, accept self-signed certs
  } else {
    $insecure = ''
  }

  exec { 'userify':
    command => "curl -sS ${insecure} \"https://${static_host}/installer.sh\" | \
      static_host=\"${static_host}\" \
      shim_host=\"${shim_host}\" \
      self_signed=${self_signed} \
      api_id=\"${api_id}\" \
      api_key=\"${api_key}\" \
      /bin/sh",
    creates => '/opt/userify/shim.sh',
    path    => ['/usr/bin', '/usr/sbin']
  }

}
