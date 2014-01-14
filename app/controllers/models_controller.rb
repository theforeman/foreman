class ModelsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => [:edit, :update, :destroy]

  def index
    @models       = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
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
  end

  def update
    if @model.update_attributes(params[:model])
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
