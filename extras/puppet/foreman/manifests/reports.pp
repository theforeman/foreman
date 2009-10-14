# please follow the instructions at: http://theforeman.org/wiki/foreman/Puppet_Reports

class foreman::reports {
  # directory where your puppet is installed
  $puppet_basedir = $operatingsystem ? {
    default => "/usr/lib/ruby/1.8/puppet",
    "CentOs" => "/usr/lib/ruby/site_ruby/1.8/puppet",
    "RedHat" => "/usr/lib/ruby/site_ruby/1.8/puppet",
  }
  
  # foreman reporter
  file {"${puppet_basedir}/reports/foreman.rb":
    mode => 444,
    owner => puppet, group => puppet,
    source => "puppet:///foreman/foreman-report.rb",
  }

}
