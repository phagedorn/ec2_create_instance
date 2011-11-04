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

exec { "oh-my-zsh install":
  command => "wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh",
  cwd => "/home/ubuntu",
  user => "ubuntu"
}

