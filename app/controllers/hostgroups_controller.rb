class SystemGroupsController < ApplicationController
  include Foreman::Controller::SystemDetails
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_system_group, :only => [:edit, :update, :destroy, :clone]

  def index
    begin
      my_groups = User.current.admin? ? SystemGroup : SystemGroup.my_groups
      values = my_groups.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = my_groups.search_for ""
    end
    @system_groups = values.paginate :page => params[:page]
  end

  def new
    @system_group = SystemGroup.new
  end

  def nest
    @parent = SystemGroup.find(params[:id])
    @system_group = @parent.dup
    #overwrite parent_id and name
    @system_group.parent_id = params[:id]
    @system_group.name = ""

    load_vars_for_ajax
    @system_group.puppetclasses = @parent.puppetclasses
    @system_group.locations = @parent.locations
    @system_group.organizations = @parent.organizations
    # Clone any parameters as well
    @system_group.group_parameters.each{|param| @parent.group_parameters << param.dup}
    render :action => :new
  end

  # Clone the system_group
  def clone
    new = @system_group.dup
    load_vars_for_ajax
    new.puppetclasses = @system_group.puppetclasses
    new.locations = @system_group.locations
    new.organizations = @system_group.organizations
    # Clone any parameters as well
    @system_group.group_parameters.each{|param| new.group_parameters << param.dup}
    new.name = ""
    new.valid?
    @system_group = new
    notice _("The following fields would need reviewing")
    render :action => :new
  end

  def create
    @system_group = SystemGroup.new(params[:system_group])
    if @system_group.save
      # Add the new system_group to the user's filters
      @system_group.users << User.current unless User.current.admin? or @system_group.users.include?(User.current)
      @system_group.users << subscribed_users
      @system_group.users << users_in_ancestors
      process_success
    else
      load_vars_for_ajax
      process_error
    end
  end

  def edit
    auth  = User.current.admin? ? true : SystemGroup.my_groups.include?(@system_group)
    not_found and return unless auth
    load_vars_for_ajax
  end

  def update
    # remove from hash :root_pass if blank?
    params[:system_group].except!(:root_pass) if params[:system_group][:root_pass].blank?
    if @system_group.update_attributes(params[:system_group])
      process_success
    else
      load_vars_for_ajax
      process_error
    end
  end

  def destroy
    if @system_group.destroy
      process_success
    else
      load_vars_for_ajax
      process_error
    end
  end

  def environment_selected
    return not_found unless (@environment = Environment.find(params[:environment_id])) if params[:environment_id].to_i > 0

    @system_group ||= SystemGroup.new
    @system_group.environment = @environment if @environment
    render :partial => 'puppetclasses/class_selection', :locals => {:obj => (@system_group)}
  end

  def process_system_group

    @parent = SystemGroup.find(params[:system_group][:parent_id]) if params[:system_group][:parent_id].to_i > 0
    return head(:not_found) unless @parent

    @system_group = SystemGroup.new(params[:system_group])
    @system_group.architecture       ||= @parent.architecture
    @system_group.operatingsystem    ||= @parent.operatingsystem
    @system_group.domain             ||= @parent.domain
    @system_group.subnet             ||= @parent.subnet
    @system_group.environment        ||= @parent.environment

    load_vars_for_ajax
    render :partial => "form"
  end

  def taxonomy_scope
    @organization = Organization.current if SETTINGS[:organizations_enabled]
    @location     = Location.current     if SETTINGS[:locations_enabled]
  end

  private

  def find_system_group
    @system_group = SystemGroup.find(params[:id])
  end

  def load_vars_for_ajax
    return unless @system_group
    @architecture    = @system_group.architecture
    @operatingsystem = @system_group.operatingsystem
    @domain          = @system_group.domain
    @subnet          = @system_group.subnet
    @environment     = @system_group.environment
  end

  def users_in_ancestors
    @system_group.ancestors.map do |ancestor|
      ancestor.users.reject { |u| @system_group.users.include?(u) }
    end.flatten.uniq
  end

  def subscribed_users
    User.where(:subscribe_to_all_system_groups => true)
  end

end
