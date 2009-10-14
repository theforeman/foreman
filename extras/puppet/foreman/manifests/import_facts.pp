# please follow the instructions at: http://theforeman.org/wiki/foreman/Puppet_Facts
# DO NOT enable this class if you have store configs enabled

class foreman::import_facts {
  file {"/etc/puppet/push_facts.rb":
    mode => 555,
    owner => puppet, group => puppet,
    source => "puppet:///foreman/push_facts.rb",
  }

  cron{"send_facts_to_foreman":
    command  => "/etc/puppet/push_facts.rb",
    user  => "puppet",
    minute => "*/2",
  }

}
