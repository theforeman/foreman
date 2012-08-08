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
        @counter = Host.count(:group => :puppetclass_id, :joins => :puppetclasses, :conditions => {:puppetclasses => {:id => @puppetclasses}})
      end
      format.json { render :json => Puppetclass.classes2hash(values.all(:select => "name, id")) }
    end
  end

  def new
    @puppetclass = Puppetclass.new
  end

  def create
    @puppetclass = Puppetclass.new(params[:puppetclass])
    Taxonomy.when_single_taxonomy do
      @puppetclass.taxonomy_ids = [Taxonomy.current.id]
    end
    if @puppetclass.save
      notice "Successfully created puppetclass."
      redirect_to puppetclasses_url
    else
      render :action => 'new'
    end
  end

  def edit
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
