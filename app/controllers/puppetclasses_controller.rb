require 'foreman/controller/environments'

class PuppetclassesController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => [:edit, :update, :destroy, :assign]
  before_filter :setup_search_options, :only => :index

  def index
    begin
      values = Puppetclass.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = Puppetclass.search_for ""
    end

    respond_to do |format|
      format.html do
        @puppetclasses = values.paginate :page => params[:page], :include => [:environments, :hostgroups]
        @host_counter = Host.count(:group => :puppetclass_id, :joins => :puppetclasses, :conditions => {:puppetclasses => {:id => @puppetclasses}})
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
    @puppetclass.locations_ids = [Location.current.id] if Taxonomy.locations_enabled
    @puppetclass.organization_ids = [Organization.current.id] if Taxonomy.organizations_enabled
    if @puppetclass.save
      notice "Successfully created puppetclass."
      redirect_to puppetclasses_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  # form AJAX methods
  def parameters
    puppetclass = Puppetclass.find(params[:id])
    host = Host.new(params[:host])
    render :partial => "puppetclasses/class_parameters", :locals => {:klass => puppetclass, :host => host}
  end

  def update
    if @puppetclass.update_attributes(params[:puppetclass])
      notice "Successfully updated puppetclass."
      redirect_to puppetclasses_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @puppetclass.destroy
      notice "Successfully destroyed puppetclass."
    else
      error @puppetclass.errors.full_messages.join("<br/>")
    end
    redirect_to puppetclasses_url
  end

end
