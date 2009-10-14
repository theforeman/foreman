class foreman::externalnodes {
  file{"/etc/puppet/node.rb":
    source => "puppet:///foreman/external_node.rb",
    mode   => 555,
    owner  => "puppet", group => "puppet",
  }
  
}
