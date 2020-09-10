class EnvironmentsController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Environment

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @environments = resource_base_search_and_page
  end

  def new
    @environment = Environment.new
  end

  def create
    @environment = Environment.new(environment_params)
    if @environment.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @environment.update(environment_params)
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
