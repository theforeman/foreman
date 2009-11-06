class foreman {

  $railspath="/var/rails"
  $foreman_dir="${railspath}/foreman"
  $foreman_user="foreman"

  import "defines.pp"

  # some defaults
  Exec {
    cwd => $foreman_dir, 
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", 
    require => User[$foreman_user],
    user => $foreman_user,
  }

  include foreman::import_facts
  include foreman::puppetca
  include foreman::tftp
  include foreman::reports
  include foreman::externalnodes

  file{$railspath: ensure => directory}
  file{$foreman_dir: 
    ensure => directory,
    require => User[$foreman_user],
    owner => $foreman_user,
  }

  user { $foreman_user:
    shell => '/bin/false',
    comment => 'Foreman system account',
    ensure => 'present',
    home => $foreman_dir,
  }
  
  package{"rake": 
    name => $operatingsystem ? {
      default => "rake",
      "CentOs" => "rubygem-rake",
      "RedHat" => "rubygem-rake",
    },
    ensure => installed,
    before => Exec["db_migrate"],
  }

  package{"sqlite3-ruby": 
    name => $operatingsystem ? {
      default => "libsqlite3-ruby",
      "CentOs" => "rubygem-sqlite3-ruby",
      "RedHat" => "rubygem-sqlite3-ruby",
    },
    ensure => installed,
    before => Exec["db_migrate"],
  }
# Initial Foreman Install
  exec{"install_foreman":
    command => "wget -q http://theforeman.org/attachments/download/27/foreman-0.1-2.tar.bz2 -O - | tar xjf -",
    cwd => $railspath,
    creates => "$foreman_dir/public",
    notify => Exec["db_migrate"],
    require => File[$foreman_dir],
  }

  exec{"db_migrate":
    command => "rake db:migrate",
    environment => "RAILS_ENV=production",
    refreshonly => true
  }

  # cleans up the session entries in the database
  # if you are using fact or report importers, this creates a session per request
  # which can easily result with a lot of old and unrequired in your database
  # eventually slowing it down.
  cron{"clear_session_table":
    command  => "rake db:sessions:clear",
    environment => "RAILS_ENV=production",
    user => $foreman_user,
    cwd => $foreman_dir,
    minute => "15",
    hour => "23",
  }

}
