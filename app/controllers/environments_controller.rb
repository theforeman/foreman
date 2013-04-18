class EnvironmentsController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    values = Environment.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html do
        @environments = values.paginate :page => params[:page]
        @counter      = Host.count(:group => :environment_id, :conditions => {:environment_id => @environments.all})
      end
      format.json { render :json => values.as_json }
    end
  end

  def show
    respond_to do |format|
      format.html { invalid_request }
      format.json { render :json => @environment.as_json(:include => :hosts)}
    end
  end

  def new
    @environment = Environment.new
  end

  def create
    @environment = Environment.new(params[:environment])
    if @environment.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @environment.update_attributes(params[:environment])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @environment.destroy
      process_success
    else
      process_error
    end
  end

end
