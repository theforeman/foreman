class PuppetclassesController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => [:edit, :update, :destroy, :assign]
  before_filter :setup_search_options, :only => :index
  before_filter :reset_redirect_to_url, :only => :index
  before_filter :store_redirect_to_url, :only => :edit

  def index
    begin
      values = Puppetclass.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = Puppetclass.search_for ""
    end

    respond_to do |format|
      format.html do
        @puppetclasses = values.paginate(:page => params[:page])
        @host_counter = Host.count(:group => :puppetclass_id, :joins => :puppetclasses, :conditions => {:puppetclasses => {:id => @puppetclasses.all}})
        @keys_counter = Puppetclass.joins(:class_params).select('distinct environment_classes.lookup_key_id').count(:group => 'name')
      end
      format.json { render :json => Puppetclass.classes2hash(values.all(:select => "name, id")) }
    end
  end

  def new
    @puppetclass = Puppetclass.new
  end

  def create
    @puppetclass = Puppetclass.new(params[:puppetclass])
    if @puppetclass.save
      notice _("Successfully created puppetclass.")
      redirect_to puppetclasses_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @puppetclass.update_attributes(params[:puppetclass])
      notice _("Successfully updated puppetclass.")
      redirect_back_or_default(puppetclasses_url)
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @puppetclass.destroy
      notice _("Successfully destroyed puppetclass.")
    else
      error @puppetclass.errors.full_messages.join("<br/>")
    end
    redirect_to puppetclasses_url
  end

  # form AJAX methods
  def parameters
    puppetclass = Puppetclass.find(params[:id])
    obj = params['host'] ? refresh_host : refresh_hostgroup
    render :partial => "puppetclasses/class_parameters", :locals => {
        :puppetclass => puppetclass,
        :obj => obj}
  end

  private

  def refresh_host
    @host = Host::Base.find_by_id(params['host_id'])
    if @host
      unless @host.kind_of?(Host::Managed)
        @host      = @host.becomes(Host::Managed)
        @host.type = "Host::Managed"
      end
      @host.attributes = params['host']
    else
      @host = Host::Managed.new(params['host'])
    end
    @host
  end

  def refresh_hostgroup
    @hostgroup = Hostgroup.find_by_id(params['host_id'])
    if @hostgroup
      @hostgroup.attributes = params['hostgroup']
    else
      @hostgroup = Hostgroup.new(params['hostgroup'])
    end
    @hostgroup
  end

  def reset_redirect_to_url
    session[:redirect_to_url] = nil
  end

  def store_redirect_to_url
    session[:redirect_to_url] ||= request.referer
  end

  def redirect_back_or_default(default)
    redirect_to(session[:redirect_to_url] || default)
    session[:redirect_to_url] = nil
  end


end
