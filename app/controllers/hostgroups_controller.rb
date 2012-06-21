require 'foreman/controller/host_details'

class HostgroupsController < ApplicationController
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_hostgroup, :only => [:show, :edit, :update, :destroy, :clone]

  def index
    begin
      my_groups = User.current.admin? ? Hostgroup : Hostgroup.my_groups
      values = my_groups.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = my_groups.search_for ""
    end

    respond_to do |format|
      format.html do
        @hostgroups = values.paginate :page => params[:page]
      end
      format.json { render :json => values }
    end
  end

  def new
    @hostgroup = Hostgroup.new
  end

  def nest
    @hostgroup = Hostgroup.new(:parent_id => params[:id])
    render :action => :new
  end

  # Clone the hostgroup
  def clone
    new = @hostgroup.clone
    load_vars_for_ajax
    new.puppetclasses = @hostgroup.puppetclasses
    # Clone any parameters as well
    @hostgroup.group_parameters.each{|param| new.group_parameters << param.clone}
    if @hypervisor
      new.vm_defaults = @hostgroup.vm_defaults
      new.send(:deserialize_vm_attributes)
    end
    new.name = ""
    new.valid?
    @hostgroup = new
    notice "The following fields would need reviewing"
    render :action => :new
  end

  def show
    auth  = User.current.admin? ? true : Hostgroup.my_groups.include?(@hostgroup)
    not_found and return unless auth
    respond_to do |format|
      format.json { render :json => @hostgroup }
    end
  end

  def create
    @hostgroup = Hostgroup.new(params[:hostgroup])
    unless User.current.admin?
      if SETTINGS[:single_org]
        @hostgroup.organization_ids = [Organization.current.id]
      end
    end
    if @hostgroup.save
      # Add the new hostgroup to the user's filters
      @hostgroup.users << User.current unless User.current.admin? or @hostgroup.users.include?(User.current)
      process_success
    else
      load_vars_for_ajax
      process_error
    end
  end

  def edit
    auth  = User.current.admin? ? true : Hostgroup.my_groups.include?(@hostgroup)
    not_found and return unless auth
    load_vars_for_ajax
  end

  def update
    if @hostgroup.update_attributes(params[:hostgroup])
      process_success
    else
      load_vars_for_ajax
      process_error
    end
  end

  def destroy
    if @hostgroup.destroy
      process_success
    else
      load_vars_for_ajax
      process_error
    end
  end

  def environment_selected
    return not_found unless (@environment = Environment.find(params[:environment_id])) if params[:environment_id].to_i > 0

    @hostgroup ||= Hostgroup.new
    @hostgroup.environment = @environment if @environment
    render :partial => 'puppetclasses/class_selection', :locals => {:obj => (@hostgroup)}
  end

  private

  def find_hostgroup
    @hostgroup = Hostgroup.find(params[:id])
  end

  def load_vars_for_ajax
    return unless @hostgroup
    @architecture    = @hostgroup.architecture
    @operatingsystem = @hostgroup.operatingsystem
    @domain          = @hostgroup.domain
    @hypervisor      = @hostgroup.hypervisor
  end

end
