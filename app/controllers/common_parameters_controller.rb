class CommonParametersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Parameter

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @common_parameters = resource_base_search_and_page
  end

  def new
    @common_parameter = CommonParameter.new
  end

  def create
    @common_parameter = CommonParameter.new(parameter_params(::CommonParameter))
    if @common_parameter.save
      respond_to do |format|
        format.html { process_success }
        format.json { render json: @common_parameter }
      end
    else
      respond_to do |format|
        format.html { process_error }
        format.json do
          render json: { errors: @common_parameter.errors }, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
  end

  def update
    if @common_parameter.update(parameter_params(::CommonParameter))
      respond_to do |format|
        format.html { process_success }
        format.json { render json: @common_parameter }
      end
    else
      respond_to do |format|
        format.html { process_error }
        format.json do
          render json: { errors: @common_parameter.errors }, status: :unprocessable_entity
        end
      end
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
    'params'
  end

  def resource_base
    model_of_controller.authorized(current_permission, Parameter).where(:type => 'CommonParameter')
  end
end
