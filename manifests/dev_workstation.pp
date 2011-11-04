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
  command => "/usr/bin/git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh",
  cwd     => "/home/ubuntu",
  user    => "ubuntu",
}

