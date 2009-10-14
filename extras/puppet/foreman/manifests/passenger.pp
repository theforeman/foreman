class foreman::passenger {
  include apache2::passenger

  file{"/etc/httpd/conf.d/foreman.conf":
    content => template("foreman/foreman-vhost.conf.erb"),
    mode => 644, notify => Exec["reload-apache2"],
  }

  exec{"restart_foreman":
    command => "/bin/touch $foreman_dir/tmp/restart.txt",
    refreshonly => true
  }

}
