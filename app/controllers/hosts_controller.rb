class HostsController < ApplicationController
  active_scaffold :host do |config|
    config.list.columns = [:name, :operatingsystem, :environment, :last_compile ]
    config.columns = %w{ name ip mac hosttype operatingsystem environment architecture media domain model root_pass serial puppetmaster ptable disk comment}
    config.columns[:architecture].form_ui  = :select
    config.columns[:media].form_ui  = :select
    config.columns[:model].form_ui  = :select
    config.columns[:domain].form_ui  = :select
    config.columns[:hosttype].form_ui  = :select
    config.columns[:environment].form_ui  = :select
    config.columns[:ptable].form_ui  = :select
    config.columns[:operatingsystem].form_ui  = :select
    config.columns[:fact_values].association.reverse = :host
    config.nested.add_link("Inventory", [:fact_values])
    config.columns[:serial].description = "unsed for now"
    config.columns[:puppetmaster].description = "leave empty if its just puppet"
    config.columns[:disk].description = "the disk layout to use"

  end

  def externalNodes
    unless params.has_key? "fqdn" and (host = Host.find_by_name params.delete "fqdn")
      head(:bad_request) and return
    else
      begin
        param = {}
        param[:puppetmaster] = host.puppetmaster
        param[:longsitename] = host.domain.fullname
        param[:hostmode] = host.environment.name
        puppetclasses = []
        puppetclasses << host.hosttype.name
        render :text => Hash['classes' => puppetclasses, 'parameters' => param].to_yaml and return
      rescue
        # failed 
        logger.warn "Failed to generate external nodes for #{host.name} with #{$!}"

        head(:precondition_failed) and return
      end
    end
  end
end
