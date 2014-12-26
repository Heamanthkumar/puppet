# define a simple static website
class webapp (
  $public = 'It is pitch black.',
  $secret = 'You are likely to be eaten by a grue.',
) {
  $demo_text = [$public, $secret]

  file { '/var/www/':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/var/www/index.html':
    ensure  => 'file',
    content => template('webapp/index.html.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  include nginx

  nginx::resource::vhost { $::ec2_public_hostname:
    www_root => '/var/www',
  }
}
