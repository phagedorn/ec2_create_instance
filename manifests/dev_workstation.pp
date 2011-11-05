file { '/home/ubuntu/src':
  ensure  => directory,
  owner   => ubuntu,
  group   => ubuntu
}

file { '/home/ubuntu/tmp':
  ensure  => directory,
  owner   => ubuntu,
  group   => ubuntu
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
  user    => 'ubuntu',  require => Package['git'],  creates => '/home/ubuntu/.oh-my-zsh'
}

exec { 'get-machine-config':
  command => '/usr/bin/git clone --no-checkout https://github.com/Pablosan/machine-config.git',
  cwd     => '/home/ubuntu/src',
  user    => 'ubuntu',
  require => [Package['git'], File['/home/ubuntu/src']],
  creates => ['/home/ubuntu/src/machine-config/.gitconfig',
              '/home/ubuntu/src/machine-config/.gitignore',
              '/home/ubuntu/src/machine-config/.vimrc',
              '/home/ubuntu/src/machine-config/.zshrc',
              '/home/ubuntu/src/machine-config/.vim']
}

user { 'ubuntu':
  ensure  => present,
  shell   => '/usr/bin/zsh',
  require => Package['zsh']
}

