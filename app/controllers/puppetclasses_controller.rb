class PuppetclassesController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch

  def index
    values = Puppetclass.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html do
        @puppetclasses = values.paginate :page => params[:page], :include => [:environments, :hostgroups, :operatingsystems]
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
    if @puppetclass.save
      notice "Successfully created puppetclass."
      redirect_to puppetclasses_url
    else
      render :action => 'new'
    end
  end

  def edit
    @puppetclass = Puppetclass.find(params[:id])
  end

  def update
    @puppetclass = Puppetclass.find(params[:id])
    if @puppetclass.update_attributes(params[:puppetclass])
      notice "Successfully updated puppetclass."
      redirect_to puppetclasses_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @puppetclass = Puppetclass.find(params[:id])
    if @puppetclass.destroy
      notice "Successfully destroyed puppetclass."
    else
      error @puppetclass.errors.full_messages.join("<br/>")
    end
    redirect_to puppetclasses_url
  end

  # AJAX methods

  # adds a puppetclass to an existing host or hostgroup
  #
  # We assign the new puppetclasses (e.g. in the context of a Host or a Host Group)
  # via ajax and not java script as rendering javascript for each and every class
  # seems to be much longer than the average roundtrip time to the server
  # TODO: convert this to pure javascript then AJAX will not be required.
  def assign
    return unless request.xhr?

    klass = Puppetclass.find(params[:id])
    type = params[:type]
    render :update do |page|
      page.insert_html :after, :selected_classes, :partial => 'selectedClasses', :locals => {:klass => klass, :type => type}
      page["puppetclass_#{klass.id}"].hide
    end
  end

end
