# define a simple static website
class webapp (
  $common_public = 'It is',
  $common_secret = 'pitch black.',
  $webapp_public = 'You are likely',
  $webapp_secret = 'to be eaten by a grue.',
) {
  $demo_text = [
    $common_public,
    $common_secret,
    $webapp_public,
    $webapp_secret,
  ]

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
