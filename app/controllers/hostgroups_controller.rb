class HostgroupsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::HostDetails
  include Foreman::Controller::Parameters::Hostgroup

  before_action :find_resource,  :only => [:nest, :clone, :edit, :update, :destroy]
  before_action :ajax_request,   :only => [:process_hostgroup, :puppetclass_parameters]
  before_action :taxonomy_scope, :only => [:new, :edit, :process_hostgroup]

  def index
    @hostgroups = resource_base_search_and_page
  end

  def new
    @hostgroup = Hostgroup.new
  end

  def nest
    @parent = @hostgroup
    @hostgroup = Hostgroup.new(:parent_id => @parent.id)

    load_vars_for_ajax
    @hostgroup.puppetclasses = @parent.puppetclasses
    @hostgroup.locations = @parent.locations
    @hostgroup.organizations = @parent.organizations
    # Clone any parameters as well
    @hostgroup.group_parameters.each{|param| @parent.group_parameters << param.dup}
    render :action => :new
  end

  # Clone the hostgroup
  def clone
    new = @hostgroup.clone
    load_vars_for_ajax
    new.valid?
    @hostgroup = new
    notice _("The following fields would need reviewing")
    render :action => :new
  end

  def create
    @hostgroup = Hostgroup.new(hostgroup_params)
    if @hostgroup.save
      process_success :success_redirect => hostgroups_path
    else
      load_vars_for_ajax
      process_error
    end
  end

  def edit
    load_vars_for_ajax
  end

  def update
    if @hostgroup.update_attributes(hostgroup_params)
      process_success :success_redirect => hostgroups_path
    else
      taxonomy_scope
      load_vars_for_ajax
      process_error
    end
  end

  def destroy
    if @hostgroup.destroy
      process_success :success_redirect => hostgroups_path
    else
      load_vars_for_ajax
      process_error
    end
  rescue Ancestry::AncestryException
    process_error(:error_msg => _("Cannot delete group %{current} because it has nested groups.") % { :current => @hostgroup.title })
  end

  def puppetclass_parameters
    @obj = params[:hostgroup][:id].empty? ? Hostgroup.new(hostgroup_params) : Hostgroup.find(params[:hostgroup_id])
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "puppetclasses/classes_parameters",
             :locals => { :obj => @obj }
    end
  end

  def environment_selected
    env_id = params[:environment_id] || params[:hostgroup][:environment_id]
    return not_found unless (@environment = Environment.find(env_id)) if env_id.to_i > 0

    @hostgroup ||= Hostgroup.new
    @hostgroup.environment = @environment if @environment

    @hostgroup.puppetclasses = Puppetclass.where(:id => params[:hostgroup][:puppetclass_ids])
    @hostgroup.config_groups = ConfigGroup.where(:id => params[:hostgroup][:config_group_ids])
    render :partial => 'puppetclasses/class_selection', :locals => {:obj => (@hostgroup), :type => 'hostgroup'}
  end

  def process_hostgroup
    define_parent
    define_hostgroup
    inherit_parent_attributes
    load_vars_for_ajax

    render :partial => "form"
  end

  private

  def load_vars_for_ajax
    return unless @hostgroup.present?

    @architecture    = @hostgroup.architecture
    @operatingsystem = @hostgroup.operatingsystem
    @domain          = @hostgroup.domain
    @subnet          = @hostgroup.subnet
    @environment     = @hostgroup.environment
    @realm           = @hostgroup.realm
  end

  def users_in_ancestors
    @hostgroup.ancestors.map do |ancestor|
      ancestor.users.reject { |u| @hostgroup.users.include?(u) }
    end.flatten.uniq
  end

  def action_permission
    case params[:action]
      when 'nest', 'clone'
        'view'
      else
        super
    end
  end

  def define_parent
    if params[:hostgroup][:parent_id].present?
      @parent = Hostgroup.authorized(:view_hostgroups).find(params[:hostgroup][:parent_id])
    end
  end

  def define_hostgroup
    if params[:hostgroup][:id].present?
      @hostgroup = Hostgroup.authorized(:view_hostgroups).find(params[:hostgroup][:id])
      @hostgroup.attributes = hostgroup_params
    else
      @hostgroup = Hostgroup.new(hostgroup_params)
    end
  end

  def inherit_parent_attributes
    return unless @parent.present?

    @hostgroup.architecture       ||= @parent.architecture
    @hostgroup.operatingsystem    ||= @parent.operatingsystem
    @hostgroup.domain             ||= @parent.domain
    @hostgroup.subnet             ||= @parent.subnet
    @hostgroup.realm              ||= @parent.realm
    @hostgroup.environment        ||= @parent.environment
  end
end
