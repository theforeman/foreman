class HostsController < ApplicationController
  helper :all
  active_scaffold :host do |config|
    list.empty_field_text ='N/A'
    list.per_page = 15
    list.sorting = {:name => 'ASC' }
    config.list.columns = [:name, :operatingsystem, :environment, :last_compile ]
    config.columns = %w{ name ip mac hostgroup puppetclasses operatingsystem environment architecture media domain model root_pass serial puppetmaster ptable disk comment host_parameters}
    config.columns[:architecture].form_ui  = :select
    config.columns[:media].form_ui  = :select
    config.columns[:hostgroup].form_ui  = :select
    config.columns[:model].form_ui  = :select
    config.columns[:domain].form_ui  = :select
    config.columns[:puppetclasses].form_ui  = :select
    config.columns[:environment].form_ui  = :select
    config.columns[:ptable].form_ui  = :select
    config.columns[:operatingsystem].form_ui  = :select
    config.columns[:fact_values].association.reverse = :host
    config.nested.add_link("Inventory", [:fact_values])
    config.columns[:serial].description = "unsed for now"
    config.columns[:puppetmaster].description = "leave empty if its just puppet"
    config.columns[:disk].description = "the disk layout to use"
    config.columns[:build].form_ui  = :checkbox
    config.action_links.add 'externalNodes', :label => 'YAML', :inline => true,
      :type => :record
    config.action_links.add 'setBuild', :label => 'Build', :inline => false,
      :type => :record, :confirm => "This actions recreates all needed settings for host installation, if the host is
         already running, it will disable certain functions.\n
         Are you sure you want to reinstall this host?"
  end

  #returns a yaml file ready to use for puppet external nodes script
  #expected a fqdn parameter to provide hostname to lookup
  #see example script in extras directory
  #will return HTML error codes upon failure

  def externalNodes
    # check our parameters and look for a host
    unless (params.has_key? "fqdn" and (host = Host.find(:first,:conditions => ["name = ?",params.delete("fqdn")]))) or (params.has_key? "id" and (host = Host.find(params[:id])))
      render :text => '404 Not Found', :status => 404 and return
    else
      begin
        #TODO: benchmark if its slower using a controller method instead of calling the model
        yaml = host.info.to_yaml
        # if we were via the YAML host link, we reformat the output to look nicer.
        yaml.gsub!("\n","<br>") if params.has_key? "id"
        render :text => yaml
      rescue
        # failed
        logger.warn "Failed to generate external nodes for #{host.name} with #{$!}"
        render :text => 'Unable to generate output, Check log files', :status => 412 and return
      end
    end
  end

  def setBuild
    host = Host.find params[:id]
    if host.setBuild != false
      flash[:foreman_notice] = "Enabled #{host.name} for installation boot away"
    else
      flash[:foreman_error] = "Failed to enable #{host.name} for installation"
    end
    redirect_to :back
  end
end
