file { '/home/ubuntu/src':
  ensure => directory,
  owner  => ubuntu,
  group  => ubuntu
}

file { '/home/ubuntu/tmp':
  ensure => directory,
  owner  => ubuntu,
  group  => ubuntu
}

package { 'git':
  ensure => installed
}

package { 'zsh':
  ensure => installed
}

exec { 'get-oh-my-zsh':
  command => '/usr/bin/git clone https://github.com/robbyrussell/oh-my-zsh.git /home/ubuntu/.oh-my-zsh',
  cwd     => '/home/ubuntu',
  user    => 'ubuntu',
  require => Package['git']
}

exec { 'get-machine-config':
  command => '/usr/bin/git clone git://github.com/Pablosan/machine-config.git .',
  cwd     => '/home/ubuntu',
  user    => 'ubuntu',
  require => Package['git']
}

user { 'ubuntu':
  ensure  => present,
  shell   => '/usr/bin/zsh',
  require => [Package['zsh'], Exec['get-oh-my-zsh', 'get-machine-config']]
}

