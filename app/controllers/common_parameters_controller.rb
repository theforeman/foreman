class CommonParametersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @common_parameters = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @common_parameter = CommonParameter.new
  end

  def create
    @common_parameter = CommonParameter.new(foreman_params)
    if @common_parameter.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @common_parameter.update_attributes(foreman_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @common_parameter.destroy
      process_success
    else
      process_error
    end
  end

  private

  def controller_permission
    'globals'
  end

  def resource_base
    model_of_controller.authorized(current_permission, CommonParameter)
  end
end
