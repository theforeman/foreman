class OperatingsystemsController < ApplicationController
  active_scaffold :operatingsystem do |config|
    config.columns = [:name, :major, :architectures, :medias, :minor, :nameindicator, :puppetclasses, :ptables ]
    config.columns[:architectures].form_ui  = :select
    config.columns[:ptables].form_ui  = :select
    config.columns[:puppetclasses].form_ui  = :select
    config.columns[:medias].form_ui  = :select
    config.columns[:name].description = "Opearting System name, e.g. CentOS"
    config.columns[:major].description = "The OS major version e.g. 5"
    config.columns[:architectures].description = "The allowed architectures for this host"
    config.columns[:medias].description = "valid medias for this host"
    config.columns[:nameindicator].description = "optional, only if a nameing standard is enforced per operatingsystem"
    config.columns[:puppetclasses].description = "which puppet classes are allowed on this operatingsystem"
    config.nested.add_link("Hosts", [:hosts])
  end
end
