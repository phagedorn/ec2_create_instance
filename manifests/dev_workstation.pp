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
