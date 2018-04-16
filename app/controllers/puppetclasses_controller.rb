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
    if params[:host]
      @obj ||= Host::Base.find_by_id(params[:host][:id])
      @obj = Host::Managed.new
      unless @obj.is_a?(Host::Managed)
        @obj      = @obj.becomes(Host::Managed)
        @obj.type = "Host::Managed"
      end
      # puppetclass_ids and config_group_ids need to be removed so they don't cause automatic insertsgroup
      @obj.attributes = host_params('host').except(:puppetclass_ids, :config_group_ids)
    elsif params[:hostgroup]
      @obj = Hostgroup.find_by_id(params[:hostgroup][:id])
      @obj ||= Hostgroup.new
      @obj.attributes = hostgroup_params('hostgroup').except(:puppetclass_ids, :config_group_ids)
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

  def resource_scope
    super.includes(:lookup_keys => [:lookup_values])
  end
end
