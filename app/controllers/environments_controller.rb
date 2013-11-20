class EnvironmentsController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_by_name, :only => %w{edit update destroy}

  def index
    @environments = Environment.authorized(:view_environments).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    @host_counter = Host.group(:environment_id).where(:environment_id => @environments.select(&:id)).count
    @authorizer   = Authorizer.new(User.current, @environments)
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
