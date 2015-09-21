class HostgroupsController < ApplicationController
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_resource,  :only => [:nest, :clone, :edit, :update, :destroy]
  before_filter :ajax_request,   :only => [:process_hostgroup, :current_parameters, :puppetclass_parameters]
  before_filter :taxonomy_scope, :only => [:new, :edit, :process_hostgroup]
  before_filter :update_parent_params!, :only => [:update, :create]

  def index
    @hostgroups = resource_base.search_for(params[:search], :order => params[:order]).paginate :page => params[:page]
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
    @hostgroup = Hostgroup.new(params[:hostgroup])
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
    if @hostgroup.update_attributes(params[:hostgroup])
      process_success :success_redirect => hostgroups_path
    else
      taxonomy_scope
      load_vars_for_ajax
      process_error
    end
  end

  def destroy
    begin
      if @hostgroup.destroy
        process_success :success_redirect => hostgroups_path
      else
        load_vars_for_ajax
        process_error
      end
    rescue Ancestry::AncestryException
      process_error(:error_msg => _("Cannot delete group %{current} because it has nested groups.") % { :current => @hostgroup.title } )
    end
  end

  def current_parameters
    Taxonomy.as_taxonomy @organization, @location do
      inherited_parameters = Hostgroup.find(params['hostgroup_parent_id']).inherited_params(true) if params['hostgroup_parent_id']
      render :partial => "common_parameters/inherited_parameters",
             :locals => { :inherited_parameters => inherited_parameters }
    end
  end

  def puppetclass_parameters
    @obj = params[:hostgroup][:id].empty? ? Hostgroup.new(params[:hostgroup]) : Hostgroup.find(params[:hostgroup_id])
    Taxonomy.as_taxonomy @organization, @location do
      render :partial => "puppetclasses/classes_parameters",
             :locals => { :obj => @obj }
    end
  end

  def environment_selected
    return not_found unless (@environment = Environment.find(params[:environment_id])) if params[:environment_id].to_i > 0

    @hostgroup ||= Hostgroup.new
    @hostgroup.environment = @environment if @environment
    @hostgroup.puppetclasses = Puppetclass.where(:id => params[:hostgroup][:puppetclass_ids])
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

  def parse_parent_params(parameters)
    parameter_keys   = parameters.select { |p| p.match(/key/) }.values
    parameter_values = parameters.select { |p| p.match(/value/) }.values
    parameters = {}
    parameters_hash = parameter_keys.zip(parameter_values).reject{|k, v| v.blank?}

    parameters_hash.each_with_index do |val, i|
      key, value = val[0], val[1]
      id = GroupParameter.last.id + 1 + i
      parameters[id] = { 'name' => key, 'value' => value } if value.present?
    end
    parameters
  end

  def update_parent_params!
    parent_params = parse_parent_params(params.select { |k| k.match(/parent.*/) } )
    if params[:hostgroup] && (params[:hostgroup][:group_parameters_attributes].present? || parent_params.present?)
      params[:hostgroup][:group_parameters_attributes] ||= {}
      params[:hostgroup][:group_parameters_attributes].merge!(parent_params)
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
      @hostgroup.attributes = params[:hostgroup]
    else
      @hostgroup = Hostgroup.new(params[:hostgroup])
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
