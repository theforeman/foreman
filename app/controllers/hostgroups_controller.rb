class HostgroupsController < ApplicationController
  include Foreman::Controller::HostDetails
  include Foreman::Controller::AutoCompleteSearch

  filter_parameter_logging :root_pass
  before_filter :find_hostgroup, :only => [:show, :edit, :update, :destroy, :clone]

  def index
    begin
      values = Hostgroup.search_for(params[:search],:order => params[:order])
    rescue => e
      error e.to_s
      values = Hostgroup.search_for ""
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
    flash[:error_customisation] = {:header_message => "Clone Hostgroup", :class => "flash notice", :id => nil,
      :message => "The following fields will need reviewing:" }
    new.valid?
    new.name = ""
    @hostgroup = new
    render :action => :new
  end

  def show
    respond_to do |format|
      format.json { render :json => @hostgroup }
    end
  end

  def create
    @hostgroup = Hostgroup.new(params[:hostgroup])
    if @hostgroup.save
      process_success
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
