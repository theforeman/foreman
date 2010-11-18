class EnvironmentsController < ApplicationController
  include Foreman::Controller::Environments

  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    respond_to do |format|
      format.html do
        @search       = Environment.search(params[:search])
        @environments = @search.paginate :page => params[:page]
      end
      format.json { render :json => Environment.all.as_json }
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
      notice "Successfully created environment."
      redirect_to environments_path
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @environment.update_attributes(params[:environment])
      notice "Successfully updated environment."
      redirect_to environments_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @environment.destroy
      notice "Successfully destroyed #{@environment.name}"
    else
      error @environment.errors.full_messages.join("<br/>")
    end
    redirect_to environments_url
  end

end
