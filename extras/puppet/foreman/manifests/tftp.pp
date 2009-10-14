class foreman::tftp {
  $tftp_dir = "${foreman_dir}/tftp"

  file{$tftp_dir:
    owner => $foreman_user,
    mode  => 644,
    require => User[$foreman_user],
    ensure => directory,
    recurse => true,
  }

  file {"${tftp_dir}/default":
    content => "default local\ntimeout 20\n\nlabel local\nlocalboot 0\n",
    mode => 544, owner => root,
    require => File[$tftp_dir],
  }

}
