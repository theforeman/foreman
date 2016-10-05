class ParametersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  private

  def controller_permission
    'params'
  end

  def resource_base
    model_of_controller.authorized(current_permission, Parameter)
  end
end
