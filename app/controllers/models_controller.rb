class ModelsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Model

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def edit
  end

  def update
    if @model.update(model_params)
      process_success :success_redirect => '/models'
    else
      process_error
    end
  end

  def destroy
    if @model.destroy
      process_success
    else
      process_error
    end
  end
end
