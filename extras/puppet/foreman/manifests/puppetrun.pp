class foreman::puppetrun {
  
  myline {
    "allow_foreman_to_execute_puppetrun":
      file => "/etc/sudoers",
      line => "${foreman_user} ALL = NOPASSWD: /usr/bin/puppetrun"
  }

}
