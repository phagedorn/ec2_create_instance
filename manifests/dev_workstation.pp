file { "/home/ubuntu/src":
  ensure => directory,
  owner  => ubuntu,
  group  => ubuntu
}

file { "/home/ubuntu/tmp":
  ensure => directory,
  owner  => ubuntu,
  group  => ubuntu
}

package { "git":
  ensure => installed
}

package { "zsh":
  ensure => installed
}

exec { "get-oh-my-zsh":
  command => "/usr/bin/wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh",
  cwd     => "/home/ubuntu",
  user    => "ubuntu",
  require => Package["zsh"]
}

exec { "run-oh-my-zsh":
  command => "/home/ubuntu/install.sh",
  cwd     => "/home/ubuntu",
  user    => "ubuntu",
  require => Exec["get-oh-my-zsh"]
}

