class EnvironmentsController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @environments = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @environment = PuppetEnvironment.new
  end

  def create
    @environment = PuppetEnvironment.new(params[:puppet_environment])
    if @environment.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @environment.update_attributes(params[:puppet_environment])
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
