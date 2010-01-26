class PuppetclassesController < ApplicationController
  active_scaffold :puppetclass do |config|
    config.label = "Puppet classes"
    config.columns = [ :name, :operatingsystems, :environments ]
    config.columns[:operatingsystems].form_ui  = :select
    config.columns[:environments].form_ui  = :select
    config.columns[:name].description = "The name of the hosttype, for example a puppetmaster"
    config.columns[:operatingsystems].description = "The operating system this host type can run on"
    config.columns[:environments].description = "The environments which are enabled for this host type"
    
    config.nested.add_link "Hosts", [:hosts]
  end
end
