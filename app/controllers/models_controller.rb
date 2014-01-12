class ModelsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    @models       = Model.authorized(:view_models).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    @host_counter = Host.group(:model_id).where(:model_id => @models.select(&:id)).count
  end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(params[:model])
    if @model.save
      process_success
    else
      process_error
    end
  end

  def edit
    @model = find_by_id(:edit_models)
  end

  def update
    @model = find_by_id(:edit_models)
    if @model.update_attributes(params[:model])
      process_success
    else
      process_error
    end
  end

  def destroy
    @model = find_by_id(:destroy_models)
    if @model.destroy
      process_success
    else
      process_error
    end
  end

  private

  def find_by_id(permission = :view_models)
    Model.authorized(permission).find(params[:id])
  end
end
