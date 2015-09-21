class ModelsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @models       = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(foreman_params)
    if @model.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @model.update_attributes(foreman_params)
      process_success
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
