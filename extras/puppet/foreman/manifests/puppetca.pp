class foreman::puppetca {
  
  file{"/etc/puppet/autosign.conf":
    owner => $foreman_user, 
    group => "puppet",
    mode  => 644,
    require => User[$foreman_user],
  }

  myline {
    "allow_foreman_to_execute_puppetca":
      file => "/etc/sudoers",
      line => "${foreman_user} ALL = NOPASSWD: /usr/sbin/puppetca";
    "do_not_require_tty_in_sudo":
      file    => "/etc/sudoers",
      line    => "Defaults:${foreman_user} !requiretty";
  }

}
