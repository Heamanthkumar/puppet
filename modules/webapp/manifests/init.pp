# define a simple static website
class webapp (
  $public = 'It is pitch black.',
  $secret = 'You are likely to be eaten by a grue.',
) {
  $text = join([$public, $secret], ' ')
  $webpage =
    "<!doctype html><html><head><title>Demo</title><body>${text}</body></html>"

  file { '/var/www/':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/var/www/index.html':
    ensure  => 'file',
    content => $webpage,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  include nginx

  nginx::resource::vhost { $::ec2_public_hostname:
    www_root => '/var/www',
  }
}
