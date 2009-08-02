class PuppetclassesController < ApplicationController
  active_scaffold :puppetclass do |config|
    config.columns = [ :name, :operatingsystems, :nameindicator, :environments ]
    config.columns[:operatingsystems].form_ui  = :select
    config.columns[:environments].form_ui  = :select
    config.columns[:nameindicator].description = "required only if following a naming standard"
    config.columns[:name].description = "The name of the hosttype, for example a puppetmaster"
    config.columns[:operatingsystems].description = "The operating system this host type can run on"
    config.columns[:environments].description = "The environments which are enabled for this host type"
  end
end
