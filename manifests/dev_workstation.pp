file { "/home/${id}/src":
  ensure => directory,
  owner  => $id,
  group  => $id
}

file { "/home/${id}/tmp":
  ensure => directory,
  owner  => $id,
  group  => $id
}

