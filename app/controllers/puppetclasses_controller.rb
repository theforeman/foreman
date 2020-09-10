class PuppetclassesController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Host
  include Foreman::Controller::Parameters::Hostgroup
  include Foreman::Controller::Parameters::Puppetclass

  before_action :find_resource, :only => [:edit, :update, :destroy, :override]
  before_action :setup_search_options, :only => :index

  def index
    @puppetclasses = resource_base_search_and_page
    @hostgroups_authorizer = Authorizer.new(User.current, :collection => HostgroupClass.where(:puppetclass_id => @puppetclasses.map(&:id)).distinct.pluck(:hostgroup_id))
  end

  def edit
  end

  def update
    if @puppetclass.update(puppetclass_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @puppetclass.destroy
      process_success
    else
      process_error
    end
  end

  def override
    if @puppetclass.class_params.present?
      @puppetclass.class_params.each do |class_param|
        class_param.update_attribute(:override, params[:enable])
      end
      if [true, :true, 'true'].include?(params[:enable])
        success _("Successfully overridden all parameters of Puppet class %s") % @puppetclass.name
      else
        success _("Successfully reset all parameters of Puppet class %s to their default values") % @puppetclass.name
      end
    else
      error _("No parameters to override for Puppet class %s") % @puppetclass.name
    end
    redirect_to puppetclasses_url
  end

  # form AJAX methods
  def parameters
    puppetclass = Puppetclass.find(params[:id])
    render :partial => "puppetclasses/class_parameters",
           :locals => { :puppetclass => puppetclass,
                        :obj         => get_host_or_hostgroup }
  end

  private

  def get_host_or_hostgroup
    # params['host_id'] = 'undefined' if NEW since hosts/form and hostgroups/form has no data-id
    host_id = params.delete(:host_id)
    if host_id == 'undefined'
      @obj = Host::Managed.new(host_params('host')) if params['host']
      @obj ||= Hostgroup.new(hostgroup_params('hostgroup')) if params['hostgroup']
    else
      if params['host']
        @obj = Host::Base.find(host_id)
        unless @obj.is_a?(Host::Managed)
          @obj      = @obj.becomes(Host::Managed)
          @obj.type = "Host::Managed"
        end
        # puppetclass_ids and config_group_ids need to be removed so they don't cause automatic insertsgroup
        @obj.attributes = host_params('host').except(:puppetclass_ids, :config_group_ids)
      elsif params['hostgroup']
        # hostgroup.id is assigned to params['host_id'] by host_edit.js#load_puppet_class_parameters
        @obj = Hostgroup.find(host_id)
        @obj.attributes = hostgroup_params('hostgroup').except(:puppetclass_ids, :config_group_ids)
      end
    end
    @obj
  end

  def action_permission
    case params[:action]
      when 'override'
        :edit
      else
        super
    end
  end
end
