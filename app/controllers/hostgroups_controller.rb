class HostgroupsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::HostDetails
  include Foreman::Controller::Parameters::Hostgroup
  include Foreman::Controller::CsvResponder
  include Foreman::Controller::SetRedirectionPath

  before_action :find_resource,  :only => [:nest, :clone, :edit, :update, :destroy]
  before_action :ajax_request,   :only => [:process_hostgroup]
  before_action :taxonomy_scope, :only => [:new, :edit, :process_hostgroup]

  def index
    respond_to do |format|
      format.html do
        @hostgroups = resource_base_search_and_page
        render :index
      end
      format.csv do
        csv_response(resource_base_with_search)
      end
    end
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
    @hostgroup.group_parameters.each { |param| @parent.group_parameters << param.dup }
    render :action => :new
  end

  # Clone the hostgroup
  def clone
    new = @hostgroup.clone
    load_vars_for_ajax
    new.valid?
    @hostgroup = new
    info _("The following fields would need reviewing")
    render :action => :new
  end

  def create
    @hostgroup = Hostgroup.new(hostgroup_params)
    if @hostgroup.save
      process_success :success_redirect => session.fetch(:redirect_path, hostgroups_path)
    else
      load_vars_for_ajax
      process_error :object => @hostgroup
    end
  end

  def edit
    load_vars_for_ajax
  end

  def update
    if @hostgroup.update(hostgroup_params)
      process_success :success_redirect => session.fetch(:redirect_path, hostgroups_path)
    else
      taxonomy_scope
      load_vars_for_ajax
      process_error :object => @hostgroup
    end
  end

  def destroy
    if @hostgroup.destroy
      process_success :success_redirect => session.fetch(:redirect_path, hostgroups_path)
    else
      load_vars_for_ajax
      process_error
    end
  rescue Ancestry::AncestryException
    process_error(:error_msg => _("Cannot delete group %{current} because it has nested groups.") % { :current => @hostgroup.title })
  end

  def process_hostgroup
    define_parent
    refresh_hostgroup
    inherit_parent_attributes
    load_vars_for_ajax
    reset_explicit_attributes

    render :partial => "form"
  end

  def csv_columns
    [:title, :hosts_count, :children_hosts_count]
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

  def refresh_hostgroup
    if params[:hostgroup][:id].present?
      @hostgroup = Hostgroup.authorized(:view_hostgroups).find(params[:hostgroup][:id])
      @hostgroup.attributes = hostgroup_params
    else
      @hostgroup = Hostgroup.new(hostgroup_params)
    end

    @hostgroup.lookup_values.each(&:validate_value)
    @hostgroup
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

  def reset_explicit_attributes
    @hostgroup.pxe_loader = nil if @parent.present?
  end
end
